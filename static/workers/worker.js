var xhrs = [];
function onComplete(xhr) {
	for (var i = 0, l = xhrs.length; i < l; i++) {
		if (xhrs[i].src == xhr.url) {
			xhrs.splice(i, 1);
			var message = JSON.parse(JSON.stringify({proxy : "oncomplete", data: {src: xhr.url }}));
			message.data.response = xhr.response;
			postMessage(message);
			break;
		}
	}
}

function onAbort(event) {
	i = xhrs.length;
	while (i--) {
		if(xhrs[i].src == event.file.src) {
			xhrs[i].xhr.abort();
			xhrs.splice(i, 1)
		}
	}
}

self.addEventListener('message', function(e) {
	switch (e.data.proxy) {
		case "load":
			var xhr = new XHRRequest(e.data.data, onComplete).xhr;
			xhrs.push({ src: e.data.data.src, xhr: xhr })
			break;
		case "abort":
			onAbort(e.data);
			break;
	}
}, false);


function XHRRequest(data, callback) {
	url = data.src;
	this.xhr = new XMLHttpRequest();
	this.callback = callback;
	this.xhr.onprogress = this.handleProgress.bind(this);
	this.xhr.onload = this.handleLoad.bind(this);
	this.xhr.onabort = this.handleAbort.bind(this);
	this.xhr.url = url;

	this.xhr.open("GET", data.src);
	if(data.type == "binary") {
		this.xhr.responseType = "arraybuffer";
	}
	this.xhr.send(null);

}

XHRRequest.prototype.handleProgress = function(event) {
	obj = JSON.parse(JSON.stringify({proxy : "onprogress", data: {loaded: event.loaded, total: event.total, src: event.target.url }}));
	postMessage(obj);
}

XHRRequest.prototype.handleAbort = function() {
	this.clean();
}

XHRRequest.prototype.clean = function() {
	this.xhr.onload = null;
	this.xhr.onabort = null;
	this.xhr.onprogress = null;
	this.callback = null;
	this.xhr = null;
}

XHRRequest.prototype.handleLoad = function(event) {
	if(this.xhr.readyState < 4 || this.xhr.status !== 200) {
		this.clean();
		return;
	}
	if(this.xhr.readyState === 4 && this.callback) {
		this.callback(this.xhr);
		this.clean();
	}	
}