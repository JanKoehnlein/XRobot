package org.lejos.ev3.ldt.container;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.jdt.core.IClasspathEntry;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.ui.wizards.IClasspathContainerPage;
import org.eclipse.jdt.ui.wizards.IClasspathContainerPageExtension;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;


public class LeJOSEV3LibContainerPage extends WizardPage 
               implements IClasspathContainerPage, IClasspathContainerPageExtension {

    private IPath _initPath;
    private Combo _dirCombo;

    /**
     * Default Constructor - sets title, page name, description
     */
    public LeJOSEV3LibContainerPage() {
        super("LeJOS EV3 Library Container", "LeJOS EV3 Library Container", null);
        setPageComplete(true);
    }
    
    
    public void initialize(IJavaProject project, IClasspathEntry[] currentEntries) {
        //_proj = project;
    }
    
    public void createControl(Composite parent) {
        Composite composite = new Composite(parent, SWT.NULL);
        composite.setLayout(new GridLayout());
        composite.setLayoutData(new GridData(GridData.VERTICAL_ALIGN_FILL
                | GridData.HORIZONTAL_ALIGN_FILL));
        composite.setFont(parent.getFont());
        
        createDirGroup(composite);
        
        setControl(composite);    
    }
    
    /**
     * Creates the directory label, combo, and browse button
     * 
     * @param parent the parent widget
     */
    private void createDirGroup(Composite parent) {
        Composite dirSelectionGroup = new Composite(parent, SWT.NONE);
        GridLayout layout= new GridLayout();
        layout.numColumns = 2;
        dirSelectionGroup.setLayout(layout);
        dirSelectionGroup.setLayoutData(new GridData(GridData.GRAB_HORIZONTAL| GridData.VERTICAL_ALIGN_FILL));

        new Label(dirSelectionGroup, SWT.NONE).setText("Select a platform: ");

        _dirCombo = new Combo(dirSelectionGroup, SWT.SINGLE | SWT.BORDER | SWT.READ_ONLY);
        int len = LeJOSEV3LibContainer.getOptionCount();
        for (int i=0; i<len; i++)
        	_dirCombo.add(LeJOSEV3LibContainer.getOptionName(i));
        _dirCombo.select(LeJOSEV3LibContainer.getOptionFromPath(_initPath));

        setControl(dirSelectionGroup);
    }
    
    public boolean finish() {
        return true;        
    }

    public IClasspathEntry getSelection() {
    	int i = this._dirCombo.getSelectionIndex();
        IPath containerPath = new Path(LeJOSEV3LibContainer.ID+"/"+LeJOSEV3LibContainer.getOptionKey(i));
        return JavaCore.newContainerEntry(containerPath);
    }

    public void setSelection(IClasspathEntry containerEntry) {
        if(containerEntry != null) {
            _initPath = containerEntry.getPath();
        }        
    }    
}
