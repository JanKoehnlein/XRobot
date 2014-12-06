/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
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