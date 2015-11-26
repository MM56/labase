class VideoController

	options:
		nbVideosRequired: 1

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

		SoundManager.updated.add @onSoundChanged

	# _____________________________
	# METHODS

	onSoundChanged: () =>
		for vo in @videoObjects
			vo.elt.muted = SoundManager.isMuted

	createVideosObjects: () =>
		if @$container.find(".video-controlled").length < @options.nbVideosRequired
			nbVideosToCreate = @options.nbVideosRequired - @$container.find(".video-controlled").length
			for i in [0..nbVideosToCreate-1]
				vo = @getVideoInstance(i)
				@$container.append vo.$elt
				@videoObjects.push vo

	getVideoInstance: (i) =>
		return new Video(i)

	play: (src, options = {}) =>

		vo = @getAvailableVo()
		console.log src, vo
		vo.src = src
		vo.available = false
		vo.keepGoing = options.keepGoing || false
		vo.onlyPreload = options.onlyPreload || false
		vo.loop = options.loop || false
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
			setTimeout =>
				@removeVo oldVo if oldVo != newVo && !oldVo.keepGoing
			, 0
		@onVideoSwitched.dispatch newVo
		@lastVo = newVo

	addVo: (vo) =>
		vo.pause()
		vo.elt.muted = SoundManager.isMuted
		vo.$elt.css "z-index", 2
		vo.play()

	searchBySrc: (src) =>
		for vo in @videoObjects
			if vo.src == src
				return vo

	removeVos: () =>
		for vo in @videoObjects
			@removeVo(vo)

	removeVo: (vo) =>
		vo.unbind()
		vo.pause()
		vo.onVideoLoaded.remove @onVideoCanPlay
		vo.$elt.css "z-index", 0
		vo.$elt.attr "src", null
		vo.$elt.children().remove()
		vo.available = true
		vo.loop = false
		delete vo.src if vo.src?
		delete vo.onlyPreload if vo.onlyPreload?
		delete vo.keepGoing if vo.keepGoing?

	# _____________________________
	# SIGNALS
	
	onVideoCanPlay: (vo) =>
		@onVideoLoaded.dispatch(vo)
		vo.onVideoLoaded.remove @onVideoCanPlay
		
		if vo.onlyPreload
			vo.pause()
			vo.seekTo 0
			return
		@switchVo vo, @lastVo



