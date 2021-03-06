define("xtext/executor", ["jquery"], function(jQuery) {
	function Executor() {
	}
	
	Executor.prototype = {
		execute : function(token, resourceId) {
			var serverData = {
				token : token,
				resource : resourceId
			};
			var settings = {
				type : "POST",
				async : true,
				dataType : "json",
				data : serverData,
				success : function(result) {
					if (result) {
						$("#tokenstatus").text(result.output);
					} else {
						$("#tokenstatus").text("Success");
					}
				}
			};
			var requestUrl = "http://" + location.host + "/xtext-service/execute";
			jQuery.ajax(requestUrl, settings);
		}
	};
	
	return Executor;
});