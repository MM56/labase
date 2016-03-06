class BModule extends BaseModule

	defaultId = "b"
	ModulesManager.add {id: defaultId, module: "BModule"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId
