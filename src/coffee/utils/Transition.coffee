class Transition

	@fadeIn: (elt, fn = null) =>
		TweenMax.set elt, { alpha : 1 }
		fn() if fn?

	@fadeOut: (elt, fn = null) =>
		TweenMax.set elt, { alpha : 0.0001 }
		fn() if fn?