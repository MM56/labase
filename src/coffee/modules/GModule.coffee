class GModule extends BaseModule

	defaultId = "g"
	ModulesManager.add {id: defaultId, module: "GModule"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId
