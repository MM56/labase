class GATracker

	event: (category, action, label, value) =>
		ga "send", "event", category, action, label, value

	pageview: (location, page, title) =>
		ga "send", "pageview", location, page, title