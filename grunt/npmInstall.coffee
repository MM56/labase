module.exports = (grunt) ->
	grunt.registerTask "npmInstall", () ->
		exec = require('child_process').exec;
		cb = @async()
		exec 'npm install', {cwd: './'}, (err, stdout, stderr) =>
			console.log stdout
			cb()

	return {}