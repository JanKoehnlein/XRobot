package org.lejos.ev3.ldt.launch;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants;
import org.eclipse.jdt.launching.IRuntimeClasspathEntry;
import org.eclipse.jdt.launching.JavaRuntime;
import org.eclipse.jdt.launching.StandardClasspathProvider;
import org.lejos.ev3.ldt.container.LeJOSEV3LibContainer;
import org.lejos.ev3.ldt.util.LeJOSEV3Util;

public class LaunchEV3ClasspathProvider extends StandardClasspathProvider
{
	
	public final static String ID = "org.lejos.ev3.ldt.LaunchEV3ClasspathProvider";

	@Override
	public IRuntimeClasspathEntry[] computeUnresolvedClasspath(ILaunchConfiguration configuration) throws CoreException
	{
		boolean useDefault = configuration.getAttribute(IJavaLaunchConfigurationConstants.ATTR_DEFAULT_CLASSPATH, true);
		if (!useDefault)
		{
			// recover persisted classpath
			return recoverRuntimePath(configuration, IJavaLaunchConfigurationConstants.ATTR_CLASSPATH);
		}

		Path lcp = new Path(LeJOSEV3LibContainer.ID+"/"+LeJOSEV3Util.LIBSUBDIR_EV3);
		
		IJavaProject proj = JavaRuntime.getJavaProject(configuration);
		if (proj == null)
		{
			IRuntimeClasspathEntry rte = JavaRuntime.newRuntimeContainerClasspathEntry(lcp, IRuntimeClasspathEntry.STANDARD_CLASSES);
			return new IRuntimeClasspathEntry[] { rte };
		}
		
		return JavaRuntime.computeUnresolvedRuntimeClasspath(proj);		
	}
}
