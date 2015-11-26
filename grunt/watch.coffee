module.exports =
	watch:
		options: spawn: false
		sass:
			files: ['src/scss/**/*.scss']
			tasks: ['sass']
		coffee:
			files: ['src/coffee/**/*.coffee']
			tasks: ['newer:coffee:dev']
		img:
			files: ['src/img/static/**/*']
			tasks: ['newer:copy:img', 'deleteSync']
		sprites:
			files: ['src/img/sprites/**/*.png']
			tasks: ['sprites']
		magipack:
			files: ['src/datas/manifest.json']
			tasks: ['packImages']
		svgs:
			files: ['src/svg/**/*.svg']
			tasks: ['svgsjson']
		vendors:
			files: ['static/vendor/**/*.js']
			tasks: ['copy:vendors']