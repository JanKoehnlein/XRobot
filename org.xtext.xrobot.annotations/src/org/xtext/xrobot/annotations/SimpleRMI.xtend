package org.xtext.xrobot.annotations

import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active

/**
 * Main annotation for remote method invocation through a socket connection.
 */
@Target(ElementType.TYPE)
@Active(SimpleRemoteProcessor)
@Retention(RetentionPolicy.SOURCE)
annotation SimpleRMI {
}

/**
 * This annotation marks a command that should not be visible in the API. It is used for data
 * that is accessed internally and is not needed by users.
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
annotation NoAPI {
}

/**
 * This annotation marks data that is calculated on the server, hence it does not need to
 * be transferred from the client.
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
annotation Calculated {
}

/**
 * This annotation marks a command that can be invoked even when the robot is already dead.
 * The cancel indicator is not queried in such commands.
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
annotation Zombie {
}

/**
 * This annotation marks a blocking command. Once such a command is started, no further
 * commands are executed until the blocking command has finished or is canceled. 
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.SOURCE)
annotation Blocking {
	String value = 'getMoving'
}

/**
 * This annotation marks a field that shall be exposed as a subcomponent.
 */
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.SOURCE)
annotation SubComponent {
}
