module.exports = (grunt) ->
	return copy:
		dev:
			src: "conf/dev.casted5.json"
			dest: "<%= globalConfig.buildPath %>/shared/conf/dev.casted5.json"

		preprod:
			src: "conf/preprod.casted5.json"
			dest: "<%= globalConfig.buildPath %>/shared/conf/preprod.casted5.json"

		staging:
			src: "conf/staging.casted5.json"
			dest: "<%= globalConfig.buildPath %>/shared/conf/staging.casted5.json"

		prod:
			src: "conf/prod.casted5.json"
			dest: "<%= globalConfig.buildPath %>/shared/conf/prod.casted5.json"

		img:
			cwd: '<%= globalConfig.srcPath %>/img/static'
			src: "**/*"
			dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/img/static"
			expand: true

		medias:
			cwd: '<%= globalConfig.assetsPath %>/medias'
			src: "**/*"
			dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/medias"
			expand: true

		models:
			cwd: '<%= globalConfig.assetsPath %>/models'
			src: "**/*"
			dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/models"
			expand: true

		fonts:
			cwd: '<%= globalConfig.assetsPath %>/fonts'
			src: "**/*"
			dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/fonts"
			expand: true

		vendors:
			cwd: '<%= globalConfig.assetsPath %>/vendor'
			src: "**/*"
			dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/vendor"
			expand: true

		js:
			cwd: '<%= globalConfig.buildPath %>/js'
			src: "**/*"
			dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/js"
			expand: true

		pdf:
			cwd: '<%= globalConfig.assetsPath %>/pdf'
			src: "**/*"
			dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/pdf"
			expand: true

		workers:
			cwd: '<%= globalConfig.assetsPath %>/workers'
			src: "**/*"
			dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/workers"
			expand: true
