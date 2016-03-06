class FModule extends BaseModule

	defaultId = "f"
	ModulesManager.add {id: defaultId, module: "FModule"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId
