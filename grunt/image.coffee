module.exports = (grunt) ->
	grunt.registerTask "min-images", ["image:min"]
	return image:
		min:
			files: [
				expand: true,
				cwd: "<%= globalConfig.buildPath %>/img/",
				src: ["**/*.{jpg,png,gif}"],
				dest: "<%= globalConfig.buildPath %>/img/"
			]