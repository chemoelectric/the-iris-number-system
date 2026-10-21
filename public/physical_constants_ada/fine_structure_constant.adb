pragma ada_2022;

package body fine_structure_constant is

   function sqrt_step
     (val : in real_type;
      tol : in real_type) return real_type
   is
      guess : real_type := (val + 1.0) * 0.5;
      diff  : real_type := 1.0;
      res   : real_type := 0.0;
   begin
      if val <= 0.0 then
         res := 0.0;
      else
         while diff > tol loop
            declare
               next_g : constant real_type := 0.5 * (guess + val / guess);
            begin
               diff := next_g - guess;
               if diff < 0.0 then
                  diff := -diff;
               end if;
               guess := next_g;
            end;
         end loop;
         res := guess;
      end if;
      return res;
   end sqrt_step;

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      pi_val    : constant real_type := compute_pi (relative_tolerance * 0.1);
      pi_sq     : constant real_type := pi_val * pi_val;
      pi_4      : constant real_type := pi_sq * pi_sq;
      pi_5      : constant real_type := pi_4 * pi_val;
      vol_d5    : constant real_type := pi_5 / 1920.0;
      sqrt_vol  : constant real_type :=
        sqrt_step (vol_d5, relative_tolerance * 0.01);
      root_vol  : constant real_type :=
        sqrt_step (sqrt_vol, relative_tolerance * 0.01);
      prefactor : constant real_type := 9.0 / (8.0 * pi_4);
      alpha_val : constant real_type := prefactor * root_vol;
   begin
      return alpha_val;
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
