initialization
initializePerforming: anHttpMethod at: aUrl configuredUsing: aMonadycBlock

	| configurator |

	method := anHttpMethod.
	url := aUrl.

	configurator := HttpRequestConfigurator new.
	commands := aMonadycBlock cull: configurator