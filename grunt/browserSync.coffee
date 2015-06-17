module.exports =
	browserSync:
		dev:
			bsFiles:
				src: [
					'<%= globalConfig.buildPath %>/css/style.desktop.css'
					'<%= globalConfig.buildPath %>/css/style.mobile.css'
					'<%= globalConfig.buildPath %>/datas/l10n/**'
					# '<%= globalConfig.buildPath %>/img/**'
					'<%= globalConfig.buildPath %>/js/**'
					'<%= globalConfig.buildPath %>/tpl/**'
				]
			options:
				# host: "ltdmi.local.com"
				# proxy: "ltdmi.local.com"
				proxy: "<%= globalConfig.serverHost %>"
				watchTask: true
				# debugInfo: true
				# open: true
