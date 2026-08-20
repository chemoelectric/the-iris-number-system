pragma ada_2022;

with ada.text_io;
with ada.numerics.generic_elementary_functions;

procedure discrete_fractal_engine is
   type real is digits 15;

   package math is new ada.numerics.generic_elementary_functions (real);

   -- multivector in cl(2,0): z = x + y * e_12
   type cl20_even is record
      s : real; -- scalar component (x)
      b : real; -- bivector component (y * e_12)
   end record;

   -- cl(2,0) multivector squaring: (x + y e_12)^2 = (x^2 - y^2) + (2xy) e_12
   function square (in_z : in cl20_even) return cl20_even
   with inline, post => square'result.s = in_z.s * in_z.s - in_z.b * in_z.b
   is
      res : cl20_even;
   begin
      res.s := in_z.s * in_z.s - in_z.b * in_z.b;
      res.b := 2.0 * in_z.s * in_z.b;
      return res;
   end square;

   -- multivector addition
   function add (in_a : in cl20_even; in_b : in cl20_even) return cl20_even
   with inline
   is
      res : cl20_even;
   begin
      res.s := in_a.s + in_b.s;
      res.b := in_a.b + in_b.b;
      return res;
   end add;

   -- squared clifford norm ||z||^2 = x^2 + y^2
   function norm_sq (in_z : in cl20_even) return real with inline is
   begin
      return in_z.s * in_z.s + in_z.b * in_z.b;
   end norm_sq;

   -- check main cardioid and period-2 bulb early containment
   function in_main_cardioid (in_c : in cl20_even) return boolean is
      x_off   : constant real := in_c.s - 0.25;
      q       : constant real := x_off * x_off + in_c.b * in_c.b;
      in_card : boolean;
      in_bulb : boolean;
   begin
      in_card := (q * (q + x_off) <= 0.25 * in_c.b * in_c.b);
      in_bulb := ((in_c.s + 1.0) * (in_c.s + 1.0) + in_c.b * in_c.b <= 0.0625);
      return in_card or in_bulb;
   end in_main_cardioid;

   -- escape-time kernel with maximum iteration bound
   function iterate_cell
     (in_c : in cl20_even; max_iter : in natural) return natural
   is
      z     : cl20_even;
      count : natural;
   begin
      if in_main_cardioid (in_c) then
         return max_iter;
      end if;
      z.s := 0.0;
      z.b := 0.0;
      count := 0;
      while count < max_iter loop
         if norm_sq (z) > 4.0 then
            return count;
         end if;
         z := add (square (z), in_c);
         count := count + 1;
      end loop;
      return max_iter;
   end iterate_cell;

   width  : constant natural := 64;
   height : constant natural := 32;
   max_k  : constant natural := 200;
   row    : natural;
   col    : natural;
   c_pt   : cl20_even;
   k_res  : natural;
   x_min  : constant real := -2.1;
   x_max  : constant real := 0.7;
   y_min  : constant real := -1.2;
   y_max  : constant real := 1.2;
   dx     : constant real := (x_max - x_min) / real (width - 1);
   dy     : constant real := (y_max - y_min) / real (height - 1);

begin
   ada.text_io.put_line ("================================================");
   ada.text_io.put_line (" discrete cl(2,0) mandelbrot vernier rasterizer ");
   ada.text_io.put_line ("================================================");
   row := 0;
   while row < height loop
      c_pt.b := y_max - real (row) * dy;
      col := 0;
      while col < width loop
         c_pt.s := x_min + real (col) * dx;
         k_res := iterate_cell (c_pt, max_k);
         if k_res = max_k then
            ada.text_io.put ("#");
         elsif k_res > 15 then
            ada.text_io.put ("*");
         elsif k_res > 5 then
            ada.text_io.put (".");
         else
            ada.text_io.put (" ");
         end if;
         col := col + 1;
      end loop;
      ada.text_io.new_line;
      row := row + 1;
   end loop;
end discrete_fractal_engine;
