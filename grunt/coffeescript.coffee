module.exports = (grunt) ->
	options = grunt.option "globalConfig"
	builds = options.builds

	taskConfig = {
		coffee:
			dev:
				options:
					bare: true
					sourceMap: options.sourceMap
				files: [
					expand: true
					cwd: '<%= globalConfig.srcPath %>/coffee/'
					src: ['**/*.coffee']
					dest: '<%= globalConfig.buildPath %>/js/'
					ext: '.js'
				]
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

	srcs = options.srcJS
	for env in ["staging", "prod"]
		for build, buildParts of builds
			tmpSrcs = []
			for src in srcs
				if src instanceof Object
					if src.builds.indexOf(build) > -1
						tmpSrcs.push src.file
				else
					tmpSrcs.push src
			taskConfig.coffee[env].files[options.buildPath + '/js/' + buildParts.src + '.js'] = tmpSrcs
	return taskConfig
