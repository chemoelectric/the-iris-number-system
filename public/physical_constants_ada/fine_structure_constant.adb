pragma ada_2022;

package body fine_structure_constant is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      pi_val    : constant real_type := compute_pi (relative_tolerance * 0.1);
      k0_sq     : constant real_type := 1.0 - 1.0 / (4.0 * pi_val * pi_val);
      term      : real_type := 0.25;
      sum       : real_type := 0.25;
      n         : real_type := 0.0;
      ratio     : real_type := 0.0;
      diff      : real_type := 1.0;
   begin
      while diff > relative_tolerance loop
         -- term_{n+1} / term_n = [ (2n+1) / (2n+2) ]^2 * k0_sq
         ratio := ((2.0 * n + 1.0) / (2.0 * n + 2.0)) *
                  ((2.0 * n + 1.0) / (2.0 * n + 2.0)) * k0_sq;
         term  := term * ratio;
         sum   := sum + term;
         n     := n + 1.0;
         diff  := term / sum;
         if diff < 0.0 then
            diff := -diff;
         end if;
      end loop;

      return sum;
   end compute;

   function compute_inverse
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      alpha_val : constant real_type := compute (relative_tolerance);
   begin
      return 1.0 / alpha_val;
   end compute_inverse;

end fine_structure_constant;
