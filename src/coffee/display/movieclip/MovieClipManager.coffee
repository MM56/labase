class MovieClipManager
	@lastTime: 0
	@movieClips: null
	@fps: 30

	@init: =>
		@lastTime = (new Date()).getTime()
		@movieClips = []
		rAFManager.add @tick, @fps

	@tick: () =>
		# render movieClips
		for movieClip in @movieClips
			# check if it has to be rendered
			if movieClip.isPlaying
				if movieClip.reverse
					if movieClip.currentFrame - 1 < 0
						movieClip.currentFrame = movieClip.totalFrames - 1
					else
						movieClip.currentFrame--
				else
					if movieClip.currentFrame + 1 > movieClip.totalFrames - 1
						movieClip.currentFrame = 0
					else
						movieClip.currentFrame++
				movieClip.render()

	@add: (movieClip) =>
		@movieClips.push movieClip

	@remove: (movieClip) =>
		index = @movieClips.indexOf(movieClip)
		if index > -1
			@movieClips.splice index, 1
