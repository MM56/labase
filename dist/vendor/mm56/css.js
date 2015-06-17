var MM = MM || {};
MM.css = (
	function() {

		function computedStyle(elt) {
			if("getComputedStyle" in window) return window.getComputedStyle(elt);
			return elt.currentStyle;
		}

		var prefix = (function () {
			var regex = /^(moz|webkit|khtml|o|ms|icab)(?=[A-Z])/;
			var someScript = document.getElementsByTagName('script')[0];
			for(var prop in someScript.style) {
				if(regex.test(prop)) {
					return prop.match(regex)[0];
				}
			}
			return '';
		})();

		var needPrefixes = [
			"appearance",
			"backfaceVisibility",
			"perspective",
			"perspectiveOrigin",
			"perspectiveOriginX",
			"perspectiveOriginY",
			"transform",
			"transformOrigin",
			"transformOriginX",
			"transformOriginY",
			"transformOriginZ",
			"transition",
		];

		var noPx = [
			"columnCount",
			"fillOpacity",
			"fontWeight",
			"lineHeight",
			"opacity",
			"orphans",
			"widows",
			"zIndex",
			"zoom",
		];

		return (function(elt, prop, value) {
			function get(elt, prop) {
				return computedStyle(elt)[prop];
			}

			function _set(elt, prop, value) {
				if(typeof value == "number" && noPx.indexOf(prop) == -1) value += "px";
				elt.style[prop] = value;
			}

			function set(elt, prop, value) {
				if(needPrefixes.indexOf(prop) > -1) {
					_set(elt, prefix + prop[0].toUpperCase() + prop.substr(1), value);
				}
				_set(elt, prop, value);
			}

			if(arguments.length == 3) {
				set(elt, prop, value);
			} else if(arguments.length == 2) {
				if(typeof prop == "object") {
					for(var key in prop) {
						set(elt, key, prop[key]);
					}
				} else {
					return get(elt, prop);
				}
			}
			return elt;
		});
	}
)();