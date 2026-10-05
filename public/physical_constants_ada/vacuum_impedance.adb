pragma ada_2022;

package body vacuum_impedance is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      alpha_val : constant real_type := compute_alpha (relative_tolerance * 0.1);
      h_val     : constant real_type := get_h;
      e_val     : constant real_type := get_e;
      r_k       : constant real_type := h_val / (e_val * e_val);
      z0_val    : real_type := 0.0;
   begin
      z0_val := 2.0 * alpha_val * r_k;
      return z0_val;
   end compute;

end vacuum_impedance;
