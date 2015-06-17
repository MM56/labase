class W

	@_els 			: []
	@_handlers 		: {}

	@init: () =>
		@window = $(window)
		@document = $(document)
		@html = $('html')
		@body = $('body')
		@root = $('#root,html,body')
		@orientationNotifier = $('#orientation-notifier')
		@detect = new MobileDetect(window.navigator.userAgent)
		@isPhone = @html.hasClass "phone"
		@isIOS = @html.hasClass "ios"
		@isTablet = @html.hasClass "tablet"
		@isDesktop = @html.hasClass "desktop"
		@isNoMobile = @html.hasClass "nomobile"
		@isTouch = @html.hasClass "touch"
		@isIE = @html.hasClass "ie"
		@isWebp = Modernizr.webp

		if @isTablet || @isPhone
			FastClick.attach(@body[0])

		if @isTablet
			@orientationNotifier.find('.anim').addClass "sprite-rotate_tablet_icon"
		else if @isPhone
			@orientationNotifier.find('.anim').addClass "sprite-rotate_phone_icon"

		@onResize()
		@bind()
		
	@bind: =>
		@window.on "resize", @onResize
		@body.on Events.CLICK, "a[rel='internal']", (event) ->
			event.preventDefault()
			event.stopPropagation()
			$this = $(this)
			return if $this.hasClass("disabled")
			app.router.navigate $this.attr("href") if $this.attr("href")?

		if @isTablet
			@document.bind "visibilitychange", @onResize
			@document.bind "touchstart", @onTouchStart

		if @isPhone
			@document.bind "touchmove", @onTouchMove

	@add: (el) =>
		@_els.push el

	@remove: (obj) =>
		for item,i in @_els
			if item == obj
				@_els.splice(i, 1)

	@onResize: () =>
		@ww = window.innerWidth
		@wh = window.innerHeight
		@wo = window.orientation

		if @isTablet
			if @ww > @wh
				MM.css @html[0], "height", @wh + "px"
				#@window[0].scrollTo(0,0)
				@hideOrientationNotifier()
			else
				MM.css @html[0], "height", "100%"
				@displayOrientationNotifier()

		if @isPhone
			if @html.hasClass "androidos"
				if (@wo % 180) == 0
					@hideOrientationNotifier()
				else
					@displayOrientationNotifier()
			else
				if @ww < @wh
					@hideOrientationNotifier()
				else
					@displayOrientationNotifier()

		for el in @_els
			el.onResize()

	@displayOrientationNotifier: =>
		MM.css @orientationNotifier[0], "display", "block"
		if @isPhone
			MM.css @html[0], "overflow", "hidden"
			MM.css @body[0], "overflow", "hidden"

	@hideOrientationNotifier: =>
		MM.css @orientationNotifier[0], "display", "none"
		if @isPhone
			MM.css @html[0], "overflow", "visible"
			MM.css @body[0], "overflow", "visible"

	@onTouchStart: (event) =>
		return if event.target.tagName == 'INPUT'
		return if event.target.tagName == 'TEXTAREA'
		event.preventDefault()

	@onTouchMove: (event) =>
		if !$(event.target).hasClass("scrollable")
			event.preventDefault()
