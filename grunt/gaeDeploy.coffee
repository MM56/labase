execSync = require('child_process').execSync
yaml = require 'js-yaml'
fs = require('fs')

module.exports = (grunt) ->

	exec = (cmd) =>
		buffer = execSync cmd
		return buffer.toString('utf-8')

	grunt.registerTask "gaeDeploy", (env = "prod") ->
		options = grunt.option "globalConfig"

		# check if repository is cleaned
		# result = exec 'git diff --shortstat 2> /dev/null | tail -n1'
		# if result != ""
		# 	throw new Error "git repository not cleaned! Commit first!"
		# 	return

		# get last commit id
		commitId = exec 'git log --pretty=format:%h -n 1'
		if commitId == ""
			throw new Error "No commit in this git repository."
			return

		env = grunt.config("env") || env
		console.log "Running task gaeConf:" + env
		grunt.task.run "gaeConf:" + env

		console.log "deploying:", 'appcfg.py update ' + options.buildPath
		exec 'appcfg.py update ' + options.buildPath

		title 		= "DEPLOYED"
		env 		= "env:    " + env
		commitId 	= "commit: " + commitId

		biggestStrLength = Math.max(title.length, env.length, commitId.length) + 4

		borderHChar = "-"
		borderH = ""
		borderH += borderHChar for i in [0...biggestStrLength]

		borderVChar = "|"
		title = addBorderV title, biggestStrLength - 4
		env = addBorderV env, biggestStrLength - 4
		commitId = addBorderV commitId, biggestStrLength - 4

		console.log borderH
		console.log borderVChar + " " + title + " " + borderVChar
		console.log borderVChar + " " + env + " " + borderVChar
		console.log borderVChar + " " + commitId + " " + borderVChar
		console.log borderH

	addBorderV = (str, totalLength) =>
		blank = ""
		if str.length < totalLength
			blank += " " for i in [0...(totalLength - str.length)]
		return str + blank

	return {}