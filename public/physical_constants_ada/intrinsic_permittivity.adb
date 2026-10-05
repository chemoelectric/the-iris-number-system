pragma ada_2022;

package body intrinsic_permittivity is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      z_0_val : constant real_type := compute_z_0 (relative_tolerance);
      c_val   : constant real_type := get_c;
      eps_val : real_type := 0.0;
   begin
      eps_val := 1.0 / (z_0_val * c_val);
      return eps_val;
   end compute;

end intrinsic_permittivity;
