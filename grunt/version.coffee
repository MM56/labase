module.exports = (grunt) ->
	grunt.registerTask "version", (env) ->
		options = grunt.option "globalConfig"
		env = grunt.config("env") || env

		now = new Date()
		nowStr = String(now.getFullYear()) + ("0" + now.getMonth()).slice(-2) + ("0" + now.getDate()).slice(-2)
		nowStr += "_"
		nowStr += ("0" + now.getHours()).slice(-2) + ("0" + now.getMinutes()).slice(-2) + ("0" + now.getSeconds()).slice(-2)
		options.version = nowStr
		grunt.file.mkdir(options.assetsFolder + "/" + options.version)

	return {}