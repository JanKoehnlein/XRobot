define([ "require", "orion/textview/textView", "orion/textview/keyBinding",
		"orion/editor/editor", "orion/editor/editorFeatures",
		"xtext/contentassist/contentAssist",
		"xtext/contentassist/dslContentAssist",
		"xtext/highlighter/serverhighlighter", "xtext/validation/validator",
		"xtext/highlighter/asyncStyler", "orion/serviceregistry",
		"xtext/resource/resourceloader", "xtext/resource/resourcepersister",
		"xtext/hover/hover", "xtext/formatter/formatter",
		"xtext/executer/executer", "xtext/organize/imports" ],

function(require, mTextView, mKeyBinding, mEditor, mEditorFeatures,
		mContentAssist, mDslContentAssist, mHighlighter, mValidator,
		mAsyncStyler, mService, mResourceLoader, mResourcePersister, mHover,
		mFormatter, mExecutor, mImports) {

	function s4() {
		return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
	}
	function guid() {
		return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
	};

	document.getElementById("resourcebutton").onclick = function() {
		var uri = guid() + ".xrobot"
		window.open("http://"+ location.host + "/xroboteditor.html?" + uri);
	};

});
