package org.lejos.ev3.ldt.preferences;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.Path;
import org.eclipse.jdt.core.ClasspathContainerInitializer;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jface.dialogs.IDialogConstants;
import org.eclipse.jface.preference.BooleanFieldEditor;
import org.eclipse.jface.preference.DirectoryFieldEditor;
import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.StringFieldEditor;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;
import org.lejos.ev3.ldt.LeJOSEV3Plugin;
import org.lejos.ev3.ldt.container.LeJOSEV3LibContainer;
import org.lejos.ev3.ldt.util.LeJOSEV3Util;

/**
 * This class represents a preference page that is contributed to the
 * Preferences dialog.
 * 
 * @author Matthias Paul Scholz and Lawrie Griffiths
 */

public class PreferencePage extends FieldEditorPreferencePage implements
		IWorkbenchPreferencePage {

	public PreferencePage() {
		super(FLAT);
		setPreferenceStore(LeJOSEV3Plugin.getDefault().getPreferenceStore());
		setDescription("Preferences for leJOS EV3");
	}
	
	private Composite newParent(Composite g, int cols)
	{
		GridData gd = new GridData();
		gd.horizontalSpan = cols;
		Composite p = new Composite(g, SWT.NONE);
		p.setFont(g.getFont());
		p.setLayoutData(gd);
		return p;
	}

	private Composite newParentF(Composite g, int cols)
	{
		GridData gd = new GridData(GridData.FILL_HORIZONTAL);
		gd.horizontalSpan = cols;
		Composite p = new Composite(g, SWT.NONE);
		p.setFont(g.getFont());
		p.setLayoutData(gd);
		return p;
	}

	public Group createGroup(Composite parent, int cols, String text) {
		GridLayout gl = new GridLayout(cols, false);
		gl.horizontalSpacing= convertHorizontalDLUsToPixels(IDialogConstants.HORIZONTAL_SPACING);
		gl.verticalSpacing= convertVerticalDLUsToPixels(IDialogConstants.VERTICAL_SPACING);
		gl.marginWidth= convertHorizontalDLUsToPixels(IDialogConstants.HORIZONTAL_MARGIN);
		gl.marginHeight= convertVerticalDLUsToPixels(IDialogConstants.VERTICAL_MARGIN);
		GridData gd = new GridData(GridData.FILL_HORIZONTAL);
		gd.horizontalSpan = 3;
		Group g = new Group(parent, SWT.NONE);		
		g.setLayoutData(gd);
		g.setLayout(gl);
		g.setText(text);
		return g;
	}
	
	/**
	 * Creates the field editors. Field editors are abstractions of the common
	 * GUI blocks needed to manipulate various types of preferences. Each field
	 * editor knows how to save and restore itself.
	 */
	@Override
	public void createFieldEditors() {
		Composite parent = getFieldEditorParent();
		initializeDialogUnits(parent);

		// EV3_HOME
		addField(new DirectoryFieldEditor(PreferenceConstants.KEY_EV3_HOME,
				"&EV3_HOME:", parent));
		
		Composite p2 = newParent(parent, 3);
		addField(new BooleanFieldEditor(PreferenceConstants.KEY_SEPARATE_JVM,
				"&Run Tools in separate JVM", p2));
		
		addField(new BooleanFieldEditor(PreferenceConstants.KEY_SSH_SCP,
				"&Use ssh and scp", p2));
		
		Group g = createGroup(parent, 2, "Defaults for run configurations:");

		// connect to named EV3?
		addField(new BooleanFieldEditor(PreferenceConstants.KEY_TARGET_CONNECT_BY_NAME,
				"Connect to &named brick", newParent(g, 1)));
		addField(new StringFieldEditor(PreferenceConstants.KEY_TARGET_BRICK_NAME,
				"&Name", newParentF(g, 1)));
		
		g = createGroup(parent, 2, "Defaults for run mode");
		
		addField(new BooleanFieldEditor(PreferenceConstants.KEY_NORMAL_RUN_AFTER_UPLOAD,
				"&Run program after upload", newParent(g, 1)));
		
	}

	@Override
	public boolean performOk() {
		boolean b = super.performOk();
		
		ClasspathContainerInitializer init = JavaCore.getClasspathContainerInitializer(LeJOSEV3LibContainer.ID);
		Path p1 = new Path(LeJOSEV3LibContainer.ID+"/"+LeJOSEV3Util.LIBSUBDIR_EV3);
		Path p2 = new Path(LeJOSEV3LibContainer.ID+"/"+LeJOSEV3Util.LIBSUBDIR_PC);
		
		IWorkspace ws = ResourcesPlugin.getWorkspace();
		IWorkspaceRoot wsr = ws.getRoot();
		IProject[] projects = wsr.getProjects();
		for (IProject p : projects)
		{
			try
			{
				if (p.isOpen() && p.isNatureEnabled(JavaCore.NATURE_ID))
				{
					IJavaProject jp = JavaCore.create(p);
					if (JavaCore.getClasspathContainer(p1, jp) != null)
						init.initialize(p1, jp);
					if (JavaCore.getClasspathContainer(p2, jp) != null)
						init.initialize(p2, jp);
				}
			}
			catch (Exception e)
			{
				LeJOSEV3Util.log(e);
			}
		}
		
		return b;
	}

	public void init(IWorkbench workbench) {
		// do nothing
	}

}