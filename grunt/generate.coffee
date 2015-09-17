Handlebars = require("handlebars")

module.exports = (grunt) ->
	grunt.registerTask "generate", ->
		options = grunt.option "globalConfig"

		buildPath = options.buildPath
		datasPath = buildPath + "/datas"

		javascriptsPath = datasPath + "/javascripts.json"
		hasJSData = grunt.file.exists(javascriptsPath)
		if hasJSData
			javascriptsData = grunt.file.readJSON(javascriptsPath)

		manifestPath = options.srcPath + "/datas/manifest.json"
		hasManifestData = grunt.file.exists(manifestPath)
		if hasManifestData
			manifestData = grunt.file.readJSON(manifestPath)

		modulesRoutesPath = datasPath + "/modules_routes.json"
		modulesRoutesData = grunt.file.readJSON(modulesRoutesPath)
		tplPath = buildPath + "/tpl"
		partialsPath = tplPath + "/partials"

		srcPath = options.srcPath
		coffeePath = srcPath + "/coffee"
		modulesPath = coffeePath + "/modules"

		processModules = (modules) =>
			for module in modules
				moduleId = module.id
				moduleIdCamelCase = moduleId.toLowerCase().replace(/-(.)/g, (match, group1) =>
					return group1.toUpperCase()
				)
				moduleIdCamelCase = moduleIdCamelCase.charAt(0).toUpperCase() + moduleIdCamelCase.slice(1)
				moduleIdCamelCase += "Module"
				modulePath = "modules"

				baseCoffeePath = ""
				moduleTplPattern = moduleId

				if module.tplPattern?
					moduleTplPattern = Handlebars.compile(module.tplPattern)()
					baseCoffeePath += "/" + moduleTplPattern.substring 0, moduleTplPattern.lastIndexOf("/")
					modulePath += "/" + moduleTplPattern.substring 0, moduleTplPattern.lastIndexOf("/")

				moduleTplPath = partialsPath + "/" + moduleTplPattern

				# add batch in manifest.json
				found = false
				if hasManifestData
					for batch in manifestData
						if batch.id == moduleId
							found = true
				if !found
					manifestData.push {id: moduleId, files: [{id: "tpl", src: "tpl/partials/" + moduleTplPattern + ".hbs"}]}

				# add tpl
				if !grunt.file.exists moduleTplPath + ".hbs"
					grunt.file.write moduleTplPath + ".hbs", '<div class="module-' + moduleId + '">\n\t<p>' + moduleId + ' {{ params.id }}</p>\n\t<div class="' + moduleId + '-module-wrapper">{{> modules}}</div>\n</div>'

				# add JS in javascripts.json
				moduleSrc = modulePath + "/" + moduleIdCamelCase
				if hasJSData
					if javascriptsData.files.src.indexOf(moduleSrc) == -1
						appIndex = javascriptsData.files.src.indexOf("App")
						javascriptsData.files.src.splice appIndex, 0, moduleSrc
				else
					console.log "js/" + moduleSrc + ".js"

				# add coffee
				moduleCoffeePath = baseCoffeePath + "/" + moduleIdCamelCase
				if !grunt.file.exists modulesPath + moduleCoffeePath + ".coffee"
					grunt.file.write modulesPath + moduleCoffeePath + ".coffee", 'class ' + moduleIdCamelCase + ' extends BaseModule\n\n\tdefaultId = "' + moduleId + '"\n\tModulesManager.add {id: defaultId, module: "' + moduleIdCamelCase + '"}\n\n\tconstructor: (parentWrapper, @params, @defaultBatches, @id) ->\n\t\tsuper(parentWrapper, @params, @defaultBatches, @id)\n\t\t@id = defaultId\n'

				# look for submodules
				if module.modules? && module.modules.length > 0
					processModules module.modules

		processModules modulesRoutesData.modules

		if hasJSData
			grunt.file.write javascriptsPath, JSON.stringify(javascriptsData, null, '\t')
		if hasManifestData
			grunt.file.write manifestPath, JSON.stringify(manifestData, null, '\t')

	return {}