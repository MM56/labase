module.exports = (grunt) ->
	options = grunt.option "globalConfig"
	builds = options.builds
	taskConfig = {
		concat: {
			vendors : {
				files : {}
			}
			sprites : {
				src: ['<%= globalConfig.srcPath %>/scss/sprites/*'],
				dest: '<%= globalConfig.srcPath %>/scss/utils/_sprites-variables.scss'
			}
		}
	}

	vendors = options.vendorsJS
	for build, buildParts of builds
		tmpVendors = []
		for vendor in vendors
			if vendor instanceof Object
				if vendor.builds.indexOf(build) > -1
					tmpVendors.push vendor.file
			else
				tmpVendors.push vendor
		dest = options.buildPath + "/js/" + buildParts.vendors + ".js"
		taskConfig.concat.vendors.files[dest] = tmpVendors

	return taskConfig
