package org.lejos.ev3.ldt.wizard;

import java.io.File;

import org.eclipse.jface.dialogs.IDialogSettings;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.IWizardContainer;
import org.eclipse.jface.wizard.IWizardPage;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IImportWizard;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.wizards.datatransfer.ExternalProjectImportWizard;
import org.lejos.ev3.ldt.util.LeJOSEV3Exception;
import org.lejos.ev3.ldt.util.LeJOSEV3Util;

public class SampleImport implements IImportWizard {
	
	ExternalProjectImportWizard delegate;

	public SampleImport() throws LeJOSEV3Exception {
		//TODO handle LeJOSEV3Exception
		File sampleszip = new File(LeJOSEV3Util.getEV3Home(), "samples.zip");
		//TODO check whether sampleszip exists
		delegate = new ExternalProjectImportWizard(sampleszip.getAbsolutePath());
	}

	/* (non-Javadoc)
	 * @see org.eclipse.jface.wizard.Wizard#performFinish()
	 */
	public boolean performFinish() {
		return delegate.performFinish();
	}
	
	public boolean performCancel() {
		return delegate.performCancel();
	}
	 
	/* (non-Javadoc)
	 * @see org.eclipse.ui.IWorkbenchWizard#init(org.eclipse.ui.IWorkbench, org.eclipse.jface.viewers.IStructuredSelection)
	 */
	public void init(IWorkbench workbench, IStructuredSelection selection) {
		delegate.init(workbench, selection);
	}
	
	/* (non-Javadoc)
     * @see org.eclipse.jface.wizard.IWizard#addPages()
     */
    public void addPages() {
    	delegate.addPages();
    }

	public boolean canFinish() {
		return delegate.canFinish();
	}

	public void createPageControls(Composite pageContainer) {
		delegate.createPageControls(pageContainer);
	}

	public void dispose() {
		delegate.dispose();
	}

	public IWizardContainer getContainer() {
		return delegate.getContainer();
	}

	public Image getDefaultPageImage() {
		return delegate.getDefaultPageImage();
	}

	public IDialogSettings getDialogSettings() {
		return delegate.getDialogSettings();
	}

	public IWizardPage getNextPage(IWizardPage page) {
		return delegate.getNextPage(page);
	}

	public IWizardPage getPage(String pageName) {
		return delegate.getPage(pageName);
	}

	public int getPageCount() {
		return delegate.getPageCount();
	}

	public IWizardPage[] getPages() {
		return delegate.getPages();
	}

	public IWizardPage getPreviousPage(IWizardPage page) {
		return delegate.getPreviousPage(page);
	}

	public IWizardPage getStartingPage() {
		return delegate.getStartingPage();
	}

	public RGB getTitleBarColor() {
		return delegate.getTitleBarColor();
	}

	public String getWindowTitle() {
		return delegate.getWindowTitle();
	}

	public boolean isHelpAvailable() {
		return delegate.isHelpAvailable();
	}

	public boolean needsPreviousAndNextButtons() {
		return delegate.needsPreviousAndNextButtons();
	}

	public boolean needsProgressMonitor() {
		return delegate.needsProgressMonitor();
	}

	public void setContainer(IWizardContainer wizardContainer) {
		delegate.setContainer(wizardContainer);
	}

    
}
