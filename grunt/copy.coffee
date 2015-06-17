module.exports = (grunt) ->
	return copy:
		dev: {src: "conf/dev.casted5.json", dest: "<%= globalConfig.buildPath %>/conf/dev.casted5.json"}
		staging: {src: "conf/staging.casted5.json", dest: "<%= globalConfig.buildPath %>/conf/staging.casted5.json"}
		prod: {src: "conf/prod.casted5.json", dest: "<%= globalConfig.buildPath %>/conf/prod.casted5.json"}
		img : {
			cwd: 'src/img/static',
			src: "**/*", 
			dest: "<%= globalConfig.buildPath %>/img/static",
			expand: true
		}