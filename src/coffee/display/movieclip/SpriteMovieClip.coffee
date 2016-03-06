class SpriteMovieClip extends MovieClip

	frameWidth: 0
	frameHeight: 0

	constructor: (@$elt, fps = 30) ->
		super(fps)
		@totalFrames = parseInt @$elt.data("frames"), 10
		@frameWidth = @$elt.data("width")
		@frameHeight = @$elt.data("height")
		@scale = parseFloat @$elt.data("scale")

		if @$elt.data("top")?
			@marginTop = parseFloat @$elt.data("top")
		else
			@marginTop = 0

		if @$elt.data("left")?
			@marginLeft = parseFloat @$elt.data("left")
		else
			@marginLeft = 0

		if @$elt.data("frame-top")?
			@frameTop = parseFloat @$elt.data("frame-top")
		else
			@frameTop = 0

		if @$elt.data("frame-left")?
			@frameLeft = parseFloat @$elt.data("frame-left")
		else
			@frameLeft = 0

		if @$elt.data("columns")?
			@nbCols = parseInt @$elt.data("columns"), 10
			@nbRows = Math.ceil(@totalFrames / @nbCols)
		else if @$elt.data("rows")?
			@nbRows = parseInt @$elt.data("rows"), 10
			@nbCols = Math.ceil(@totalFrames / @nbRows)
		else
			@nbCols = 1
			@nbRows = @totalFrames

		if @$elt.data("gutter-x")?
			@gutterX = parseFloat @$elt.data("gutter-x")
		else
			@gutterX = 0

		if @$elt.data("gutter-y")?
			@gutterY = parseFloat @$elt.data("gutter-y")
		else
			@gutterY = 0

		@$elt.width @frameWidth * @scale
		@$elt.height @frameHeight * @scale

		x = @scale * ((@frameWidth + 2 * @frameLeft - @gutterX) * @nbCols + @marginLeft * 2) + @gutterX * @scale
		y = @scale * ((@frameHeight + 2 * @frameTop - @gutterY) * @nbRows + @marginTop * 2) + @gutterY * @scale
		@$elt.css "background-size", x + "px "  + y + "px "
		@render()

	render: () =>
		i = (@currentFrame % @nbCols)
		j = Math.floor(@currentFrame / @nbCols)
		x = i * (@frameWidth + @frameLeft * 2 - @gutterX * 2 * @scale) + @marginLeft + @frameLeft
		y = j * (@frameHeight + @frameTop * 2 - @gutterY * 2 * @scale) + @marginTop + @frameTop

		@$elt.css("background-position", -x * @scale + "px " + " " + -y * @scale + "px")
		super()
