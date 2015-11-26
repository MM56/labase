class Cache

	handles = []
	separator = "."

	@set: (key, value) =>
		handles[key] = value 

	@remove: (key) =>
		if handles[key]?
			delete handles[key] 

	@get: (key) =>
		if handles[key]?
			return handles[key]
		return false

	@getAll: () =>
		return handles