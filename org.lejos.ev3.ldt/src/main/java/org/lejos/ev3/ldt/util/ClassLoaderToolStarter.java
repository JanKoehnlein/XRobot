package org.lejos.ev3.ldt.util;

import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.ui.console.IOConsole;
import org.lejos.ev3.ldt.LeJOSEV3Plugin;

public class ClassLoaderToolStarter implements ToolStarter
{
	private static void initializeSystemContext(ClassLoader cl, File ev3Home) throws LeJOSEV3Exception
	{
		LeJOSEV3Plugin p = LeJOSEV3Plugin.getDefault();
		IOConsole con = p.getConsole();
		Writer consw = p.getConsoleWriter();
		InputStream cins = con.getInputStream();
		InputStreamReader cinsr;
		try
		{
			cinsr = new InputStreamReader(cins, LeJOSEV3Plugin.CONSOLE_CHARSET);
		}
		catch (UnsupportedEncodingException e1)
		{
			throw new RuntimeException(e1);
		}
		
		try
		{
			Class<?> c = cl.loadClass("lejos.pc.comm.SystemContext");
			Method m;
			
			m = c.getDeclaredMethod("setEV3Home", String.class);
			m.invoke(null, ev3Home.getAbsolutePath());
			
			m = c.getDeclaredMethod("setOut", Writer.class);
			m.invoke(null, consw);
			
			m = c.getDeclaredMethod("setErr", Writer.class);
			m.invoke(null, consw);
			
			m = c.getDeclaredMethod("setIn", Reader.class);
			m.invoke(null, cinsr);
		}
		catch (Exception e)
		{
			Throwable t = e;
			if (t instanceof InvocationTargetException)
				t = ((InvocationTargetException)t).getTargetException();
			
			throw new LeJOSEV3Exception("unanble to initialize system context", t);
		}
	}

	private ClassLoader classloader;
	private File ev3Home;
	
	public ClassLoaderToolStarter(File ev3Home) throws LeJOSEV3Exception
	{
		LeJOSEV3Util.message("Initializing LeJOS EV3 JDK at "+ev3Home);
		
		ArrayList<File> tmp = new ArrayList<File>();
		LeJOSEV3Util.buildPCClasspath(ev3Home, tmp);
		URL[] urls = new URL[tmp.size()];
		int i = 0;
		for (File e : tmp)
		{
			try
			{
				urls[i++] = e.toURI().toURL();
			}
			catch (MalformedURLException e1)
			{
				throw new RuntimeException(e1);
			}
		}
		
		URLClassLoader cl = new URLClassLoader(urls);
		initializeSystemContext(cl, ev3Home);
		
		this.ev3Home = ev3Home;
		this.classloader = cl;		
	}

	public int invokeTool(String tool, List<String> args)	throws Exception, InvocationTargetException
	{
		String[] args2 = args.toArray(new String[args.size()]);
		
		Class<?> c = classloader.loadClass(tool);
		Method m = c.getDeclaredMethod("start", String[].class);
		Object r1 = m.invoke(null, (Object)args2);
		int r2 = ((Integer)r1).intValue();
		return r2;
	}

	public int invokeSwingTool(String tool, List<String> args) throws Exception, InvocationTargetException
	{
		//TODO move to swing thread
		return this.invokeTool(tool, args);
	}
	
	public boolean isUp2Date()
	{
		//TODO check timestamps of files
		return true;
	}
	
	public File getEV3Home() {
		return this.ev3Home;
	}

}
