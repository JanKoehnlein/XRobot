package org.lejos.ev3.ldt.actions;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectDescription;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.core.JavaModelException;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.actions.ActionDelegate;
import org.lejos.ev3.ldt.LeJOSEV3Nature;
import org.lejos.ev3.ldt.container.LeJOSEV3LibContainer;
import org.lejos.ev3.ldt.util.LeJOSEV3Exception;
import org.lejos.ev3.ldt.util.LeJOSEV3Util;

/**
 * converts a Java project into a Java project with additional leJOS project
 * nature
 * 
 * @author Matthias Paul Scholz and Lawrie Griffiths
 * 
 */
public class ConvertToLeJOSEV3ProjectAction extends ActionDelegate {

	private ISelection selection;

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.ui.IActionDelegate#run(org.eclipse.jface.action.IAction)
	 */
	@Override
	public void run(IAction action) {
		addLeJOSEV3Nature();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.ui.IActionDelegate#selectionChanged(org.eclipse.jface.action.IAction,
	 *      org.eclipse.jface.viewers.ISelection)
	 */
	@Override
	public void selectionChanged(IAction action, ISelection newSelection) {
		this.selection = newSelection;
		ArrayList<IJavaProject> list = new ArrayList<IJavaProject>();
		LeJOSEV3Util.getJavaProjectFromSelection(newSelection, list);
		action.setEnabled(!list.isEmpty());
	}

	/**
	 * set the leJOS nature on a project
	 * 
	 * @param project
	 */
	private void addLeJOSEV3Nature() {
		ArrayList<IJavaProject> list = new ArrayList<IJavaProject>();
		LeJOSEV3Util.getJavaProjectFromSelection(selection, list);
		for (IJavaProject project : list)
		{
			IProject project2 = project.getProject();
			try {
				removeLeJOSEV3Nature(project2);
				addLeJOSEV3Nature(project2);
	
				// update classpath
				updateClasspath(project);
				// log
				LeJOSEV3Util.message("project " + project2.getName() + " now is a leJOS EV3 project");
			} catch (Throwable t) {
				// log
				LeJOSEV3Util.error("project " + project2.getName()+" was not converted.", t);
			}
		}
	}

	public static void removeLeJOSEV3Nature(IProject project) throws CoreException {
		IProjectDescription description = project.getDescription();

		LinkedHashSet<String> newNatures = new LinkedHashSet<String>();
		newNatures.addAll(Arrays.asList(description.getNatureIds()));
		newNatures.remove(LeJOSEV3Nature.ID);
		
		String[] tmp = new String[newNatures.size()];
		newNatures.toArray(tmp);
		description.setNatureIds(tmp);
		project.setDescription(description, null);
	}

	public static void addLeJOSEV3Nature(IProject project) throws CoreException {
		IProjectDescription description = project.getDescription();

		LinkedHashSet<String> newNatures = new LinkedHashSet<String>();
		newNatures.add(LeJOSEV3Nature.ID);
		newNatures.addAll(Arrays.asList(description.getNatureIds()));
		
		String[] tmp = new String[newNatures.size()];
		newNatures.toArray(tmp);
		description.setNatureIds(tmp);
		project.setDescription(description, null);
	}

	/**
	 * update the project's classpath with additional leJOS libraries.
	 * 
	 * @param aProject
	 *            a java project
	 */
	private void updateClasspath(IJavaProject project) throws JavaModelException, LeJOSEV3Exception
	{
		File ev3Home = LeJOSEV3Util.getEV3Home();
		ArrayList<File> tmp = new ArrayList<File>();
		LeJOSEV3Util.buildEV3Classpath(ev3Home, tmp);
		LinkedHashSet<IPath> ev3Files = new LinkedHashSet<IPath>();
		for (File e : tmp)
			ev3Files.add(LeJOSEV3Util.toPath(e));
		
		ev3Files.add(LeJOSEV3Util.toPath(new File(ev3Home, LeJOSEV3Util.LIBDIR+"/ev3classes.jar")));
		ev3Files.add(LeJOSEV3Util.toPath(new File(ev3Home, LeJOSEV3Util.LIBDIR+"/dbusjava.jar")));
		
		// create new classpath with additional leJOS libraries last
		ArrayList<IClasspathEntry> newClasspath = new ArrayList<IClasspathEntry>();
		Path lcp = new Path(LeJOSEV3LibContainer.ID);
		IClasspathEntry lc = JavaCore.newContainerEntry(lcp);
		
		// get existing classpath
		IClasspathEntry[] existingClasspath = project.getRawClasspath();
		for (IClasspathEntry cpEntry : existingClasspath) {
			boolean skip = false;
			boolean insertBefore = false;
			switch (cpEntry.getEntryKind())
			{
				case IClasspathEntry.CPE_CONTAINER:
					IPath p = cpEntry.getPath();
					if (p != null && p.segmentCount() > 0)
					{
						String s = p.segment(0);
						if (s.equals(LeJOSEV3LibContainer.ID)) {
							// skip leJOS container
							skip = true;
						}
					}
					insertBefore = true;
					break;
				case IClasspathEntry.CPE_LIBRARY:
					if (ev3Files.contains(cpEntry.getPath().makeAbsolute())) {
						skip = true;
					}
					insertBefore = true;
					break;
				case IClasspathEntry.CPE_PROJECT:
				case IClasspathEntry.CPE_VARIABLE:
					insertBefore = true;
				default:
					skip = false;
					
			}
			
			if (insertBefore && lc != null) {
				newClasspath.add(lc);
				lc = null;
			}
			if (!skip) {
				newClasspath.add(cpEntry);
			}
		}
		
		if (lc != null)
			newClasspath.add(lc);
		
		// set new classpath to project
		IClasspathEntry[] cpEntries = newClasspath.toArray(new IClasspathEntry[newClasspath.size()]);
		project.setRawClasspath(cpEntries, null);
	}
}
