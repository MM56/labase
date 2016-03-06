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

		@duration = 1.5
		@ease = Power4.easeInOut
		@progress = { value : 0 }

	onLoadStart: () =>
		rAFManager.add @onTick

	onTick: () =>
		if @progress.value >= 100
			rAFManager.remove @onTick

	onLoadProgress: (e) =>

	onLoadComplete: () =>
		@onCompleteProgress()
		
	onCompleteProgress: () =>
		@isHided = true
		setTimeout =>
			@onHideLoader()
		, 300

	onHideLoader: () =>
		if !@isHided
			@isHided = true
		else
			MM.css @$elt[0], "display", "none"
			@destroy.dispatch()
			@unbind()
			rAFManager.remove @onTick
