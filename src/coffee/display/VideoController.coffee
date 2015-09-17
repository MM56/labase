class VideoController

	options: {
		nbVideosRequired: 1
	}

	$container: null
	videoObjects: null
	lastVo: null

	constructor: (@$container, options) ->

		for key, value of @options
			@options[key] = if options?[key]? then options[key] else value

		@onVideoLoaded = new MM.Signal()
		@onVideoSwitched = new MM.Signal()

		@videoObjects = []
		@createVideosObjects()

		#app.onSoundChanged.add @onSoundChanged

	# _____________________________
	# METHODS

	onSoundChanged: () =>
		for vo in @videoObjects
			vo.elt.muted = app.muted

	createVideosObjects: () =>
		if @$container.find(".video-controlled").length < @options.nbVideosRequired
			nbVideosToCreate = @options.nbVideosRequired - @$container.find(".video-controlled").length
			for i in [0..nbVideosToCreate-1]
				vo = @getVideoInstance(i)
				@$container.append vo.$elt
				@videoObjects.push vo

	getVideoInstance: (i) =>
		return new Video(i)

	play: (src) =>
		vo = @getAvailableVo()
		vo.available = false
		vo.setSource src
		vo.init()
		
		vo.onVideoLoaded.add @onVideoCanPlay

		return vo

	getAvailableVo: () =>
		for vo in @videoObjects
			if vo.available
				return vo

	switchVo: (newVo, oldVo) =>
		if newVo?
			@addVo newVo

		if oldVo?
			TweenMax.delayedCall 0, =>
				@removeVo oldVo
		@onVideoSwitched.dispatch newVo

	addVo: (vo) =>
		vo.pause()
		vo.elt.muted = false
		vo.$elt.css "z-index", 2
		vo.play()

	removeVo: (vo) =>
		vo.unbind()
		vo.pause()
		vo.onVideoLoaded.remove @onVideoCanPlay
		vo.$elt.css "z-index", 0
		vo.$elt.attr "src", null
		vo.$elt.children().remove()
		vo.available = true

	# _____________________________
	# SIGNALS

	onVideoCanPlay: (vo) =>
		@onVideoLoaded.dispatch(vo)
		vo.onVideoLoaded.remove @onVideoCanPlay
		@switchVo vo, @lastVo
		@lastVo = vo

