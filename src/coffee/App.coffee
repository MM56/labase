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

	init: =>
		@datas = {}
		@loadConfig()

	loadConfig: =>
		@manifestLoader.defaults["modulesRoutes"] = routesJSON
		@manifestLoader.defaults["l10n"] = l10nJSON
		@manifestLoader.defaults["manifest"] = manifestJSON

		@manifestLoader.complete.add @onConfigLoaded
		@manifestLoader.load "defaultDesktop"

	onConfigLoaded: () =>
		@manifestLoader.complete.remove @onConfigLoaded
		@datas.l10n = @manifestLoader.defaults.l10n
		@datas.GLOBAL = {
			baseURL: baseURL
			basePath: basePath
			locale: locale
		}
		@manifestLoader.addData @datas.l10n
		@manifestLoader.addCachedTemplates(defaultTemplates)
		@onModulesRoutesLoaded(@manifestLoader.defaults)

	onModulesRoutesLoaded: (data) =>
		@datas.modulesRoutes = data.modulesRoutes
		ModulesManager.setModulesRoutesData @datas.modulesRoutes
		@initModulesDefault()
		@initRouter()
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
		@router = new Router(locale, @datas.l10n, noLocaleInRoute)
		@router.addRoutes ModulesManager.routes

	connectSwitcherToRouter: =>
		@router.routeMatched.add @onRoutesMatched

	initModulesDefault: =>
		@loader = new LoaderModule()

	onRoutesMatched: (matchedRoutes) =>
		ModulesManager.switch matchedRoutes

