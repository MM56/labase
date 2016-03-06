class Events

	if "ontouchstart" || "onmsgesturechange" in window
		@SUPPORTS_TOUCH = true
		@MOUSE_UP = "touchend"
		@MOUSE_OUT = "touchend"
		@MOUSE_DOWN = "touchstart"
		@MOUSE_OVER = "touchstart"
		@MOUSE_MOVE = "touchmove pointermove MSPointerMove"
	else
		@SUPPORTS_TOUCH = false
		@MOUSE_UP = "mouseup"
		@MOUSE_OUT = "mouseleave"
		@MOUSE_DOWN = "mousedown"
		@MOUSE_OVER = "mouseenter"
		@MOUSE_MOVE = "mousemove"

	@WHEEL 					= "wheel"
	@CLICK 					= "click"
	@KEY_UP 				= "keyup"
	@RESIZE 				= "resize"
	@KEY_DOWN 				= "keydown"
	@VISIBILITY_CHANGE 		= "visibilitychange"
	
	@SCROLLED 	= new MM.Signal()
	@RESIZED 	= new MM.Signal()