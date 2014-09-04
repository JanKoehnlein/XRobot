package org.lejos.ev3.ldt.wizard;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.ui.wizards.NewJavaProjectWizardPageOne;
import org.eclipse.jdt.ui.wizards.NewJavaProjectWizardPageTwo;
import org.lejos.ev3.ldt.actions.ConvertToLeJOSEV3ProjectAction;

public class NewEV3ProjectPageTwo extends NewJavaProjectWizardPageTwo {

	public NewEV3ProjectPageTwo(NewJavaProjectWizardPageOne mainPage) {
		super(mainPage);
	}

	@Override
	public void performFinish(IProgressMonitor monitor) throws CoreException, InterruptedException {
		super.performFinish(monitor);
		
		IJavaProject p = this.getJavaProject();
		ConvertToLeJOSEV3ProjectAction.addLeJOSEV3Nature(p.getProject());
	}
}
