class Share
	@twitter: (text, hashtags = []) =>
		width  = 500
		height = 310

		link = "https://twitter.com/intent/tweet?text=" + encodeURIComponent(text)
		if hashtags.length > 0
			link += "&hashtags=" + hashtags.join(",")

		@openPopup link, width, height

	@facebook: (url) =>
		width  = 555
		height = 320

		# console.log encodeURIComponent(url)

		link = "http://www.facebook.com/sharer/sharer.php?u=" + encodeURIComponent(url)

		@openPopup link, width, height

	@openPopup: (link, width, height) =>
		left = (window.innerWidth - width) * .5
		top = (window.innerHeight - height) * .5
		options = 'width=' + width + ',height=' + height + ',top=' + top + ',left=' + left + ',scrollbars=1,location=0,menubar=0,resizable=0,status=0,toolbar=0'
		window.open link, 'twitter', options