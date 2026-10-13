# API Client

When dealing with HTTP APIs, the `API Client` group in the baseline provides
abstractions to ease this kind of interaction.

`RESTfulAPIClient` is the key abstraction for these features. Some of its
functionality is more useful when dealing with a RESTful API but is usable for
non-RESTful APIs as well.

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

will instantiate a client pooling `ZnClient` instances and using an in-memory cache.

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
- `queryAt:configuredBy:withSuccessfulResponseDo:` will execute a QUERY against
  the location in the first argument, configured by the second argument. If the
  response is successful the last argument is evaluated with the response's body.

The configuration blocks follow the builder pattern defined [here](HTTP-Request.md).

If the execution is unsuccessful an `HTTPClientError` exception is raised with
the corresponding response code.

It also supports some convenience methods built on the previous ones:

- `get:accepting:withSuccessfulResponseDo:` will execute a `GET` against the
  location in the first argument, setting the `Accept` header according to the
  second argument. If the response is successful the last argument is evaluated
  with the response's body.
- `get:withSuccessfulResponseDo:` will execute a `GET` against the location in the
  first argument without further configuration. If the response is successful
  the last argument is evaluated with the response's body.
- `post:at:withSuccessfulResponseDo:` will execute a `POST`, whose body and
  `Content-Type` is defined by the entity in the first argument, against the
  second argument. If the response is successful the last argument is evaluated
  with the response's body.
- `patch:at:withSuccessfulResponseDo:` will execute a `PATCH`, whose body and
  `Content-Type` is defined by the entity in the first argument, against the
  second argument. If the response is successful the last argument is evaluated
  with the response's body.
- `put:at:` will execute a `PUT`, whose body and `Content-Type` is defined by the
  entity in the first argument, against the second argument. If the response is
  successful the last argument is evaluated with the response's body.
- `deleteAt:` will execute a `DELETE` against the location in the first argument.
  If there's an entity tag associated with this location it will set the
  `If-Match` header making the `DELETE` conditional.
- `query:at:accepting:withSuccessfulResponseDo:` will execute a `QUERY`,
  whose body and `Content-Type` is defined by the entity in the first argument,
  against the second argument, setting the `Accept` header according to the
  third argument. If the response is successful the last argument is evaluated
  with the response's body.  

## Error handling

When a response is not successful, the API client signals an `HTTPError` with
the response's status code: an `HTTPServerError` for `5xx` codes and an
`HTTPClientError` otherwise, whatever the HTTP method. Network errors are
signaled as an `HTTPServerError` too: `504` for a timeout, `500` for anything
else.

The error's message is a default one (`Cannot complete the request`,
`Cannot complete update` or `Cannot complete delete`) unless the response
describes it. By default, an `application/json` response with a `message`
member, as Stargate answers its errors, provides the message.

To read other error formats, register a block for their media type with
`onErrorsTyped:do:`. The block receives the error about to be signaled and the
response, and can change the error's message or attach additional data to it:

```smalltalk
apiClient
  onErrorsTyped: 'application/vnd.acme.error+json'
  do: [ :error :response |
    | json |
    json := NeoJSONObject fromString: response contents.
    error
      messageText: ( json at: #summary );
      additionalDataAt: #reasons put: ( json at: #reasons ) ]
```

- The media type can be a pattern, like `application/*`. Blocks are tried in the
  order they were registered, and before the default one for `application/json`,
  so registering `application/json` replaces it.
- Registering the same media type again replaces its block.
- If the block fails, the error is signaled with its default message and no
  additional data, and a warning `LogRecord` names the status code, the location
  and the reason.

For APIs answering [problem details](https://www.rfc-editor.org/rfc/rfc9457)
(`application/problem+json`), send `handleErrorsTypedAsProblemDetails` to the
client. The `detail` member, or the `title` when there is no `detail`, becomes
the error's message, and every other member except `status` (`type`, `title`,
`instance` and any extension member) is kept as the error's additional data:

```smalltalk
apiClient handleErrorsTypedAsProblemDetails.
[
  apiClient
    get: 'https://api.example.com/account/12345'
    withSuccessfulResponseDo: [ :contents | ... ] ]
  on: HTTPClientError
  do: [ :error |
    error messageText. "Your current balance is 30, but that costs 50."
    error additionalDataAt: #type. "https://example.com/probs/out-of-credit"
    error additionalDataAt: #balance "30" ]
```

## Pooling

Every time an API call is made, if a new authority and port is used
for the invocation the API client will create a connection pool.

Currently, each pool created has at least one connection alive with
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

`RESTfulAPIClient` takes advantage of entity tags, when present, in the following
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
  saved body is used as the response body; unless a `no-store` caching directive
  is in place.

An `ETag` value that is not a valid entity tag, such as `"1 2 3"` or one not
enclosed in double quotes, is treated as if the header were absent: the response
body is still answered, nothing is cached for that location, and any entity tag
previously saved for it is discarded. A warning `LogRecord` names the location,
the value and why it was refused.

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
the responses. When the API client receives any of the `GET` or
`QUERY`-related messages it looks up in the cache if there's a non-expired
resource cached for this location (also  considering the content of the body
in the case of `QUERY`).

If it is, it will reuse that. In case there's no cached resource or the cached one
has expired it will proceed to execute the `GET` or `QUERY`.

Resources are cached when a successful `GET` or `QUERY` response is received;
and cleared when any `POST`, `PUT`, `PATCH`, or `DELETE` method
is executed against this location, or when a cached resource is expired.

The following caching headers are supported:

- `Expires`
- `Cache-Control`
  - `Max-Age`
  - `no-cache`
  - `no-store`
