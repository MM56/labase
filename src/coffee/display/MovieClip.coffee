class MovieClip

	currentFrame: 0
	loopFrame : 0
	totalFrames: 0
	$parent: null
	$elt: null
	isPlaying: false
	framesScripts: null
	reverse: false
	name: null
	isRendering: false
	fps: 30
	yoyo: false
	loop: true

	constructor: (@fps = 30) ->
		@name = null
		@isPlaying = false
		@isRendering = false
		@framesScripts = []
		@reverse = false
		@yoyo = false

	addToRAF: =>
		rAFManager.add @tick, @fps

	removeFromRAF: =>
		rAFManager.remove @tick

	gotoAndPlay: (frame) =>
		@currentFrame = @validateFrame frame
		@play()

	gotoAndStop: (frame) =>
		@currentFrame = @validateFrame frame
		@render()
		@stop()

	validateFrame: (frame) =>
		if frame < 0
			frame = 0
		else if frame > @totalFrames - 1
			frame = @totalFrames - 1
		return frame

	addFrameScript: (frame, callback) =>
		frame = @validateFrame frame

		# if callback is null, we remove the script for the frame
		unless callback?
			@removeFrameScript frame
			return

		# if script already registered for this frame, we override it
		for frameScript in @framesScripts
			if frameScript.frame == frame
				frameScript.callback = callback
				return

		@framesScripts.push {frame: frame, callback: callback}

	removeFrameScript: (frame) =>
		frame = @validateFrame frame
		for frameScript in @framesScripts
			if frameScript.frame == frame
				@framesScripts.splice @framesScripts.indexOf(frameScript), 1
				break

	play: () =>
		@render()
		@isPlaying = true
		@startRendering()

	stop: () =>
		@isPlaying = false
		@stopRendering()

	startRendering: =>
		@isRendering = true

	stopRendering: =>
		@isRendering = false

	render: () =>
		for frameScript in @framesScripts
			if frameScript.frame == @currentFrame
				frameScript.callback()
				break

	tick: () =>
		# check if it has to be rendered
		# console.log @currentFrame, @totalFrames
		if @isPlaying
			if @reverse
				if @currentFrame - 1 < 0
					if @loop
						if @yoyo
							@currentFrame++
							@reverse = false
						else
							@currentFrame = @totalFrames - 1
				else
					@currentFrame--
			else
				if @currentFrame + 1 > @totalFrames - 1
					if @loop
						if @yoyo
							@currentFrame--
							@reverse = true
						else
							@currentFrame = @loopFrame
				else
					@currentFrame++
			if @isRendering
				@render()
