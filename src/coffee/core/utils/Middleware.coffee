class Middleware

	@RESPONSE: new MM.Signal()

	@callMethod: (methodName) =>
		if typeof MiddlewareMethods[methodName] == "function"
			MiddlewareMethods[methodName].call @
		else
			@respondPositive()

	@respondPositive: =>
		@RESPONSE.dispatch true

	@respondNegative: =>
		@RESPONSE.dispatch false
