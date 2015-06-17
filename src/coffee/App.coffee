class App

	manifestLoader : null
	listeners : null

	constructor: ->
		@initGlobal()

	initGlobal: =>
		@pixelRatio = window.devicePixelRatio || 1
		@pixelRatio = 2 if window.devicePixelRatio > 2
		@pixelRatio += "x"
		
		W.init()
		@manifestLoader = new ManifestLoader(basePath, { "pixelRatio" : @pixelRatio })
		@manifestLoader.isPhone = W.isPhone
		@manifestLoader.isTablet = W.isTablet
		@manifestLoader.isDesktop = W.isDesktop
		@manifestLoader.isWebp = W.isWebp
		
		rAFManager.init()

		if W.html.hasClass "csstransforms3d"
			FunctionStats.init()

	init: ->
		@datas = {}
		@loadConfig()

	loadConfig: =>
		@manifestLoader.complete.add @onConfigLoaded
		@manifestLoader.load [
			{id: "modulesRoutes", src: "datas/modules_routes.json"},
			{id: "manifest", src: "datas/manifest.json"},
			# {id: "l10n", src: apiURL},
			{id: "l10n", src: "datas/l10n/" + locale + ".json"},
		], true

	onConfigLoaded: () =>
		@manifestLoader.complete.remove @onConfigLoaded

		if typeof @manifestLoader.defaults.l10n == "string"
			@datas.l10n = JSON.parse @manifestLoader.defaults.l10n
		else
			@datas.l10n = @manifestLoader.defaults.l10n

		@datas.l10n.GLOBAL = {
			baseURL: baseURL
			basePath: basePath
			locale: locale
		}

		@manifestLoader.addData @datas.l10n
		@manifestLoader.addCachedTemplates(defaultTemplates)
		@onModulesRoutesLoaded(@manifestLoader.defaults)

	onModulesRoutesLoaded: (data) =>
		@datas.modulesRoutes = data.modulesRoutes
		@datas.modulesRoutes = $.parseJSON data.modulesRoutes if typeof data.modulesRoutes == "string"
			
		ModulesManager.setModulesRoutesData @datas.modulesRoutes
		@initModulesDefault()

		@initRouter()
		@connectSwitcherToRouter()
		@start()

	start: () =>
		@router.parse()

	# 	@testRouteListener = new signals.Signal()
	# 	@testRouteListener.add @onRouteTriggered
	# 	ModulesManager.addListener "page", @testRouteListener

	# onRouteTriggered: (routeObject) =>
	# 	console.log "---------------", routeObject

	initRouter: =>
		@router = new Router(locale, @datas.l10n, noLocaleInRoute)
		@router.addRoutes ModulesManager.routes

	connectSwitcherToRouter: =>
		@router.routeMatched.add @onRoutesMatched

	initModulesDefault: =>
		@loader = new LoaderModule()

	onRoutesMatched: (matchedRoutes) =>
		ModulesManager.switch matchedRoutes

