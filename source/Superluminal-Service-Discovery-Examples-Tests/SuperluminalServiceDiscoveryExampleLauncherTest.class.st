"
A SuperluminalServiceDiscoveryExampleLauncherTest is a test class for testing the behavior of SuperluminalServiceDiscoveryExampleLauncher
"
Class {
	#name : #SuperluminalServiceDiscoveryExampleLauncherTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Service-Discovery-Examples-Tests'
}

{ #category : #tests }
SuperluminalServiceDiscoveryExampleLauncherTest >> testActivate [

	self
		should: [ 
			| launcher |

			launcher := SuperluminalServiceDiscoveryExampleLauncher new.
			launcher
				commandLine: ( CommandLineArguments withArguments:
							  #( '--consul-agent-location=http://consul:8500'
							     '--message=Hello' '--retry-delay-in-ms=1' '--debug-mode' ) );
				activate
			]
		raise: NameLookupFailure
]

{ #category : #tests }
SuperluminalServiceDiscoveryExampleLauncherTest >> testArguments [

	| launcher |

	launcher := SuperluminalServiceDiscoveryExampleLauncher new.
	launcher commandLine: ( CommandLineArguments withArguments:
			  #( '--consul-agent-location=http://consul:8500' '--message=Hello' '--retry-delay-in-ms=1'
			     '--debug-mode' ) ).

	self
		assert: launcher message equals: 'Hello';
		assertUrl: launcher consulAgentLocation equals: 'http://consul:8500'
]

{ #category : #tests }
SuperluminalServiceDiscoveryExampleLauncherTest >> testCommandName [

	self assert: SuperluminalServiceDiscoveryExampleLauncher commandName
		equals: 'super-luminal-service-discovery'
]

{ #category : #tests }
SuperluminalServiceDiscoveryExampleLauncherTest >> testDescription [

	self assert: SuperluminalServiceDiscoveryExampleLauncher description
		equals: 'I''m a command line example using as dependency an echo API'
]

{ #category : #tests }
SuperluminalServiceDiscoveryExampleLauncherTest >> testLogPrefix [

	self assert: SuperluminalServiceDiscoveryExampleLauncher logPrefix
		equals: 'Superluminal-Service-Discovery'
]
