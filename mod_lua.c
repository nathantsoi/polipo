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

lua_State *L = NULL;
AtomPtr luaScriptDir = NULL;
int luaActive = 0;

int last_function_number;
static void open_libs(lua_State *L);

void
modLua_init() {
    luaActive = 1;
    L = luaL_newstate();
    open_libs(L);
}

void
modLua_shutdown() {
    luaActive = 0;
    lua_close(L);
}

static void open_libs(lua_State *L)
{
    luaL_openlibs(L);
}

void
modLua_reportErrors(lua_State *L, int status)
{
    if(status == 0)
        return;
    fprintf(stderr, "%sLua error: '%s'%s\n", KRED, lua_tostring(L, -1), KEND);
    lua_pop(L, 1);
}

void
modLua_printGlobals() {
  const char* name = NULL;
  // Get global table
  lua_pushglobaltable(L);
  // Put a nil key on stack
  lua_pushnil(L);
  // key(-1) is replaced by the next key(-1) in table(-2)
  while (lua_next(L,-2) != 0) {
    // Get key(-2) name
    name = lua_tostring(L,-2);
    fprintf(stderr, "global: %s\n", name);
    // remove value(-1), now key on top at(-1)
    lua_pop(L,1);
  }
  // remove global table(-1)
  lua_pop(L,1);
}

void
modLua_loadFile(char* filename) {
    int err = luaL_dofile(L, filename);
    if (err) {
      printf("Error loading lua source: '%s'\n", filename);
      modLua_reportErrors(L, err);
    } else {
      printf("Loaded lua source: '%s'\n", filename);
    }
    fflush(stdout);
}

int
initLuaScripts()
{
    glob_t globBuffer;
    int i, matchCount;

    if(luaScriptDir != NULL && luaScriptDir->length == 0) {
        releaseAtom(luaScriptDir);
        luaScriptDir = NULL;
    }

    if(luaScriptDir == NULL)
      luaScriptDir = internAtom("~/.polipo/lua/");

    luaScriptDir = expandTilde(luaScriptDir);
    if (luaScriptDir->string[luaScriptDir->length - 1] != '/') {
      luaScriptDir = atomCat(luaScriptDir, "/*");
    } else {
      luaScriptDir = atomCat(luaScriptDir, "*");
    }

    glob(luaScriptDir->string, 0 , NULL , &globBuffer);
    matchCount = globBuffer.gl_pathc;
    if(matchCount > 0) {
        modLua_init();
    }

    for (i=0; i < matchCount; i++) {
        if(access(globBuffer.gl_pathv[i], F_OK) < 0) {
            fprintf(stderr, "Error loading lua source '%s'\n", globBuffer.gl_pathv[i]);
        } else {
            modLua_loadFile(globBuffer.gl_pathv[i]);
        }
    }
    globfree(&globBuffer);

    return 1;
}
