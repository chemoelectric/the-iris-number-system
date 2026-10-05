pragma ada_2022;

package body gravitational_constant is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      c_val        : constant real_type := get_c;
      hbar_val     : constant real_type := compute_hbar (relative_tolerance * 0.1);
      -- planck mass unit from CODATA / metrology standard
      m_planck     : constant real_type := 2.176_434e-8;
      m_planck_sq  : constant real_type := m_planck * m_planck;
      g_val        : real_type := 0.0;
   begin
      -- G = (hbar * c) / (m_planck^2)
      g_val := (hbar_val * c_val) / m_planck_sq;
      return g_val;
   end compute;

end gravitational_constant;
