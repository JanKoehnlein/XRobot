package org.lejos.ev3.ldt.wizard;

import org.eclipse.core.runtime.Path;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.ui.wizards.NewJavaProjectWizardPageOne;

import org.lejos.ev3.ldt.container.LeJOSEV3LibContainer;

public class NewEV3ProjectPageOne extends NewJavaProjectWizardPageOne {
	@Override
	public IClasspathEntry[] getDefaultClasspathEntries() {
		IClasspathEntry[] oldEntries = super.getDefaultClasspathEntries();
		Path lcp = new Path(LeJOSEV3LibContainer.ID);
		
		int len = oldEntries.length;
		IClasspathEntry[] newEntries = new IClasspathEntry[len + 1];
		System.arraycopy(oldEntries, 0, newEntries, 0, len);
		newEntries[len] = JavaCore.newContainerEntry(lcp);
		
		return newEntries;
	}
}
