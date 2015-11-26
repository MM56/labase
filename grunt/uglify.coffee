module.exports =
	uglify:
		options:
			compress:
				drop_console: true
			screwIE8: true
		all:
			expand: true
			cwd: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/js"
			src: [
				"build.js"
				"build.mobile.js"
			]
			dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/js"