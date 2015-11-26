module.exports = (grunt) ->
	taskConfig =
		deleteSync :
			sync :
				cwd : "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/img/static"
				src: ["**/*"]
				syncWith: "<%= globalConfig.srcPath %>/img/static"

	grunt.registerMultiTask 'deleteSync', 'Synchronize file deletion between two directories.', ->
		options = @options()
		files = @files
		files.map (file) ->
			file.src.map (val) ->
				targetFileName = file.cwd + '/' + val
				if grunt.file.exists(targetFileName) and !grunt.file.exists(file.syncWith + '/' + val)
					grunt.log.writeln 'Deleting file ' + targetFileName
					grunt.file.delete targetFileName, options

	return taskConfig