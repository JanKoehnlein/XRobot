package org.lejos.ev3.ldt.util;

import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Writer;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;

import org.lejos.ev3.ldt.LeJOSEV3Plugin;

public class ExternalJVMToolStarter implements ToolStarter {

	private File ev3Home;
	private boolean debug = false;

	public ExternalJVMToolStarter(File ev3Home)
	{
		this.ev3Home = ev3Home;
	}
	
	public Process createProcess(String tool, List<String> args)
			throws LeJOSEV3Exception {
		ArrayList<File> pccp = new ArrayList<File>();
		LeJOSEV3Util.buildPCClasspath(ev3Home, pccp);
		
		String javaHome = System.getProperty("java.home");
		if (javaHome == null)
			throw new LeJOSEV3Exception("java.home property is not set");
		File f = new File(javaHome);
		if (!f.isDirectory())
			throw new LeJOSEV3Exception("java.home property is not a directory");
		
		String osName = System.getProperty("os.name", "").toLowerCase();
		if (osName.startsWith("windows "))
			f = new File(f, "bin/java.exe");
		else
			f = new File(f, "bin/java");
		
		if (!f.isFile())
			throw new LeJOSEV3Exception(f.getAbsolutePath()+ " does not exist");
		
		ArrayList<String> args2 = new ArrayList<String>();
		args2.add(f.getAbsolutePath());

		args2.add("-Dev3.home="+ev3Home.getAbsolutePath());
		args2.add("-classpath");
		args2.add(LeJOSEV3Util.getClasspathString(pccp));
		args2.add(tool);
		args2.addAll(args);
		
		try {
			StringBuilder sb = new StringBuilder();
			for(String arg: args2) {
				sb.append(arg + " ");
			}
			if (debug) LeJOSEV3Util.message("Command line: " + sb.toString());
			
			return LeJOSEV3Util.createProcessBuilder(args2).start();
		} catch (IOException e) {
			throw new LeJOSEV3Exception("Failed to start external JVM", e);
		}
	}

	public int invokeTool(String tool, List<String> args) throws Exception, InvocationTargetException
	{
		LeJOSEV3Plugin p2 = LeJOSEV3Plugin.getDefault();
		Writer consw = p2.getConsoleWriter();
		
		Process t = createProcess(tool, args);
		
		t.getOutputStream().close();		
		new PipeThread(new InputStreamReader(t.getInputStream()), consw).start();
		new PipeThread(new InputStreamReader(t.getErrorStream()), consw).start();
		//TODO join with threads
		
		try {
			return t.waitFor();
		} catch (InterruptedException e) {
			t.destroy();
			
			Thread.currentThread().interrupt();
			throw new LeJOSEV3Exception("interrupted while waiting for tool to end", e);
		}
	}

	public int invokeSwingTool(String tool, List<String> args) throws Exception, InvocationTargetException
	{
		Process t = createProcess(tool, args);
		t.getOutputStream().close();
		t.getInputStream().close();
		t.getErrorStream().close();
		
		//TODO what to return? How to check that program actually started?
		return 0;
	}
	
	public boolean isUp2Date()
	{
		return true;
	}

	public File getEV3Home() {
		return this.ev3Home;
	}

}
