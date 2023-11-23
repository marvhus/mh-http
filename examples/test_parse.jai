#import,dir "..";

main :: () {
    {
        print("Testing parsing of HTTP response message...\n");
        success, parsed := parse_response("HTTP/1.1 200 OK\r\nA: b\r\nB: c\r\n\r\nHello World!\n");
        if success {
            print_response(parsed);
            print_response(parsed, true);
        }
    }
    {
        print("Testing parsing of HTTP request message...\n");
        success, parsed := parse_request("GET / HTTP/1.1\r\nA: b\r\nB: c\r\n\r\nHello, World!\n");
        if success {
            print_request(parsed);
            print_request(parsed, true);
        }
    }
}

#import "Basic";
