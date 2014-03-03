# Polipo

Polipo is single-threaded, non blocking caching web proxy that has
very modest resource needs, now with lua extensibility.

## Usage
```
polipo [ -h ] [ -v ] [ -x ] [ -c filename ] [ -- ] [ var=val... ]
  -h: display this message.
  -v: display the list of configuration variables.
  -x: perform expiry on the disk cache.
  -c: specify the configuration file to use.
```


# Building

Clone the source and run:

```
make
./polipo
```

note, I've only built the lua-extended version on my mac. I hope it works on other platforms, but no guarantees


# Config

polipo expects a config file at ```~/.polipo/config```

see the [sample config](config.sample)


# Lua Scripting

on startup, polipo will load all files ending in ```.lua``` in the folder ```~/.polipo/lua``` or the folder specified as the config parameter ```luaScriptDir```

e.g. add the file ```~/.polipo/lua/proxyChooser.lua``` and you'll see something like this when you start polipo:
```
Loaded lua source: '/home/username/.polipo/lua/proxyChooser.lua'
```

## When do I have to restart?

changes within api methods do not require polipo to be restarted

howevever, if initialization is done within a lua script file, outside of an api methods, polipo must be restarted to re-load the file and re-run the initalization method(s)

e.g. no restart required. note, this example is explained in depth below
```
 parentProxyScript = function(method, url, headers)
   if method == "GET" then
     return "127.0.0.1", "8080"
   end
   return nil, nil
 end
```

e.g. if upstreamHost is changed, polipo must be restarted:
```
upstreamHost = "127.0.0.1"
parentProxyScript = function(method, url, headers)
  if method == "GET" then
    return upstreamHost, "8080"
  end
  return nil, nil
end
```


## API methods

 - parentProxyScript(method, url, headers): returns host, port

   parentProxyScript takes a method name and url then returns a parent proxy hostname and port

   e.g.
```
-- always use the proxy  on localhost:8080 for GET requests to and no proxy for other requests
parentProxyScript = function(method, url, headers)
  if method == "GET" then
    return "127.0.0.1", "8080"
  end
  return nil, nil
end
```


# Contributing

it would be awesome if you want to implement other hooks or make the existing better, I'll gladly pull them in

### Original Readme:

Current information about Polipo can be found on the Polipo web page,

    http://www.pps.jussieu.fr/~jch/software/polipo/

Further inquiries should be sent to the Polipo-users mailing list:

    <polipo-users@lists.sourceforge.net>

Please see the Polipo web page for subscription information.


Juliusz Chroboczek
<jch@pps.jussieu.fr>
