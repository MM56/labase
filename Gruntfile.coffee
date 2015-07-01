module.exports = (grunt) ->

	require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

	tasks = {
		dev: [
			"clean:all",
			"sprites"
			"sass",
			"clean:img",
			"copy:img",
			"packImages",
			"coffee:dev",
			"writeEnvFile:dev", "copy:dev",
			"browserSync",
			"watch"
		]
		staging: [
			"clean:all"
			"sprites"
			"sass"
			"clean:img"
			"copy:img"
			"clean:sprites"
			"packImages"
			"concat:vendors"
			"coffee:staging"
			"writeEnvFile:staging", "copy:staging"
			"uglify"
		]
		prod: [
			"clean:all"
			"sprites"
			"sass"
			"clean:img"
			"copy:img"
			"clean:sprites"
			"packImages"
			"concat:vendors"
			"coffee:prod"
			"writeEnvFile:prod", "copy:prod"
			"uglify"
		]
	}

	srcPath = "src"
	buildPath = "dist"

	javascriptsFiles = grunt.file.readJSON("dist/datas/javascripts.json")

	vendorsJS = []
	javascriptsFiles.files.vendors.forEach (path) ->
		if path instanceof Object
			path.file = buildPath + "/" + path.file
			vendorsJS.push path
		else
			vendorsJS.push buildPath + "/" + path

	srcJS = []
	javascriptsFiles.files.src.forEach (path) ->
		srcJS.push srcPath + "/coffee/" + path + ".coffee"

	gruntFolder = "./grunt"

	config =
		globalConfig:
			gruntTasksFolder: gruntFolder
			srcPath: srcPath
			buildPath: buildPath
			vendorsJS: vendorsJS
			builds: javascriptsFiles.builds
			srcJS: srcJS

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