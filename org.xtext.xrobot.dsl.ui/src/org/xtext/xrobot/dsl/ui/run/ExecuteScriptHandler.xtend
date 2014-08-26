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
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.xtext.ui.editor.utils.EditorUtils
import org.eclipse.xtext.util.CancelIndicator
import org.xtext.xrobot.dsl.interpreter.ScriptRunner
import org.xtext.xrobot.dsl.ui.internal.XRobotDSLActivator
import org.xtext.xrobot.dsl.xRobotDSL.Program
import org.xtext.xrobot.server.RemoteRobotConnector

@Singleton
class ExecuteScriptHandler extends AbstractHandler {

	@Inject RemoteRobotConnector connector	
	
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
		if(robotName != null) {
			val runningJob = name2controller.get(robotName)
			if(runningJob != null) {
				try {
					runningJob.cancel
					runningJob.join
				} catch (Exception e) {
					MessageDialog.openError(xtextEditor.editorSite.shell, 'Error', 'Error canceling running job')
				}
			}
			val robot = connector.getRobot(robotName)
			if(robot == null) {
				MessageDialog.openError(xtextEditor.editorSite.shell, 'Error', 'Could not locate robot \'' + robotName + '\'')
			} else {
				val document = xtextEditor.document 
				val scriptName = document.readOnly [
					(contents.head as Program)?.name
				] 
				val model = document.get
				val job = new Job('Running script \'' + scriptName + '\' on robot \'' + robotName + '\'') {
					override protected run(IProgressMonitor monitor) {
						try {
							val runner = new ScriptRunner()
							runner.run(robot, model, new CancelIndicator() {
								override isCanceled() {
									monitor.isCanceled
								}
							})
							return Status.OK_STATUS
						} catch(Exception exc) {
							return new Status(IStatus.ERROR, XRobotDSLActivator.ORG_XTEXT_XROBOT_DSL_XROBOTDSL, exc.message, exc)
						}
					}
				}
				job.schedule
			} 
		}
		null
	}
}