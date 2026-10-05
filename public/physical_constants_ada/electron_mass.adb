pragma ada_2022;

package body electron_mass is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      r_inf     : constant real_type := 10_973_731.568_160;
      h_val     : constant real_type := get_h;
      c_val     : constant real_type := get_c;
      alpha_val : constant real_type := compute_alpha (relative_tolerance * 0.1);
      alpha_sq  : constant real_type := alpha_val * alpha_val;
      m_e_val   : real_type := 0.0;
   begin
      m_e_val := (2.0 * r_inf * h_val) / (alpha_sq * c_val);
      return m_e_val;
   end compute;

end electron_mass;
