function Header(el)
   -- Checks if it is a Level 2 header (# Chapter)
   if el.level == 2 then
      return {
         pandoc.RawBlock('tex', '\\newpage'),
         el
      }
   end
end
