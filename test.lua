def = require 'blunt'

testf = {
   none = def ^ function(ret)
      if ret then return ret end
   end;

   ret = def 'number' ^ function (ret)
      if ret=='none' then return end
      if ret then return 'fail' end
      return 1
   end;

   mulret = def ('number', 'number') ^ function (ret)
      if ret == 1 then return 1 end
      if ret == 2 then return 1, 2 end
      if ret == 3 then return 1, 2, 3 end
   end;

   arg = def {'number'} ^ function (arg)
   end;

   retarg = def 'number' {'number', 'number'} ^ function (a, b)
      if a == 0 and b == 0 then return 'string' end
      return a + b
   end;

   gret = def 't' ^ function (ret)
      if ret == 'num' then return 1 end
      if ret == 'string' then return 'asd' end
   end;

   garg = def {'t','t'} ^ function (a, b)
      if type(a) == 'number' then
         return a + b
      elseif type(a) == 'string' then
         return a..b
      end
   end;

   gretarg = def 't' {'t', 't'} ^ function (a, b)
      if type(a) == 'number' then
         return a + b
      elseif type(a) == 'string' then
         return 1
      end
   end;

   multi = def 'string|nil' {'number|string', 'number|nil'} ^ function (a, b)
      if type(a) == 'string' and b then
         return tostring(a) .. tostring(b)
      elseif type(a) == 'number' and b then
         return a + b
      end
   end
}

tests = {
   none = {
      [true] = {{}, {true}, {false}, {1,2}},
   },

   ret = {
      [true] = {{}, {false}},
      [false] = {{true}, {'none'}, {1,2,3}}
   },

   mulret = {
      [true] = {{2}},
      [false] = {{1}, {3}}
   },

   arg = {
      [true] = {{1}},
      [false] = {{}, {1,2}, {'string'}}
   },

   retarg = {
      [true] = {{1, 2}},
      [false] = {{0,0}, {1}, {nil, 1}, {}}
   },

   gret = {
      [true] = {{'num'}, {'string'}, {}},
      [false] = {}
   },

   garg = {
      [true] = {{1,2}, {'a', 'b'}},
      [false] = {{1,'2'}, {1}, {nil, 2}}
   },

   gretarg = {
      [true] = {{1, 2}},
      [false] = {{'a', 'b'}, {1,'2'}, {1}, {nil, 2}, {1,2,3}}
   },

   multi = {
      [true] = {{'asd', 2}, {1}, {'asd'}},
      [false] = {{1,2}, {}, {1,'asd'}, {1,2,3}, {nil, '1'}}
   },
}

for i, func in pairs(testf) do
   local tests = tests[i]

   for succ_expected, tests in pairs(tests) do
      for _, args in pairs(tests) do
         local state = {pcall(func, unpack(args))}
         if state[1] == succ_expected then
            print(
               '\27[32m'..i..'.'..tostring(succ_expected)..'.'.._..' passed'..'\27[0m')
         else
            print(
               '\27[31m'..i..'.'..tostring(succ_expected)..'.'.._..' failed'..'\27[0m')
         end
      end
   end
end

