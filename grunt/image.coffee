module.exports = (grunt) ->
	grunt.registerTask "min-images", ["image:min"]
	return image:
		min:
			files: [
				expand: true,
				cwd: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/img/",
				src: ["**/*.{jpg,png,gif}"],
				dest: "<%= globalConfig.assetsFolder %>/<%= globalConfig.version %>/img/"
			]