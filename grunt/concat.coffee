module.exports = (grunt) ->
	options = grunt.option "globalConfig"
	builds = options.builds
	srcPath = options.assetsPath

	taskConfig = {
		concat:
			vendors_preprod:
				files: {}
			vendors_staging:
				files: {}
			vendors_prod:
				files: {}
			sprites:
				src: ['<%= globalConfig.srcPath %>/scss/sprites/*'],
				dest: '<%= globalConfig.srcPath %>/scss/utils/_sprites-variables.scss'
	}

	srcs = options.vendors
	for env in ["preprod", "staging", "prod"]
		for build, buildParts of builds
			tmpSrcs = []
			for src in srcs
				if typeof src == "object"
					if src.builds.indexOf(build) > -1
						tmpSrcs.push srcPath + "/" + src.file
				else
					tmpSrcs.push srcPath + "/" + src
			taskConfig.concat["vendors_" + env].files[options.buildPath + "/js/" + buildParts.vendors + ".js"] = tmpSrcs

	return taskConfig
