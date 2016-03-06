class CModule extends BaseModule

	defaultId = "c"
	ModulesManager.add {id: defaultId, module: "CModule"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId
