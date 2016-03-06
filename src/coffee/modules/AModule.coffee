class AModule extends BaseModule

	defaultId = "a"
	ModulesManager.add {id: defaultId, module: "AModule"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId