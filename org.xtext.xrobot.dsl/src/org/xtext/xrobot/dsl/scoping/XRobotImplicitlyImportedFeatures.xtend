package org.xtext.xrobot.dsl.scoping

import org.eclipse.xtext.xbase.scoping.batch.ImplicitlyImportedFeatures
import org.xtext.xrobot.api.GeometryExtensions
import org.xtext.xrobot.api.Sample

class XRobotImplicitlyImportedFeatures extends ImplicitlyImportedFeatures {
	
	/**
	 * Reduce inference time for binary operations by skipping some overloaded 
	 * variants that will not be needed
	 */
	override protected getExtensionClasses() {
		newArrayList(
			ArrayExtensions,
//			BigDecimalExtensions,
//			BigIntegerExtensions,
			BooleanExtensions,
//			ByteExtensions,
//			CharacterExtensions,
			CollectionExtensions,
			ComparableExtensions,
			DoubleExtensions,
//			FloatExtensions,
			FunctionExtensions,
			IntegerExtensions,
			IterableExtensions,
			IteratorExtensions,
			ListExtensions,
			LongExtensions,
			MapExtensions,
			ObjectExtensions,
			ProcedureExtensions,
//			ShortExtensions,
			StringExtensions,
			Math, 
			GeometryExtensions)
	}
	
	override protected getStaticImportClasses() {
		val result = super.getStaticImportClasses
		result += Math
		result += Sample
		result += GeometryExtensions
		result
	}
	
	
}