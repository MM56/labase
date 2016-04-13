class VScroll

	event 	= { originalEvent: null }

	@init: () =>
		window.addEventListener(Events.MOUSE_DOWN, @onMouseDown)
		window.addEventListener(Events.MOUSE_UP, @onMouseUp)
		window.addEventListener(Events.MOUSE_MOVE, @onMouseMove)
		window.addEventListener(Events.WHEEL, @onWheelMouse)
		window.addEventListener(Events.KEY_DOWN, @onKeyDown)
		window.addEventListener(Events.KEY_UP  , @onKeyUp)

	@destroy: () =>
		window.removeEventListener(Events.MOUSE_DOWN, @onMouseDown)
		window.removeEventListener(Events.MOUSE_UP, @onMouseUp)
		window.removeEventListener(Events.MOUSE_MOVE, @onMouseMove)
		window.removeEventListener(Events.WHEEL, @onWheelMouse)
		window.removeEventListener(Events.KEY_DOWN, @onKeyDown)
		window.removeEventListener(Events.KEY_UP  , @onKeyUp)

	@notify: (e) =>
		event.originalEvent = e
		Events.SCROLLED.dispatch(event)

	@onMouseDown: (e) =>
		@notify(e)

	@onMouseUp: (e) =>
		@notify(e)

	@onMouseMove: (e) =>
		@notify(e)

	@onKeyDown: (e) =>
		@notify(e)

	@onKeyUp: (e) =>
		@notify(e)

	@onWheelMouse: (e) =>
		@notify(e)


		
	