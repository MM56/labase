var MM = MM || {};
MM.Signal = (function() {

	function Signal() {
		this.bindings = [];
	}

	Signal.prototype.add = function(callback, scope, addOnce) {
		if(callback == null || typeof callback != "function") {
			throw new Error("Invalid callback");
			return;
		}
		addOnce = addOnce || false;
		this.bindings.unshift({callback: callback, scope: scope, addOnce: addOnce});
	}

	Signal.prototype.addOnce = function(callback, scope) {
		this.add(callback, scope, true);
	}

	Signal.prototype.dispatch = function() {
		var args = Array.prototype.slice.call(arguments), i = this.bindings.length - 1, binding;
		for(; i >= 0; i--) {
			binding = this.bindings[i];
			binding.callback.apply(binding.scope, args);
			if(binding.addOnce) {
				this.bindings.splice(i, 1);
			}
		}
	}

	Signal.prototype.remove = function(callback, scope) {
		var i = this.bindings.length - 1, binding;
		for(; i >= 0; i--) {
			binding = this.bindings[i];
			if(binding.callback == callback && binding.scope == scope) {
				this.bindings.splice(i, 1);
			}
		}
	}

	Signal.prototype.removeAll = function() {
		this.bindings = [];
	}

	return Signal;
})();

// browserify & webpack
if(typeof module === "object") {
	module.exports = MM.Signal;
}
