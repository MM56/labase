class AbstractModule
	id: null
	$elt: null
	preloadComplete: null
	showStart: null
	showed : null
	showEnd: null
	hideStart: null
	hideEnd: null
	onEnterEnd: null
	onExitEnd: null
	onDestroy: null
	$parentWrapper: null
	defaultBatches: null
	submodules: null

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		# console.log @
		parentWrapper = "root-module-wrapper" if !parentWrapper?
		@$parentWrapper = $("." + parentWrapper)

		@showed = false

		@preloadComplete = new MM.Signal()
		@showStart = new MM.Signal()
		@showEnd = new MM.Signal()
		@hideStart = new MM.Signal()
		@hideEnd = new MM.Signal()
		@onEnterEnd = new MM.Signal()
		@onExitEnd = new MM.Signal()
		@onDestroy = new MM.Signal()

		@submodules = []

	@getBatches: (id) =>
		return id

	preload: =>

	onResize: () =>

	enter: () =>
		@show()

	addSubmodule: (submodule) =>
		submodule.onDestroy.addOnce @onSubmoduleDestroy, {submodule: submodule, submodules: @submodules, _this: @}
		@submodules.push submodule

	onSubmoduleDestroy: ->
		@submodules.splice @submodules.indexOf(@submodule), 1

	exit: (cascade = true) =>
		return if !@showed
		if cascade? && cascade && @submodules.length > 0
			for submodule in @submodules.slice(0).reverse()
				submodule.exit() if submodule.showed
			@hide()
		else
			@hide()

	show: =>
		@onShowStart()
		@onShowEnd()

	onShowStart: =>
		@showed = true
		console.log '%c AbstractModule - onShowStart ', 'background: #555; color: #fff', @
		@showStart.dispatch @

	onShowEnd: =>
		console.log '%c AbstractModule - onShowEnd ', 'background: #555; color: #fff', @
		@showEnd.dispatch @
		@onEnterEnd.dispatch()

	hide: =>
		console.log '%c AbstractModule - hide ', 'background: #555; color: #fff', @
		@onHideStart()
		@onHideEnd()

	onHideStart: =>
		console.log '%c AbstractModule - onHideStart ', 'background: #555; color: #fff', @
		@hideStart.dispatch @

	onHideEnd: =>
		console.log '%c AbstractModule - onHideEnd ', 'background: #555; color: #fff', @
		@showed = false
		@hideEnd.dispatch @
		@exitEnd()

	exitEnd: =>
		@destroy()
		@onExitEnd.dispatch()

	destroy: =>
		console.log '%c AbstractModule - destroy ', 'background: #555; color: #fff', @
		@onDestroy.dispatch()

	unbindLoad: =>
