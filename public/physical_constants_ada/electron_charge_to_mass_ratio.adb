pragma ada_2022;

package body electron_charge_to_mass_ratio is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      e_val   : constant real_type := get_e;
      m_e_val : constant real_type := compute_m_e (relative_tolerance);
      ratio   : real_type := 0.0;
   begin
      ratio := e_val / m_e_val;
      return ratio;
   end compute;

end electron_charge_to_mass_ratio;
