define(
[ "require", "xtext/xtext-orion", "text!Example.xrobot" ],

function(require, xtext, initialContent) {
	
	var editor = xtext.createEditor();
	editor.setInput(null, null, initialContent);

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
			$('#execute').removeClass('cboxElement');
		} else {
			$('#execute').colorbox({
				href : "inline.html",
				onOpen : function() {
					var text = editor.getTextView().getText();
					document.getElementById("sourceCode").setAttribute("value", text);
				},
				onComplete : function() {
					$('#tokentext').focus();
					$('#tokentext').select();
				}
			});
		}
	}

	document.getElementById("save").onclick = function() {
		save(editor);
	};

	document.getElementById("execute").onclick = function() {
		execute();
	};

	var dirtyIndicator = "";
	var status = "";

	editor.addEventListener("DirtyChanged", function(event) {
		if (editor.isDirty())
			document.getElementById("save").style.background='#B22222';
		else
			document.getElementById("save").style.background='#228B22';
	});

	$('#jqxSplitter').on('resize', function(event) {
		textView.redraw();
	});

	window.onbeforeunload = function() {
		if (editor.isDirty()) {
			return "There are unsaved changes.";
		}
	};
});
