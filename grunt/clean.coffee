module.exports =
	clean:
		all: [
			"<%= globalConfig.buildPath %>/conf/*"
			"<%= globalConfig.buildPath %>/css/*"
			"<%= globalConfig.buildPath %>/js/*"
			"<%= globalConfig.buildPath %>/manifest.appcache"
			"<%= globalConfig.buildPath %>/img/sprites"
		]
		sprites: [
			"<%= globalConfig.buildPath %>/img/sprites"
		]
		img: [
			"<%= globalConfig.buildPath %>/img/static"
		]
		js: [
			"<%= globalConfig.buildPath %>/js/*"
			"!<%= globalConfig.buildPath %>/js/built*.js"
		]
		sass: [
			"<%= globalConfig.srcPath %>/scss/sprites"
		]
