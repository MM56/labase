class App

	manifestLoader : null
	listeners : null

	constructor: ->
		window.app = @
		@initGlobal()

	initGlobal: =>
		@pixelRatio = window.devicePixelRatio || 1
		@pixelRatio = 2 if window.devicePixelRatio > 2
		@pixelRatio += "x"

		@datas =
			pixelRatio: @pixelRatio
			svg: svg
			GLOBAL:
				baseURL: baseURL
				basePath: basePath
				locale: locale
				assetsPath: assetsPath
				assetsBaseURL: assetsBaseURL

		W.init()
		@manifestLoader = new ManifestLoader(basePath, @datas)
		@manifestLoader.isPhone = W.isPhone
		@manifestLoader.isTablet = W.isTablet
		@manifestLoader.isDesktop = W.isDesktop
		@manifestLoader.isWebp = W.isWebp

		rAFManager.init()
		VScroll.init()

		@mainLoader = new MainLoader()

		if W.html.hasClass "csstransforms3d" && ["staging", "prod"].indexOf(env) == -1
			FunctionStats.init()

		@init()

	init: =>
		@loadConfig()

	loadConfig: =>
		@manifestLoader.defaults["modulesRoutes"] = routesJSON
		@manifestLoader.defaults["l10n"] = l10nJSON
		@manifestLoader.defaults["manifest"] = manifestJSON
		@onConfigLoaded()

	onConfigLoaded: () =>
		@manifestLoader.complete.remove @onConfigLoaded
		@datas.l10n = @manifestLoader.defaults.l10n
		@manifestLoader.addData @datas.l10n
		@manifestLoader.addCachedTemplates(defaultTemplates)
		@onModulesRoutesLoaded(@manifestLoader.defaults)

	onModulesRoutesLoaded: (data) =>
		@datas.modulesRoutes = data.modulesRoutes
		ModulesManager.setModulesRoutesData @datas.modulesRoutes
		@initRouter()
		@initModulesDefault()
		@connectSwitcherToRouter()
		@start()

	start: () =>
		@router.parse()

	# 	@testRouteListener = new MM.Signal()
	# 	@testRouteListener.add @onRouteTriggered
	# 	ModulesManager.addListener "page", @testRouteListener

	# onRouteTriggered: (routeObject) =>
	# 	console.log "---------------", routeObject

	initRouter: =>
		@router = new RouterExtend(locale, @datas.l10n, noLocaleInRoute)
		@router.addRoutes ModulesManager.routes

	connectSwitcherToRouter: =>
		@router.routeMatched.add @onRoutesMatched

	initModulesDefault: =>
		@loader = new LoaderModule()

	onRoutesMatched: (matchedRoutes) =>
		ModulesManager.switch matchedRoutes

new App()
