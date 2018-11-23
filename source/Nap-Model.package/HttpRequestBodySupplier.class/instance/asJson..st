configuring
asJson: aDictionary

	| json |

	json := NeoJSONWriter toString: aDictionary.
	^ SetBodyCommand to: (ZnStringEntity json: json)