/*
Copyright (c) 2014 Nathan Tsoi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#include "polipo.h"

extern lua_State *L;
extern int last_function_number;
// Should match the values in http.h
const char * METHOD_STRINGS[] =
{
  "GET",
  "HEAD",
  "CONDITIONAL_GET",
  "CONNECT",
  "POST",
  "PUT"
};

void
modLuaApi_parentProxyScript(int method, ObjectPtr object, HTTPRequestPtr requestor) {
    size_t len;
    char* url = object->key;
    // pgl.yoyo.org/luai/i/lua_call
    // gamedevgeek.com/tutorials/calling-lua-functions/
    lua_getglobal(L, "parentProxyScript");
    // if the function exists
    if(lua_isfunction(L,lua_gettop(L))) {
        lua_pushstring(L, METHOD_STRINGS[method]);
        lua_pushstring(L, url);
        lua_pushstring(L, requestor->headers->string);
        int err = lua_pcall(L, 3, LUA_MULTRET, last_function_number);
        if (err != 0) {
            modLua_reportErrors(L, err);
        } else {
            // check for headers
            lua_tolstring(L, -1, &len);
            if (len) {
              const char* headers = lua_tostring(L, -1);
              if (strcmp(headers, requestor->headers->string) != 0) {
                releaseAtom(requestor->headers);
                requestor->headers = internAtom(headers);
              }
            }
            lua_pop(L, 1);
            // check for port
            lua_tolstring(L, -1, &len);
            if (len) {
              parentPort = (int)lua_tointeger(L, -1);
            }
            lua_pop(L, 1);
            // check for host
            lua_tolstring(L, -1, &len);
            if (len) {
              parentHost = internAtom(lua_tostring(L, -1));
            }
            lua_pop(L, 1);
        }
    // no function with that name exists, which is fine
    } else {
        // pop the function name off and continue
        fprintf(stderr, "  doesnt exist\n");
        lua_pop(L, 1);
    }
}
