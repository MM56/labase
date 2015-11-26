module.exports =
	browserSync:
		dev:
			bsFiles:
				src: [
					"<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/css",
					"<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/img"
					"<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/js",
					"<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/vendor",
					"<%= globalConfig.buildPath %>/shared/**"
					# '<%= globalConfig.buildPath %>/img/**'
				]
			options:
				# host: "ltdmi.local.com"
				# proxy: "ltdmi.local.com"
				proxy: "<%= globalConfig.serverHost %>"
				watchTask: true
				# debugInfo: true
				# open: true
