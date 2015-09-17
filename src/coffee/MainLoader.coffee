class MainLoader

	$elt : null

	constructor: ->
		@destroy = new MM.Signal()
		window.app = new App()
		@registerDOM()

	init: ->
		app.manifestLoader.start.add @onLoadStart
		app.manifestLoader.progress.add @onLoadProgress
		app.manifestLoader.complete.add @onLoadComplete
		app.init()

	registerDOM : () =>
		@$elt = $('#mainLoader')

	onLoadStart: () =>

	onLoadProgress: (e) =>
		progress = e.progress * 100

	onLoadComplete: () =>
		@onDestroy()

	onDestroy: () =>
		@$elt.addClass "transparent"
		app.manifestLoader.start.remove @onLoadStart
		app.manifestLoader.progress.remove @onLoadProgress
		app.manifestLoader.complete.remove @onLoadComplete
		setTimeout @onDestroyComplete, 300

	onDestroyComplete: () =>
		@$elt.remove()
		@destroy.dispatch()

mainLoader = new MainLoader()
mainLoader.init()