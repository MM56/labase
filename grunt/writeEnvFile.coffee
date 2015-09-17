module.exports = (grunt) ->
	grunt.registerTask "writeEnvFile", (env) ->
		options = grunt.option "globalConfig"
		env = grunt.config("env") || env


		localConfFile = options.gruntTasksFolder + "/config/local.json"
		if grunt.file.exists localConfFile
			localConf = grunt.file.readJSON localConfFile
		else
			console.error "ERROR: MISSING FILE grunt/config/local.json"

		buildInfo = {
			env: env
		}
		grunt.file.write options.buildPath + "/datas/buildInfo.json", JSON.stringify(buildInfo)

	return {}