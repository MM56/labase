class rAFManager

	@datas: null

	@init: =>
		@datas = []
		TweenMax.ticker.addEventListener "tick", @tick

	@tick: () =>
		now = (new Date()).getTime()
		i =  @datas.length - 1
		while i >= 0
			data = @datas[i]
			delta = now - data.lastTime
			interval = 1000 / data.fps
			if delta > interval
				data.lastTime = now - (delta % interval)
				if data.delay? && data.delay > 0
					data.delayCount++
					continue if data.delayCount < data.delay
				data.cb()
				@remove data.cb if data.once
			i--

	@add: (cb, fps = 60, delay = 0, once = false) =>
		return false if typeof cb != "function"
		data = {cb: cb, fps: fps, once: once, delayCount: 0, delay: delay, lastTime: (new Date()).getTime()}
		@datas.push data
		data.id = @datas.length
		return data

	@addOnce: (cb, fps = 60, delay = 0) =>
		return @add cb, fps, delay, true

	@remove: (cb) =>
		for data, i in @datas
			if data.cb == cb
				@datas.splice i, 1
				break