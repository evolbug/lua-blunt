--[[
   evolbug 2018, MIT License
   blunt typechecking library
]]

local function table_len (t)
   local ln = 0
   for _,v in pairs(t) do ln = _ end
   return ln
end

local function table_pcat (t, delim)
   local out = ''
   for i=1, table_len(t) do
      out = out .. tostring(t[i]) .. delim
   end
   return out:sub(0,#out-#delim)
end

local function check_rets (types, const, ptypes, pconst)
   local len_const = table_len(const)
   local len_types = table_len(types)
   local len_max = len_const > len_types and len_const or len_types

   for i = 1, len_max do

      if #const[i] == 1 then -- 1 char type length == generic

         for j = i + 1, len_max do
            if const[j] == const[i] and types[i] ~= types[j] then
               error(
                  'return type mismatch:'
                  ..'\n\tfor generic constraint ['..const[i]..']'
                  ..'\n\texpected ['..table_pcat(const, ", ")..']'
                  ..'\n\tgot      ['..table_pcat(types, ', ')..']'
               )
            end
         end

         if ptypes and pconst then
            for j = 1, table_len(pconst) do

               if pconst[j] == const[i] and types[i] ~= ptypes[j] then
                  error(
                     'argument and return type mismatch:'
                     ..'\n\tfor generic constraint ['..const[i]..']'
                     ..'\n\texpected ('..table_pcat(pconst, ", ")..') -> ['..table_pcat(const, ", ")..']'
                     ..'\n\tgot      ('..table_pcat(ptypes, ', ')..') -> ['..table_pcat(types, ", ")..']'
                  )
               end

            end
         end

      elseif not const[i]:find('(%f[%w_]'..tostring(types[i])..'%f[^%w_])') then

         error(
            'return type mismatch:'
            ..'\n\texpected ['..table_pcat(const, ", ")..']'
            ..'\n\tgot      ['..table_pcat(types, ', ')..']'
         )

      end
   end
end


local function check_args (types, const)
   local len_const = table_len(const)
   local len_types = table_len(types)
   local len_max = len_const > len_types and len_const or len_types

   for i = 1, len_max do
      if #const[i] == 1 then -- 1 char type length == generic

         for j = i + 1, len_max do
            if const[j] == const[i] and types[i] ~= types[j] then
               error(
                  'argument type mismatch:'
                  ..'\n\tfor generic constraint ['..const[i]..']'
                  ..'\n\texpected ('..table_pcat(const, ", ")..')'
                  ..'\n\tgot      ('..table_pcat(types, ', ')..')'
               )
            end
         end

      elseif not const[i]:find('(%f[%w_]'..tostring(types[i])..'%f[^%w_])') then

         error(
            'argument type mismatch:'
            ..'\n\texpected ('..table_pcat(const, ", ")..')'
            ..'\n\tgot      ('..table_pcat(types, ', ')..')'
         )

      end
   end
end

local function def (...)
   if type(...) ~= 'table' then -- return type
      return setmetatable({...}, {
         __call = function (returns, ...) -- parameter types
            return setmetatable(..., {
               __pow = function(params, func) -- define the final function (ret + para)
                  -- print('defined ret:para')
                  return function (...)
                     local args = {...}
                     local targs = {}
                     for _,val in pairs(args) do
                        targs[_] = type(val)
                     end

                     check_args(targs, params)

                     local value = {func(...)}
                     local tvalue = {}
                     for _,val in ipairs(value) do
                        tvalue[_] = type(val)
                     end

                     check_rets(tvalue, returns, targs, params)

                     return unpack(value)
                  end
               end
            })
         end;

         __pow = function (returns, func) -- define the final function (ret only)
            -- print('defined ret')
            return function(...)
               local value = {func(...)}
               local tvalue = {}
               for _,val in ipairs(value) do
                  tvalue[_] = type(val)
               end

               check_rets(tvalue, returns)

               return unpack(value)
            end
         end
      })

   else -- parameters
      return setmetatable(..., {
         __pow = function(params, func) -- define the final function (para only)
            return function(...)
               local args = {...}
               local targs = {}
               for _,val in pairs(args) do
                  targs[_] = type(val)
               end

               check_args(targs, params)

               return func(...)
            end
         end
      })
   end

end
debug.setmetatable(def, {__pow = function(self, f) return f end})

return def
