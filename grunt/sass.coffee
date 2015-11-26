module.exports =
	sass:
		desktop:
			src: "src/scss/style.desktop.scss"
			dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/css/style.desktop.css"

		mobile:
			src: "src/scss/style.mobile.scss"
			dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/css/style.mobile.css"
