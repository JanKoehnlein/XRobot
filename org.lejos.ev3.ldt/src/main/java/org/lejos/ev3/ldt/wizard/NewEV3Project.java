package org.lejos.ev3.ldt.wizard;

public class NewEV3Project extends AbstractNewProjectWizard {

	public NewEV3Project() {
		super();
		pageOne = new NewEV3ProjectPageOne();
		pageTwo = new NewEV3ProjectPageTwo(pageOne);
		
		pageOne.setTitle("New LeJOS EV3 Project");
		pageOne.setDescription("Create a new LeJOS Project for programs running on the EV3");
		
	    setWindowTitle("New LeJOS EV3 Project");
	}
}
