module.exports =
	watch:
		options: spawn: false
		sass:
			files: ['src/scss/**/*.scss']
			tasks: ['sass']
		coffee:
			files: ['src/coffee/**/*.coffee']
			tasks: ['coffee:dev']
		img:
			files: ['src/img/static/**/*']
			tasks: ['newer:copy:img', 'deleteSync']
		sprites:
			files: ['src/img/sprites/**/*.png']
			tasks: ['sprites']
		packer:
			files: ['src/datas/manifest.json']
			tasks: ['pack']
		svgs:
			files: ['src/svg/**/*.svg']
			tasks: ['svgsjson']
		vendors:
			files: ['static/vendor/**/*.js']
			tasks: ['copy:vendors']