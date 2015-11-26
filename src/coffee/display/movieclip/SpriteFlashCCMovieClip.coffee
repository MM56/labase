class SpriteFlashCCMovieClip extends MovieClip

	frames: null
	data: null

	constructor: (@data, @$elt) ->
		super()
		@frames = @data.frames
		@totalFrames = @frames.length
		@marginW = @frames[0].frame.x
		@marginH = @frames[0].frame.y
		@scale = @$elt.width() / @frames[0].frame.w
		if @$elt.width() != @frames[0].frame.w && @$elt.width() != 0
			@$elt.css "background-size", @scale * @data.meta.size.w + "px " + @scale * @data.meta.size.h + "px"
		else
			@$elt.width @frames[0].frame.w
			@$elt.height @frames[0].frame.h
		@render()

	render: () =>
		frameData = @frames[@currentFrame].frame
		@$elt.css("background-position", (-frameData.x * @scale)  + "px " + " " + (-frameData.y * @scale) + "px")
		super()