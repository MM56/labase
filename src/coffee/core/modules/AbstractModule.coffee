class AbstractModule
	id: null
	$elt: null
	preloadComplete: null
	showStart: null
	showEnd: null
	hideStart: null
	hideEnd: null
	onEnterEnd: null
	onExitEnd: null
	onDestroy: null
	$parentWrapper: null
	defaultBatches: null
	submodules: null
	submodulesExited: 0

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		# console.log @
		parentWrapper = "root-module-wrapper" if !parentWrapper?
		@$parentWrapper = $("." + parentWrapper)

		@preloadComplete = new signals.Signal()
		@showStart = new signals.Signal()
		@showEnd = new signals.Signal()
		@hideStart = new signals.Signal()
		@hideEnd = new signals.Signal()
		@onEnterEnd = new signals.Signal()
		@onExitEnd = new signals.Signal()
		@onDestroy = new signals.Signal()

		@submodules = []

	@getBatches: (id) =>
		return id

	preload: =>

	onResize: (width, height) =>

	enter: () =>
		@show()

	addSubmodule: (submodule) =>
		submodule.onDestroy.addOnce @onSubmoduleDestroy, {submodule: submodule, submodules: @submodules, _this: @}
		@submodules.push submodule

	onSubmoduleDestroy: () ->
		@submodules.splice @submodules.indexOf(@submodule), 1

	exit: (cascade = true) =>
		if cascade? && cascade && @submodules.length > 0
			@submodulesExited = 0
			for submodule in @submodules
				submodule.onExitEnd.addOnce @onSubmoduleExitEnd
				submodule.exit()
		else
			@hide()

	onSubmoduleExitEnd: =>
		@submodulesExited++
		if @submodulesExited >= @submodules.length
			@hide()
	show: =>
		@onShowStart()
		@onShowEnd()

	onShowStart: =>
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
		@hideEnd.dispatch @
		@exitEnd()

	exitEnd: =>
		@destroy()
		@onExitEnd.dispatch()

	destroy: =>
		console.log '%c AbstractModule - destroy ', 'background: #555; color: #fff', @
		@onDestroy.dispatch()

	unbindLoad: =>
