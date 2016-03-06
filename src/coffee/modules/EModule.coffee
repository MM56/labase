class EModule extends BaseModule

	defaultId = "e"
	ModulesManager.add {id: defaultId, module: "EModule"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId
