class BodyMovinAnim

	constructor: (@data, @element, @type) ->
		@animation = bodymovin.loadAnimation {
			wrapper: @element
			animType: @type
			loop: false,
			autoplay: false,
			animationData: @data
		}