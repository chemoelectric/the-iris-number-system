pragma ada_2022;

-- proton_mass.ads
--
-- computes the rest mass of the proton m_p in kilograms from:
--   m_p = (m_p / m_e) * m_e
--
-- where both (m_p / m_e) and m_e are computed to the given relative tolerance.

generic
   type real_type is digits <>;
   with function compute_m_p_over_m_e
     (relative_tolerance : in real_type) return real_type;
   with function compute_m_e
     (relative_tolerance : in real_type) return real_type;
package proton_mass is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 1.672e-27 and compute'result < 1.673e-27;

end proton_mass;
