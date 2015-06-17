class ModulesSwitcher

	@EXIT_BEFORE_ENTER = "exitBeforeEnter"
	@ENTER_BEFORE_EXIT = "enterBeforeExit"
	@SIMULTANEOUS = "simultaneous"

	nextModule: null
	previousModule: null

	nextModuleEnterEnd: null
	nextModuleEnterStart: null

	@instances: []

	@getInstanceById: (id) =>
		for instance in @instances
			return instance if instance.id == id
		return null

	constructor: () ->
		@id = ModulesSwitcher.instances.length
		ModulesSwitcher.instances.push @
		@nextModuleEnterStart = new signals.Signal()
		@nextModuleEnterEnd = new signals.Signal()
		@isSwitching = false

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
			if @previousModule?
				@unbind @previousModule
				@previousModule.exit()
			@previousModule = @nextModule
			@previousModule.unbindLoad()
		@isSwitching = true
		@nextModule = new ModuleClass(parentModuleWrapper, params, defaultBatches, moduleId)
		@nextModule.preloadComplete.addOnce @onNextModulePreloadComplete
		@nextModule.preload()

	onNextModulePreloadComplete: (timingType) =>
		@nextModule.preloadComplete.remove @onNextModulePreloadComplete

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
		@nextModuleEnterStart.dispatch(@nextModule)

	onNextModuleEnterEndAfterPreviousExitEnd: =>
		@nextModule.onEnterEnd.remove @onNextModuleEnterEndAfterPreviousExitEnd
		@nextModuleEnterEnd.dispatch(@nextModule)
		@isSwitching = false

	onEnterBeforeExit: =>
		@nextModule.onEnterEnd.addOnce @onNextModuleEnterEnd
		@nextModule.enter()
		@nextModuleEnterStart.dispatch(@nextModule)

	onNextModuleEnterEnd: =>
		@nextModule.onEnterEnd.remove @onNextModuleEnterEnd
		if @previousModule?
			@previousModule.exit()

		@previousModule = @nextModule
		@isSwitching = false
		@nextModuleEnterEnd.dispatch(@nextModule)

	onSimultaneous: =>
		if @previousModule?
			@previousModule.exit()
		@nextModule.onEnterEnd.addOnce @onNextModuleEnterEndAfterSimultaneous
		@nextModule.enter()
		@previousModule = @nextModule
		@nextModuleEnterStart.dispatch(@nextModule)

	onNextModuleEnterEndAfterSimultaneous: =>
		@nextModule.onEnterEnd.remove @onNextModuleEnterEndAfterSimultaneous
		@nextModuleEnterEnd.dispatch(@nextModule)
