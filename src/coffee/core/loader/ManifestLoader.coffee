class ManifestLoader

	cache: null
	cacheIds: null
	defaults : {}
	
	separator = "."
	loader = null
	nbFilesCached = 0
	nbFiles = 0

	constructor: (@basePath = "/", @data)->
		@cache = {}
		@cacheIds = []

		@complete = new signals.Signal()
		@tplComplete = new signals.Signal()
		@progress = new signals.Signal()
		@start = new signals.Signal()
		@hideLoader = new signals.Signal()
		
	reset:(files) =>
		nbFilesCached = 0
		nbFiles = files.length
		if loader?
			loader.removeAllEventListeners()
			loader.reset()
			loader.removeAll()

	onProgress: (event) =>
		@progress.dispatch(event)

	load: (datas, isConfig) =>
		files = datas
		files = [datas] if typeof datas == "string"
		files = @getFilesToLoad(files) if !isConfig?
		@reset(files)

		filesToLoad = []
		for file in files
			file.id =  TemplateRenderer.compile(file.id, @data)
			if @cache[file.id]?
				@onFileLoaded {item: {id: file.id}}
			else
				file.src = @getFileSrc(file) if isConfig?
				obj = {id: file.id, src: file.src, data: file.infos}
				obj.type = file.type if file.type?
				filesToLoad.push obj

		if nbFilesCached == nbFiles
			@onFilesLoaded()
		else
			loader = new createjs.LoadQueue(true)
			loader.installPlugin(createjs.Sound)
			createjs.Sound.alternateExtensions = ["mp3", "ogg"]
			loader.addEventListener "fileload", @onFileLoaded
			loader.addEventListener "progress", @onProgress
			loader.addEventListener "complete", @onFilesLoaded
			@start.dispatch()

			for file in filesToLoad
				loader.loadFile file

	onFileLoaded: (event) =>
		loaderItem = event.item
		id = loaderItem.id
		nbFilesCached++

		if id == "manifest" || id == "l10n" || id == "modulesRoutes"
			@defaults[id] = loader.getResult id
		else
			if !@cache[id]?
				@cache[id] = {item: loader.getResult id}
				@cache[id].mapping = loaderItem.data.data.mapping if loaderItem.data?.data?.mapping?
				batchId = loaderItem.data.batchId
				fileId = loaderItem.data.fileId
				# if it's a pack, cache files mapped
				if (fileId.indexOf("packConf") != -1 && @cache[batchId + separator + "packFile"]?) || (fileId.indexOf("packFile") != -1 && @cache[batchId + separator + "packConf"]?)
					packConfCached = @cache[batchId + separator + "packConf"]
					packConf = packConfCached.item
					packFile = @cache[batchId + separator + "packFile"].item
					mapping = packConfCached.mapping
					mp = new Magipack(packFile, packConf)
					for mappedObject in mapping
						img = new Image()
						img.src = mp.getURI(mappedObject.src)
						@cache[batchId + separator + mappedObject.id] = {item: img}

			tplSuffix = separator + "tpl"
			if id.indexOf(tplSuffix) == id.length - tplSuffix.length
				@tplComplete.dispatch(@cache[id].item.slice(0), id.substring(0, id.indexOf(tplSuffix)))

	onFilesLoaded: () =>
		loader.removeEventListener "fileload", @onFileLoaded
		loader.removeEventListener "progress", @onProgress
		loader.removeEventListener "complete", @onFilesLoaded
		@complete.dispatch()

	getFilesToLoad : (ids) =>
		files = []
		modulesIds = ids 
		modulesIds = [ids] if typeof ids == "string"
		idsFound = 0

		for i in [0..1]
			_modulesIds = modulesIds
			for manifest in @defaults.manifest
				for id in _modulesIds
					if manifest.id == id && manifest.dependencies?
						for _id in manifest.dependencies
							modulesIds.push _id if modulesIds.indexOf(_id) == -1

		for manifest in @defaults.manifest
			for id in modulesIds
				if manifest.id == id
					idsFound++
					for file in manifest.files
						if file.sequence?
							nbFiles = parseInt file.sequence, 10
							for i in [0..nbFiles-1]
								fileId = manifest.id + separator + file.id + i
								data = $.extend({}, @data, {sequence: i})
								src = @getFileSrc(file, data)
								files.push {id: fileId, src: src, infos: {batchId: manifest.id, fileId: file.id + i, data: file}}
						else
							src = @getFileSrc(file, @data)
							
							obj = {id: manifest.id + separator + file.id, src: src, infos: {batchId: manifest.id, fileId: file.id, data: file}}
							obj.type = "binary" if file.id.indexOf("packFile") != -1
							if ((file.id.indexOf("packFile") != -1) || (file.id.indexOf("packConf") != -1))
								if manifest.support?
									continue if (@isWebp && (file.id != "packFile.webp" && file.id != "packConf.webp"))
									continue if (!@isWebp && (file.id != "packFile" && file.id != "packConf"))
									obj.id = obj.id.replace('.webp','') if @isWebp

							files.push obj

		throw "Some batches were not found: " + modulesIds.toString() if idsFound != modulesIds.length
		return files

	getFileSrc: (file, data) =>
		src = file.src
		src = TemplateRenderer.compile(file.src, data) if data?

		if file.basePath? && !file.basePath
		else
			src = @basePath + src
			src = StringUtils.removeLeadingSlash(src)  if src.indexOf("http") != -1
		return src

	getFile: (batchId, fileId, clone = false) =>
		item = @cache[batchId + separator + fileId].item
		item = $(item).clone()[0] if clone
		return item

	addCachedTemplates: (templates) =>
		for name, template of templates
			@cache[name + separator + "tpl"] = {item: template}

	addData: (data) =>
		@data = $.extend(@data, data)
