# mh-http

> a simple http library written in Jai.

> [!WARNING]
> This is unfinished software. Here be Dragons!

## Jai Version
The latest version of Jai I have compiled this with is:
```console
$ jai -version
Version: beta 0.1.077, built on 17 November 2023.
```

## Examples
I have made some examples in the `examples/` directory.

## Features
- HTTP Request message parser  
    Can parse HTTP request messages.
    You provide the message as a string, and it does the rest.
    It is located in the `parse_request.jai` file, and can
    be disabled with the `NO_PARSE_REQUEST` flag.
- HTTP Response message parser  
    Can parse HTTP response messages.
    You provide the message as a string, and it does the rest.
    It is located in the `parse_response.jai` file, and can
    be disabled with the `NO_PARSE_RESPONSE` flag.
