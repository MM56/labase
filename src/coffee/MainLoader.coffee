class MainLoader

	count: 0
	$elt : null

	constructor: ->
		@destroy = new signals.Signal()
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
		@count++
		@onDestroy() if @count > 1

	onDestroy: () =>
		Transition.fadeOut(@$elt[0], @onDestroyComplete)
		app.manifestLoader.start.remove @onLoadStart
		app.manifestLoader.progress.remove @onLoadProgress
		app.manifestLoader.complete.remove @onLoadComplete

	onDestroyComplete: () =>
		@$elt.remove()
		@destroy.dispatch()

mainLoader = new MainLoader()
mainLoader.init()