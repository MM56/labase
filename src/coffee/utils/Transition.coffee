class Transition

	@fadeIn: (elt, fn = null) =>
		TweenMax.set elt, { z : 0.1 }
		if fn?
			TweenMax.to elt, 0.3, { alpha : 1, ease : Expo.easeOut, onComplete : fn }
		else
			TweenMax.set elt, { alpha : 1 }

	@fadeOut: (elt, fn = null) =>
		TweenMax.set elt, { z : 0.1 }
		if fn?
			TweenMax.to elt, 0.3, { alpha : 0.01, ease : Expo.easeOut, onComplete : fn }
		else
			TweenMax.set elt, { alpha : 0.01 }