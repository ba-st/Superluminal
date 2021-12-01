# HTTP Requests

The library's base abstraction, provided by the `Core` baseline group, is `HttpRequest`.
It provides a builder-like interface to create HTTP requests that can be
later applied to an HTTP client (like `ZnClient` in Pharo).

`HttpRequest` creates instances by using any of:

- `get:configuredUsing:`
- `post:configuredUsing:`
- `delete:configuredUsing:`
- `patch:configuredUsing:`
- `put:configuredUsing:`

where the first argument is anything convertible to an URL (it will receive the
`asUrl` message), and the second argument is a configuration closure providing
the builder interface.

For example:

```smalltalk
HttpRequest
    get: 'https://api.example.com'
    configuredUsing: [ :request | 
      request headers setBearerTokenTo: 'eJwdjdmOqlgARd' ].
```

will produce the following

```http
GET / HTTP/1.1
Authorization: Bearer eJwdjdmOqlgARd
Host: api.example.com
```

## Configuring the request

The builder instance injected into the configuration closure supports the
following messages:

- `body`
- `headers`
- `queryString:`

The `body` builder supports:

- `contents:` receiving an `Entity`
- `contents:encodedAs:` will produce an entity including the contents in the
  first argument with the media type in the second argument as its type.
- `formUrlEncoded:` produces a body of type `application/x-www-form-urlencoded`
  with the fields declared in the argument block.
- `multiPart:` produces a body of type `multipart/form-data` with the fields and
  files declared in the argument block.
- `json:` is syntactic sugar to easily produce a JSON body. The media type will
  be `application/json`, and the argument will be converted to JSON by using `NeoJSONWriter`.

The `headers` builder supports:

- `set:to:` setting a header named as the first argument with the value in the
  second one.
- `setAcceptTo:` will set the `Accept` header with the value in the argument.
- `setIfMatchTo:` and `setIfNoneMatchTo:` will receive an `ETag` and use it as the
  corresponding value in `If-Match` or `If-None-Match` header.
- `setAuthorizationTo:` will set the value in the `Authorization` header
- `setBearerTokenTo:` is syntactic sugar over the previous one to easily set a
  Bearer token directive.

The `queryString:` builder supports:

- `fieldNamed:pairedTo:` to add a query field with the provided name and value.

The `formUrlEncoded:` builder supports:

- `fieldNamed:pairedTo:` to add a form field with the provided name and value.

The `multiPart:` builder supports:

- `fieldNamed:pairedTo:` to add a form field with the provided name and value.
- `fieldNamed:attaching:` to add a file attachment with the provided name and content.

## Applying the request

Once the request is created, to execute it you need to apply it to some
compatible HTTP client by sending  `applyOn:`.

For example:

```smalltalk
| request |
request :=
  HttpRequest
    get: 'https://api.example.com'
    configuredUsing: [ :request | 
      request headers setBearerTokenTo: 'eJwdjdmOqlgARd' ].
request applyOn: ZnClient new
```
