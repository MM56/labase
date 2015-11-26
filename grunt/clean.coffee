module.exports =
	clean:
		all: [
			"<%= globalConfig.buildPath %>/conf/*"
			"<%= globalConfig.buildPath %>/css"
			"<%= globalConfig.buildPath %>/js"
			"<%= globalConfig.buildPath %>/manifest.appcache"
			"<%= globalConfig.buildPath %>/img"
			"<%= globalConfig.buildPath %>/static/*"
		]
		sprites: [
			"<%= globalConfig.buildPath %>/img/sprites"
		]
		js: [
			"<%= globalConfig.buildPath %>/js"
		]
		sass: [
			"<%= globalConfig.srcPath %>/scss/sprites"
		]
