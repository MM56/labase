module.exports = (grunt) ->

	require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

	tasks = {
		dev: [
			"clean:all"
			"version"
			"svgsjson"
			"sprites"
			"sass"
			"copy:img"
			"packImages"
			"coffee:dev"
			"writeEnvFile:dev"
			"copy:dev"
			"copy:fonts"
			"copy:vendors"
			"copy:medias"
			"copy:models"
			"copy:pdf"
			"browserSync"
			"watch"
		]
		preprod: [
			"clean:all"
			"version"
			"svgsjson"
			"sprites"
			"sass"
			"copy:img"
			"packImages"
			"coffee:preprod"
			"concat:vendors_preprod"
			"writeEnvFile:preprod"
			"copy:preprod"
			"copy:fonts"
			"copy:medias"
			"copy:pdf"
			"copy:js"
			"copy:models"
			# "uglify"
			"clean:js"
		]
		staging: [
			"clean:all"
			"version"
			"svgsjson"
			"sprites"
			"sass"
			"copy:img"
			"packImages"
			"coffee:staging"
			"concat:vendors_staging"
			"writeEnvFile:staging"
			"copy:staging"
			"copy:fonts"
			"copy:medias"
			"copy:models"
			"copy:pdf"
			"copy:js"
			# "uglify"
			"clean:js"
		]
		prod: [
			"clean:all"
			"version"
			"svgsjson"
			"sprites"
			"sass"
			"copy:img"
			"packImages"
			"coffee:prod"
			"concat:vendors_prod"
			"writeEnvFile:prod"
			"copy:prod"
			"copy:fonts"
			"copy:medias"
			"copy:models"
			"copy:pdf"
			"copy:js"
			"uglify"
			"clean:js"
		]
	}

	srcPath = "src"
	buildPath = "dist"
	assetsPath = "static"

	javascriptsFiles = grunt.file.readJSON("dist/shared/datas/javascripts.json")

	gruntFolder = "./grunt"

	assetsFolder = buildPath + "/" + assetsPath

	config =
		globalConfig:
			gruntTasksFolder: gruntFolder
			srcPath: srcPath
			buildPath: buildPath
			builds: javascriptsFiles.builds
			srcs: javascriptsFiles.files.src
			vendors: javascriptsFiles.files.vendors
			assetsFolder: assetsFolder
			assetsPath: assetsPath

	localConfFile = gruntFolder + "/config/local.json"
	if grunt.file.exists localConfFile
		localConf = grunt.file.readJSON localConfFile
		config.globalConfig.serverHost = localConf.host
		if localConf.sourceMap?
			config.globalConfig.sourceMap = localConf.sourceMap
		else
			config.globalConfig.sourceMap = true
	else
		config.globalConfig.sourceMap = false

	grunt.option "globalConfig", config.globalConfig
	grunt.option "tasksList", tasks

	grunt.file.expand({cwd: config.globalConfig.gruntTasksFolder}, ["*.coffee", "*.js"]).forEach (path) ->
		taskConfig = require(config.globalConfig.gruntTasksFolder + "/" + path.replace("/\.(js|coffee)$/", ""))
		taskConfig = taskConfig(grunt) if typeof taskConfig is "function"
		grunt.util._.extend config, taskConfig

	grunt.initConfig config
	grunt.registerTask "default", tasks.dev
	grunt.registerTask "build", ["prompt:build", "buildDist"]