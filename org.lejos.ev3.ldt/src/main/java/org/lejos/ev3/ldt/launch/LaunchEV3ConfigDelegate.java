package org.lejos.ev3.ldt.launch;

import java.io.File;
import java.io.FileInputStream;
import java.lang.reflect.InvocationTargetException;
import java.rmi.Naming;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import lejos.remote.ev3.RMIMenu;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.debug.core.ILaunch;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchManager;
import org.eclipse.jdi.Bootstrap;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.debug.core.JDIDebugModel;
import org.eclipse.jdt.launching.AbstractJavaLaunchConfigurationDelegate;
import org.lejos.ev3.ldt.LeJOSEV3Plugin;
import org.lejos.ev3.ldt.preferences.PreferenceConstants;
import org.lejos.ev3.ldt.util.BrickInfo;
import org.lejos.ev3.ldt.util.Discover;
import org.lejos.ev3.ldt.util.JarCreator;
import org.lejos.ev3.ldt.util.LeJOSEV3Util;
import org.lejos.ev3.ldt.util.PrefsResolver;
import org.lejos.ev3.ldt.util.ToolStarter;

import com.sun.jdi.VirtualMachine;
import com.sun.jdi.VirtualMachineManager;
import com.sun.jdi.connect.AttachingConnector;
import com.sun.jdi.connect.Connector;
import com.sun.jdi.connect.Connector.Argument;
import com.sun.jdi.connect.Connector.IntegerArgument;
import com.sun.jdi.connect.Connector.StringArgument;

public class LaunchEV3ConfigDelegate extends AbstractJavaLaunchConfigurationDelegate {
	public static final String ID_TYPE = "org.lejos.ev3.ldt.LaunchType";
	private boolean debug = false;
	
	//TODO we should make sure, that uploads to the same EV3 are executed sequentially, not in parallel
	
	private boolean resolve(PrefsResolver p, ILaunchConfiguration config,
			String defSwitch, String suffix, boolean def) throws CoreException {
		if (config.getAttribute(defSwitch, true))
			return p.getBoolean(suffix, def);
		else
			return config.getAttribute(LaunchConstants.PREFIX+suffix, def);
	}
	
	private String resolve(PrefsResolver p, ILaunchConfiguration config,
			String defSwitch, String suffix, String def) throws CoreException {
		if (config.getAttribute(defSwitch, true))
			return p.getString(suffix, def);
		else
			return config.getAttribute(LaunchConstants.PREFIX+suffix, def);
	}

	public void launch(ILaunchConfiguration config, String mode,	ILaunch launch, IProgressMonitor monitor)
		throws CoreException
	{
		if (monitor == null)
			monitor = new NullProgressMonitor();
		
		monitor.beginTask("Launching "+config.getName()+"...", 3); //$NON-NLS-1$
		
		PrefsResolver p = new PrefsResolver(LeJOSEV3Plugin.ID, null);
		
		boolean run = resolve(p, config, "", mode+LaunchConstants.SUFFIX_RUN_AFTER_UPLOAD, true);
		
		boolean useSsh = p.getBoolean(org.lejos.ev3.ldt.preferences.PreferenceConstants.KEY_SSH_SCP, false);
		
		boolean namedBrick = p.getBoolean(org.lejos.ev3.ldt.preferences.PreferenceConstants.KEY_TARGET_CONNECT_BY_NAME, false);
		
		boolean debugMode = (ILaunchManager.DEBUG_MODE.equals(mode));
		
		if (monitor.isCanceled())
			return;
		
		try
		{
			monitor.subTask("Verifying launch configuration ..."); 
			
			String mainTypeName = this.verifyMainTypeName(config);	
			IJavaProject project = this.verifyJavaProject(config);
			
			monitor.worked(1);			
			if (monitor.isCanceled())
				return;
		
			String simpleName;
			int i = mainTypeName.lastIndexOf('.');
			if (i < 0)
				simpleName = mainTypeName;
			else
				simpleName = mainTypeName.substring(i+1);
			
			IProject project2 = project.getProject();
			IFile binary = project2.getFile(simpleName+".jar");
			String binaryPath = binary.getLocation().toOSString();
			i = binary.getLocation().toPortableString().lastIndexOf("/");
			String binDirectory = binary.getLocation().toPortableString().substring(0,i+1) + "bin";
			
			monitor.worked(1);			
			monitor.subTask("Creating jar file and uploading " + binaryPath + " to the brick...");
			
			if (debug) LeJOSEV3Util.message("Binary path is " + binaryPath);
			if (debug) LeJOSEV3Util.message("Main type name is " + mainTypeName);
			if (debug) LeJOSEV3Util.message("Project relative path is " + binary.getProjectRelativePath().toPortableString());
			if (debug) LeJOSEV3Util.message("Bin directory is " + binDirectory);
			
			JarCreator jc = new JarCreator(binDirectory, binaryPath, mainTypeName);
			jc.run();
			
			LeJOSEV3Util.message("Jar file has been created successfully");
				
			monitor.subTask("Uploading ...");
			
			String brickName = resolve(p, config, LaunchConstants.KEY_TARGET_USE_DEFAULTS,
					PreferenceConstants.KEY_TARGET_BRICK_NAME, "");
			
			if (useSsh) {
				LeJOSEV3Util.message("Using scp for upload and ssh to execute program");
				
				// start EV3ScpUpload
				ToolStarter starter = LeJOSEV3Util.getCachedExternalStarter();
				
				ArrayList<String> args = new ArrayList<String>();
				
				if (run) args.add("-r");
				
				if (debugMode) args.add("-d");
				
				args.add("-n");	
				
				// TODO: case where brick name not specified
				args.add(brickName); 
				
				args.add(binaryPath);
				
				args.add("/home/lejos/programs/" + binary.getProjectRelativePath().toPortableString());
				
				if (debugMode) {
					new Thread(new DebugStarter(launch, brickName, simpleName)).start();
				}
				
				LeJOSEV3Util.message("Uploading to " + brickName + " ...");
				int r = starter.invokeTool(LeJOSEV3Util.TOOL_EV3SCPUPLOAD, args);
					
				if (r == 0)
					LeJOSEV3Util.message("EV3ScpUpload has finished");
				else
					LeJOSEV3Util.error("Starting EV3ScpUpload failed with exit status "+r);
			} else {
				LeJOSEV3Util.message("Using the EV3 menu for upload and to execute program");
				
				if (!namedBrick) {			
					// TODO : case where a specific brick is specified
					BrickInfo[] bricks = Discover.discover();
					
					if (bricks.length ==  0) {
						LeJOSEV3Util.error("No EV3 Found");
						return;
					} else {	
						brickName = bricks[0].getIPAddress();
					}
				}
					
				RMIMenu menu = (RMIMenu)Naming.lookup("//" + brickName + "/RemoteMenu");
				File f = new File(binaryPath);
				FileInputStream in = new FileInputStream(f);
				byte[] data = new byte[(int)f.length()];
			    in.read(data);
			    in.close();
			    
				LeJOSEV3Util.message("Uploading to " + brickName + " ...");
				
			    menu.uploadFile("/home/lejos/programs/" + binary.getProjectRelativePath().toPortableString(), data);
			    
			    LeJOSEV3Util.message("Program has been uploaded");
			    
			    if (run) {
			    	if (debugMode) {
			    		LeJOSEV3Util.message("Starting program in debug mode ...");
			    		new Thread(new DebugStarter(launch, brickName, simpleName)).start();
			    		menu.debugProgram(binary.getProjectRelativePath().toPortableString().replace(".jar", ""));
			    	}
			    	else {
			    		LeJOSEV3Util.message("Running program ...");
			    		menu.runProgram(binary.getProjectRelativePath().toPortableString().replace(".jar", ""));
			    	}	
			    }
			}
			
			LeJOSEV3Util.message("leJOS EV3 plugin launch complete");
		}
		catch (Exception t)
		{
			Throwable t2 = t;
			if (t2 instanceof InvocationTargetException)
				t2 = ((InvocationTargetException)t).getTargetException();
			
			// log
			LeJOSEV3Util.error("Creating the jar file or uploading the program failed", t2);
		}
		finally
		{
			monitor.done();
		}
	}
	
	class DebugStarter implements Runnable {
		private String brickName, simpleName;
		private ILaunch launch;
		
		public DebugStarter(ILaunch launch, String brickName, String simpleName) {
			this.launch = launch;
			this.brickName = brickName;
			this.simpleName = simpleName;
		}

		public void run() {
    		try {
				Thread.sleep(5000);
			} catch (InterruptedException e) {
			}
    		
			LeJOSEV3Util.message("Starting debugger ...");
			
			// Find the socket attach connector
			VirtualMachineManager mgr=Bootstrap.virtualMachineManager();
			
			List<?> connectors = mgr.attachingConnectors();
			
			AttachingConnector chosen=null;
			for (Iterator<?> iterator = connectors.iterator(); iterator
					.hasNext();) {
				AttachingConnector conn = (AttachingConnector) iterator.next();
				if(conn.name().contains("SocketAttach")) {
					chosen=conn;
					break;
				}
			}
			
			if(chosen == null) {
				LeJOSEV3Util.error("No suitable connector");
			} else {
				Map<String, Argument> connectorArgs = chosen.defaultArguments();
				
				Connector.IntegerArgument portArg = (IntegerArgument) connectorArgs.get("port");
				Connector.StringArgument hostArg = (StringArgument) connectorArgs.get("hostname");
				portArg.setValue(8000);
				
				//LeJOSEV3Util.message("hostArg is " + hostArg);
				hostArg.setValue(brickName);
			
				VirtualMachine vm;
						
				int retries = 10;
				while (true) {
					try {
						vm = chosen.attach(connectorArgs);
						break;
					} catch (Exception e) {
						if (--retries == 0) {
							LeJOSEV3Util.message("Failed to attach to the debugger: " + e);
							return;
						}
			    		try {
							Thread.sleep(2000);
						} catch (InterruptedException e1) {
						}
					}
				}
				LeJOSEV3Util.message("Connection established");
				
				JDIDebugModel.newDebugTarget(launch, vm, simpleName, null, true, true, true);	
			}
		}
	}
}
