pragma ada_2022;

package body proton_mass is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      ratio_val : constant real_type := compute_m_p_over_m_e (relative_tolerance * 0.1);
      m_e_val   : constant real_type := compute_m_e (relative_tolerance * 0.1);
      m_p_val   : real_type := 0.0;
   begin
      m_p_val := ratio_val * m_e_val;
      return m_p_val;
   end compute;

end proton_mass;
