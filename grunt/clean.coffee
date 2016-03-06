module.exports =
	clean:
		all: [
			"<%= globalConfig.buildPath %>/css"
			"<%= globalConfig.buildPath %>/js"
			"<%= globalConfig.buildPath %>/manifest.appcache"
			"<%= globalConfig.buildPath %>/img"
			"<%= globalConfig.buildPath %>/shared/conf/*"
			"<%= globalConfig.buildPath %>/static/*"
			"<%= globalConfig.buildPath %>/app.yaml"
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
