module.exports = (grunt) ->
	return "concat-json":
		"parts":
			src: [ "src/datas/parts/*.json" ]
			dest: "dist/shared/datas/parts.json"
		"targets":
			src: [ "src/datas/targets/*.json" ]
			dest: "dist/shared/datas/targets.json"