class Video

	id 	  : null
	$elt  : null
	elt   : null
	available : true

	onVideoEnded   	 	 : null
	onVideoWaited		 : null
	onVideoSeeked		 : null
	onVideoLoaded   	 : null
	onVideoProgressed	 : null
	onVideoTimeUpdated   : null
	onVideoFullScreen    : null
	
	constructor: (@id) ->
		if typeof @id == "number"
			elt = "<video id=\"video-" + @id + "\" class=\"video-controlled\" preload=\"none\"></video>"
		else
			elt = @id

		@$elt = $(elt)
		@elt = @$elt[0]
		@available = true

		@onVideoPaused = new MM.Signal()
		@onVideoLoaded = new MM.Signal()
		@onVideoEnded = new MM.Signal()
		@onVideoTimeUpdated = new MM.Signal()
		@onVideoProgressed = new MM.Signal()
		@onVideoSeeked = new MM.Signal()
		@onVideoWaited = new MM.Signal()
		@onVideoFullScreen = new MM.Signal()

	init: () =>
		@unbind()
		@bind()
		@onResize()
		@elt.load()

		# FF needs play() to get loadedmetadata & canplay events
		if navigator.userAgent.indexOf("Firefox") > -1
			@elt.play()
		
	bind: () =>
		W.add @
		@$elt.on "loadstart", @onLoadStart
		@$elt.on "loadedmetadata", @onLoadedMetaData
		@$elt.on "canplay", @onCanPlay
		@$elt.on "timeupdate", @onTimeUpdate
		@$elt.on "ended", @onEnded
		@$elt.on "pause", @onPause
		@$elt.on "seeking", @onSeeking
		@$elt.on "waiting", @onWaiting
		@$elt.on "progress", @onProgress
		
		@onFullscreen()

	unbind: () =>
		W.remove @
		@$elt.off "loadstart", @onLoadStart
		@$elt.off "loadedmetadata", @onLoadedMetaData
		@$elt.off "canplay", @onCanPlay
		@$elt.off "timeupdate", @onTimeUpdate
		@$elt.off "ended", @onEnded
		@$elt.off "pause", @onPause
		@$elt.off "seeking", @onSeeking
		@$elt.off "waiting", @onWaiting
		@$elt.off "progress", @onProgress
		# needs to hide element
		@$elt.css { "width" : 0, "height" : 0, "top" : 0, "left" : 0}
		@offFullscreen()

	onFullscreen: () =>
		if @elt.requestFullscreen
			document.addEventListener("fullscreenchange", @FShandler)
		else if  @elt.mozRequestFullScreen
			document.addEventListener("mozfullscreenchange", @FShandler)
		else if  @elt.webkitRequestFullscreen
			document.addEventListener("webkitfullscreenchange", @FShandler)
		else if  @elt.msRequestFullscreen
			document.addEventListener("MSFullscreenChange", @FShandler)
		else if @elt.webkitExitFullscreen
			@elt.addEventListener("webkitbeginfullscreen", @FShandlerBegin)
			@elt.addEventListener("webkitendfullscreen", @FShandlerEnd)

	offFullscreen: () =>
		if @elt.requestFullscreen
			document.removeEventListener("fullscreenchange", @FShandler)
		else if  @elt.mozRequestFullScreen
			document.removeEventListener("mozfullscreenchange", @FShandler)
		else if  @elt.webkitRequestFullscreen
			document.removeEventListener("webkitfullscreenchange", @FShandler)
		else if  @elt.msRequestFullscreen
			document.removeEventListener("MSFullscreenChange", @FShandler)
		else if @elt.webkitExitFullscreen
			@elt.removeEventListener("webkitbeginfullscreen", @FShandlerBegin)
			@elt.removeEventListener("webkitendfullscreen", @FShandlerEnd)

	FShandler: (e) =>
		e.fullscreenElement = document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement
		e.fullscreenEnabled = document.fullscreenEnabled || document.mozFullScreenEnabled || document.webkitFullscreenEnabled
		@onVideoFullScreen.dispatch(e)

	FShandlerBegin: (e) =>
		e.fullscreenElement = @elt
		@onVideoFullScreen.dispatch(e)

	FShandlerEnd: (e) =>
		e.fullscreenElement = null
		@onVideoFullScreen.dispatch(e)

	enterFullscreen: () =>
		if @elt.requestFullscreen
			@elt.requestFullscreen()
		else if  @elt.mozRequestFullScreen
			@elt.mozRequestFullScreen()
		else if  @elt.webkitRequestFullscreen
			@elt.webkitRequestFullscreen()
		else if  @elt.msRequestFullscreen
			@elt.msRequestFullscreen()
		else if @elt.webkitEnterFullscreen
			@elt.webkitEnterFullscreen()

	exitFullscreen: =>
		if @elt.exitFullscreen
			@elt.exitFullscreen()
		else if  @elt.mozCancelFullScreen
			@elt.mozCancelFullScreen()
		else if @elt.webkitCancelFullScreen
			@elt.webkitCancelFullScreen()
		else if  @elt.msExitFullscreen
			@elt.msExitFullscreen()

	# EVENTS
	onProgress: (e) =>
		#console.log "____ONPROGRESS"
		@onVideoProgressed.dispatch(e)

	onTimeUpdate: (e) =>
		#console.log "____ONTIMEUPDATE"
		@onVideoTimeUpdated.dispatch(e)

	onEnded: (e) =>
		#console.log "____ONENDED", @idSrc
		@onVideoEnded.dispatch()

	onPause: (e) =>
		#console.log "____ONPAUSE", @idSrc
		@onVideoPaused.dispatch()

	onSeeking: (e) =>
		#console.log "____ONSEEKING", @idSrc
		@onVideoSeeked.dispatch()

	onWaiting: (e) =>
		#console.log "____ONWAITING", @idSrc
		@onVideoWaited.dispatch()

	onLoadStart: (e) =>
		console.log "____ONLOADSTART", @idSrc, @elt.currentTime, @elt.playing

	onLoadedMetaData: (e) =>
		console.log "____ONLOADEDMETADATA", @idSrc

	onCanPlay: (e) =>
		console.log "____ONCANPLAY", @idSrc
		@onVideoLoaded.dispatch(@)

	onResize: () =>
		@setSize()

	# METHODS
	togglePlayPause: (e) =>
		if @elt.paused
			@play()
			console.log "____PLAY toggle", @idSrc
		else
			@pause()
			console.log "____PAUSE toggle", @idSrc

		@available = false

	play: () =>
		@elt.play()
		#console.log "____PLAY", @idSrc

	pause: () =>
		@elt.pause()
		#console.trace "____PAUSE", @idSrc

	seekTo: (time) =>
		try
			@elt.currentTime = parseFloat(time)
		catch
			console.log e
		#console.log "____SEEK", @idSrc

	setMuted: () =>
		if @elt.muted
			@elt.muted = false
		else
			@elt.muted = true

	setSource: (src) =>
		ext = ".mp4"
		support = FunctionUtils.getSupportVideo()
		if support.h264
			ext = ".mp4"
			type = "video/mp4"
		else if support.webm
			ext = ".webm"
			type = "video/webm"
		@addSourceToVideo(src + ext, type)

	addSourceToVideo: (src,type) =>
		source = document.createElement('source')
		source.src = src
		source.type = type
		@elt.appendChild source
		@elt.setAttribute "src",source.src

	setSize: () =>
		size = FunctionUtils.getCoverSizeImage(1280, 720, W.ww, W.wh)
		MM.css @$elt[0].css { "width" : size.width + "px" , "height" : size.height + "px", "top" : size.top + "px", "left" : size.left + "px"}
		