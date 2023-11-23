/*
    mh-http, this is the section for parsing HTTP request messages.
    Copyright (C) 2023  marvhus

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
#scope_file

LINE_BREAK :: "\r\n";

#scope_export

HTTP_Method :: enum {
    INVALID; // just for internal use. Ignore me if you are using the library.
    GET;
    HEAD;
    POST;
    PUT;
    DELETE;
    CONNECT;
    OPTIONS;
    TRACE;
    PATCH;
}

Request :: struct {
    method: HTTP_Method;
    path: string;
    protocol_version: string;

    headers: Table(string, string);

    body: string;
}

parse_request :: (text: string) -> success: bool, request: Request {
    request := Request.{};
    remainder := text;

    // parse status line
    {
        found: bool;
        line: string;
        found, line, remainder = split_from_left(remainder, LINE_BREAK);
        if !found {
            mh_log("Unable to find status line. Request is too short.");
            return false, .{};
        }

        success, method, path, protocol_version := parse_request_status(line);
        if !success {
            mh_log("Failed to parse status line.");
            return false, .{};
        }
        request.method = method;
        request.path = path;
        request.protocol_version = protocol_version;
    }

    // parse headers
    {
        success: bool;
        success, remainder = parse_request_headers(remainder, *request.headers);
        if !success {
            mh_log("Failed to parse headers.");
            return false, .{};
        }
    }

    // parse body (just remove the trailing newline)
    {
        found, body, _ := split_from_right(remainder, #char "\n");
        if !found {
            mh_log("Missing newline at ned of body.");
            return false, .{};
        }
        request.body = body;
    }

    return true, request;
}

print_request :: (request: Request, big := false) {
    if big {
        print("{\n");
        print("    method: %\n", request.method);
        print("    path: '%'\n", request.path);
        print("    protocol_version: '%'\n", request.protocol_version);
        print("    headers:\n");
        for request.headers {
            print("     - '%': '%'\n", it_index, it);
        }
        print("    body: '%'\n", request.body);
        print("}\n");
    } else {
        print("{ %, '%', '%', count: %, '%' }\n",
            request.method,
            request.path,
            request.protocol_version,
            request.headers.count,
            request.body);
    }
}

#scope_file

parse_request_headers :: (text: string, headers: *Table(string, string)) -> success: bool, remainder: string {
    found, line, remainder := split_from_left(text, LINE_BREAK);
    // while found a new line, and line is not empty
    while found && line.count > 0 {
        key, value: string;
        // @NOTE: Does it use ': ' or just ':'???
        found, key, value = split_from_left(line, ": ");
        if !found {
            mh_log("Failed to parse header. Invalid formating of header. '%'", line);
        }

        table_add(headers, key, value);

        found, line, remainder = split_from_left(remainder, LINE_BREAK);
    }
    if !found {
        mh_log("Failed to parse headers. Headers ended early.");
        return false, "";
    }

    return true, remainder;
}

parse_request_status :: (text: string) -> success: bool, method: HTTP_Method, path: string, protocol_version: string {
    remainder := text;
    method: HTTP_Method;
    path: string;
    protocol_version: string;

    // HTTP method
    {
        found, left, right := split_from_left(remainder, #char " ");
        if !found {
            mh_log("Failed to find HTTP method.");
            return false, .INVALID, "", "";
        }
        remainder = right;

        if left == {
            case "GET";     method = .GET;
            case "HEAD";    method = .HEAD;
            case "POST";    method = .POST;
            case "PUT";     method = .PUT;
            case "DELETE";  method = .DELETE;
            case "CONNECT"; method = .CONNECT;
            case "OPTIONS"; method = .OPTIONS;
            case "TRACE";   method = .TRACE;
            case "PATCH";   method = .PATCH;
            case;
                mh_log("Invalid HTTP method '%'.", left);
        }
    }

    // path
    {
        found, left, right := split_from_left(remainder, #char " ");
        if !found {
            mh_log("Failed to find request target.");
            return false, .INVALID, "", "";
        }
        remainder = right;
        path = left;
    }

    // protocol version
    {
        // @NOTE: should I just store "1.1" or should I store the full "HTTP/1.1"???
        found, left, right := split_from_left(remainder, #char "/");
        if !found {
            mh_log("Failed to find protocol_version.");
            return false, .INVALID, "", "";
        }
        protocol_version = right;
    }

    return true, method, path, protocol_version;
}

#import "Hash_Table";
#import "String";
#import "Basic";
