class A1Module extends BaseModule

	defaultId = "a1"
	ModulesManager.add {id: defaultId, module: "A1Module"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId
