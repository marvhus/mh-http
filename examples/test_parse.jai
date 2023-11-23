#import,dir "..";

main :: () {
    success, parsed := parse_response("HTTP/1.1 200 OK\r\nA: b\r\nB: c\r\n\r\nHello World!\n");
    if success {
        print_response(parsed);
        print_response(parsed, true);
    }
}
