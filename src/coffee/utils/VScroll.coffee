class VScroll

	els = []
	isDown = false
	# Mutiply the touch action by two making the scroll a bit faster than finger movement
	touchMult = 1
	# Firefox on Windows needs a boost, since scrolling is very slow
	firefoxMult = 100
	# How many pixels to move with each key press
	keyStep = 120
	# General multiplier for all mousehweel including FF
	mouseMult = 1
	bodyTouchAction = undefined
	hasWheelEvent = 'onwheel' in document
	hasMouseWheelEvent = 'onmousewheel' in document
	hasTouch = "ontouchstart" of document
	hasTouchWin = navigator.msMaxTouchPoints and navigator.msMaxTouchPoints > 1
	hasPointer = !!window.navigator.msPointerEnabled
	hasKeyDown = "onkeydown" of document
	isFirefox = navigator.userAgent.indexOf("Firefox") > -1
	event = {
		y: 0
		x: 0
		deltaX: 0
		deltaY: 0
		lastDeltaX : [0,0,0]
		lastDeltaY : [0,0,0]
		lastX : 0
		lastY : 0
		originalEvent: null
		momentumX : 0
		momentumY : 0
	}
	deltaIndex = 0
	historyDeltaMax = 3
	
	@init: () =>
		document.body.addEventListener "wheel", @onWheel
		document.body.addEventListener "mousewheel", @onMouseWheel 
		if hasTouch
			document.body.addEventListener "touchstart", @onTouchStart
			document.body.addEventListener "touchmove", @onTouchMove
			document.body.addEventListener "touchend", @onTouchEnd
			document.body.addEventListener "touchcancel", @onTouchEnd
		else
			document.body.addEventListener "mousedown", @onMouseStart
			document.body.addEventListener "mousemove", @onMouseMove
			document.body.addEventListener "mouseup", @onMouseEnd
			document.body.addEventListener "mouseleave", @onMouseEnd

		if hasPointer && hasTouchWin
			bodyTouchAction = document.body.style.msTouchAction
			document.body.style.msTouchAction = "none"
			document.body.addEventListener "MSPointerDown", @onTouchStart, true
			document.body.addEventListener "MSPointerMove", @onTouchMove, true
			document.body.addEventListener "MSPointerUp", @onTouchEnd, true

		if hasKeyDown
			document.body.addEventListener "keydown", @onKeyDown
			document.body.addEventListener "keyup", @onKeyUp

	@destroy: () =>
		if hasWheelEvent 
			document.body.removeEventListener "wheel", @onWheel
		if hasMouseWheelEvent
			document.body.removeEventListener "mousewheel", @onMouseWheel 
		if hasTouch
			document.body.removeEventListener "touchstart", @onTouchStart
			document.body.removeEventListener "touchmove", @onTouchMove
			document.body.removeEventListener "touchend", @onTouchEnd
			document.body.removeEventListener "touchcancel", @onTouchEnd
		else
			document.body.removeEventListener "mousedown", @onMouseStart
			document.body.removeEventListener "mousemove", @onMouseMove
			document.body.removeEventListener "mouseup", @onMouseEnd
			document.body.removeEventListener "mouseleave", @onMouseEnd

		if hasPointer && hasTouchWin
			bodyTouchAction = document.body.style.msTouchAction
			document.body.style.msTouchAction = "none"
			document.body.removeEventListener "MSPointerDown", @onTouchStart, true
			document.body.removeEventListener "MSPointerMove", @onTouchMove, true
			document.body.removeEventListener "MSPointerUp", @onTouchEnd, true

		if hasKeyDown
			document.body.removeEventListener "keydown", @onKeyDown
			document.body.removeEventListener "keyup", @onKeyUp

	@add: (el) =>
		els.push el

	@remove: (obj) =>
		for item,i in els
			if item == obj
				els.splice(i, 1)

	@onScroll: (e) =>
		for el in els
			el.onScroll(e)

	@notify: (e) =>
		event.x += event.deltaX
		event.y += event.deltaY
		event.originalEvent = e
		@onScroll(event)

	@onWheel: (e) =>
		# In Chrome and in Firefox (at least the new one)
		event.deltaX = e.wheelDeltaX || e.deltaX * -1
		event.deltaY = e.wheelDeltaY || e.deltaY * -1
		# for our purpose deltamode = 1 means user is on a wheel mouse, not touch pad 
		# real meaning: https://developer.mozilla.org/en-US/docs/Web/API/WheelEvent#Delta_modes
		if isFirefox && e.deltaMode == 1
			event.deltaX *= firefoxMult
			event.deltaY *= firefoxMult

		event.deltaX *= mouseMult
		event.deltaY *= mouseMult

		@notify(e)

	@onMouseWheel: (e) =>
		# In Safari, IE and in Chrome if 'wheel' isn't defined
		event.deltaX = if e.wheelDeltaX then e.wheelDeltaX else 0
		event.deltaY = if e.wheelDeltaY then e.wheelDeltaY else e.wheelDelta
		@notify(e)

	@onTouchStart: (e) =>
		event.lastX = e.touches[0].pageX
		event.lastY = e.touches[0].pageY
		event.deltaX = 0
		event.deltaY = 0
		event.momentumX = 0
		event.momentumY = 0
		@notify(e)

	@onTouchMove: (e) =>
		t = e.touches[0]
		event.deltaX = (t.pageX - event.lastX) * touchMult
		event.deltaY = (t.pageY - event.lastY) * touchMult

		event.lastDeltaX[deltaIndex] = event.deltaX
		event.lastDeltaY[deltaIndex] = event.deltaY
		deltaIndex = (deltaIndex + 1) % historyDeltaMax
		
		event.lastX = t.pageX
		event.lastY  = t.pageY
		@notify(e)

	@onTouchEnd: (e) =>
		event.momentumX = event.lastDeltaX.reduce(((a, b) ->
			if Math.abs(a) > Math.abs(b) then a else b
		), 0)
		event.momentumY = event.lastDeltaY.reduce(((a, b) ->
			if Math.abs(a) > Math.abs(b) then a else b
		), 0)
		i = 0
		while i < historyDeltaMax
			event.lastDeltaX[i] = 0
			event.lastDeltaY[i] = 0
			i++
		@notify(e)

	@onMouseStart: (e) =>
		isDown = true
		event.lastX = e.pageX
		event.lastY = e.pageY
		event.deltaX = 0
		event.deltaY = 0
		event.momentumX = 0
		event.momentumY = 0
		@notify(e)
		
	@onMouseMove: (e) =>
		return if !isDown
		event.deltaX = (e.pageX - event.lastX) * touchMult
		event.deltaY = (e.pageY - event.lastY) * touchMult

		event.lastDeltaX[deltaIndex] = event.deltaX
		event.lastDeltaY[deltaIndex] = event.deltaY
		deltaIndex = (deltaIndex + 1) % historyDeltaMax
		event.lastX = e.pageX
		event.lastY = e.pageY
		@notify(e)

	@onMouseEnd: (e) =>
		isDown = false
		event.momentumX = event.lastDeltaX.reduce(((a, b) ->
			if Math.abs(a) > Math.abs(b) then a else b
		), 0)
		event.momentumY = event.lastDeltaY.reduce(((a, b) ->
			if Math.abs(a) > Math.abs(b) then a else b
		), 0)

		i = 0
		while i < historyDeltaMax
			event.lastDeltaX[i] = 0
			event.lastDeltaY[i] = 0
			i++

		@notify(e)

	@onKeyDown: (e) =>
		# 37 left arrow, 38 up arrow, 39 right arrow, 40 down arrow
		event.deltaX = event.deltaY = 0
		event.keyCode = e.keyCode
		isDown = false
		switch e.keyCode
			when 37
				event.deltaX = -keyStep
			when 39
				event.deltaX = keyStep
			when 38
				event.deltaY = keyStep
			when 40
				event.deltaY = -keyStep
		@notify(e)

	@onKeyUp: (e) =>
		event.deltaX = event.deltaY = 0
		isDown = false
		@notify(e)


		
	