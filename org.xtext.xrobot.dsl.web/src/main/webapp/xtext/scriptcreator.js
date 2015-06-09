/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
define("xtext/scriptcreator", ["jquery", "text!xtext/Example.xrobot"],

function(jQuery, initialContent) {
	function ScriptCreator() {
	}
	
	ScriptCreator.prototype = {
		createScript : function(resourceUri) {
			var deferred = jQuery.Deferred();
			var serverData = {
				resource: resourceUri,
				fullText: initialContent
			};
			var settings = {
				type : "POST",
				async : true,
				dataType : "json",
				data : serverData,
				success : function(result) {
					if (result.conflict)
						deferred.reject(result.conflict);
					else
						deferred.resolve();
				}
			};
			var requestUrl = "http://" + location.host + "/xtext-service/create";
			jQuery.ajax(requestUrl, settings);
			return deferred.promise();
		}
	};
	
	return ScriptCreator;
});