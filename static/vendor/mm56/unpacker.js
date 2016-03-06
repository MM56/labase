(function(global){

	var Unpacker = (function() {
		var URLProxy = window.URL || window.webkitURL || window.mozURL || window.msURL;
		var isIE = Boolean(document.all);

		var hasBlob;
		try {
			hasBlob = Boolean(Blob);
		} catch(e) {
			hasBlob = false;
		}
		if(!hasBlob) {
			var s = document.createElement('script');
			s.type = 'text/vbscript';
			s.text = '' +
				'Function IEBinaryToArray_ByteStr(Binary)\n' +
				'	IEBinaryToArray_ByteStr = CStr(Binary)\n' +
				'End Function\n' +
				'Function IEBinaryToArray_ByteStr_Last(Binary)\n' +
				'	Dim lastIndex\n' +
				'	lastIndex = LenB(Binary)\n' +
				'	if lastIndex mod 2 Then\n' +
				'		IEBinaryToArray_ByteStr_Last = Chr( AscB( MidB( Binary, lastIndex, 1 ) ) )\n' +
				'	Else\n' +
				'		IEBinaryToArray_ByteStr_Last = ""\n' +
				'	End If\n' +
				'End Function';
			document.childNodes[document.childNodes.length - 1].appendChild(s);

			function GetIEByteArray_ByteStr(IEByteArray) {
				var ByteMapping = {};
				for ( var i = 0; i < 256; i++ ) {
					for ( var j = 0; j < 256; j++ ) {
						ByteMapping[ String.fromCharCode( i + j * 256 ) ] =
							String.fromCharCode(i) + String.fromCharCode(j);
					}
				}
				var rawBytes = IEBinaryToArray_ByteStr(IEByteArray);
				var lastChr = IEBinaryToArray_ByteStr_Last(IEByteArray);
				return rawBytes.replace(/[\s\S]/g,
					function( match ) { return ByteMapping[match]; }) + lastChr;
			}
		}

		function b64encodeString(value) {
			var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.split("");
			var l = value.length;
			var i = cb = b = bl = v = 0;
			var b0, b1, b2;
			var c0, c1, c2, c3;
			var ret = '';
			while(i < l) {
				b0 = value.charCodeAt(i + 0) & 0xFF;
				b1 = value.charCodeAt(i + 1) & 0xFF;
				b2 = value.charCodeAt(i + 2) & 0xFF;
				c0 = b0 >> 2 & 0x3F;
				c1 = (b0 << 4 | b1 >> 4) & 0x3F;
				c2 = (b1 << 2 | b2 >> 6) & 0x3F;
				c3 = b2 & 0x3F;

				ret += chars[c0] + chars[c1] + chars[c2] + chars[c3];
				i += 3;
			}

			i = l % 3;
			l = ret.length;
			if(i == 1) {
				ret = ret.substr(0, l - 2) + "==";
			} else if(i == 2) {
				ret = ret.substr(0, l - 1) + "=";
			}
			return ret;
		}

		function Unpacker(pack, config) {
			if(pack) {
				this._init(pack, config);
			}
		}

		Unpacker.prototype._init = function(pack, config) {
			this.config = config;
			this.pack = pack;
			if(pack != null) {
				if(hasBlob) {
					this.blob = new Blob([pack], { type: 'plain/text'});
				} else {
					this.ieBlob = GetIEByteArray_ByteStr(pack);
				}
			}
		}

		Unpacker.prototype.getURI = function() {
			if(arguments.length == 0) throw new Error('Not enough arguments.');
			if(isNaN(arguments[0]) && !this.config) throw new Error('No config file loaded.');

			var type;

			if(!isNaN(arguments[0]) && !isNaN(arguments[1])) {
				type = arguments[2];
				if(!type) type = 'text/plain';
				return this._getRange(arguments[0], arguments[1], type);
			}

			var file = this._findFile(arguments[0]);
			if(!file) throw new Error('File not found in pack.');
			type = file[3];
			if(!type) type = 'text/plain';

			return this._getRange(file[1], file[2], type);
		}

		Unpacker.prototype._getRange = function(i, e, type) {
			if(hasBlob) {
				var b;
				if(this.blob.slice) {
					b = this.blob.slice(i, e, type);
					if(type == "text/plain") {
						return String.fromCharCode.apply(null, new Uint8Array(this.pack.slice(i, e)));
					}
					return URLProxy.createObjectURL(b);
				} else if(this.blob.webkitSlice) {
					b = this.blob.webkitSlice(i, e, type);
					if(type == "text/plain") {
						return String.fromCharCode.apply(null, new Uint8Array(this.pack.slice(i, e)));
					}
					return URLProxy.createObjectURL(b);
				} else if(this.blob.mozSlice) {
					b = this.blob.mozSlice(i, e, type);
					if(type == "text/plain") {
						return String.fromCharCode.apply(null, new Uint8Array(this.pack.slice(i, e)));
					}
					return URLProxy.createObjectURL(b);
				}
			} else {
				if(isIE) {
					if(type == "text/plain") {
						return String.fromCharCode.apply(null, new Uint8Array(this.pack.slice(i, e)));
					}
					return 'data:' + type + ';base64,' + b64encodeString(this.ieBlob.substr(i, e - i));
				}
			}
		}

		Unpacker.prototype._findFile = function(name) {
			var i;
			i = this.config.length;
			while (i-- > 0) {
				if(this.config[i][0] == name)
				{
					return this.config[i];
				}
			}
			while (i-- > 0) {
				if (name.indexOf(this.config[i][0]) >= 0) {
					return this.config[i];
				}
			}
		}

		return Unpacker;
	})();

	//exports to multiple environments
	if(typeof define === 'function' && define.amd){ //AMD
		define(function () { return Unpacker; });
	} else if (typeof module !== 'undefined' && module.exports){ //node
		module.exports = Unpacker;
	} else { //browser
		//use string because of Google closure compiler ADVANCED_MODE
		/*jslint sub:true */
		global['Unpacker'] = Unpacker;
	}
}(this));