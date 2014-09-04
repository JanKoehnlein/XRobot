package org.lejos.ev3.ldt.container;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.jdt.core.ClasspathContainerInitializer;
import org.eclipse.jdt.core.IClasspathContainer;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.JavaCore;
import org.lejos.ev3.ldt.util.LeJOSEV3Exception;
import org.lejos.ev3.ldt.util.LeJOSEV3Util;


public class LeJOSEV3LibContainerInitializer extends ClasspathContainerInitializer {

	@Override
	public void initialize(IPath containerPath, IJavaProject project) throws CoreException
	{
		LeJOSEV3LibContainer container;
		try {
			container = new LeJOSEV3LibContainer(containerPath);
		} catch (LeJOSEV3Exception e) {
			LeJOSEV3Util.log(e);
			// JDT will show an error when using null
			container = null;
		}
		JavaCore.setClasspathContainer(containerPath, new IJavaProject[] { project }, new IClasspathContainer[] { container }, null);
	}

	@Override
	public boolean canUpdateClasspathContainer(IPath containerPath, IJavaProject project)
	{
		return true;
	}

	@Override
	public void requestClasspathContainerUpdate(IPath containerPath, IJavaProject project, IClasspathContainer containerSuggestion)	throws CoreException
	{
		this.initialize(containerPath, project);
	}

}
