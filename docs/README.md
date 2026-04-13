# Superluminal Documentation

Superluminal provides building blocks for creating HTTP requests and API
clients, including:

- Entity tags handling
- Caching
- Service Discovery

To learn about the project, [install it](how-to/how-to-load-in-pharo.md) and
lookup for details in the reference docs:

- [HTTP Requests](reference/HTTP-Request.md)
- [API Clients](reference/API-Client.md)
- [Service Discovery](reference/Service-Discovery.md)

To correctly run some of the tests from within the Pharo image,
you will need to run local containers of [httpbin](http://httpbin.org/) and
[memcached](https://memcached.org/), which can be achieved by executing:
`docker run -d -p 127.0.0.1:80:80 ghcr.io/ba-st-dependencies/httpbin:master`
and
`docker run -d -p 127.0.0.1:11211:11211 memcached:1.6-alpine`
respectively.

---

To use the project as a dependency of your project, take a look at:

- [How to use Superluminal as a dependency](how-to/how-to-use-as-dependency-in-pharo.md)
- [Baseline groups reference](reference/Baseline-groups.md)
