package org.xtext.xrobot.dsl.ui.run

import com.google.inject.Inject
import com.google.inject.Provider
import com.google.inject.Singleton
import java.util.List
import java.util.Map
import java.util.SortedMap
import java.util.TreeMap
import org.apache.log4j.Logger
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
import org.xtext.xrobot.RobotID
import org.xtext.xrobot.dsl.interpreter.IRobotListener
import org.xtext.xrobot.dsl.interpreter.ScriptParser
import org.xtext.xrobot.dsl.interpreter.ScriptRunner
import org.xtext.xrobot.dsl.ui.internal.XRobotDSLActivator
import org.xtext.xrobot.dsl.xRobotDSL.Mode
import org.xtext.xrobot.server.IRemoteRobot
import org.xtext.xrobot.server.RemoteRobot
import org.xtext.xrobot.api.IArena

@Singleton
class ExecuteScriptHandler extends AbstractHandler {

	static val LOG = Logger.getLogger(ExecuteScriptHandler)

	@Inject IRemoteRobot.Connector connector

	@Inject IResourceSetProvider resourceSetProvider

	@Inject ScriptParser scriptParser

	@Inject Provider<ScriptRunner> scriptRunnerProvider

	val Map<RobotID, Job> id2controller = newHashMap
	
	volatile boolean gameOver

	override execute(ExecutionEvent event) throws ExecutionException {
		val xtextEditor = EditorUtils.getActiveXtextEditor(event)
		val robotName = event.getParameter('org.xtext.xrobot.dsl.ui.robotParameter')
		if (robotName != null) {
			val robotID = RobotID.valueOf(robotName)
			val runningJob = id2controller.get(robotName)
			if (runningJob != null) {
				try {
					runningJob.cancel
					runningJob.join
				} catch (Exception e) {
					MessageDialog.openError(xtextEditor.editorSite.shell, 'Error', 'Error canceling running job')
				}
			}
			var IRemoteRobot.Factory tempRobotFactory = null
			try {
				tempRobotFactory = connector.getRobotFactory(robotID)
			} catch (Exception exc) {
				MessageDialog.openError(xtextEditor.editorSite.shell, 'Error', '''
					Could not locate robot '«robotName»':
					«exc.message»
					See log for details.
				''')
				LOG.error(exc)
				return null
			}
			val robotFactory = tempRobotFactory
			val document = xtextEditor.document
			val scriptName = document.readOnly [
				URI.trimFileExtension.lastSegment
			]
			val file = (xtextEditor.editorInput as IFileEditorInput).file
			val project = file.project
			val resourceSet = resourceSetProvider.get(project) as XtextResourceSet
			val model = document.get
			val dialog = new StateDialog(xtextEditor)
			val scriptRunner = scriptRunnerProvider.get
			scriptRunner.addRobotListener(dialog)
			scriptRunner.addRobotListener(new IRobotListener {
				override stateRead(IRemoteRobot robot) { }
				override modeChanged(IRemoteRobot robot, Mode newMode) { }
				override stateChanged(IRemoteRobot robot) {
					if (robot.centerDirection.distance > IArena.ARENA_OUTER_RADIUS || robot.isDead) {
						gameOver = true
					}
				}
				override variableChanged(String name, Object value) { }
				override lineChanged(int line) { }
			})
			val job = new Job('Running script \'' + scriptName + '\' on robot \'' + robotName + '\'') {
				override protected run(IProgressMonitor monitor) {
					try {
						Display.getDefault.asyncExec [
							dialog.open(monitor)
						]
						val program = scriptParser.parse(model, resourceSet)
						gameOver = false
						scriptRunner.run(program, robotFactory,
							new CancelIndicator() {
								override isCanceled() {
									monitor.isCanceled || gameOver
								}
							})
						return Status.OK_STATUS
					} catch (Exception exc) {
						return new Status(IStatus.ERROR, XRobotDSLActivator.ORG_XTEXT_XROBOT_DSL_XROBOTDSL,
							exc.message, exc)
					} finally {
						robotFactory.release
						Display.getDefault.asyncExec [
							dialog.close
						]
					}
				}
			}
			job.schedule
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

		override modeChanged(IRemoteRobot robot, Mode newMode) {		
			Display.getDefault.asyncExec [
				content.put('Mode', newMode.name)
				tableViewer.refresh
			]
		}

		override stateChanged(IRemoteRobot robot) {
			Display.getDefault.asyncExec [
				content.put('Position', '''
					x=«robot.ownPosition.x as int» y=«robot.ownPosition.y as int» a=«robot.ownPosition.viewDirection as int»
				''')
				content.put('Opponent position', '''
					x=«robot.opponentPosition.x as int» y=«robot.opponentPosition.y as int» a=«robot.opponentPosition.viewDirection as int»
				''')
				content.put('Opponent distance', robot.opponentDirection.distance.toString)
				content.put('Opponent angle', robot.opponentDirection.angle.toString)
				content.put('Battery', ((robot.batteryState * 100) as int).toString + '%')
				content.put('isMoving', robot.moving.toString)
				content.put('Command number', (robot as RemoteRobot).state.lastExecutedCommandSerialNr.toString)
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
		
		override stateRead(IRemoteRobot robot) {
		}
	}

}
