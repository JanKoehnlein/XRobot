package org.xtext.xrobot.dsl.scoping

import org.eclipse.xtext.xbase.scoping.batch.ImplicitlyImportedFeatures

class XRobotImplicitlyImportedFeatures extends ImplicitlyImportedFeatures {
	
	override protected getExtensionClasses() {
		val result = super.getExtensionClasses
		result += Math
		result 
	}
	
	override protected getStaticImportClasses() {
		val result = super.getStaticImportClasses
		result += Math
		result
	}
	
}