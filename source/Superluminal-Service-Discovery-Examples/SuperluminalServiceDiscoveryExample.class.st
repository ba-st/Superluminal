Class {
	#name : #SuperluminalServiceDiscoveryExample,
	#superclass : #LaunchpadApplication,
	#category : #'Superluminal-Service-Discovery-Examples'
}

{ #category : #accessing }
SuperluminalServiceDiscoveryExample class >> commandName [

	^ 'superluminal-service-discovery'
]

{ #category : #accessing }
SuperluminalServiceDiscoveryExample class >> configurationParameters [

	^ Array
		  with: ( MandatoryConfigurationParameter named: 'Message' describedBy: 'Message to echo' )
		  with: ( MandatoryConfigurationParameter named: 'Consul Agent Location'
				    describedBy: 'Location of the Consul agent'
				    convertingWith: #asUrl )
		  with: ( OptionalConfigurationParameter named: 'Retry Delay in ms'
				    describedBy: 'Milliseconds to wait between retries'
				    defaultingTo: 200 milliSeconds
				    convertingWith: [ :parameter | parameter asNumber milliSeconds ] )
]

{ #category : #accessing }
SuperluminalServiceDiscoveryExample class >> description [

	^ 'I''m a command line example using as dependency an echo API'
]

{ #category : #accessing }
SuperluminalServiceDiscoveryExample class >> version [

	^ '3.0.0'
]

{ #category : #'private - activation' }
SuperluminalServiceDiscoveryExample >> basicStartWithin: context [

	| echoServiceLocation |

	LaunchpadLogRecord emitInfo: 'Discovering dependencies'
		during: [ echoServiceLocation := self discoverEchoServiceQueryingConsulAgent ].

	RESTfulAPIClient cachingOnLocalMemory
		get: ( echoServiceLocation
				  scheme: #http;
				  addPathSegment: 'echo';
				  addPathSegment: self configuration message;
				  yourself )
		withSuccessfulResponseDo: [ :response | 
			response = self configuration message asUppercase ifFalse: [ 
				Error signal: 'Invalid response received' ]
			].
	self exitSuccess
]

{ #category : #'private - activation' }
SuperluminalServiceDiscoveryExample >> discoverEchoServiceQueryingConsulAgent [

	^ ( ConsulAgentHttpAPIBasedDiscoveryClient queryingAgentOn: self configuration consulAgentLocation
		    configuredBy: [ :options | options at: #retry put: self retryOptions ] ) 
		  withLocationOfService: #echo
		  do: [ :location | location ]
		  ifUnable: [ Error signal: 'Cannot discover #echo service' ]
]

{ #category : #'private - activation' }
SuperluminalServiceDiscoveryExample >> retryOptions [

	^ [ :retry | 
	  retry
		  upTo: 3 timesEvery: self configuration retryDelayInMs;
		  on: Error evaluating: [ :attemptNumber :exception | 
			  LaunchpadLogRecord emitWarning:
					  ( 'Attempt #<1p> failed with error: <2s>' expandMacrosWith: attemptNumber
						    with: exception messageText )
			  ]
	  ]
]

{ #category : #'error handling' }
SuperluminalServiceDiscoveryExample >> stackTraceDumper [

	^ NullStackTraceDumper new
]
