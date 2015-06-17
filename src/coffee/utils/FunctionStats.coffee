class FunctionStats

	@init: () =>
		stats = new Stats()
		stats.setMode 0 # 0: fps, 1: ms

		# Align top-left
		stats.domElement.style.position = "fixed"
		stats.domElement.style.right = "0px"
		stats.domElement.style.top = "0px"
		stats.domElement.style.zIndex = "100000"
		document.body.appendChild stats.domElement
		setInterval (->
			stats.begin()
			# your code goes here
			stats.end()
			return
		), 1000 / 60