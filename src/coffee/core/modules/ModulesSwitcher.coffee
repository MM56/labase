class ModulesSwitcher

	@EXIT_BEFORE_ENTER = "exitBeforeEnter"
	@ENTER_BEFORE_EXIT = "enterBeforeExit"
	@SIMULTANEOUS = "simultaneous"

	nextModule: null
	previousModule: null

	nextModuleReady: null

	@instances: []

	@getInstanceById: (id) =>
		for instance in @instances
			return instance if instance.id == id
		return null

	constructor: () ->
		@id = ModulesSwitcher.instances.length
		ModulesSwitcher.instances.push @
		@nextModuleReady = new MM.Signal()
		@isSwitching = false

	reset: =>
		@isSwitching = false
		@unbind @previousModule
		@unbind @nextModule
		@previousModule = null
		@nextModule = null

	exit: =>
		if @previousModule?
			@unbind @previousModule
			@previousModule.unbindLoad()
			@previousModule.exit()
			@previousModule = null
		else if @isSwitching
			@unbind @nextModule
			@nextModule.unbindLoad()
			@nextModule.exit()
			@nextModule = null

	unbind: (module) =>
		if module?
			module.preloadComplete.remove @onNextModulePreloadComplete
			module.onExitEnd.remove @onPreviousModuleExitEnd
			module.onEnterEnd.remove @onNextModuleEnterEndAfterPreviousExitEnd
			module.onEnterEnd.remove @onNextModuleEnterEnd
			module.onEnterEnd.remove @onNextModuleEnterEndAfterSimultaneous

	switch: (newModule, params, parentModuleWrapper, defaultBatches, moduleId) =>
		@unbind @previousModule
		@unbind @nextModule
		if typeof newModule == "string" && typeof window[newModule] != "undefined"
			ModuleClass = window[newModule]
		else if typeof newModule == "object"
			ModuleClass = newModule
		else
			throw newModule + " class doesn't exist"

		if @isSwitching
			@unbind @previousModule
			@previousModule.exit() if @previousModule?
			@previousModule = @nextModule
			@previousModule.unbindLoad() if @previousModule?

		@isSwitching = true
		@nextModule = new ModuleClass(parentModuleWrapper, params, defaultBatches, moduleId)
		@nextModule.preloadComplete.addOnce @onNextModulePreloadComplete
		@nextModule.preload()

	onNextModulePreloadComplete: (timingType) =>
		@nextTiming = timingType

		@nextModule.preloadComplete.remove @onNextModulePreloadComplete

		@nextModuleReady.dispatch(@nextModule)

	doSwitch: =>
		# Logger.log "doSwitch", @previousModule, @nextModule
		timingType = @nextTiming
		switch timingType
			when ModulesSwitcher.ENTER_BEFORE_EXIT
				@onEnterBeforeExit()
			when ModulesSwitcher.SIMULTANEOUS
				@onSimultaneous()
			else
				@onExitBeforeEnter()

	onExitBeforeEnter: =>
		if @previousModule?
			@previousModule.onExitEnd.addOnce @onPreviousModuleExitEnd
			@previousModule.exit()
		else
			@onPreviousModuleExitEnd()

	onPreviousModuleExitEnd: =>
		if @previousModule?
			@previousModule.onExitEnd.remove @onPreviousModuleExitEnd
		@nextModule.onEnterEnd.addOnce @onNextModuleEnterEndAfterPreviousExitEnd
		@previousModule = @nextModule
		@nextModule.enter()

	onNextModuleEnterEndAfterPreviousExitEnd: =>
		@nextModule.onEnterEnd.remove @onNextModuleEnterEndAfterPreviousExitEnd
		@isSwitching = false

	onEnterBeforeExit: =>
		@nextModule.onEnterEnd.addOnce @onNextModuleEnterEnd
		@nextModule.enter()

	onNextModuleEnterEnd: =>
		@nextModule.onEnterEnd.remove @onNextModuleEnterEnd
		@previousModule.exit() if @previousModule?
		@previousModule = @nextModule
		@isSwitching = false

	onSimultaneous: =>
		@previousModule.exit() if @previousModule?
		@nextModule.onEnterEnd.addOnce @onNextModuleEnterEndAfterSimultaneous
		@nextModule.enter()
		@previousModule = @nextModule

	onNextModuleEnterEndAfterSimultaneous: =>
		@nextModule.onEnterEnd.remove @onNextModuleEnterEndAfterSimultaneous
