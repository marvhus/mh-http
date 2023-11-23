/*
    mh-http, This is the module entrypoint for a simple http library in Jai.
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

#scope_export

#module_parameters (
    NO_LOG            := false,
    NO_PARSE_RESPONSE := false,
    NO_PARSE_REQUEST  := false
);

#if !NO_PARSE_RESPONSE #load "parse_response.jai";
#if !NO_PARSE_REQUEST  #load "parse_request.jai";

#scope_module

mh_log :: (text: string, args: ..Any) {
    #if !NO_LOG {
        log(tprint("MH_LOG: %\n", text), ..args);
    }
}

#import "Basic";
