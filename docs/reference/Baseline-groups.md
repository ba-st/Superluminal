# Baseline Groups

Superluminal includes the following groups in its Baseline that can be used as
loading targets:

- `Core` will load the minimal required packages to support `HttpRequest` and
  its building interface
- `API Client` will load the packages needed to support API clients, including:
  - HTTP client pooling by authority
  - ETag caching and automatic support for `If-None-Match` and `If-Match` headers,
    and `Not modified` responses
  - Caching support according to `Cache-Control` headers, both in-memory or using
    memcached
- `Service Discovery` will load the packages needed to support service discovery
  against a Consul agent
- `Deployment` will load all the packages needed in a deployed application, which in this
  case correspond to `Core` + `API Client` + `Service Discovery`
- `Examples` will load a service discovery-enabled application
- `Tests` will load the test cases
- `Dependent-SUnit-Extensions` will load extensions to SUnit for testing API clients
- `CI` is the group loaded in the continuous integration setup, in this
  particular case it is the same as `Tests`
- `Development` will load all the needed packages to develop and contribute to
  the project
