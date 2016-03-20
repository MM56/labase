class W

	@init: () =>
		@$window = $(window)
		@$document = $(document)
		@$html = $('html')
		@$body = $('body')
		@$root = $('#root')
		@orientationNotifier = $('#orientation-notifier')
		@isPhone = @$html.hasClass "phone"
		@isIOS = @$html.hasClass "ios"
		@isTablet = @$html.hasClass "tablet"
		@isDesktop = @$html.hasClass "desktop"
		@isNoMobile = @$html.hasClass "nomobile"
		@isTouch = @$html.hasClass "touch"
		@isIE = @$html.hasClass "ie"
		@isFirefox = @$html.hasClass "firefox"
		@isSafari = @$html.hasClass "safari"

		if @isTablet || @isPhone
			FastClick.attach(@$body[0])
			if @isTablet
				@orientationNotifier.find('.anim').addClass "sprite-rotate_tablet_icon"
			else
				@orientationNotifier.find('.anim').addClass "sprite-rotate_phone_icon"

		@onResize()
		@bind()

	@bind: =>
		Events.SCROLLED.add @onScroll
		@$window.on Events.CLICK, "a[rel='internal']", @onClick
		@$window.on(Events.RESIZE, @onResize)

		# if @isTablet
		# 	@$document.bind "visibilitychange", @onResize
		# 	@$document.bind Events.MOUSE_OVER, @onTouchStart

		# if @isPhone
		# 	@$document.bind Events.MOUSE_MOVE, @onTouchMove

	@onClick: (e) =>
		e.preventDefault()
		e.stopPropagation()
		$this = $(this)
		return if $this.hasClass("disabled")
		app.router.navigate $this.attr("href") if $this.attr("href")?

	@onScroll: (e) =>

	@onResize: () =>
		@ww = window.innerWidth
		@wh = window.innerHeight
		@wo = window.orientation

		if @isTablet
			if @ww > @wh
				MM.css @$html[0], "height", @wh + "px"
				@hideOrientationNotifier()
			else
				MM.css @$html[0], "height", "100%"
				@displayOrientationNotifier()

		else if @isPhone
			if @$html.hasClass "androidos"
				if (@wo % 180) == 0
					@hideOrientationNotifier()
				else
					@displayOrientationNotifier()
			else
				if @ww < @wh
					@hideOrientationNotifier()
				else
					@displayOrientationNotifier()

		Events.RESIZED.dispatch()

	@displayOrientationNotifier: =>
		MM.css @orientationNotifier[0], "display", "block"

	@hideOrientationNotifier: =>
		MM.css @orientationNotifier[0], "display", "none"
		if @isPhone
			MM.css @$html[0], "overflow", "visible"
			MM.css @$body[0], "overflow", "visible"

	@onTouchStart: (event) =>
		return if event.target.tagName == 'INPUT'
		return if event.target.tagName == 'TEXTAREA'
		event.preventDefault()

	@onTouchMove: (event) =>
		if !$(event.target).hasClass("scrollable")
			event.preventDefault()
