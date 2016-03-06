class HModule extends BaseModule

	defaultId = "h"
	ModulesManager.add {id: defaultId, module: "HModule"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId
