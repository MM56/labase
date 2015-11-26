class MainLoader

	$elt : null

	constructor: ->
		@destroy = new MM.Signal()
		@registerDOM()
		@bind()

	bind: =>
		app.manifestLoader.start.add @onLoadStart
		app.manifestLoader.progress.add @onLoadProgress
		app.manifestLoader.complete.add @onLoadComplete
		app.manifestLoader.hideLoader.add @onHideLoader

	unbind: () =>
		app.manifestLoader.start.remove @onLoadStart
		app.manifestLoader.progress.remove @onLoadProgress
		app.manifestLoader.complete.remove @onLoadComplete
		app.manifestLoader.hideLoader.remove @onHideLoader

	registerDOM : () =>
		@$elt = $('#mainLoader')

	onLoadStart: () =>
		@isHided = false

	onLoadProgress: (e) =>

	onLoadComplete: () =>
		@isHided = true
		@onHideLoader()
		
	onHideLoader: () =>
		if !@isHided
			@isHided = true
		else
			setTimeout =>
				MM.css @$elt[0], "display", "none"
				@destroy.dispatch()
				@unbind()
			, 300