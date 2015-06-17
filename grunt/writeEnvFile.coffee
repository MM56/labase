module.exports = (grunt) ->
	grunt.registerTask "writeEnvFile", (env) ->
		options = grunt.option "globalConfig"
		env = grunt.config("env") || env
		buildInfo = {
			env: env
		}
		grunt.file.write options.buildPath + "/datas/buildInfo.json", JSON.stringify(buildInfo)

	return {}