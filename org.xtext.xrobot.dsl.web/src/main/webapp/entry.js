/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
define([ "xtext/scriptcreator" ],

function(ScriptCreator) {

	function s4() {
		return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
	}
	
	function guid() {
		return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
	};
	
	document.getElementById("resourcebutton").onclick = function() {
		var uri = guid() + ".xrobot"
		var scriptCreator = new ScriptCreator();
		scriptCreator.createScript(uri).done(function() {
			window.open("http://"+ location.host + "/xroboteditor.html?" + uri);
		});
	};

});
