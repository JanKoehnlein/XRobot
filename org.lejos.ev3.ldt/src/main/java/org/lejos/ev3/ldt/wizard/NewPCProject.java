package org.lejos.ev3.ldt.wizard;

import org.eclipse.jdt.ui.wizards.NewJavaProjectWizardPageTwo;

public class NewPCProject extends AbstractNewProjectWizard {

	public NewPCProject() {
		super();
		pageOne = new NewPCProjectPageOne();
		pageTwo = new NewJavaProjectWizardPageTwo(pageOne);
		
		pageOne.setTitle("New LeJOS EV3 PC Project");
		pageOne.setDescription("Create a new LeJOS Project for remote controlling the EV3");
		
	    setWindowTitle("New LeJOS EV3 PC Project");
	}
}
