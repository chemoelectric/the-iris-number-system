pragma ada_2022;

with interfaces;
with ada.text_io;

procedure discrete_ifs_generator is

   use interfaces;

   type real is digits 15;

   type affine_map is record
      a, b, c, d, e, f : real;
      prob_accum       : real;
   end record;

   type ifs_table is array (1 .. 4) of affine_map;

   -- barnsley fern affine map table in cl(2,0)
   fern : constant ifs_table :=
     (1 => (0.00, 0.00, 0.00, 0.16, 0.0, 0.00, 0.01),
      2 => (0.85, 0.04, -0.04, 0.85, 0.0, 1.60, 0.86),
      3 => (0.20, -0.26, 0.23, 0.22, 0.0, 1.60, 0.93),
      4 => (-0.15, 0.28, 0.26, 0.24, 0.0, 0.44, 1.00));

   -- lcg pseudorandom generator for deterministic grid chaos game
   seed : unsigned_64 := 42;
   function next_rand return real is
   begin
      seed := (seed * 1103515245 + 12345) mod 2147483648;
      return real (seed) / 2147483648.0;
   end next_rand;

   grid_w : constant natural := 60;
   grid_h : constant natural := 30;

   type char_grid is array (0 .. grid_h - 1, 0 .. grid_w - 1) of character;

   display : char_grid := [others => [others => ' ']];
   x       : real := 0.0;
   y       : real := 0.0;
   nxt_x   : real;
   nxt_y   : real;
   r       : real;
   map_idx : natural;
   step    : natural := 0;
   px      : integer;
   py      : integer;
   r_idx   : natural;
   c_idx   : natural;

begin
   ada.text_io.put_line ("================================================");
   ada.text_io.put_line ("   discrete ifs barnsley fern generator (ada)   ");
   ada.text_io.put_line ("================================================");
   while step < 50000 loop
      r := next_rand;
      if r < fern (1).prob_accum then
         map_idx := 1;
      elsif r < fern (2).prob_accum then
         map_idx := 2;
      elsif r < fern (3).prob_accum then
         map_idx := 3;
      else
         map_idx := 4;
      end if;
      nxt_x := fern (map_idx).a * x + fern (map_idx).b * y + fern (map_idx).e;
      nxt_y := fern (map_idx).c * x + fern (map_idx).d * y + fern (map_idx).f;
      x := nxt_x;
      y := nxt_y;
      if step > 20 then
         px := integer (real'floor ((x + 2.5) / 5.5 * real (grid_w - 1)));
         py := integer (real'floor ((10.0 - y) / 10.0 * real (grid_h - 1)));
         if px in 0 .. grid_w - 1 and py in 0 .. grid_h - 1 then
            display (py, px) := '#';
         end if;
      end if;
      step := step + 1;
   end loop;
   r_idx := 0;
   while r_idx < grid_h loop
      c_idx := 0;
      while c_idx < grid_w loop
         ada.text_io.put (display (r_idx, c_idx));
         c_idx := c_idx + 1;
      end loop;
      ada.text_io.new_line;
      r_idx := r_idx + 1;
   end loop;
end discrete_ifs_generator;
