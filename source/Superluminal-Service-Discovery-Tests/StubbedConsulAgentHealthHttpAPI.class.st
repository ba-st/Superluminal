"
I'm a test double stubbing the health HTTP API of the Consul Agent.
"
Class {
	#name : 'StubbedConsulAgentHealthHttpAPI',
	#superclass : 'Object',
	#instVars : [
		'asserter',
		'server'
	],
	#category : 'Superluminal-Service-Discovery-Tests',
	#package : 'Superluminal-Service-Discovery-Tests'
}

{ #category : 'instance creation' }
StubbedConsulAgentHealthHttpAPI class >> configuredBy: configuration on: aTestAsserter [

	^ self new initializeConfiguredBy: configuration on: aTestAsserter
]

{ #category : 'initialization' }
StubbedConsulAgentHealthHttpAPI >> configureTeapotServerWith: configuration [

	server := Teapot configure: configuration , { #defaultOutput -> #json }.
	server GET:
		'v1/health/service/<serviceName:IsObject>'
		-> [ :request | self handleServiceHealthLookup: request ]
]

{ #category : 'private' }
StubbedConsulAgentHealthHttpAPI >> handleServiceHealthLookup: httpRequest [

	| serviceName json |

	asserter assert: httpRequest method equals: #GET.
	serviceName := httpRequest at: #serviceName.
	json := serviceName = 'mns' then: [ self stubbedBodyResponse ] otherwise: [ '[]' ].
	^ TeaResponse ok
		  body: (NeoJSONObject fromString: json);
		  headerName: 'X-Consul-Effective-Consistency' value: 'leader';
		  headerName: 'X-Consul-Index' value: '23';
		  headerName: 'X-Consul-Knownleader' value: 'true';
		  headerName: 'X-Consul-Lastcontact' value: '0';
		  yourself
]

{ #category : 'initialization' }
StubbedConsulAgentHealthHttpAPI >> initializeConfiguredBy: configuration on: aTestAsserter [

	asserter := aTestAsserter.
	self configureTeapotServerWith: configuration
]

{ #category : 'controlling' }
StubbedConsulAgentHealthHttpAPI >> start [

	server start
]

{ #category : 'controlling' }
StubbedConsulAgentHealthHttpAPI >> stop [

	server stop
]

{ #category : 'private' }
StubbedConsulAgentHealthHttpAPI >> stubbedBodyResponse [ 
		
	^'[
  {
    "Node": {
      "ID": "ebc2d7c6-9909-ad1a-43d2-5e003202ca31",
      "Node": "93b450bf7c73",
      "Address": "127.0.0.1",
      "Datacenter": "dc1",
      "TaggedAddresses": {
        "lan": "127.0.0.1",
        "lan_ipv4": "127.0.0.1",
        "wan": "127.0.0.1",
        "wan_ipv4": "127.0.0.1"
      },
      "Meta": {
        "consul-network-segment": ""
      },
      "CreateIndex": 11,
      "ModifyIndex": 12
    },
    "Service": {
      "ID": "mns-01649d6c4b01",
      "Service": "mns",
      "Tags": [
        "metrics-provider"
      ],
      "Address": "01649d6c4b01",
      "Meta": {},
      "Port": 60666,
      "Weights": {
        "Passing": 1,
        "Warning": 1
      },
      "EnableTagOverride": false,
      "Proxy": {
        "MeshGateway": {},
        "Expose": {}
      },
      "Connect": {},
      "CreateIndex": 22,
      "ModifyIndex": 22
    },
    "Checks": [
      {
        "Node": "93b450bf7c73",
        "CheckID": "serfHealth",
        "Name": "Serf Health Status",
        "Status": "passing",
        "Notes": "",
        "Output": "Agent alive and reachable",
        "ServiceID": "",
        "ServiceName": "",
        "ServiceTags": [],
        "Type": "",
        "Definition": {},
        "CreateIndex": 11,
        "ModifyIndex": 11
      },
      {
        "Node": "93b450bf7c73",
        "CheckID": "service:mns-01649d6c4b01",
        "Name": "health-check",
        "Status": "passing",
        "Notes": "",
        "Output": "HTTP POST http://01649d6c4b01:60666/operations/health-check: 200 OK Output: {\"status\":\"PASS\"}",
        "ServiceID": "mns-01649d6c4b01",
        "ServiceName": "mns",
        "ServiceTags": [
          "metrics-provider"
        ],
        "Type": "http",
        "Definition": {},
        "CreateIndex": 22,
        "ModifyIndex": 26
      }
    ]
  },
  {
    "Node": {
      "ID": "ebc2d7c6-9909-ad1a-43d2-5e003202ca31",
      "Node": "93b450bf7c73",
      "Address": "127.0.0.1",
      "Datacenter": "dc1",
      "TaggedAddresses": {
        "lan": "127.0.0.1",
        "lan_ipv4": "127.0.0.1",
        "wan": "127.0.0.1",
        "wan_ipv4": "127.0.0.1"
      },
      "Meta": {
        "consul-network-segment": ""
      },
      "CreateIndex": 11,
      "ModifyIndex": 12
    },
    "Service": {
      "ID": "mns-94e2ce29d72a",
      "Service": "mns",
      "Tags": [
        "metrics-provider"
      ],
      "Address": "94e2ce29d72a",
      "Meta": {},
      "Port": 60666,
      "Weights": {
        "Passing": 1,
        "Warning": 1
      },
      "EnableTagOverride": false,
      "Proxy": {
        "MeshGateway": {},
        "Expose": {}
      },
      "Connect": {},
      "CreateIndex": 14,
      "ModifyIndex": 14
    },
    "Checks": [
      {
        "Node": "93b450bf7c73",
        "CheckID": "serfHealth",
        "Name": "Serf Health Status",
        "Status": "passing",
        "Notes": "",
        "Output": "Agent alive and reachable",
        "ServiceID": "",
        "ServiceName": "",
        "ServiceTags": [],
        "Type": "",
        "Definition": {},
        "CreateIndex": 11,
        "ModifyIndex": 11
      },
      {
        "Node": "93b450bf7c73",
        "CheckID": "service:mns-94e2ce29d72a",
        "Name": "health-check",
        "Status": "critical",
        "Notes": "",
        "Output": "Post \"http://94e2ce29d72a:60666/operations/health-check\": dial tcp: lookup 94e2ce29d72a on 127.0.0.11:53: no such host",
        "ServiceID": "mns-94e2ce29d72a",
        "ServiceName": "mns",
        "ServiceTags": [
          "metrics-provider"
        ],
        "Type": "http",
        "Definition": {},
        "CreateIndex": 14,
        "ModifyIndex": 38
      }
    ]
  }
]'
]
