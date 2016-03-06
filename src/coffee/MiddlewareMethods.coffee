class MiddlewareMethods extends Middleware

	@isValidUser: () =>
		if appDebug
			@respondPositive()
		else
			@respondNegative()
			app.router.navigate "/"

		