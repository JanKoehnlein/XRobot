package org.lejos.ev3.ldt.container;

import java.io.File;
import java.util.ArrayList;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.jdt.core.IAccessRule;
import org.eclipse.jdt.core.IClasspathAttribute;
import org.eclipse.jdt.core.IClasspathContainer;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.JavaCore;
import org.lejos.ev3.ldt.util.LeJOSEV3Exception;
import org.lejos.ev3.ldt.util.LeJOSEV3Util;


public class LeJOSEV3LibContainer implements IClasspathContainer {
	public static final String ID = "org.lejos.ev3.ldt.LEJOS_EV3_LIBRARY_CONTAINER";
    
    private static final int DEFAULT_OPTION = 0;
    private static final int IDX_KEY = 0;
    private static final int IDX_NAME = 1;
    private static final int IDX_SYSTEM = 2;
       
    private static final String[][] options = {
    		{ LeJOSEV3Util.LIBSUBDIR_EV3, "EV3 Runtime", "true" },
    		{ LeJOSEV3Util.LIBSUBDIR_PC, "PC Libraries", "false" },
    	};
    
    static int getOptionCount()
    {
    	return options.length;
    }
    
    static String getOptionKey(int i)
    {
    	return options[i][IDX_KEY];
    }
    
    static String getOptionName(int i)
    {
    	return options[i][IDX_NAME];
    }
    
    static boolean isSystemContainer(int i)
    {
    	return Boolean.parseBoolean(options[i][IDX_SYSTEM]);
    }
    
    static int getOptionIndex(String s)
    {
    	for (int i=0; i<options.length; i++)
    		if (getOptionKey(i).equals(s))
    			return i;
    	
    	return -1;
    }
    
    static int getOptionFromPath(IPath p)
    {
        if(p != null && p.segmentCount() > 1 ) {
            int i= LeJOSEV3LibContainer.getOptionIndex(p.segment(1));
            if (i >= 0)
            	return i;
        }
        
        return DEFAULT_OPTION;
    }
    
    
    // path string that uniquiely identifies this container instance
    private final IPath path;
    private final String name;
    private final IClasspathEntry[] cp;
  
    public LeJOSEV3LibContainer(IPath path) throws LeJOSEV3Exception {
        int option = getOptionFromPath(path);
        
        this.path = path;
        this.name = "LeJOS EV3 "+getOptionName(option);
        this.cp = createClasspath(option);
    }
    
    private IClasspathEntry[] createClasspath(int option) throws LeJOSEV3Exception {
        ArrayList<File> entryList = new ArrayList<File>();
        
    	File ev3Home = LeJOSEV3Util.getEV3Home();
    	String subdir = getOptionKey(option);
    	LeJOSEV3Util.buildClasspath(ev3Home, subdir, entryList);
    	
        int len = entryList.size();
        IClasspathEntry[] entryArray = new IClasspathEntry[entryList.size()];
        for (int i=0; i<len; i++)
        {
        	File lib = entryList.get(i);
        	File src = guessSource(lib);
        	IPath lib2 = LeJOSEV3Util.toPath(lib);
        	IPath src2 = (src == null) ? null : LeJOSEV3Util.toPath(src);        	
        	IAccessRule[] accessRules = { JavaCore.newAccessRule(new Path("**/internal/**"), IAccessRule.K_DISCOURAGED) };
        	IClasspathAttribute[] attributes = {};
        	entryArray[i] = JavaCore.newLibraryEntry(lib2, src2, null, accessRules, attributes, false);
        }
        return entryArray;
	}

	private File guessSource(File lib) throws LeJOSEV3Exception {
		File parent = lib.getParentFile();
		File project = new File(LeJOSEV3Util.getEV3Home(), "projects");
		String basename = lib.getName();
		int i = basename.lastIndexOf('.');
		if (i >= 0)
			basename = basename.substring(0, i);
		
		File[] test = new File[] {
				new File(parent, basename+".zip"),
				new File(parent, basename+"-src.zip"),
				new File(project, basename),
				new File(project, basename+".zip"),
				new File(project, basename+"-src.zip"),
			};
		
		for (File f : test)
			if (f.exists())
				return f;
		
		return null;
	}

	public IClasspathEntry[] getClasspathEntries() {
    	return cp;
    }
    
    public String getDescription() {
        return name;
    }

    public int getKind() {
        int option = getOptionFromPath(path);
        
        // K_SYSTEM doesn't seem to need a custom IRuntimeClasspathEntryResolver
        // K_DEFAULT_SYSTEM is used by JREContainer, but requires a custom IRuntimeClasspathEntryResolver
        if (isSystemContainer(option))                    
            return IClasspathContainer.K_SYSTEM;
        
        return IClasspathContainer.K_APPLICATION;
    }
    
    public IPath getPath() {
        return path;
    }
    
}
