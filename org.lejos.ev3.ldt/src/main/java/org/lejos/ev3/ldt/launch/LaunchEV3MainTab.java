package org.lejos.ev3.ldt.launch;

import java.util.ArrayList;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchConfigurationWorkingCopy;
import org.eclipse.jdt.core.IClassFile;
import org.eclipse.jdt.core.ICompilationUnit;
import org.eclipse.jdt.core.IJavaElement;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IMember;
import org.eclipse.jdt.core.IType;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.core.search.IJavaSearchScope;
import org.eclipse.jdt.core.search.SearchEngine;
import org.eclipse.jdt.debug.ui.launchConfigurations.JavaLaunchTab;
import org.eclipse.jdt.launching.IJavaLaunchConfigurationConstants;
import org.eclipse.jdt.ui.ISharedImages;
import org.eclipse.jdt.ui.JavaElementLabelProvider;
import org.eclipse.jdt.ui.JavaUI;
import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.jface.window.Window;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.dialogs.ElementListSelectionDialog;
import org.lejos.ev3.ldt.LeJOSEV3Nature;
import org.lejos.ev3.ldt.util.LeJOSEV3Util;

public class LaunchEV3MainTab extends JavaLaunchTab {
	
	private static class LabelText
	{
		Label label;
		Text text;
		Color textBackground;
		
		public LabelText(Composite parent, String labelText, ModifyListener updater) {
			GridLayout gl = new GridLayout(2, false);
			Composite c = new Composite(parent, SWT.NONE);
			c.setFont(parent.getFont());
			c.setLayout(gl);
			
			label = new Label(c, SWT.NONE);
			label.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
			label.setFont(c.getFont());
			label.setText(labelText);
			
			GridData gd = new GridData(GridData.FILL_HORIZONTAL);
			gd.minimumWidth = 100;
			
			text = new Text(c, SWT.SINGLE | SWT.BORDER);
			text.setLayoutData(gd);
			text.setFont(c.getFont());
			text.addModifyListener(updater);
			
			textBackground = text.getBackground();
		}
		
		void setEnabled(boolean b) {
			this.label.setEnabled(b);
			this.text.setEditable(b);
			this.text.setBackground(b ? this.textBackground : this.label.getBackground());
		}
	}

	private Text projectText;
	private Text mainClassText;
	private Button projectSearch;
	private Button mainClassSearch;
	
	private Button normalUseDefaults;
	private Button normalRun;
	private Button debugUseDefaults;
	private Button debugRun;
	private Button debugMonitorNormal;
	private Button targetUseDefaults;
	private Button targetConnectByName;
	private LabelText targetBrickName;
	private Button debugMonitorJdwp;
	
	private static IWorkspaceRoot getRoot()
	{
		return ResourcesPlugin.getWorkspace().getRoot();
	}
	
	private static IJavaProject[] getLejosProjects() throws CoreException
	{
		IProject[] projects = getRoot().getProjects();
		ArrayList<IJavaProject> projects2 = new ArrayList<IJavaProject>();
		for (IProject p : projects)
			if (p.exists() && p.isOpen() && p.getProject().isNatureEnabled(LeJOSEV3Nature.ID))
				projects2.add(JavaCore.create(p));
		
		return projects2.toArray(new IJavaProject[projects2.size()]);
	}
	
	private void handleProjectButtonSelected()
	{
		ILabelProvider labelProvider= new JavaElementLabelProvider(JavaElementLabelProvider.SHOW_DEFAULT);
		ElementListSelectionDialog dialog= new ElementListSelectionDialog(getShell(), labelProvider);
		dialog.setTitle("Select Project");
		dialog.setMessage("Select a LeJOS Project"); 
		try
		{
			dialog.setElements(getLejosProjects());
		}
		catch (CoreException jme)
		{
			LeJOSEV3Util.log(jme);
		}
		IJavaProject javaProject= getJavaProject();
		if (javaProject != null)
			dialog.setInitialSelections(new Object[] { javaProject });
		
		if (dialog.open() == Window.OK)
		{
			IJavaProject project = (IJavaProject) dialog.getFirstResult();
			projectText.setText(project.getElementName());
		}
	}
	
	private IProject getProject()
	{
		String name = projectText.getText().trim();
		if (name.length() <= 0)
			return null;
		
		return getRoot().getProject(name);
	}
	
	private IJavaProject getJavaProject()
	{
		return JavaCore.create(getProject());		
	}
	
	private void handleSearchButtonSelected()
	{
		IJavaProject project = getJavaProject();
		IJavaElement[] elements;
		try
		{
			if (project != null && project.exists() && project.isOpen())
				elements = new IJavaElement[] { project };
			else
				elements = getLejosProjects();
		}
		catch (CoreException e)
		{
			LeJOSEV3Util.log(e);
			elements = new IJavaElement[]{};
		}
		
		int constraints = IJavaSearchScope.SOURCES;
		// constraints |= IJavaSearchScope.APPLICATION_LIBRARIES;
		IJavaSearchScope searchScope = SearchEngine.createJavaSearchScope(elements, constraints);
		MainMethodSearchHelper engine = new MainMethodSearchHelper();
		ArrayList<IType> result = new ArrayList<IType>();
		try
		{
			engine.searchMainMethods(getLaunchConfigurationDialog(), searchScope, result);
		}
		catch (CoreException e)
		{
			setErrorMessage(e.getMessage());
			return;
		}
		catch (InterruptedException e)
		{
			setErrorMessage(e.getMessage());
			return;
		}
		MainTypeSelectDialog mtsd = new MainTypeSelectDialog(getShell(), result, "Select Main Class");
		IType type = mtsd.openAndGetResult();
		if (type == null)
			return;
		
		projectText.setText(type.getJavaProject().getElementName());
		mainClassText.setText(type.getFullyQualifiedName());
	}	

	private void createProjectEditor(Composite parent, ModifyListener updater)
	{
		Group g = newGroup(parent, 2, "&Project:");
		
		Text t = new Text(g, SWT.SINGLE | SWT.BORDER);
		t.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
		t.setFont(g.getFont());
		
		projectText = t;
		projectText.addModifyListener(updater);
		projectSearch = createPushButton(g, "&Browse...", null); 
		projectSearch.addSelectionListener(new SelectionAdapter()
			{
				@Override
				public void widgetSelected(SelectionEvent e)
				{
					handleProjectButtonSelected();
				}
			});
	}
	
	private void createMainTypeEditor(Composite parent, ModifyListener updater)
	{
		Group g = newGroup(parent, 2, "&Main Class:");
		
		Text t = new Text(g, SWT.SINGLE | SWT.BORDER);
		t.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
		t.setFont(g.getFont());
		
		mainClassText = t;
		mainClassText.addModifyListener(updater);
		mainClassSearch = createPushButton(g, "&Search...", null); 
		mainClassSearch.addSelectionListener(new SelectionAdapter()
			{
				@Override
				public void widgetSelected(SelectionEvent e) {
					handleSearchButtonSelected();
				}
			});
	}
	
	@Override
	public Image getImage()
	{
		return JavaUI.getSharedImages().getImage(ISharedImages.IMG_OBJS_CLASS);
	}
	
	public String getName()
	{
		return "Main";
	}

	public void createControl(Composite parent)
	{
		Composite comp = new Composite(parent, SWT.NONE);
		comp.setFont(parent.getFont());
		GridLayout gl = new GridLayout(1, false);
		gl.verticalSpacing = 0;
		comp.setLayout(gl);
		GridData gd = new GridData(GridData.FILL_BOTH);
		gd.horizontalSpan = 1;
		comp.setLayoutData(gd);
		
		ModifyListener updater = new ModifyListener()
			{
				public void modifyText(ModifyEvent e)
				{
				    //TODO display error, if project is not a leJOS project
					updateLaunchConfigurationDialog();
				}
			};
			
		SelectionListener updater2 = new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				updateLaunchConfigurationDialog();
				updateEnabledDisabled();
			}
		};
				
		createProjectEditor(comp, updater);
		createVerticalSpacer(comp, 1);
		createMainTypeEditor(comp, updater);
		createVerticalSpacer(comp, 1);
		createOptionEditor(comp, updater, updater2);
		
		
		setControl(comp);
	}
	
	private void updateEnabledDisabled() {
		boolean e = !this.targetUseDefaults.getSelection();
		this.targetConnectByName.setEnabled(e);
		this.targetBrickName.setEnabled(e);
		
		e = !this.normalUseDefaults.getSelection();
		this.normalRun.setEnabled(e);
		
		e = !this.debugUseDefaults.getSelection();
		this.debugRun.setEnabled(e);
		this.debugMonitorNormal.setEnabled(e);
		this.debugMonitorJdwp.setEnabled(e);
	}

	private Group newGroup(Composite p, int cols, String text)
	{
		Group g = new Group(p, SWT.NONE);
		g.setLayout(new GridLayout(cols, false));
		g.setText(text);
		g.setFont(p.getFont());
		GridData gd1 = new GridData(GridData.FILL_HORIZONTAL);
		g.setLayoutData(gd1);
		return g;
	}

	private void createOptionEditor(Composite parent, ModifyListener updater2, SelectionListener updater)
	{
		GridData gd = new GridData();
		gd.horizontalSpan = 2;
		
		Group g = newGroup(parent, 2, "Target EV3:");
		this.targetUseDefaults = createCheckButton(g, "Use &defaults from Preferences");
		Composite c = new Composite(g, SWT.NONE);
		c.setLayout(new GridLayout(3, false));
		c.setLayoutData(gd);
		this.targetConnectByName = createCheckButton(g, "Connect to name");
		this.targetBrickName = new LabelText(g, "Name", updater2);
		
		this.targetUseDefaults.addSelectionListener(updater);
		this.targetConnectByName.addSelectionListener(updater);
		this.targetUseDefaults.setLayoutData(gd);

		createVerticalSpacer(parent, 1);
		g = newGroup(parent, 2, "When in run mode:");

		this.normalUseDefaults = createCheckButton(g, "Use &defaults from Preferences");
		this.normalRun = createCheckButton(g, "&Run program after upload");
		
		this.normalUseDefaults.addSelectionListener(updater);
		this.normalRun.addSelectionListener(updater);
		this.normalUseDefaults.setLayoutData(gd);
		
		createVerticalSpacer(parent, 1);
		g = newGroup(parent, 2, "When in debug mode:");

		this.debugUseDefaults = createCheckButton(g, "Use &defaults from Preferences");
		this.debugRun = createCheckButton(g, "&Run program after upload");

		this.debugUseDefaults.addSelectionListener(updater);
		this.debugRun.addSelectionListener(updater);
		this.debugUseDefaults.setLayoutData(gd);
		
		this.debugMonitorNormal = createRadioButton(g, "Normal Debug Monitor");
		this.debugMonitorJdwp = createRadioButton(g, "Remote Debug Monitor (will start eclipse debugger)");
		this.debugMonitorJdwp.setLayoutData(gd);
		
		this.debugMonitorNormal.addSelectionListener(updater);
		this.debugMonitorJdwp.addSelectionListener(updater);
	}

	public void setDefaults(ILaunchConfigurationWorkingCopy config)
	{
		
		IJavaElement context = getContext();
		if (context != null)
			initializeJavaProject(context, config);
		else
			config.setAttribute(IJavaLaunchConfigurationConstants.ATTR_PROJECT_NAME, "");
		
		if (context instanceof IMember) {
			IMember member = (IMember)context;
			if (member.isBinary())
				context = member.getClassFile();
			else
				context = member.getCompilationUnit();
		}
		if (context instanceof ICompilationUnit || context instanceof IClassFile) {
			IJavaSearchScope scope = SearchEngine.createJavaSearchScope(new IJavaElement[]{ context }, false);
			ArrayList<IType> result = new ArrayList<IType>();
			MainMethodSearchHelper helper = new MainMethodSearchHelper();
			try {
				helper.searchMainMethods(getLaunchConfigurationDialog(), scope, result);				
			}
			catch (InterruptedException e)
			{
				LeJOSEV3Util.log(e);
			}
			catch (CoreException e)
			{
				LeJOSEV3Util.log(e);
			}
			if (!result.isEmpty()) {
				// Simply grab the first main type found in the searched element
				IType mainType = result.get(0);
				config.setAttribute(IJavaLaunchConfigurationConstants.ATTR_MAIN_TYPE_NAME, mainType.getFullyQualifiedName());
				// JDT uses mainType.getTypeQualifiedName('$'), but that is not consistent with the launch short cut 
				String name = getLaunchConfigurationDialog().generateName(mainType.getTypeQualifiedName('.'));
				config.rename(name);
			}
		}
	}

	@Override
	public boolean isValid(ILaunchConfiguration config)
	{
		setErrorMessage(null);
		setMessage(null);
		String pname = projectText.getText().trim();
		if (pname.length() <= 0)
		{
			setErrorMessage("Project not specified"); 
			return false;
		}
		IWorkspace workspace = ResourcesPlugin.getWorkspace();
		IStatus status = workspace.validateName(pname, IResource.PROJECT);
		if (!status.isOK())
		{
			setErrorMessage("Illegal project name: "+pname); 
			return false;
		}
		IProject project= workspace.getRoot().getProject(pname);
		if (!project.exists())
		{
			setErrorMessage("Project "+pname+" does not exist"); 
			return false;
		}
		if (!project.isOpen())
		{
			setErrorMessage("Project "+pname+" is closed"); 
			return false;
		}
		String mname = mainClassText.getText().trim();
		if (mname.length() <= 0)
		{
			setErrorMessage("Main type not specified"); 
			return false;
		}
		return true;
	}
	
	public void performApply(ILaunchConfigurationWorkingCopy config)
	{
		config.setAttribute(IJavaLaunchConfigurationConstants.ATTR_PROJECT_NAME, projectText.getText().trim());
		config.setAttribute(IJavaLaunchConfigurationConstants.ATTR_MAIN_TYPE_NAME, mainClassText.getText().trim());
		
		this.updateMappedResource(config);
	}
	
	private static IResource getMainResource(ILaunchConfiguration candidate) throws CoreException
	{
		String pname = candidate.getAttribute(IJavaLaunchConfigurationConstants.ATTR_PROJECT_NAME, "");
		if (pname.length() > 0)
		{
			IProject project = getRoot().getProject(pname);
			String mname = candidate.getAttribute(IJavaLaunchConfigurationConstants.ATTR_MAIN_TYPE_NAME, "");
			if (mname.length() > 0)
			{
				if (project != null && project.exists() && project.isOpen()) {
					IJavaProject jproject = JavaCore.create(project);
					if (jproject != null && jproject.exists() && jproject.isOpen()) {
						// replace $ with . for nested classes 
						IType type = jproject.findType(mname.replace('$', '.'));
						if (type != null) {
							return type.getUnderlyingResource();
						}
					}
				}
			}
			return project;
		}
		return null;
	}

	private void updateMappedResource(ILaunchConfigurationWorkingCopy config) {
		try
		{
			IResource resource = getMainResource(config);
			IResource[] resources;
			if (resource == null)
				resources = null;
			else
				resources = new IResource[] { resource };
			
			config.setMappedResources(resources);
		}
		catch (CoreException ce)
		{
			setErrorMessage(ce.getMessage());
		}
	}
	
	@Override
	public void initializeFrom(ILaunchConfiguration config)
	{
		super.initializeFrom(config);
		projectText.setText(extractConfigValue(config, IJavaLaunchConfigurationConstants.ATTR_PROJECT_NAME, ""));
		mainClassText.setText(extractConfigValue(config, IJavaLaunchConfigurationConstants.ATTR_MAIN_TYPE_NAME, ""));
		
		updateEnabledDisabled();
	}
	
	private boolean extractConfigBool(ILaunchConfiguration config, String key, boolean def)
	{
		boolean r;
		try
		{
			r = config.getAttribute(key, def);
		}
		catch (CoreException ce)
		{
			setErrorMessage(ce.getMessage());
			r = def;
		}
		return r;
	}

	private String extractConfigValue(ILaunchConfiguration config, String key, String def)
	{
		String r;
		try
		{
			r = config.getAttribute(key, def);
		}
		catch (CoreException ce)
		{
			setErrorMessage(ce.getMessage());
			r = def;
		}
		return r;
	}
}
