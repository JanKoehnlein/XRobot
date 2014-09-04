package org.lejos.ev3.ldt;

import java.util.ArrayList;

import org.eclipse.core.resources.ICommand;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectDescription;
import org.eclipse.core.resources.IProjectNature;
import org.eclipse.core.runtime.CoreException;

/**
 *
 * leJOS EV3 project nature
 * @author Matthias Paul Scholz and Lawrie Griffiths
 * 
 */
public class LeJOSEV3Nature implements IProjectNature {

	/**
	 * ID of this project nature
	 */
	public static final String ID = "org.lejos.ev3.ldt.leJOSEV3Nature";

	private IProject project;

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.core.resources.IProjectNature#configure()
	 */
	public void configure() throws CoreException {
		ArrayList<ICommand> newCommands = new ArrayList<ICommand>();
		
		IProjectDescription desc = project.getDescription();
		ICommand[] commands = desc.getBuildSpec();
		for (ICommand c : commands) {
			if (!LeJOSEV3Builder.ID.equals(c.getBuilderName())) {
				newCommands.add(c);
			}
		}

		ICommand command = desc.newCommand();
		command.setBuilderName(LeJOSEV3Builder.ID);
		newCommands.add(command);
		
		commands = newCommands.toArray(new ICommand[newCommands.size()]);
		desc.setBuildSpec(commands);
		project.setDescription(desc, null);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.core.resources.IProjectNature#deconfigure()
	 */
	public void deconfigure() throws CoreException {
		ArrayList<ICommand> newCommands = new ArrayList<ICommand>();
		
		IProjectDescription desc = project.getDescription();
		ICommand[] commands = desc.getBuildSpec();
		for (ICommand c : commands) {
			if (!LeJOSEV3Builder.ID.equals(c.getBuilderName())) {
				newCommands.add(c);
			}
		}

		commands = newCommands.toArray(new ICommand[newCommands.size()]);
		desc.setBuildSpec(commands);
		project.setDescription(desc, null);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.core.resources.IProjectNature#getProject()
	 */
	public IProject getProject() {
		return project;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.core.resources.IProjectNature#setProject(org.eclipse.core.resources.IProject)
	 */
	public void setProject(IProject project) {
		this.project = project;
	}

}
