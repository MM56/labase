module.exports = (grunt) ->
	return prompt:
		build:
			options:
				questions: [
					{
						config: "env"
						type: "list"
						message: "Choose an environment"
						choices: ["dev", "preprod", "staging", "prod"]
					}
					{
						config: "minimages"
						type: "confirm"
						message: "Minify images?"
					}
				]
