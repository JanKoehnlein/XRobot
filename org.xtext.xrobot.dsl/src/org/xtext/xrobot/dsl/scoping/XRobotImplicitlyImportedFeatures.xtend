package org.xtext.xrobot.dsl.scoping

import org.eclipse.xtext.xbase.scoping.batch.ImplicitlyImportedFeatures
import org.xtext.xrobot.api.GeometryExtensions
import org.xtext.xrobot.api.IRobotGeometry

class XRobotImplicitlyImportedFeatures extends ImplicitlyImportedFeatures {
	
	override protected getExtensionClasses() {
		val result = super.getExtensionClasses
		result += Math
		result += GeometryExtensions
		result 
	}
	
	override protected getStaticImportClasses() {
		val result = super.getStaticImportClasses
		result += Math
		result += IRobotGeometry
		result
	}
	
}