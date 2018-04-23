instance creation
againstServiceOn: aURL applying: configurationCommandsCollection

	^ self
		using: ZnClient new beOneShot 
		againstServiceOn: aURL
		applying: configurationCommandsCollection