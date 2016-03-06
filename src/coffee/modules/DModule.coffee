class DModule extends BaseModule

	defaultId = "d"
	ModulesManager.add {id: defaultId, module: "DModule"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId
