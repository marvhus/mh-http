/*
    mh-http, this is the section for parsing HTTP response messages.
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

Response :: struct {
    protocol_version: string;
    status_code: u16;
    status_text: string;

    headers: Table(string, string);

    body: string;
}

parse_response :: (text: string) -> success: bool, response: Response {
    response := Response.{};
    remainder := text;

    // parse status line
    {
        found: bool;
        line: string;
        found, line, remainder = split_from_left(remainder, LINE_BREAK);
        if !found {
            mh_log("Unable to find status line. Response is too short.");
            return false, .{};
        }

        success, protocol_version, status_code, status_text := parse_response_status(line);
        if !success {
            mh_log("Failed to parse status line.");
            return false, .{};
        }
        response.protocol_version = protocol_version;
        response.status_code = status_code;
        response.status_text = status_text;
    }

    // parse headers
    {
        success: bool;
        success, remainder = parse_response_headers(remainder, *response.headers);
        if !success {
            mh_log("Failed to parse headers.");
            return false, .{};
        }
    }

    // parse body (just remove the trailing newline)
    {
        found, body, _ := split_from_right(remainder, #char "\n");
        if !found {
            mh_log("Missing newline at end of body.");
            return false, .{};
        }
        response.body = body;
    }

    return true, response;
}

print_response :: (response: Response, big := false) {
    if big {
        print("{\n");
        print("    protocol_version: '%'\n", response.protocol_version);
        print("    status_code: %\n", response.status_code);
        print("    status_text: '%'\n", response.status_text);
        print("    headers:\n");
        for response.headers {
            print("     - '%': '%'\n", it_index, it);
        }
        print("    body: '%'\n", response.body);
        print("}\n");
    } else {
        print("{ '%', %, '%', count: %, '%' }\n",
            response.protocol_version,
            response.status_code,
            response.status_text,
            response.headers.count,
            response.body);
    }
}

#scope_file

parse_response_headers :: (text: string, headers: *Table(string, string)) -> success: bool, remainder: string {
    found, line, remainder := split_from_left(text, LINE_BREAK);
    // while found a new line, and line is not empty
    while found && line.count > 0 {
        key, value: string;
        // @NOTE: Does it use ': ' or just ':'???
        found, key, value = split_from_left(line, ": ");
        if !found {
            mh_log("Failed to parse header. Invalid formating of header. '%'", line);
            return false, "";
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

parse_response_status :: (text: string) -> success: bool, protocol_version: string, status_code: u16, status_text: string {
    remainder := text;
    protocol_version: string;
    status_code: u16;
    status_text: string;

    // protocol version
    {
        // @NOTE: Should I just store "1.1" or should I store the full "HTTP/1.1"???
        found, left, right := split_from_left(remainder, #char " ");
        if !found {
            mh_log("Failed to find protocol version.");
            return false, "", 0, "";
        }
        found, _, protocol_version = split_from_left(left, #char "/");
        if !found {
            mh_log("Invalid protocol version format.");
            return false, "", 0, "";
        }
        remainder = right;
        protocol_version = copy_string(protocol_version);
    }

    // status code and text
    {
        found, code, rest_of_status := split_from_left(remainder, #char " ");
        if !found {
            mh_log("Failed to find status code.");
            return false, "", 0, "";
        }
        parsed_code, success := string_to_int(code, 10, u16);
        if !success {
            mh_log("Status code is not a number.");
            return false, "", 0, "";
        }
        status_code = parsed_code;
        status_text = rest_of_status;
    }

    return true, protocol_version, status_code, status_text;
}

#import "Hash_Table";
#import "String";
#import "Basic";
