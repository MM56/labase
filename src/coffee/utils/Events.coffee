class Events

	@DOWN = if !$('html').hasClass('no-touch') then 'touchstart' else 'mousedown'
	@UP = if !$('html').hasClass('no-touch') then 'touchend' else 'mouseup'
	@MOVE = if !$('html').hasClass('no-touch') then 'touchmove' else 'mousemove'
	@CLICK = 'click'
	@OVER  = if !$('html').hasClass('no-touch') then 'touchstart' else 'mouseenter'
	@LEAVE = if !$('html').hasClass('no-touch') then 'touchend' else 'mouseleave'