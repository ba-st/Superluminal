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

	| commandLine |

	commandLine := CommandLineArguments withArguments:
		               #( 'launchpad' 'start' '--debug-mode' 'superluminal-service-discovery'
		                  '--consul-agent-location=http://consul:8500'
		                  '--message=Hello' '--retry-delay-in-ms=1' ).

	self should: [ LaunchpadCommandLineHandler activateWith: commandLine ] raise: NameLookupFailure
]

{ #category : #tests }
SuperluminalServiceDiscoveryExampleLauncherTest >> testActivateInReleaseMode [

	| commandLine |

	commandLine := CommandLineArguments withArguments:
		               #( 'launchpad' 'start' 'superluminal-service-discovery'
		                  '--consul-agent-location=http://consul:8500'
		                  '--message=Hello' '--retry-delay-in-ms=1' ).

	self should: [ LaunchpadCommandLineHandler activateWith: commandLine ]
		raise: Exit
		withExceptionDo: [ :exit | self deny: exit isSuccess ]
]

{ #category : #tests }
SuperluminalServiceDiscoveryExampleLauncherTest >> testCommandName [

	self assert: SuperluminalServiceDiscoveryExample commandName
		equals: 'superluminal-service-discovery'
]

{ #category : #tests }
SuperluminalServiceDiscoveryExampleLauncherTest >> testDescription [

	self assert: SuperluminalServiceDiscoveryExample description
		equals: 'I''m a command line example using as dependency an echo API'
]

{ #category : #tests }
SuperluminalServiceDiscoveryExampleLauncherTest >> testHelp [

	self assert:
		( String streamContents: [ :stream | SuperluminalServiceDiscoveryExample printHelpOn: stream ] )
		equals: 'NAME
		superluminal-service-discovery [3.0.0] - I''m a command line example using as dependency an echo API
SYNOPSYS
		superluminal-service-discovery --message=<message> --consul-agent-location=<consulAgentLocation> [--retry-delay-in-ms=<retryDelayInMs>]
PARAMETERS
		--message=<message>
			Message to echo.
		--consul-agent-location=<consulAgentLocation>
			Location of the Consul agent.
		--retry-delay-in-ms=<retryDelayInMs>
			Milliseconds to wait between retries. Defaults to 0:00:00:00.2.
ENVIRONMENT
		MESSAGE
			Message to echo.
		CONSUL_AGENT_LOCATION
			Location of the Consul agent.
		RETRY_DELAY_IN_MS
			Milliseconds to wait between retries. Defaults to 0:00:00:00.2.
'
]
