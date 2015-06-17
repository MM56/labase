class LoaderModule

	constructor: () ->
		@registerDOM()
		mainLoader.destroy.add @init

	init: =>
		mainLoader.destroy.remove @init
		app.manifestLoader.start.add @onLoadStart
		app.manifestLoader.progress.add @onLoadProgress

	registerDOM : () =>
		@$elt = $('#usualLoader')
		@$progress = @$elt.find('.progress')

	onLoadStart: () =>
		TweenMax.set @$progress, { width : 0 }
		@$elt.addClass "opaque"

	onLoadProgress: (e) =>
		progress = e.progress * 100
		if progress < 100
			TweenMax.to @$progress, 1, { width : progress + "%", ease: Expo.easeInOut }
		else
			TweenMax.to @$progress, 0.1, { width : progress + "%", ease: Expo.easeOut, onComplete: @onLoadComplete }

	onLoadComplete: () =>
		@$elt.removeClass "opaque"