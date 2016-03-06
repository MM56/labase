class FunctionUtils

	@getName: (f) =>
		name = f.toString()
		name = name.substr "function ".length
		name = name.substr 0, name.indexOf("(")
		return name

	@getSupportVideo: () =>
		elem = document.createElement('video')
		bool = false
		try
			if bool = ! !elem.canPlayType
				bool = new Boolean(bool)
				bool.ogg = elem.canPlayType('video/ogg; codecs="theora"').replace(/^no$/, '')
				bool.h264 = elem.canPlayType('video/mp4; codecs="avc1.42E01E"').replace(/^no$/, '')
				bool.webm = elem.canPlayType('video/webm; codecs="vp8, vorbis"').replace(/^no$/, '')
		catch e
		return bool

	@getNearest: (array, value) =>
		smallestDiff = Math.abs(value - array[0])
		closest = 0
		i = 1
		while i < array.length
			currentDiff = Math.abs(value - array[i])
			if currentDiff < smallestDiff
				smallestDiff = currentDiff
				closest = i
			i++

		return array[closest]

	@randomNumber: (min, max) =>
		return min + (Math.random() * (max - min))

	@pointSphere: (rad1, rad2, r) =>
		x = Math.cos(rad1) * Math.cos(rad2) * r
		z = Math.cos(rad1) * Math.sin(rad2) * r
		y = Math.sin(rad1) * r
		return [x, y, z]

	@getCoverSizeImage: (picWidth, picHeight, containerWidth, containerHeight) =>
		pw = picWidth
		ph = picHeight
		cw = containerWidth || W.ww
		ch = containerHeight || W.wh
		pr = pw / ph
		cr = cw / ch

		if cr < pr
			return {
				'width': ch * pr
				'height': ch
				'top': 0
				'left': - ((ch * pr) - cw) * 0.5
			}

		else
			return {
				'width': cw
				'height': cw / pr
				'top': - ((cw / pr) - ch) * 0.5
				'left': 0
			}

	@getContainSizeImage: (picWidth, picHeight, containerWidth, containerHeight) =>
		pw = picWidth
		ph = picHeight
		cw = containerWidth || W.ww
		ch = containerHeight || W.wh
		pr = pw / ph
		cr = cw / ch

		if cr < pr
			return {
				'width': cw
				'height': cw / pr
				'top': (ch - cw / pr) * 0.5
				'left': 0
			}

		else
			return {
				'width': ch * pr
				'height': ch
				'top': 0
				'left': (cw - ch * pr) * 0.5
			}

