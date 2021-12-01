# API Client

When dealing with HTTP APIs, the `API Client` group in the baseline provides
abstractions to ease this kind of interaction.

`RESTfulAPIClient` is the key abstraction for these features. Some of its
functionality is more useful when dealing with a RESTful API but is usable for
non-RESTful APIs also.

`RESTfulAPIClient` provides pooling of the underlying HTTP client, handling of
entity tags, and caching support.

To create an API client you need to provide a block for creating a basic HTTP
client instance and the caching policy.

For example:

```smalltalk
RESTfulAPIClient
  buildingHttpClientWith: [ ZnClient new ]
  cachingIn: ExpiringCache onLocalMemory
```

will instantiate a client pooling ZnClient instances and using an in-memory cache.

API clients support the following methods:

- `getAt:configuredBy:withSuccessfulResponseDo:` will execute a GET against the
  location in the first argument, configured by the second argument. If the
  response is successful the last argument is evaluated with the response's body.
- `postAt:configuredBy:withSuccessfulResponseDo:` will execute a POST against the
  location in the first argument, configured by the second argument. If the
  response is successful the last argument is evaluated with the response's body.
- `putAt:configuredBy:withSuccessfulResponseDo:` will execute a PUT against the
  location in the first argument, configured by the second argument. If
  the response is successful, the last argument is evaluated with the response's
  body, unless it is `204/No content`.
- `patchAt:configuredBy:withSuccessfulResponseDo:` will execute a PATCH against the
  location in the first argument, configured by the second argument. If
  the response is successful, the last argument is evaluated with the response's
  body.
- `deleteAt:configuredBy:withSuccessfulResponseDo:` will execute a DELETE against
  the location in the first argument, configured by the second argument. If the
  response is successful the last argument is evaluated with the response's body.

The configuration blocks follow the builder pattern defined [here](HTTP-Request.md).

If the execution is unsuccessful an `HTTPClientError` exception is raised with
the corresponding response code.

It also supports some convenience methods built on the previous ones:

- `get:accepting:withSuccessfulResponseDo:` will execute a GET against the
  location in the first argument, setting the `Accept` header according to the
  second argument. If the response is successful the last argument is evaluated
  with the response's body.
- `get:withSuccessfulResponseDo:` will execute a GET against the location in the
  first argument without further configuration. If the response is successful
  the last argument is evaluated with the response's body.
- `post:at:withSuccessfulResponseDo:` will execute a POST, whose body and
  `Content-Type` is defined by the entity in the first argument, against the
  second argument. If the response is successful the last argument is evaluated
  with the response's body.
- `patch:at:withSuccessfulResponseDo:` will execute a PATCH, whose body and
  `Content-Type` is defined by the entity in the first argument, against the
  second argument. If the response is successful the last argument is evaluated
  with the response's body.
- `put:at:` will execute a PUT, whose body and `Content-Type` is defined by the
  entity in the first argument, against the second argument. If the response is
  successful the last argument is evaluated with the response's body.
- `deleteAt:` will execute a DELETE against the location in the first argument.
  If there's an entity tag associated with this location it will set the
  `If-Match` header making the delete conditional.

## Pooling

By default, an API client will lazily create a pool for each authority and port
used in an invocation. Currently, each pool has at least a connection alive with
a maximum of 5 connections.

On API client disposition all the connections in the pool are closed.

## Entity tags handling

The `ETag` HTTP response header is an identifier for a specific version of a
resource. It allows caches to be more efficient, and saves bandwidth, as a web
server does not need to send a full response if the content has not changed. On
the other side, if the content has changed, entity tags are useful to help prevent
simultaneous updates of a resource from overwriting each other ("mid-air collisions").

If the resource at a given URL changes, a new entity tag value must be generated.
Entity tags are therefore similar to fingerprints and might also be used for tracking
purposes by some servers. A comparison of them allows us to quickly determine
whether two representations of a resource are the same, but they might also be
set to persist indefinitely by a tracking server.

`RESTfulAPIClient` take advantage of entity tags, when present, in the following
scenarios:

- When receiving a successful response including the `ETag` header, both the
  entity tag value and the response body are cached in the client.
- When using `deleteAt:` or `patch:at:withSuccessfulResponseDo:` convenience
  methods, if an entity tag was previously saved its value is used in an
  `If-Match` header preventing deleting or patching a resource whose representation
  has changed from the last time it was seen by the client.
- When using any of the `GET`-related methods, if an entity tag was previously
  saved its value is used in an `If-None-Match` header. Giving the server the
  chance to respond with `204/Not modified` and in that case, the previously
  saved body is used as the response body.

## Caching

`RESTfulAPIClient` also provides a resource cache. It can be configured to use an
in-memory cache (inside the same image) or a shared cache using [Memcached](https://www.memcached.org/).

To use an in-memory cache provide it to the API client doing:

```smalltalk
ExpiringCache onLocalMemory
```

and, for a shared cache:

```smalltalk
ExpiringCache onDistributedMemoryAt: serverList
```

where `serverList` is something like `{'127.0.0.1:11211'}`

Both kinds of caches take into account the `Cache-Control` headers received in
the responses. When the API client receives any of the `GET`-related messages it
lookups in the cache if there's a non-expired resource cached for this location.
If it is, it will reuse that. In case there's no cached resource or the cached one
is expired it will proceed to execute the `GET`.

Resources are cached when a successful `GET` response is received; and cleared when
any `POST`, `PUT`, `PATCH`, or `DELETE` method is executed against this location,
or when a cached resource is expired.
