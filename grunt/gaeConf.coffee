yaml = require 'js-yaml'
fs = require('fs')
execSync = require('child_process').execSync

module.exports = (grunt) ->

	exec = (cmd) =>
		buffer = execSync cmd
		return buffer.toString('utf-8')

	grunt.registerTask "gaeConf", (env = "prod") ->
		options = grunt.option "globalConfig"

		# get last commit id
		commitId = exec 'git log --pretty=format:%h -n 1'
		if commitId == ""
			throw new Error "No commit in this git repository."
			return

		# APP
		env = grunt.config("env") || env
		defaultAppJson = yaml.safeLoad fs.readFileSync options.gruntTasksFolder + "/config/app.yaml"
		if env == "staging"
			defaultAppJson.module = "staging"
		defaultAppJson.version = commitId

		console.log "Writing file:", options.buildPath + "/app.yaml"
		grunt.file.write options.buildPath + "/app.yaml", yaml.dump(defaultAppJson, {indent: 4})

	return {}