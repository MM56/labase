class TemplateRenderer

	@compile: (tpl, data) =>
		template = Handlebars.compile tpl
		return template(data)

	@registerPartial: (id, partial) =>
		Handlebars.registerPartial id, partial

	@append: ($elt, tpl, data) =>
		$compiledTpl = $(@compile(tpl, data))
		@add $elt, $compiledTpl
		return $compiledTpl

	@prepend: ($elt, tpl, data) =>
		$compiledTpl = $(@compile(tpl, data))
		@add $elt, $compiledTpl, true
		return $compiledTpl

	@add: ($elt, $compiledTpl, prepend = false) =>
		if prepend
			$elt.prepend $compiledTpl
		else
			$elt.append $compiledTpl

	TemplateRenderer.registerPartial "modules", ""

	Handlebars.registerHelper 'IfEqual', (a, b, opts)  =>
		return opts.fn @ if(a == b)
		return opts.inverse @