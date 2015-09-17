class BaseModule extends AbstractModule

	preloadReady: null

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@preloadReady = new signals.Signal()

	preload: =>
		@preloadReady.addOnce @onPreloadReady
		@preloadReady.dispatch()

	onPreloadReady: () =>
		@preloadReady.remove @onPreloadReady
		# batches = @.__proto__.constructor.getBatches(@defaultBatches || @id)
		batches = Object.getPrototypeOf(@).constructor.getBatches(@defaultBatches || @id)
		@load batches

	load: (manifestId) =>
		console.log '%c BaseModule - load ', 'background: #555; color: #fff', @
		app.manifestLoader.tplComplete.add @onPreloadTplComplete
		app.manifestLoader.complete.add @onPreloadComplete
		app.manifestLoader.load manifestId

	onPreloadTplComplete: (tpl, batchId) =>
		if batchId == @id
			console.log '%c BaseModule - onPreloadTplComplete ', 'background: #555; color: #fff', @
			@addTemplate @$parentWrapper, tpl, app.datas
			Transition.fadeOut @$elt
			@registerDOM()

	addTemplate: ($elt, tpl, data) =>
		@$elt = TemplateRenderer.append $elt, tpl, data

	registerDOM: =>

	onPreloadComplete: =>
		console.log '%c BaseModule - onPreloadComplete ', 'background: #555; color: #fff', @
		@unbindLoad()
		@preloadComplete.dispatch()
		app.manifestLoader.hideLoader.dispatch()

	bind: =>

	show: =>
		#console.log "********** show", @
		@onShowStart()
		Transition.fadeIn @$elt, @onShowEnd

	onShowStart: =>
		super()
		@unbind()
		@bind()

	hide: =>
		#console.log "********** hide", @
		@onHideStart()
		Transition.fadeOut @$elt, @onHideEnd

	onHideStart: =>
		super()
		@unbind()

	unbind: =>

	unbindLoad: =>
		app.manifestLoader.tplComplete.remove @onPreloadTplComplete
		app.manifestLoader.complete.remove @onPreloadComplete

	destroy: =>
		super()
		@$elt.remove()
