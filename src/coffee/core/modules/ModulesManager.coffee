class ModulesManager

	@modulesDefinitions: []
	@routes: null
	@lastSwitchersTmp: []
	@lastSwitchers: []
	@modulesRoutesData: null
	@listeners: []

	previousModule = null
	@moduleWrapperSuffix: "-module-wrapper"

	@add: (moduleDefinition) =>
		return if @modulesDefinitions.indexOf(moduleDefinition) > -1
		@modulesDefinitions.push moduleDefinition

	@setModulesRoutesData: (data) =>
		@modulesRoutesData = data
		@routes = parseRoutes @modulesRoutesData.modules
		createSwitchers @modulesRoutesData
		@modulesRoutesData.switcher = ModulesSwitcher.getInstanceById(0)

	@cloneModulesRoutes: () =>
		modulesRoutes = $.extend true, {}, @modulesRoutesData
		routes = parseRoutes modulesRoutes.modules
		createParents modulesRoutes
		return modulesRoutes

	@addListener: (id, signal) =>
		@listeners.push {id: id, signal: signal}

	@removeListener: (id, signal) =>
		for listener, i in @listeners
			if listener.id == id && listener.signal == signal
				@listeners.splice i, 1
				return

	@switch: (routesObjects) =>
		return if routesObjects.length == 0

		modulesRoutes = @cloneModulesRoutes()

		# required when switching from submodule to n-1 level
		@cleanSwitchers()

		# routesObjects should not be > 1 (can't guarantee the result)
		# lastSwitchers is the array of switchers needed for previous tree
		# lastSwitchersTmp is the array of switchers for wanted tree
		@lastSwitchers = @lastSwitchersTmp.slice()
		@lastSwitchersTmp = []

		for routeObject in routesObjects
			module = getModuleByRoute routeObject.route, modulesRoutes

			# if we're going to a parent route -> exit submodules
			if moduleIsAParent(module, previousModule)
				firstSubmodule = module.modules[0]
				firstSubmodule.switcher.exit()
				@lastSwitchersTmp.push module.switcher
				previousModule = module
				continue

			previousModule = module
			# dispatch for matching modules id
			for listener in @listeners
				if listener.id == module.id
					listener.signal.dispatch routeObject

			moduleObject = getModuleDefinitionById module.id

			if moduleObject?
				# 1) clean tree
				clonedModule = module
				cleanModuleTree(clonedModule, clonedModule)
				removeRoutedModules(clonedModule)
				addRoutesToParents(clonedModule)

				# 2) get top module
				topModule = getTopModule(clonedModule, @lastSwitchers)

				# 3) get array of switchers for wanted tree
				switchers = getSwitchersToRoot clonedModule
				cleanedSwitchers = []
				for s in switchers
					cleanedSwitchers.push s if cleanedSwitchers.indexOf(s) == -1

				for s in cleanedSwitchers
					@lastSwitchersTmp.push s if @lastSwitchersTmp.indexOf(s) == -1

				# 4) grab all batchIds needed for preloading new view
				modules = getModules topModule.parent
				modules.sort (moduleA, moduleB) =>
					if moduleA.routes? && moduleB.routes?
						return 0
					else if moduleA.routes?
						return -1
					else if moduleB.routes?
						return 1
					else
						return 0

				modulesIds = []
				modulesIds.push(module.id) for module in modules

				# get modules definitions
				modulesDefinitions = getModulesDefinitionsByIds modulesIds
				batchesIds = []
				for moduleDefinition in modulesDefinitions
					batchesIds = batchesIds.concat window[moduleDefinition.module].getBatches(moduleDefinition.id)

				# 5) when top module enter end, switch descending modules
				cascadeSwitch topModule, batchesIds, routeObject, clonedModule, true, topModule.switcher
			else
				throw "No module definition found for " + module.id

	@cleanSwitchers: =>
		switchersToClean = []
		for switcher in @lastSwitchers
			if @lastSwitchersTmp.indexOf(switcher) == -1
				switchersToClean.push switcher

		for switcher in switchersToClean
			switcher.reset()

	moduleIsAParent = (module, previousModule) =>
		if !previousModule?
			return false
		if previousModule.parent.id?
			if previousModule.parent.id == module.id
				return true
			else
				return moduleIsAParent(module, previousModule.parent)
		else
			return false

	addRoutesToParents = (module) =>
		if module.parent?
			unless module.parent.routes?
				module.parent.routes = []
			addRoutesToParents module.parent

	cascadeSwitch = (module, batchesIds, routeObject, requestedModule, isFirst, directSwitcher) =>
		return if !module?
		moduleParent = module.parent

		for m in moduleParent.modules
			batchesIds = null unless isFirst
			isFirst = false if hasRoutes(m)
			moduleDefinition = getModuleDefinitionById m.id

			if hasRoutes(m)
				if module.switcher?
					params = null
					params = routeObject.params if requestedModule == m
					ctx =
						m: m
						requestedModule: requestedModule
						batchesIds: batchesIds
						routeObject: routeObject
						isFirst: isFirst
						module: moduleParent
						lastSwitchers: @lastSwitchers
						lastSwitchersTmp: @lastSwitchersTmp
						directSwitcher: directSwitcher
					module.switcher.nextModuleReady.addOnce onNextModuleReady, ctx
					module.switcher.switch moduleDefinition.module, params, m.parentWrapperName, batchesIds, moduleDefinition.id

	onNextModuleReady = (moduleInstance) ->
		m = @m
		module = @module

		# add submodules to parent module
		if module.parent?
			m.parent.switcher.nextModule.addSubmodule moduleInstance

		if m.modules? && m.modules.length > 0
			# if there are submodules in tree, keep switching modules
			for submodule in m.modules
				cascadeSwitch submodule, @batchesIds, @routeObject, @requestedModule, @isFirst, @directSwitcher
		else
			# console.log @lastSwitchersTmp.reverse(), @lastSwitchers, @directSwitcher
			for switcher in @lastSwitchersTmp.reverse()
				if @lastSwitchers.indexOf(switcher) == -1 || switcher == @directSwitcher
					switcher.doSwitch()

	getSwitchersToRoot = (m) =>
		switchers = []
		if m.switcher?
			if switchers.indexOf(m.switcher) == -1
				switchers.push m.switcher
		if m.parent?
			tmpSwitchers = getSwitchersToRoot m.parent
			for s in tmpSwitchers
				if switchers.indexOf(s) == -1
					switchers.push s
		return switchers

	hasRoutes = (module) =>
		if module.routes?
			return true
		else if module.modules?
			for module in module.modules
				return true if hasRoutes(module)
			return false
		else
			return false

	getModulesDefinitionsByIds = (modulesIds) =>
		modulesDefinitions = []
		for moduleId in modulesIds
			moduleDefinition = getModuleDefinitionById moduleId
			if moduleDefinition?
				modulesDefinitions.push moduleDefinition
		return modulesDefinitions

	getModules = (rootModule) =>
		modules = []
		getModulesIterator(rootModule, modules)
		return modules

	getModulesIterator = (module, modules) =>
		if module.modules?
			for m in module.modules
				modules.push m
				getModulesIterator(m, modules)

	cleanModuleTree = (module, moduleExcepted) =>
		if module.parent?
			removeRoutedModules(module.parent, moduleExcepted)
			cleanModuleTree(module.parent, module.parent)

	removeRoutedModules = (module, moduleExcepted) =>
		if module.modules?
			module.modules = module.modules.filter (m) =>
				return true if m == moduleExcepted
				return false
			for m in module.modules
				if m != moduleExcepted
					removeRoutedModules(m, m)

	getTopModule = (module, lastSwitchers) =>
		if module.parent?.id? && isIdLastSwitcher(module.parent.id, lastSwitchers)
			return module # dirty check \ same level of submodule
		else if !module.parent?.id?
			return module # root
		else
			return getTopModule(module.parent, lastSwitchers)

	isIdLastSwitcher = (id, lastSwitchers) =>
		for switcher in lastSwitchers
			if switcher?.previousModule?.id == id
				return true
		return false

	parseRoutes = (data) =>
		routes = []
		for modulesRoutes in data
			if modulesRoutes.routes?
				if typeof modulesRoutes.routes == "string"
					routes.push modulesRoutes.routes
				else if modulesRoutes.routes instanceof Array
					routes = routes.concat modulesRoutes.routes
			if modulesRoutes.modules?
				routes = routes.concat parseRoutes(modulesRoutes.modules)
		return routes

	getModuleDefinitionById = (id) =>
		for moduleDefinition in @modulesDefinitions
			if id == moduleDefinition.id
				return moduleDefinition
		return null

	getModuleByRoute = (route, data) =>
		for modulesRoutes in data.modules
			if modulesRoutes.routes?
				if typeof modulesRoutes.routes == "string"
					if modulesRoutes.routes == route
						return modulesRoutes
				else if modulesRoutes.routes instanceof Array
					if modulesRoutes.routes.indexOf(route) > -1
						return modulesRoutes

			if modulesRoutes.modules?
				module = getModuleByRoute(route, modulesRoutes)
				return module if module?

	createSwitchers = (data) =>
		if data.modules?
			currentSwitcher = null
			for modulesRoutes in data.modules
				if modulesRoutes.routes?
					unless currentSwitcher?
						currentSwitcher = new ModulesSwitcher()
					modulesRoutes.switcher = currentSwitcher

				createSwitchers modulesRoutes

	createParents = (data) =>
		if data.modules?
			for modulesRoutes in data.modules
				unless modulesRoutes.parent?
					modulesRoutes.parent = data
				unless modulesRoutes.parentWrapperName?
					if data.id?
						modulesRoutes.parentWrapperName = data.id + @moduleWrapperSuffix
					else
						modulesRoutes.parentWrapperName = "root" + @moduleWrapperSuffix

				createParents modulesRoutes
