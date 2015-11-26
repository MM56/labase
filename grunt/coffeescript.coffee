module.exports = (grunt) ->
	options = grunt.option "globalConfig"
	builds = options.builds
	srcPath = options.srcPath

	taskConfig = {
		coffee:
			dev:
				options:
					bare: true
					sourceMap: options.sourceMap
				files: [
					expand: true
					cwd: "<%= globalConfig.srcPath %>/coffee/"
					src: ["**/*.coffee"]
					dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/js/"
					ext: ".js"
				]
			preprod:
				options:
					bare: true
					join: true
				files: {}
			staging:
				options:
					bare: true
					join: true
				files: {}
			prod:
				options:
					bare: true
					join: true
				files: {}
	}

	srcs = options.srcs
	for env in ["preprod", "staging", "prod"]
		for build, buildParts of builds
			tmpSrcs = []
			for src in srcs
				if typeof src == "object"
					if src.builds.indexOf(build) > -1
						tmpSrcs.push srcPath + "/coffee/" + src.file + ".coffee"
				else
					tmpSrcs.push srcPath + "/coffee/" + src + ".coffee"
			taskConfig.coffee[env].files[options.buildPath + "/js/" + buildParts.src + ".js"] = tmpSrcs
	return taskConfig
