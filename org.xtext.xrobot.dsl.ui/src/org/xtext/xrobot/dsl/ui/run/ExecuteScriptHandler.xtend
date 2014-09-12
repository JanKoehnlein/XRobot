package org.xtext.xrobot.dsl.ui.run

import com.google.inject.Inject
import com.google.inject.Provider
import com.google.inject.Singleton
import java.util.List
import java.util.Map
import java.util.SortedMap
import java.util.TreeMap
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.IStatus
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.jface.dialogs.Dialog
import org.eclipse.jface.dialogs.IDialogConstants
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.jface.viewers.IStructuredContentProvider
import org.eclipse.jface.viewers.ITableLabelProvider
import org.eclipse.jface.viewers.LabelProvider
import org.eclipse.jface.viewers.TableViewer
import org.eclipse.jface.viewers.Viewer
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.TableColumn
import org.eclipse.ui.IFileEditorInput
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.ui.editor.XtextEditor
import org.eclipse.xtext.ui.editor.utils.EditorUtils
import org.eclipse.xtext.ui.resource.IResourceSetProvider
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.dsl.interpreter.IRobotListener
import org.xtext.xrobot.dsl.interpreter.ScriptRunner
import org.xtext.xrobot.dsl.ui.internal.XRobotDSLActivator
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.server.IRobotState
import org.xtext.xrobot.server.RemoteRobotConnector
import org.xtext.xrobot.api.IRobot
import org.xtext.xrobot.server.RemoteRobot

@Singleton
class ExecuteScriptHandler extends AbstractHandler {

	@Inject RemoteRobotConnector connector

	@Inject Provider<ScriptRunner> scriptRunnerProvider

	@Inject IResourceSetProvider resourceSetProvider

	Map<String, Job> name2controller = newHashMap

	override execute(ExecutionEvent event) throws ExecutionException {
		val xtextEditor = EditorUtils.getActiveXtextEditor(event)
		val robotParameter = event.getParameter('org.xtext.xrobot.dsl.ui.robotParameter')
		val robotName = switch robotParameter {
			case "0",
			case "Xtend": 'Xtend'
			case "1",
			case "Xtext": 'Xtext'
			default: null
		}
		if (robotName != null) {
			val runningJob = name2controller.get(robotName)
			if (runningJob != null) {
				try {
					runningJob.cancel
					runningJob.join
				} catch (Exception e) {
					MessageDialog.openError(xtextEditor.editorSite.shell, 'Error', 'Error canceling running job')
				}
			}
			val robotFactory = connector.getRobotFactory(robotName)
			if (robotFactory == null) {
				MessageDialog.openError(xtextEditor.editorSite.shell, 'Error',
					'Could not locate robot \'' + robotName + '\'')
			} else {
				val document = xtextEditor.document
				val scriptName = document.readOnly [
					URI.trimFileExtension.lastSegment
				]
				val project = (xtextEditor.editorInput as IFileEditorInput).file.project
				val resourceSet = resourceSetProvider.get(project) as XtextResourceSet
				val model = document.get
				val dialog = new StateDialog(xtextEditor)
				val scriptRunner = scriptRunnerProvider.get
				scriptRunner.addRobotListener(dialog)
				val job = new Job('Running script \'' + scriptName + '\' on robot \'' + robotName + '\'') {
					override protected run(IProgressMonitor monitor) {
						try {
							Display.getDefault.asyncExec [
								dialog.open(monitor)
							]
							scriptRunner.run(robotFactory, model, resourceSet,
								new CancelIndicator() {
									override isCanceled() {
										monitor.isCanceled
									}
								})
							return Status.OK_STATUS
						} catch (Exception exc) {
							return new Status(IStatus.ERROR, XRobotDSLActivator.ORG_XTEXT_XROBOT_DSL_XROBOTDSL,
								exc.message, exc)
						} finally {
							try {
								robotFactory.release
								Display.getDefault.asyncExec [
									dialog.close
								]
							} catch (Exception exc) {
							}
						}
					}
				}
				job.schedule
			}
		}
		null
	}

	static class StateDialog extends Dialog implements IRobotListener {

		TableViewer tableViewer
		final SortedMap<String, String> content = new TreeMap

		XtextEditor editor

		IProgressMonitor monitor
	

		new(XtextEditor editor) {
			super(editor.site.shell)
			this.editor = editor
			blockOnOpen = false
		}

		override protected createDialogArea(Composite parent) {
			val composite = super.createDialogArea(parent) as Composite
			tableViewer = new TableViewer(composite)
			new TableColumn(tableViewer.table, SWT.NONE) => [
				width = 150
			]
			new TableColumn(tableViewer.table, SWT.NONE) => [
				width = 150
			]
			tableViewer.contentProvider = new IStructuredContentProvider {
				override getElements(Object inputElement) {
					val map = inputElement as SortedMap<String, String>
					map.entrySet.map[#[it.key, it.value]]
				}
				override dispose() {}
				override inputChanged(Viewer viewer, Object oldInput, Object newInput) {}
			}
			tableViewer.labelProvider = new TableLabelProvider
			tableViewer.input = content
			tableViewer.control.layoutData = new GridData(GridData.FILL_BOTH) => [
				minimumHeight = 300
			]
			composite
		}

		override protected createButtonsForButtonBar(Composite parent) {
			createButton(parent, IDialogConstants.CANCEL_ID, IDialogConstants.CANCEL_LABEL, false);
		}

		def open(IProgressMonitor monitor) {
			open()
			this.monitor = monitor
		}

		override protected cancelPressed() {
			monitor.canceled = true
			super.cancelPressed()
		}

		override modeChanged(Mode newMode) {
			Display.getDefault.asyncExec [
				content.put('Mode', newMode.name)
				tableViewer.refresh
			]
		}

		override stateChanged(RemoteRobot robot) {
			Display.getDefault.asyncExec [
				content.put('Opponent detected', robot.robotSight.detected.toString)
				content.put('Opponent distance', robot.robotSight.distance.toString)
				content.put('Opponent angle', robot.robotSight.angle.toString)
				content.put('Battery', ((robot.state.batteryState * 100) as int).toString +'%')
				content.put('isMoving', robot.state.moving.toString)
				tableViewer.refresh
			]
		}
		
		override variableChanged(String name, Object value) {
			Display.getDefault.asyncExec [
				content.put(name, value.toString)
				tableViewer.refresh
			]
		}

		override lineChanged(int line) {
			val region = editor.document.getLineInformation(line - 1)
			editor.setHighlightRange(region.offset, region.length, false)
		}
	
		static class TableLabelProvider extends LabelProvider implements ITableLabelProvider {
			
			override getColumnImage(Object element, int columnIndex) {
				null
			}
			
			override getColumnText(Object element, int columnIndex) {
				val list = element as List<String>
				list.get(columnIndex)
			}
			
		}

	}

}
