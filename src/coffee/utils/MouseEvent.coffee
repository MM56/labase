class MouseEvent

	if "ontouchstart" || "onmsgesturechange" in window
		@SUPPORTS_TOUCH = true
		@MOUSE_DOWN = "touchstart"
		@MOUSE_UP = "touchend"
		@MOUSE_MOVE = "touchmove pointermove MSPointerMove"
		@MOUSE_OVER = "touchstart"
		@MOUSE_OUT = "touchend...."
	else
		@SUPPORTS_TOUCH = false
		@MOUSE_DOWN = "mousedown"
		@MOUSE_UP = "mouseup"
		@MOUSE_MOVE = "mousemove"
		@MOUSE_OVER = "mouseenter"
		@MOUSE_OUT = "mouseleave"

	@CLICK = "click"