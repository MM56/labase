class Router

	#
	matchedRoute: null

	# on init
	l10n: null
	noLocaleInRoute: false
	regexps: null
	routes: null
	locale: null

	# signals
	onSameRoute: null
	routeMatched: null
	middlewareRefused: null

	# accessible
	lastRoute: null
	tmpNextRoute: null
	nextRoute: null
	isPopState: false

	constructor: (@locale, @l10n, @noLocaleInRoute) ->
		@onSameRoute = new MM.Signal()
		@routeMatched = new MM.Signal()
		@middlewareRefused = new MM.Signal()
		@regexps = []
		@isPopState = false

		window.addEventListener "popstate", @onPopState

	onPopState: (event) =>
		return if !event?.state?
		@isPopState = true
		@navigate(event.state)

	navigate: (hash, @extra) =>
		@parse(hash)

	replaceState: (hash) =>
		if !@extra? || (@extra.silent? && !@extra.silent)
			if window.history.pushState
				if !@lastRoute?
					return
				if @lastRoute.cleanFull == hash
					window.history.replaceState(hash, null, hash)
				else
					window.history.pushState(hash, null, hash)
			else
				console.error "Not supporting window.history.pushState"

	parse: (hash) =>
		if !hash?
			# on init
			hash = @removeBasePath window.location.pathname

		@lastRoute = @nextRoute
		@tmpNextRoute = @buildRouteObjectFromHash hash

		if @lastRoute? && @lastRoute.cleanFull == @tmpNextRoute.cleanFull
			@onSameRoute.dispatch()
			return

		console.log '%c Router ', 'background: #555; color: #fff', @tmpNextRoute.clean

		# assume we have only 1 route
		matchedRoute = null
		for regexpObject, i in @regexps
			regexpResult = regexpObject.regexp.exec @tmpNextRoute.clean
			if regexpResult?
				rawParams = regexpResult.splice(1)
				params = {}
				for rawParam, j in rawParams
					params[regexpObject.keys[j].name] = rawParam
				routeObj = regexpObject.routeObj
				matchedRoute = {route: routeObj.routes[0], params: params, middleware: routeObj.middleware}
				break

		@parseResponse(matchedRoute)

	parseResponse: (matchedRoute) =>
		if matchedRoute?
			if matchedRoute.middleware?
				@matchedRoute = matchedRoute
				MiddlewareMethods.RESPONSE.addOnce @onMiddlewareResponse
				MiddlewareMethods.callMethod matchedRoute.middleware
			else
				@doReplaceState()
				@nextRoute = @tmpNextRoute
				@routeMatched.dispatch [matchedRoute]
		else
			console.error "No routes matched."

	onMiddlewareResponse: (isPositive) =>
		@nextRoute = @tmpNextRoute
		if isPositive
			matchedRoute = @matchedRoute
			@doReplaceState()
		else
			@middlewareRefused.dispatch()
			return

		@routeMatched.dispatch [matchedRoute]

	doReplaceState: =>
		if !@isPopState
			@replaceState @tmpNextRoute.cleanFull
		@isPopState = false

	removeBasePath: (str) =>
		if str.indexOf(basePath) == 0
			return str.substr basePath.length
		return str

	buildRouteObjectFromHash: (hash) =>
		route = {}
		route.raw = hash

		hash = StringUtils.removeLeadingSlash hash
		if @noLocaleInRoute
			hash =  "/" + hash
		else
			localeRegex = new RegExp("^" + @locale + "([^\\w]|$)")
			hash = hash.replace localeRegex, ""
			hash = StringUtils.removeLeadingSlash(hash)
			hash = "/" + @locale + "/" + hash
		hash = StringUtils.removeTrailingSlash(hash)
		hash += "/"
		route.clean = hash

		hash = StringUtils.removeLeadingSlash(hash)
		hash = basePath + hash
		route.cleanFull = hash

		return route

	addRoutes: (@routes) =>
		for routeObj in @routes
			for route in routeObj.routes
				localizedRoute = @localizeRoute(route)
				keys = []
				if @noLocaleInRoute
					route = localizedRoute
				else
					route = "/" + @locale + localizedRoute
				@regexps.push {regexp: pathToRegexp(route, keys), keys: keys, middleware: routeObj.middleware, routeObj: routeObj}

	localizeRoute: (route) =>
		template = Handlebars.compile route
		return template(@l10n.routes)
