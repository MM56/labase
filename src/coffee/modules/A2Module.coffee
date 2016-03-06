class A2Module extends BaseModule

	defaultId = "a2"
	ModulesManager.add {id: defaultId, module: "A2Module"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId
