execSync = require('child_process').execSync
fs = require('fs')
path = require('path')
Handlebars = require('handlebars')
packer = require("mm-packer")

module.exports = (grunt) ->

	exec = (cmd) =>
		buffer = execSync cmd
		return buffer.toString('utf-8')

	pad = (n, width, z) =>
		z = z || '0'
		n = n + ''
		if n.length >= width
			return n
		else
			return new Array(width - n.length + 1).join(z) + n

	compile = (tpl, data) =>
		template = Handlebars.compile tpl
		return template(data)

	Array::unique = ->
		a = @concat()
		i = 0
		while i < a.length
			j = i + 1
			while j < a.length
				a.splice j--, 1 if a[i] == a[j]
				++j
			++i
		return a

	get = (batch, packPath, options, batchSupport = null) =>
		batchId = batch.id
		files = []
		batchFiles = batch.files.slice(0)

		i = batchFiles.length - 1
		while i >= 0
			file = batchFiles[i]
			if file.nopack? && file.nopack
				i--
				continue

			# find images
			matched = file.src.match(/.*\.(jpg|jpeg|gif|png|obj)/i)
			if matched?
				src = file.src
				src = file.src.replace('.' + matched[1], '.' + batchSupport) if file.support? && file.support.indexOf(batchSupport) != -1
				if file.sequence?
					nbFiles = parseInt file.sequence, 10
					offset = 0
					offset = parseInt file.offset, 10 if file.offset?
					nbFiles = 1 if file.firstFrame? && file.firstFrame

					for j in [offset...nbFiles]
						srcTmp = compile src, {sequence: j}
						files.push {id: file.id + j, src: srcTmp}
				else
					files.push {id: file.id, src: src}
				batchFiles.splice i, 1

			i--

		if files.length > 1
			# create folder for batch
			batchPath = packPath + "/" + batchId
			grunt.file.mkdir batchPath

			# move images to tmp folder
			tmpImagesPath = batchPath + "/tmp"
			for file in files
				grunt.file.copy options.assetsFolder + "/" + options.version + "/" + file.src, tmpImagesPath + "/" + file.src
			if batchSupport?
				packer tmpImagesPath, batchPath, "pack." + batchSupport
			else
				packer tmpImagesPath, batchPath, "pack"

			grunt.file.delete tmpImagesPath

			if batchSupport?
				batchFiles.push {id: "packConf." + batchSupport,  src: "{{GLOBAL.assetsBaseURL}}{{GLOBAL.assetsPath}}packs/" + batchId + "/pack." + batchSupport + ".json", mapping: files}
				batchFiles.push {id: "packFile." + batchSupport, src: "{{GLOBAL.assetsBaseURL}}{{GLOBAL.assetsPath}}packs/" + batchId + "/pack." + batchSupport + ".pack"}
			else
				batchFiles.push {id: "packConf", src: "{{GLOBAL.assetsBaseURL}}{{GLOBAL.assetsPath}}packs/" + batchId + "/pack.json", mapping: files}
				batchFiles.push {id: "packFile", src: "{{GLOBAL.assetsBaseURL}}{{GLOBAL.assetsPath}}packs/" + batchId + "/pack.pack"}

			return batchFiles

	grunt.registerTask "pack", () ->
		options = grunt.option "globalConfig"
		manifestData = grunt.file.readJSON(options.srcPath + "/datas/manifest.json")
		packPath = options.assetsFolder + "/" + options.version + "/packs"

		if grunt.file.exists packPath
			grunt.file.delete packPath
		grunt.file.mkdir packPath

		for batch in manifestData
			batchFiles = batch.files.slice(0)
			i = batchFiles.length - 1
			while i >= 0
				file = batchFiles[i]
				if file.support?
					batch.support = [] if !batch.support?
					for sup in file.support
						batch.support.push sup if !batch.support[sup]?
				i--

		for batch in manifestData
			batchFilesTmp = []
			if batch.support? && batch.support.length > 0
				for batchSupport in batch.support
					batchFiles = get(batch, packPath, options,  batchSupport)
					batchFilesTmp = batchFilesTmp.concat(batchFiles).unique()
				batchFiles = get(batch, packPath, options)
				batchFilesTmp = batchFilesTmp.concat(batchFiles).unique()
			else
				batchFiles = get(batch, packPath, options)
				batchFilesTmp = batchFilesTmp.concat(batchFiles).unique()

			if batchFiles?
				batch.files = batchFilesTmp

		grunt.file.write options.buildPath + "/shared/datas/manifest.json", JSON.stringify(manifestData, null, '\t')
		return null

	return {}