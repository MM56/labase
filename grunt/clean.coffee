module.exports =
	clean:
		all: [
			"<%= globalConfig.buildPath %>/conf/*"
			"<%= globalConfig.buildPath %>/css/*"
			"<%= globalConfig.buildPath %>/js/*"
		]
		sprites: [
			"<%= globalConfig.buildPath %>/img/sprites/**/1x-*"
			"<%= globalConfig.buildPath %>/img/sprites/**/2x-*"
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
