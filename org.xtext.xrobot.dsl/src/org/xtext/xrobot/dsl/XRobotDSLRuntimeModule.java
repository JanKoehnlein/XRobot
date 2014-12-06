/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.dsl;

import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.resource.IDefaultResourceDescriptionStrategy;
import org.eclipse.xtext.xbase.imports.IImportsConfiguration;
import org.eclipse.xtext.xbase.scoping.XImportSectionNamespaceScopeProvider;
import org.eclipse.xtext.xbase.scoping.batch.FeatureScopes;
import org.eclipse.xtext.xbase.scoping.batch.ImplicitlyImportedFeatures;
import org.xtext.xrobot.dsl.imports.XRobotImportsConfiguration;
import org.xtext.xrobot.dsl.scoping.XRobotFeatureScopes;
import org.xtext.xrobot.dsl.scoping.XRobotImplicitlyImportedFeatures;
import org.xtext.xrobot.dsl.scoping.XRobotImportedNamespaceScopeProvider;
import org.xtext.xrobot.dsl.scoping.XRobotResourceDescriptionStrategy;

/**
 * Use this class to register components to be used at runtime / without the Equinox extension registry.
 */
public class XRobotDSLRuntimeModule extends org.xtext.xrobot.dsl.AbstractXRobotDSLRuntimeModule {

	public Class<? extends ImplicitlyImportedFeatures> bindImplicitlyImportedFeatures() {
		return XRobotImplicitlyImportedFeatures.class;
	}
	
	public Class<? extends IDefaultResourceDescriptionStrategy> bindIDefaultResourceDescriptionStrategy() {
		return XRobotResourceDescriptionStrategy.class;
	}
	
	public Class<? extends IGenerator> bindIGenerator() {
		return IGenerator.NullGenerator.class;
	}
	
	public Class<? extends FeatureScopes> bindFeatureScopes() {
		return XRobotFeatureScopes.class;
	}
	
	public Class<? extends IImportsConfiguration> bindIImportsConfiguration() {
		return XRobotImportsConfiguration.class;
	}
	
	public Class<? extends XImportSectionNamespaceScopeProvider> bindXImportSectionNamespaceScopeProvider() {
		return XRobotImportedNamespaceScopeProvider.class;
	}
	
}
