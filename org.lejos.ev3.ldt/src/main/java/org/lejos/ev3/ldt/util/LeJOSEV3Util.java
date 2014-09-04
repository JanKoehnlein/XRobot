package org.lejos.ev3.ldt.util;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Status;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.ICompilationUnit;
import org.eclipse.jdt.core.IJavaElement;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IType;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.core.JavaModelException;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.lejos.ev3.ldt.LeJOSEV3Nature;
import org.lejos.ev3.ldt.LeJOSEV3Plugin;
import org.lejos.ev3.ldt.preferences.PreferenceConstants;

/**
 * utility methods for the plugin
 * 
 * @author Matthias Paul Scholz and Lawrie Griffiths
 * 
 */
public class LeJOSEV3Util {

	public static final String LIBDIR = "lib";
	public static final String LIBSUBDIR_PC = "";
	public static final String LIBSUBDIR_EV3 = "";
	
	public static boolean isWindows() {
		return System.getProperty("os.name", "").toLowerCase().startsWith("windows ");
	}

	public static boolean isOSX() {
		return System.getProperty("os.name", "").toLowerCase().startsWith("mac os x");
	}

	public static boolean getJavaProjectFromSelection(ISelection selection, Collection<IJavaProject> dst) {
		boolean foundInvalid = false;
		if (selection instanceof IStructuredSelection) {
			IStructuredSelection ss = (IStructuredSelection)selection;
			for (Iterator<?> it = ss.iterator(); it.hasNext();) {
				Object element = it.next();
				if (element instanceof IJavaProject) {
					// we see IJavaProjects when selecting in package explorer
					dst.add((IJavaProject) element);
				} else if (element instanceof IProject) {
					// we see IProjects when selecting in project explorer, or navigator.
					IProject p = (IProject) element;
					try {
						if (p.isOpen() && p.isNatureEnabled(JavaCore.NATURE_ID))
							dst.add(JavaCore.create(p));
					} catch (CoreException e) {
						foundInvalid = true;
					}
				} else {
					foundInvalid = true;
				}
			}
		}
		return foundInvalid;
	}
	
	public static boolean getFilesFromSelection(ISelection selection, Collection<File> dst)
	{
		boolean foundInvalid = false;
		if (selection instanceof IStructuredSelection) {
			IStructuredSelection ss = (IStructuredSelection) selection;
			for (Iterator<?> it = ss.iterator(); it.hasNext(); ) {
				Object element = it.next();
				if (element instanceof IFile) {
					IFile f = (IFile)element;
					dst.add(f.getLocation().toFile());
				} else {
					foundInvalid = true;
				}
			}
		}
		return foundInvalid;
	}

	public static IJavaElement getFirstJavaElementFromSelection(ISelection selection) {
		if (selection instanceof IStructuredSelection) {
			IStructuredSelection ss = (IStructuredSelection) selection;
			for (Iterator<?> it = ss.iterator(); it.hasNext(); ) {
				Object element = it.next();
				if (element instanceof IJavaElement) {
					// we see IJavaProjects when selecting in package explorer
					IJavaElement e = (IJavaElement) element;
					return e;
				} else if (element instanceof IFile) {
					// we see IFile when selecting in project explorer, or navigator.
					IJavaElement e = JavaCore.create((IFile)element);
					if (e != null)
						return e;
				}
			}
		}
		return null;
	}

	public static IType getJavaTypeFromElement(IJavaElement element) {
		switch (element.getElementType())
		{
			case IJavaElement.COMPILATION_UNIT:
				return ((ICompilationUnit)element).findPrimaryType();
			case IJavaElement.TYPE:
				return (IType)element;
		}		
		return null;
	}

	public static boolean isLeJOSProject(IProject project) throws CoreException {
		return project.isNatureEnabled(LeJOSEV3Nature.ID);
	}

	public static boolean isLeJOSProject(IJavaProject project) throws CoreException {
		return isLeJOSProject(project.getProject());
	}

	public static void message(String message) {
		message(message, null);
	}

	public static void message(String msg, Throwable throwable) {
		// log to leJOS EV3 console
		PrintWriter pw = LeJOSEV3Plugin.getDefault().getConsoleWriter();
		if (msg != null)
			pw.println(msg);
		if (throwable != null)
		{
			pw.println(throwable);
			Throwable t = throwable.getCause();
			while (t != null)
			{
				pw.println("Caused by "+t);
				t = t.getCause();
			}
			pw.println("See Eclipse error log for detailed stack trace.");
			log(throwable);
		}
	}

	public static void error(String message) {
		error(message, null);
	}

	public static void error(String msg, Throwable throwable) {
		LeJOSEV3Plugin.getDefault().getConsole().activate();
		message(msg, throwable);
	}

	public static void log(Throwable throwable) {
		// log to error log
		Status status = new Status(IStatus.ERROR, LeJOSEV3Plugin.ID, throwable.getMessage(), throwable);
		LeJOSEV3Plugin.getDefault().getLog().log(status);
	}

	private static void walkTreeAndReturnJARS(File dir, Collection<File> dst)
	{
		for (File e : dir.listFiles())
		{
			if (e.isDirectory())
				walkTreeAndReturnJARS(e, dst);
			else
			{
				if (e.getName().toLowerCase().endsWith(".jar"))
				{
					dst.add(e);
				}
			}
		}
	}
	
	public static void buildClasspath(File ev3Home, String subdir, Collection<File> dst) throws LeJOSEV3Exception
	{
		File f1 = new File(ev3Home, LIBDIR);
		File f2 = new File(f1, subdir);
		if (!f2.isDirectory())
			throw new LeJOSEV3Exception(f2+" is not a directory");
		
		walkTreeAndReturnJARS(f2, dst);
	}
	
	public static void buildEV3Classpath(File ev3Home, Collection<File> dst) throws LeJOSEV3Exception
	{
		buildClasspath(ev3Home, LIBSUBDIR_EV3, dst);
	}
	
	public static void buildPCClasspath(File ev3Home, Collection<File> dst) throws LeJOSEV3Exception
	{
		buildClasspath(ev3Home, LIBSUBDIR_PC, dst);
	}
	
	
	public static File getEV3Home() throws LeJOSEV3Exception
	{
		// get EV3_HOME
		PrefsResolver p = new PrefsResolver(LeJOSEV3Plugin.ID, null);
		String ev3Home = p.getString(PreferenceConstants.KEY_EV3_HOME, null);
		
		if (ev3Home == null || ev3Home.length() <= 0)
			throw new LeJOSEV3Exception("EV3_HOME is not set. Please specify it in the plug-in's preferences");
		
		File f = new File(ev3Home);
		if (!f.isDirectory())
			throw new LeJOSEV3Exception("EV3_HOME="+f+" is not a directory");
		
		//message("EV3 Home is " + f.getPath());

		return f;
	}
	
	public static void getUploadOpts(List<String> dst) throws LeJOSEV3Exception
	{
		PrefsResolver p = new PrefsResolver(LeJOSEV3Plugin.ID, null);
		
		boolean byName = p.getBoolean(PreferenceConstants.KEY_TARGET_CONNECT_BY_NAME, false);
		
	}

	public static void getUploadOpts(List<String> dst, String type, String addr, String name) throws LeJOSEV3Exception
	{
		
		if (addr != null)
		{
			dst.add("-d");
			dst.add(addr);
		}
		if (name != null)
		{
			dst.add("-n");
			dst.add(name);
		}
	}

	public static File resolvePath(IPath path)
	{
		IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
		IResource res = root.findMember(path);
		if (res != null)
			path = res.getLocation();
		
		return path.toFile();
	}
	
	public static IPath toPath(File f)
	{
		return Path.fromOSString(f.getAbsolutePath());
	}

	/**
	 * 
	 * build the classpath for the link and upload utility
	 * 
	 * @param project
	 * @return String classpath
	 * @throws JavaModelException
	 * @throws LeJOSEV3Exception 
	 */
	public static void getProjectClassPath(IJavaProject project, boolean onlyExported, List<File> dst) throws JavaModelException, LeJOSEV3Exception {
		dst.add(resolvePath(project.getOutputLocation()));
		// project's classpath
		IClasspathEntry[] entries = project.getResolvedClasspath(true);
		// build string
		for (IClasspathEntry classpathEntry : entries) {
			if (!onlyExported || classpathEntry.isExported())
			{
				switch (classpathEntry.getEntryKind()) {
					case IClasspathEntry.CPE_SOURCE: // source => ignore
						IPath p = classpathEntry.getOutputLocation();
						if (p != null)
							dst.add(resolvePath(p));
						break;
					case IClasspathEntry.CPE_PROJECT: // another project =>
						// append classpath of other project
						IWorkspaceRoot workspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
						IProject referencedProject = workspaceRoot.getProject(classpathEntry.getPath().toString());
				        IJavaProject referencedJavaProject = JavaCore.create(referencedProject);
				        getProjectClassPath(referencedJavaProject, true, dst);
						break;
					case IClasspathEntry.CPE_LIBRARY:
						dst.add(resolvePath(classpathEntry.getPath()));
						break;
					case IClasspathEntry.CPE_VARIABLE:
					case IClasspathEntry.CPE_CONTAINER:
						// variable and container should never occur, since we use resolved classpath
					default:
						throw new LeJOSEV3Exception("unsupported classpath entry "+classpathEntry);
				}
			}
		}
	}
	
	public static String getClasspathString(List<File> c)
	{
		StringBuilder sb = new StringBuilder();
		Iterator<File> i = c.iterator();
		if (i.hasNext())
		{
			sb.append(i.next().getAbsolutePath());
			while (i.hasNext())
			{
				sb.append(File.pathSeparatorChar);
				sb.append(i.next().getAbsolutePath());
			}
		}
		return sb.toString();
	}
	
	private static ToolStarter currentStarter;
	private static ToolStarter currentStarterExt;
	private static boolean currentStarterType;

	private static synchronized void updateStarters() throws LeJOSEV3Exception
	{
		PrefsResolver p = new PrefsResolver(LeJOSEV3Plugin.ID, null);
		boolean separateJVM = p.getBoolean(PreferenceConstants.KEY_SEPARATE_JVM, false);
		File ev3Home = getEV3Home();
		
		if (currentStarterExt == null || !ev3Home.equals(currentStarterExt.getEV3Home()) || !currentStarterExt.isUp2Date())
		{
			currentStarterExt = new ExternalJVMToolStarter(ev3Home);
		}
		if (currentStarter == null || currentStarterType != separateJVM || !ev3Home.equals(currentStarter.getEV3Home()) || !currentStarter.isUp2Date())
		{
			if (separateJVM)
				currentStarter = currentStarterExt;
			else
				currentStarter = new ClassLoaderToolStarter(ev3Home);
			
			currentStarterType = separateJVM;
		}
	}
	
	public static synchronized ToolStarter getCachedExternalStarter() throws LeJOSEV3Exception
	{
		updateStarters();
		return currentStarterExt;
	}
	
	public static synchronized ToolStarter getCachedToolStarter() throws LeJOSEV3Exception
	{
		updateStarters();
		return currentStarter;
	}

	public static final String TOOL_EV3CONTROL = "lejos.ev3.tools.EV3Control";
	public static final String TOOL_EV3MAPCOMMAND = "lejos.ev3.tools.EV3MapCommand";
	public static final String TOOL_EV3SCPUPLOAD = "lejos.ev3.tools.EV3ScpUpload";
	public static final String TOOL_EV3SDCARD = "lejos.ev3.tools.EV3SDCard";
	
	public static ProcessBuilder createProcessBuilder(List<String> args2) throws IOException
	{
		int len = args2.size();
		ArrayList<String> args3;
		if (len <= 1 || !isWindows())
		{
			args3 = new ArrayList<String>(len);
			args3.addAll(args2);
		}
		else
		{
			args3 = new ArrayList<String>(2);
			Iterator<String> it = args2.iterator();
			args3.add(it.next());
			
			// Both java.lang.Runtime.exec(String[]) as well as in java.lang.ProcessBuilder
			// don't escape the arguments that are passed to the program. Also, they fail to
			// handle the empty string correctly. Hence, we manually escape all arguments.
			// If the second element of the command list starts and ends with a quote,
			// then ProcessBuilder won't add more quotes and the string will be passed
			// to the invoked program without any further processing (not documented, but
			// the implementation shows that this is the case).
			StringBuilder sb = new StringBuilder();
			while (it.hasNext())
			{
				sb.append(' ');
				// the escaping must add quotes around the argument in order to
				// satisfy the requirements described above.
				escapeWindowsArg(it.next(), sb);
			}			
			args3.add(sb.substring(1));
		}
		return new ProcessBuilder(args3);
	}

	private static void escapeWindowsArg(String t, StringBuilder sb) {
		/* Escaping of quotes and backslashes, compatible
		 * with that Microsoft's default decoding. See
		 * http://msdn.microsoft.com/en-us/library/a1y7w461.aspx
		 * 
		 * How microsoft's default decoding works:
		 * 2n backslashes + quote => n backslashes + closing quote
		 * 2n+1 backslashes + quote => n backslashes + inner quote
		 * n backslashes not followed by a quote => n backslashes
		 */
		int len = t.length();
		sb.append('"');
		for (int i=0; i<len; )
		{
			char c = t.charAt(i);
			switch (c)
			{
				case '\\':
					int j=i++;
					sb.append('\\');
					for (; i<len && t.charAt(i)=='\\'; i++)
						sb.append('\\');
					// double the number of backslashes if they are at the
					// end of the argument or precede a quote
					if (i==len || t.charAt(i)=='"')
						for (; j<i; j++)
							sb.append('\\');
					break;
				case '"':
					sb.append('\\');
				default:
					sb.append(c);
					i++;
			}
		}
		sb.append('"');
	}
}
