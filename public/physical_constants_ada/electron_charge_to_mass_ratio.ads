pragma ada_2022;

-- electron_charge_to_mass_ratio.ads
--
-- computes the specific charge of the electron (e / m_e) in C/kg.
--
-- mathematical form:
--   e / m_e = e / [ (2.0 * R_inf * h) / (alpha^2 * c) ]
--           = (e * alpha^2 * c) / (2.0 * R_inf * h)

generic
   type real_type is digits <>;
   with function get_e return real_type;
   with function compute_m_e
     (relative_tolerance : in real_type) return real_type;
package electron_charge_to_mass_ratio is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 1.758e11 and compute'result < 1.759e11;

end electron_charge_to_mass_ratio;
