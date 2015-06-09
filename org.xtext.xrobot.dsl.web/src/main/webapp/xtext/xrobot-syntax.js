define("xtext/xrobot-syntax", ["orion/editor/stylers/lib/syntax"], function(mLib) {
	var keywords = ["as", "author", "case", "catch", "def", "default", "do", "else", "extends", "extension", "false", "finally", "for", "if", "import", "instanceof", "left", "new", "null", "on", "return", "robot", "static", "super", "switch", "synchronized", "throw", "true", "try", "typeof", "val", "var", "when", "while"];

	var grammars = [];
	grammars.push.apply(grammars, mLib.grammars);
	grammars.push({
		id: "xtext.xrobot",
		contentTypes: ["xtext/xrobot"],
		patterns: [
			{include: "orion.c-like#comment_singleLine"},
			{include: "orion.c-like#comment_block"},
			{include: "orion.lib#string_doubleQuote"},
			{include: "orion.lib#string_singleQuote"},
			{include: "orion.lib#number_decimal"},
			{include: "orion.lib#number_hex"},
			{include: "orion.lib#brace_open"},
			{include: "orion.lib#brace_close"},
			{include: "orion.lib#bracket_open"},
			{include: "orion.lib#bracket_close"},
			{include: "orion.lib#parenthesis_open"},
			{include: "orion.lib#parenthesis_close"},
			{match: "\\b(?:" + keywords.join("|") + ")\\b", name: "keyword.operator.xrobot"}
		]
	});

	return {
		id: "xtext.xrobot",
		grammars: grammars,
		keywords: keywords
	};
});
