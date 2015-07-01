class FakeModule extends BaseModule

	ModulesManager.add {id: "a", module: "FakeModule"}
	ModulesManager.add {id: "a1", module: "FakeModule"}
	ModulesManager.add {id: "a2", module: "FakeModule"}
	ModulesManager.add {id: "b", module: "FakeModule"}
	ModulesManager.add {id: "c", module: "FakeModule"}
	ModulesManager.add {id: "d", module: "FakeModule"}
	ModulesManager.add {id: "e", module: "FakeModule"}
	ModulesManager.add {id: "f", module: "FakeModule"}
	ModulesManager.add {id: "g", module: "FakeModule"}
	ModulesManager.add {id: "h", module: "FakeModule"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		# console.log "-------------", @id, parentWrapper, @$parentWrapper
		# debugger
		if @$parentWrapper.selector == ".root-module-wrapper"
			@$parentWrapper = $('#root')
		# @id = ["a", "a1", "a2", "b", "c", "d", "g", "h"]
