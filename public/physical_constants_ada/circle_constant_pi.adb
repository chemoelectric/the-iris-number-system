pragma ada_2022;

package body circle_constant_pi is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      a       : real_type := 1.0;
      b       : real_type := sqrt (0.5);
      t       : real_type := 0.25;
      p       : real_type := 1.0;
      a_next  : real_type := 0.0;
      diff    : real_type := 1.0;
      pi_val  : real_type := 0.0;
   begin
      while diff > relative_tolerance loop
         a_next := 0.5 * (a + b);
         b := sqrt (a * b);
         t := t - p * (a - a_next) * (a - a_next);
         p := 2.0 * p;
         diff := a - a_next;
         if diff < 0.0 then
            diff := -diff;
         end if;
         a := a_next;
      end loop;

      pi_val := ((a + b) * (a + b)) / (4.0 * t);
      return pi_val;
   end compute;

end circle_constant_pi;
