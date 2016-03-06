class LoaderModule

	constructor: () ->
		@registerDOM()
		@init()

	init: =>
		app.manifestLoader.start.add @onLoadStart
		app.manifestLoader.hideLoader.add @onLoadComplete

	registerDOM : () =>
		@$elt = $('#usualLoader')

	onLoadStart: () =>
		MM.css @$elt[0], "display", "block"
		
	onLoadComplete: () =>
		MM.css @$elt[0], "display", "none"
		