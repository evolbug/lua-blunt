# lua-blunt

An experimental function typechecker implementation for Lua

```lua
add = def 'number' {'number', 'number'}
^ function(a, b)
   return a + b
end

add(1, 2)


generic_add = def 'T' {'T', 'T'}
^ function (a, b)
   return a + b
end

generic_add(1, 2)
```
