pragma ada_2022;

-- gravitational_constant.ads
--
-- computes newton's gravitational constant G in m^3 / (kg * s^2)
-- derived by classical wave refraction in the universal electromagnetic field.
--
-- mathematical form:
--   G = (c^4 * delta_omega^2) / (4 * pi * E) = (c^2 * delta_omega^2) / (4 * pi * m)
--
-- where:
--   c           = exact speed of electromagnetic waves (299792458.0 m/s)
--   delta_omega = planck length grid aperture = 1.616255e-35 m
--   m           = planck mass unit = 2.176434e-8 kg
--   E           = m * c^2
--
-- or directly from the planck units relation:
--   G = (hbar * c) / (m_planck^2)
--   G = (c^3 * l_planck^2) / hbar

generic
   type real_type is digits <>;
   with function get_c return real_type;
   with function compute_hbar
     (relative_tolerance : in real_type) return real_type;
package gravitational_constant is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 6.674e-11 and compute'result < 6.675e-11;

end gravitational_constant;
