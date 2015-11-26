var MM = MM || {};
MM._log = function(params) {
	if(navigator.appVersion.indexOf("MSIE") > -1) {
		return;
	}
	console.log.apply(console, params);
}
MM.clog = function(msg, style) {
	style = style || {
		backgroundColor: "#000000",
		color: "#ffffff",
	};
	style.backgroundColor = style.backgroundColor || "#000000";
	style.color = style.color || "#ffffff";
	var str = "";
	var key;
	for(var i in style) {
		key = i.replace(/([A-Z])/g, function(v) {return "-" + v.toLowerCase()});
		str += key + ":" + style[i] + ";";
	}
	var params = ["%c%s", str, msg];
	var args = [];
	for(var i in arguments) {
		args.push(arguments[i]);
	}
	params = params.concat(args.slice(2));
	MM._log(params);
};
MM.log = function() {
	var params = [""];
	var argument;
	for(var i in arguments) {
		argument = arguments[i];
		if(/[a-f0-9]{6}|[a-f0-9]{3}/i.test(argument)) {
			params[0] += "%c  %c";
			params.push("background-color:" + argument + ";");
		} else {
			if(i > 0) {
				params[0] += " ";
			}
			params[0] += "%o";
		}
		params.push(argument);
	}
	MM._log(params);
};
//console.image("http://assets.cdn.cargocollective.com/280373/841551417385733862387032669658550272/logo_mm_stamp_dark.png?f6ef6d57df");
MM.clog("   ♥  Merci-Michel  ♥   ", {lineHeight: "34px",fontSize:"25px", backgroundColor: "#f1f2ed", color: "#4d4d4d", fontFamily: "Georgia,serif"});
console.log("        ", "www.merci-michel.com");