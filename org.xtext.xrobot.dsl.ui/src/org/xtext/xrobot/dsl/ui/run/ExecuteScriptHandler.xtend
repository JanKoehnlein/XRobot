package org.xtext.xrobot.dsl.ui.run

import com.google.inject.Inject
import com.google.inject.Singleton
import java.util.Map
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
import org.eclipse.swt.SWT
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.Label
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
import com.google.inject.Provider

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

		Label opponentDistance
		Label mode
		Label opponentAngle
		Label battery
		Label isMoving

		XtextEditor editor

		IProgressMonitor monitor
	

		new(XtextEditor editor) {
			super(editor.site.shell)
			this.editor = editor
			blockOnOpen = false
		}

		override protected createDialogArea(Composite parent) {
			val composite = new Composite(parent, SWT.NONE)
			composite.layout = new GridLayout(2, true)
			new Label(composite, SWT.NONE) => [
				text = 'Mode'
			]
			mode = new Label(composite, SWT.NONE) => [
				layoutData = new GridData(SWT.FILL,SWT.FILL,true,true)
			]
			new Label(composite, SWT.NONE) => [
				text = 'Opponent distance'
			]
			opponentDistance = new Label(composite, SWT.NONE) => [
				layoutData = new GridData(SWT.FILL,SWT.FILL,true,true)
			]
			new Label(composite, SWT.NONE) => [
				text = 'Opponent angle'
			]
			opponentAngle = new Label(composite, SWT.NONE)=> [
				layoutData = new GridData(SWT.FILL,SWT.FILL,true,true)
			]
			new Label(composite, SWT.NONE) => [
				text = 'isMoving'
			]
			isMoving = new Label(composite, SWT.NONE)=> [
				layoutData = new GridData(SWT.FILL,SWT.FILL,true,true)
			]
			new Label(composite, SWT.NONE) => [
				text = 'Battery'
			]
			battery = new Label(composite, SWT.NONE)=> [
				layoutData = new GridData(SWT.FILL,SWT.FILL,true,true)
			]
			composite
		}

		override stateChanged(IRobotState newState) {
			Display.getDefault.asyncExec [
				opponentDistance.text = newState.opponentPosition.rawDistance.toString
				opponentAngle.text = newState.opponentPosition.rawAngular.toString
				battery.text = (newState.batteryState * 100 as int).toString +'%'
				isMoving.text = newState.moving.toString
			]
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
				mode.text = newMode.name
			]
		}

		override lineChanged(int line) {
			val region = editor.document.getLineInformation(line - 1)
			editor.setHighlightRange(region.offset, region.length, false)
		}

	}

}
