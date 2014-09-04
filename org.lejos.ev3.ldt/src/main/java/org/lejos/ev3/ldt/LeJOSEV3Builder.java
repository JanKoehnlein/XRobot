package org.lejos.ev3.ldt;

import java.util.Map;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IncrementalProjectBuilder;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;

/**
 * leJOS EV3 project builder
 * @author Matthias Paul Scholz and Lawrie Griffiths
 *
 */
public class LeJOSEV3Builder extends IncrementalProjectBuilder {

	public static final String ID = "org.lejos.ev3.ldt.leJOSEV3Builder";

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.core.internal.events.InternalBuilder#build(int,
	 *      java.util.Map, org.eclipse.core.runtime.IProgressMonitor)
	 */
	@Override
	protected IProject[] build(int kind, Map args, IProgressMonitor monitor) throws CoreException {
		
		// nothing to do yet
		
		return null;
	}
}

