class ManifestLoader

	defaults: null

	separator = "."
	loader = null
	nbFilesCached = 0
	nbFiles = 0

	constructor: (@basePath = "/", @datas)->
		@defaults = {}

		@complete = new MM.Signal()
		@tplComplete = new MM.Signal()
		@progress = new MM.Signal()
		@start = new MM.Signal()
		@hideLoader = new MM.Signal()

	reset:(files) =>
		nbFilesCached = 0
		nbFiles = files.length

	onProgress: (event) =>
		@progress.dispatch(event)

	load: (datas) =>
		files = datas
		files = [datas] if typeof datas == "string"
		files = @getFilesToLoad(files)
		@reset(files)

		filesToLoad = []
		for file in files
			file.id =  TemplateRenderer.compile(file.id, @datas)
			if Cache.get(file.id)
				@onFileLoaded {item: {id: file.id}}
			else
				obj = {id: file.id, src: file.src, data: file.infos}
				obj.type = file.type if file.type?
				filesToLoad.push obj

		@start.dispatch()

		if nbFilesCached == nbFiles
			@onFilesLoaded()

		#only once
		if !loader?
			loader = new MM.Loader()
			loader.onFileLoad = @onFileLoaded
			loader.onProgress = @onProgress
			loader.onComplete = @onFilesLoaded
		loader.load(filesToLoad)

	onFileLoaded: (event) =>
		loaderItem = event.item
		id = loaderItem.id
		nbFilesCached++

		if !Cache.get(id)
			value = {item: loaderItem.result}
			value.mapping = loaderItem.data.data.mapping if loaderItem.data?.data?.mapping?
			Cache.set(id, value)
			batchId = loaderItem.data.batchId
			fileId = loaderItem.data.fileId
			# if it's a pack, cache files mapped
			if (fileId.indexOf("packConf") != -1 && Cache.get(batchId + separator + "packFile")) || (fileId.indexOf("packFile") != -1 && Cache.get(batchId + separator + "packConf"))
				packConfCached = Cache.get(batchId + separator + "packConf")
				packConf = packConfCached.item
				packFile = Cache.get(batchId + separator + "packFile").item
				mapping = packConfCached.mapping
				mp = new Unpacker(packFile, packConf)
				for mappedObject in mapping
					match = mappedObject.src.match(/.*\.(jpg|jpeg|gif|png|obj)/i)
					if match[1] == "obj"
						d = mp.getURI(mappedObject.src)
					else
						d = new Image()
						d.src = mp.getURI(mappedObject.src)
					Cache.set(batchId + separator + mappedObject.id, {item: d})

		tplSuffix = separator + "tpl"
		if id.indexOf(tplSuffix) == id.length - tplSuffix.length
			@tplComplete.dispatch(Cache.get(id).item.slice(0), id.substring(0, id.indexOf(tplSuffix)))

	onFilesLoaded: () =>
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
								data = $.extend({}, @datas, {sequence: i})
								src = @getFileSrc(file, data)

								files.push {id: fileId, src: src, infos: {batchId: manifest.id, fileId: file.id + i, data: file}}
						else
							src = @getFileSrc(file, @datas)
							obj = {id: manifest.id + separator + file.id, src: src, infos: {batchId: manifest.id, fileId: file.id, data: file}}
							obj.type = "binary" if file.id.indexOf("packFile") != -1
							files.push obj

		throw "Some batches were not found: " + modulesIds.toString() if idsFound != modulesIds.length
		return files

	getFile: (batchId, fileId, clone = false) =>
		handles = Cache.getAll()
		item = handles[batchId + separator + fileId].item
		item = $(item).clone()[0] if clone
		return item

	addCachedTemplates: (templates) =>
		for name, template of templates
			Cache.set(name + separator + "tpl", {item: template})

	getPrefix: () =>
		prefix = baseURL
		if (prefix.indexOf('http://') == -1 && prefix.indexOf('https://') == -1)
			prefix = window.location.protocol + prefix
		return prefix

	getFilesByBatchId: (batchId) =>
		handles = Cache.getAll()
		files = []
		for key, value of handles
			k = key + separator
			if k.indexOf(batchId + separator) != -1
				files.push { id: key, item: value}
		return files

	getFileSrc: (file, data) =>
		src = file.src
		src = TemplateRenderer.compile(file.src, data) if data?
		if src.indexOf('http://') == -1 && src.indexOf('https://') == -1
			prefix = @getPrefix()
			prefix += "/" if prefix.substring(prefix.length-1) != "/"
			src = prefix + StringUtils.removeLeadingSlash(src)
		return src

	addData: (data) =>
		@data = $.extend(@data, data)
