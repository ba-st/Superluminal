instance creation
againstServiceOn: aURL applying: configurationCommandsCollection

	^ self
		using: ZnClient new
		againstServiceOn: aURL
		applying: configurationCommandsCollection