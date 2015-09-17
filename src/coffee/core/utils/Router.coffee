class Router

	routeMatched: null
	regexps: null
	routes: null
	locale: null
	l10n: null
	currentHash: null
	noLocaleInRoute: false
	onSameRoute: null
	previousRoute: null
	previousHash: null

	constructor: (@locale, @l10n, @noLocaleInRoute) ->
		@onSameRoute = new MM.Signal()
		@routeMatched = new MM.Signal()
		@regexps = []

		window.addEventListener "popstate", @onPopState

	onPopState: (event) =>
		return if event?.state? && !Object.keys(event.state).length
		@navigate(event.state)

	navigate: (hash, @extra) =>
		@previousHash = @currentHash
		@currentHash = hash
		@parse()

	replaceState: (hash) =>
		if !@extra? || (@extra.silent? && !@extra.silent)
			if window.history.pushState
				if @previousRoute == hash
					window.history.replaceState(hash, null, hash)
				else
					window.history.pushState(hash, null, hash)
			else
				console.error "Not supporting window.history.pushState"

	parse: =>
		if @currentHash?
			currentRoute = @currentHash
		else
			currentRoute = window.location.pathname
			if currentRoute.indexOf(basePath) == 0
				currentRoute = currentRoute.substr basePath.length

		currentRoute = StringUtils.removeLeadingSlash(currentRoute)

		if !@noLocaleInRoute
			if currentRoute.indexOf(@locale) == 0
				currentRoute = currentRoute.substr @locale.length
				currentRoute = StringUtils.removeLeadingSlash(currentRoute)

			currentRoute = "/" + @locale + "/" + currentRoute
		else
			currentRoute =  "/" + currentRoute

		currentRoute = StringUtils.removeTrailingSlash(currentRoute)
		currentRoute += "/"


		# case when subfolders
		realRoute = StringUtils.removeLeadingSlash(currentRoute)
		realRoute = basePath + realRoute

		@replaceState(realRoute)

		if @previousRoute?
			if @previousRoute == currentRoute
				@onSameRoute.dispatch()
				return

		@previousRoute = currentRoute

		console.log '%c Router ', 'background: #555; color: #fff', currentRoute

		matchedRoutes = []
		for regexpObject, i in @regexps
			regexpResult = regexpObject.regexp.exec currentRoute
			if regexpResult?
				rawParams = regexpResult.splice(1)
				params = {}
				for rawParam, j in rawParams
					params[regexpObject.keys[j].name] = rawParam
				matchedRoutes.push {route: @routes[i], params: params}

		if matchedRoutes.length > 0
			@routeMatched.dispatch matchedRoutes
		else
			console.error "No routes matched."
	addRoutes: (@routes) =>
		for route in @routes
			localizedRoute = @localizeRoute(route)
			keys = []
			if @noLocaleInRoute
				route = localizedRoute
			else
				route = "/" + @locale + localizedRoute
			@regexps.push {regexp: pathToRegexp(route, keys), keys: keys}

	localizeRoute: (route) =>
		template = Handlebars.compile route
		return template(@l10n.routes)