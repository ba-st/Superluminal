# Logging HTTP Requests

The requests sent by `HttpRequest` and `RESTfulAPIClient` go through `ZnClient`,
which announces a `ZnLogEvent` for each step. Hyperspace's
`ZnEventToLogRecordAdapter`, loaded by the `Core` baseline group, turns those
events into [Bell](https://github.com/ba-st/Bell/blob/release-candidate/docs/reference/Logging.md)
`LogRecord`s with structured data, so they can be output by any Bell logger.

To start logging the outgoing requests:

```smalltalk
adapter := ZnEventToLogRecordAdapter new.
adapter
  logOutgoingRequests: true;
  startUpListeners
```

and to stop:

```smalltalk
adapter stopListeners
```

Each request produces two `DEBUG` log records: `Outgoing HTTP request sent`
when the request is written, and `Outgoing HTTP request responded` when the
response arrives. With `StandardStreamLogger onStandardOutput` handling the
log records, a request looks like:

<!-- markdownlint-disable line_length -->
```bash
2026-10-12T20:25:25.600748-03:00 [DEBUG] Outgoing HTTP request sent {"summary":"2026-10-12 20:25:25 005 896848 Request Written a ZnRequest(GET /help) 0ms","durationInMilliseconds":0,"request":{"method":"GET","uri":"http://localhost:18471/help"},"processId":896848,"eventId":5}
2026-10-12T20:25:25.605932-03:00 [DEBUG] Outgoing HTTP request responded {"summary":"2026-10-12 20:25:25 011 896848 GET /help 200 769B 4ms","durationInMilliseconds":4,"request":{"method":"GET","uri":"http://localhost:18471/help"},"processId":896848,"eventId":11,"response":{"code":200,"totalSize":769}}
```
<!-- markdownlint-enable line_length -->

The structured data holds:

- `summary`: Zinc's own one-line description of the event
- `durationInMilliseconds`
- `request`: its `method` and `uri`
- `response`: its `code` and `totalSize`, only when the response has a
  non-binary entity
- `processId` and `eventId`, to correlate the records of the same request

Headers are not logged, so an `Authorization` header set with
`setBearerTokenTo:` or `setUsername:andPassword:` does not reach the logs. The
query string does, as part of the `uri`: avoid sending secrets in it.

`logIncomingRequests: true` also logs the requests received by a `ZnServer` in
the same image. Stargate applications use it to log the requests they serve.
