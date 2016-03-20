class App

	manifestLoader : null
	listeners : null

	constructor: ->
		window.app = @
		@initGlobal()

	initGlobal: =>
		@tracker = new GATracker()
		
		@pixelRatio = window.devicePixelRatio || 1
		@pixelRatio = 2 if window.devicePixelRatio > 2
		@pixelRatio += "x"

		@datas =
			pixelRatio: @pixelRatio
			svgs: svgs
			GLOBAL:
				baseURL: baseURL
				basePath: basePath
				locale: locale
				isDesktop: isDesktop
				isTablet: isTablet
				isPhone: isPhone
				assetsPath: assetsPath
				assetsBaseURL: assetsBaseURL

		W.init()
		@manifestLoader = new ManifestLoader(basePath, @datas)
		@manifestLoader.isPhone = W.isPhone
		@manifestLoader.isTablet = W.isTablet
		@manifestLoader.isDesktop = W.isDesktop

		rAFManager.init()
		VScroll.init()

		@mainLoader = new MainLoader()

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
		#SoundManager.init()


	onRoutesMatched: (matchedRoutes) =>
		if matchedRoutes
			ModulesManager.switch matchedRoutes
		# else
		# 	app.router.navigate "/404"

new App()
