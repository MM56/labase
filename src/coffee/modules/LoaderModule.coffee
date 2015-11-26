class LoaderModule

	constructor: () ->
		@registerDOM()

	init: =>
		app.manifestLoader.start.add @onLoadStart
		app.manifestLoader.hideLoader.add @onLoadComplete

	registerDOM : () =>
		@$elt = $('#usualLoader')

	onLoadStart: () =>
		
	onLoadComplete: () =>
		