tests - support
withJsonFromContentsIn: httpResponse do: aBlock

	aBlock value: (NeoJSONObject fromString: httpResponse contents)