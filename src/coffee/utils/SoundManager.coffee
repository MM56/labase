class SoundManager

	@isMuted: false
	@updated: new MM.Signal()

	@toggleMute: =>
		if @isMuted
			@unmute()
		else
			@mute()

	@mute: =>
		@isMuted = true
		@updated.dispatch()

	@unmute: =>
		@isMuted = false
		@updated.dispatch()
