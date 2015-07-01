module.exports = (grunt) ->
	options = grunt.option "globalConfig"
	taskConfig =
		cacheManifest :
			src: ["<%= globalConfig.buildPath %>/vendor/**/*.*","<%= globalConfig.buildPath %>/img/**/*.*","<%= globalConfig.buildPath %>/js/**/*.*"]

	grunt.registerMultiTask "cacheManifest", ->
		files = @files
		files.forEach (file) ->
			files = file.src
			contents = "CACHE MANIFEST\n"
			contents += "# v: " + new Date().getTime() + "\n"
			contents += "\nCACHE:\n"
			if files
				files.forEach (item) ->
					uri = encodeURI(item)
					uri = uri.replace(options.buildPath, "")
					contents += uri + "\n"
			contents += "\nNETWORK:\n"
			contents += "*\n"
			grunt.file.write options.buildPath + "/manifest.appcache", contents

	return taskConfig

