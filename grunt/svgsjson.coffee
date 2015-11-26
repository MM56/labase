module.exports = (grunt) ->
	grunt.registerTask "svgsjson", (env) ->
		options = grunt.option "globalConfig"

		svgsFolder = options.srcPath + '/svg/'
		jsonPath = options.buildPath + '/shared/datas/svgs.json'

		svgsObject = {}
		count = 0
		grunt.file.expand({ filter: 'isFile'}, svgsFolder+'**/*.svg').forEach (path) ->
			content = grunt.file.read path
			ids = path.replace(svgsFolder, '').replace('.svg', '').split('/')
			ref = svgsObject
			for id, i in ids
				if i == ids.length-1
					ref[id] = content
				else
					ref[id] = {} if !ref[id]?
					ref = ref[id]
			count++
			# console.log path

		grunt.file.write jsonPath, JSON.stringify(svgsObject)
		# console.log '------------------------------------------'
		# console.log jsonPath, '<--', count, 'svgs'

	return {}