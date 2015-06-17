module.exports =
	uglify:
		options:
			compress:
				drop_console: true
		all:
			expand: true
			cwd: "<%= globalConfig.buildPath %>/js"
			src: "**/*.js"
			dest: "<%= globalConfig.buildPath %>/js"