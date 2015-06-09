define("xtext/executor", ["xtext/services/AbstractXtextService"], function(AbstractXtextService) {
	function Executor() {
		var resourceUri = document.getElementById("uri").value;
		this.initialize(serverUrl, resourceUri, "execute");
	}
	Executor.prototype = new AbstractXtextService();
	Executor.prototype.execute = function() {
		var token = document.getElementById("tokentext").value;
		
		var serverData = {
			uri : uri,
			token : token
		};
		this.sendRequest(editorContext, {
			type : "POST",
			data : serverData,
			success : function(result) {
				if (result) {
					$("#tokenstatus").text(result.output);
				} else {
					$("#tokenstatus").text("Success");
				}
			}
		});
	};
	return Executor;
});