/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
define([ "xtext/xtext-orion", "jquery" ],

function(xtext, jQuery) {
	
	var resourceId = location.search.substring(1);
	var editor = xtext.createEditor({
		resourceId: resourceId,
		enableSaveAction: true
	});

	function execute() {
		var annotationModel = editor.getAnnotationModel();
		var annotations = annotationModel.getAnnotations(0, annotationModel.getTextModel().getCharCount());
		var hasError = false;
		while (annotations.hasNext()) {
			annotation = annotations.next();
			if (annotation.type === "orion.annotation.error") { // AnnotationType.ANNOTATION_ERROR
				hasError = true;
			}
		}
		if (hasError) {
			window.alert('The program cannot be executed because it contains errors.');
			jQuery('#execute').removeClass('cboxElement');
		} else {
			window.resourceId = resourceId;
			jQuery('#execute').colorbox({
				href : "execute.html",
				onComplete : function() {
					jQuery('#tokentext').focus();
					jQuery('#tokentext').select();
				}
			});
		}
	}

	document.getElementById("save").onclick = function() {
		xtext.invokeService(editor, "save");
	};

	document.getElementById("execute").onclick = function() {
		execute();
	};

	editor.addEventListener("DirtyChanged", function(event) {
		if (editor.isDirty())
			document.getElementById("save").style.background='#B22222';
		else
			document.getElementById("save").style.background='#228B22';
	});

	$('#jqxSplitter').on('resize', function(event) {
		editor.getTextView().redraw();
	});

	window.onbeforeunload = function() {
		if (editor.isDirty()) {
			return "There are unsaved changes.";
		}
	};
});
