Class {
	#name : #SuperluminalServiceDiscoveryExampleLauncher,
	#superclass : #LaunchpadCommandLineHandler,
	#category : #'Superluminal-Service-Discovery-Examples'
}

{ #category : #accessing }
SuperluminalServiceDiscoveryExampleLauncher class >> commandName [

	^'super-luminal-service-discovery'
]

{ #category : #accessing }
SuperluminalServiceDiscoveryExampleLauncher class >> description [

	^ 'I''m a command line example using as dependency an echo API'
]

{ #category : #'private - accessing' }
SuperluminalServiceDiscoveryExampleLauncher class >> logPrefix [

	^ 'Superluminal-Service-Discovery'
]

{ #category : #'private - activation' }
SuperluminalServiceDiscoveryExampleLauncher >> basicActivate [

	| consulAgentLocation echoServiceLocation |

	consulAgentLocation := self consulAgentLocation.
	CurrentLogger value logAsInfo: 'Discovering dependencies' during: [ 
		echoServiceLocation := Retry
			                       value: [ 
				                       ( ConsulAgentHttpAPIBasedDiscoveryClient queryingAgentOn:
					                         consulAgentLocation ) withLocationOfService: #echo
					                       do: [ :location | location ]
					                       ifUnable: [ Error signal: 'Cannot discover #echo service' ]
				                       ]
			                       configuredBy: [ :retry | 
				                       retry
					                       upTo: 3 timesEvery: ( self configuration at: 'retry-delay-in-ms' );
					                       on: Error evaluating: [ :attemptNumber :exception | 
						                       CurrentLogger value logAsWarning:
								                       ( 'Attempt #<1p> failed with error: <2s>' expandMacrosWith:
										                         attemptNumber
									                         with: exception messageText )
						                       ]
				                       ]
		].

	RESTfulAPIClient default
		get: ( echoServiceLocation
				  scheme: #http;
				  addPathSegment: 'echo';
				  addPathSegment: self message;
				  yourself )
		withSuccessfulResponseDo: [ :response | 
			response = self message asUppercase ifFalse: [ Error signal: 'Invalid response received' ] ].

	self exitSuccess
]

{ #category : #'private - accessing' }
SuperluminalServiceDiscoveryExampleLauncher >> configurationDefinition [

	^ Array 
		with: ( MandatoryArgument named: 'message' )
		with: ( MandatoryArgument named: 'consul-agent-location' convertingWith: #asUrl )
		with: ( OptionalArgument named: 'retry-delay-in-ms' defaultingTo: 200 convertingWith: [:parameter | parameter asNumber milliSeconds ])
]

{ #category : #'private - accessing' }
SuperluminalServiceDiscoveryExampleLauncher >> consulAgentLocation [

	^ self configuration at: 'consul-agent-location'
]

{ #category : #'private - accessing' }
SuperluminalServiceDiscoveryExampleLauncher >> message [

	^ self configuration at: 'message'
]
