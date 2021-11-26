"
I'm a service discovery client using the Consul HTTP API to get a list of service locations.

I will use the [Health](https://www.consul.io/api-docs/health) endpoint to obtain the list of healthy services. 
I can be chained with another service discovery client as a fallback when a service is not found in my list.
"
Class {
	#name : #ConsulAgentHttpAPIBasedDiscoveryClient,
	#superclass : #ServiceDiscoveryClient,
	#instVars : [
		'agentLocation',
		'fallbackClient',
		'apiClient'
	],
	#category : #'Superluminal-Service-Discovery'
}

{ #category : #'Instance creation' }
ConsulAgentHttpAPIBasedDiscoveryClient class >> queryingAgentOn: aConsulAgentLocation [

	^ self queryingAgentOn: aConsulAgentLocation chainedWith: NullServiceDiscoveryClient new
]

{ #category : #'instance creation' }
ConsulAgentHttpAPIBasedDiscoveryClient class >> queryingAgentOn: aConsulAgentLocation chainedWith: aServiceDiscoveryClient [

	^ self new initializeQueryingAgentOn: aConsulAgentLocation chainedWith: aServiceDiscoveryClient
]

{ #category : #private }
ConsulAgentHttpAPIBasedDiscoveryClient >> discoverLocationOf: serviceName ifFound: foundBlock otherwise: failBlock [

	| serviceHealthList |

	^ apiClient
		  getAt: agentLocation / 'v1' / 'health' / 'service' / serviceName
		  configuredBy: [ :request | 
			  ( request queryString: [ :queryString | 
				    queryString fieldNamed: 'filter' pairedTo: 'Checks.Status == passing' ] )
			  + ( request headers setAcceptTo: ZnMimeType applicationJson )
			  ]
		  withSuccessfulResponseDo: [ :responseContents | 
			  serviceHealthList := NeoJSONObject fromString: responseContents.

			  self withLocationOfServiceOn: serviceHealthList
				  do: foundBlock
				  ifUnable: [ 
				  fallbackClient withLocationOfService: serviceName do: foundBlock ifUnable: failBlock ]
			  ]
]

{ #category : #initialization }
ConsulAgentHttpAPIBasedDiscoveryClient >> initializeQueryingAgentOn: aConsulAgentLocation chainedWith: aServiceDiscoveryClient [

	agentLocation := aConsulAgentLocation.
	fallbackClient := aServiceDiscoveryClient.
	apiClient := RESTfulAPIClient cachingOnLocalMemory
]

{ #category : #accessing }
ConsulAgentHttpAPIBasedDiscoveryClient >> withLocationOfService: serviceName do: foundBlock ifUnable: failBlock [

	^ Retry value: [ self discoverLocationOf: serviceName ifFound: foundBlock otherwise: failBlock ]
		  configuredBy: [ :retry | 
			  retry
				  upTo: 2;
				  on: NetworkError , HTTPError
			  ]
]

{ #category : #private }
ConsulAgentHttpAPIBasedDiscoveryClient >> withLocationOfServiceOn: serviceHealthList do: foundBlock ifUnable: failBlock [

	"The API endpoint only filters the service instances failing all healthchecks, 
	so we need to filter them here anyway"

	^ serviceHealthList
		  detect: [ :health | health Checks allSatisfy: [ :check | check Status = 'passing' ] ]
		  ifFound: [ :health | 
			  | service |

			  service := health Service.
			  foundBlock value: ( ( ZnUrl new host: service Address ) port: service Port )
			  ]
		  ifNone: failBlock
]
