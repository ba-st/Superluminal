# Service Discovery

When dealing with internal HTTP APIs, the `Service Discovery` group in the
baseline provides abstractions to ease the discovery of the hostname and port
attached to a service.

These functions are performed by sending the message
`withLocationOfService:do:ifUnable:` to a service discovery client. Service
discovery clients can be chained, so if one client cannot discover a service
it will pass the query to the next one in the chain.

The following service discovery clients are supported:

- `NullServiceDiscoveryClient` will always fail when looking up services by their
  name. In general, it's the last one in a discovery client chain.
- `FixedServiceDiscoveryClient` works with a fixed list of service locations.
  It's useful for testing purposes or when transitioning from clients not using the
  service discovery mechanics. It is chainable with another service discovery
  client as a fallback.
- `ConsulAgentHttpAPIBasedDiscoveryClient` will use the [Consul HTTP API](https://www.consul.io/use-cases/service-discovery-and-health-checking)
  to get a list of service locations. It uses the `Health` endpoint to obtain
  the list of healthy services, then looks up the `Address` and `Port` provided
  in the response. It is chainable with another service discovery client as a fallback.
  Since it's querying an API it requires some configuration:
  - `#agentLocation` must provide the location of the Consul agent
  - `#retry` is optional and used to configure the retry policy in case the API
    call fails.

    By default the client will retry up to 2 times when a `NetworkError` or
    `HTTPError` happens during the API call, before failing and passing
    control to the next client in the chain.

    The retry options can be anyone of those described [here](https://github.com/ba-st/Hyperspace/blob/release-candidate/docs/Resilience.md)
