class PageModule extends BaseModule

	defaultId = "page"
	ModulesManager.add {id: defaultId, module: "PageModule"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId
