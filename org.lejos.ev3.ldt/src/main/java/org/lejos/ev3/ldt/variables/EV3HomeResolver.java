package org.lejos.ev3.ldt.variables;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.variables.IDynamicVariable;
import org.eclipse.core.variables.IDynamicVariableResolver;
import org.lejos.ev3.ldt.LeJOSEV3Plugin;
import org.lejos.ev3.ldt.util.LeJOSEV3Exception;
import org.lejos.ev3.ldt.util.LeJOSEV3Util;

public class EV3HomeResolver implements IDynamicVariableResolver {

	public String resolveValue(IDynamicVariable variable, String argument) throws CoreException
	{
		try {
			return LeJOSEV3Util.getEV3Home().getAbsolutePath();
		} catch (LeJOSEV3Exception e) {
			throw new CoreException(new Status(IStatus.ERROR, LeJOSEV3Plugin.ID, "could not determine EV3_HOME", e));
		}
	}
}
