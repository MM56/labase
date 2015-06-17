class PageModule extends BaseModule

	defaultId = "page"
	ModulesManager.add {id: defaultId, module: "PageModule"}

	constructor: (parentWrapper, @params, @defaultBatches, @id) ->
		super(parentWrapper, @params, @defaultBatches, @id)
		@id = defaultId + @params.id
		@$elt = $('.page-' + @params.id)

	preload: =>
		app.manifestLoader.tplComplete.add @onPreloadTplComplete
		app.manifestLoader.complete.add @onPreloadComplete
		@load "page" + @params.id

	onShowStart: () =>
		super()