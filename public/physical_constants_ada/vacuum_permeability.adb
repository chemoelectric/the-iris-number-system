pragma ada_2022;

package body vacuum_permeability is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      z_0_val : constant real_type := compute_z_0 (relative_tolerance);
      c_val   : constant real_type := get_c;
      mu_val  : real_type := 0.0;
   begin
      mu_val := z_0_val / c_val;
      return mu_val;
   end compute;

end vacuum_permeability;
