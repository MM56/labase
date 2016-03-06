class StringUtils

	@pad: (n, width, z) =>
		z = z || '0'
		n = n + ''
		if n.length >= width
			return n
		else
			return new Array(width - n.length + 1).join(z) + n

	@removeLeadingSlash: (str) =>
		if str.indexOf("/") == 0
			return str.substr 1
		return str

	@removeTrailingSlash: (str) =>
		if str.lastIndexOf("/") == str.length - 1
			return str.substring 0, str.lastIndexOf("/")
		return str

	@ucFirst: (str) =>
		return str.charAt(0).toUpperCase() + str.slice(1)
