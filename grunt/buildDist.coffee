module.exports = (grunt) ->
	grunt.registerTask "buildDist", (env) ->
		tasks = grunt.option "tasksList"
		env = grunt.config("env") || env

		currentTasks = tasks[env]
		foundWriteEnvFile = false
		for task in currentTasks
			if task.indexOf("writeEnvFile") == 0
				foundWriteEnvFile = true
				break
		unless foundWriteEnvFile
			currentTasks.push "writeEnvFile"

		if grunt.config("minimages")? && grunt.config("minimages")
			currentTasks.push "min-images"

		grunt.task.run currentTasks

	return {}