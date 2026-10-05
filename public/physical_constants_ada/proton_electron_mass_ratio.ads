pragma ada_2022;

-- proton_electron_mass_ratio.ads
--
-- computes the dimensionless proton-to-electron mass ratio (m_p / m_e)
-- from the 5-dimensional conformal sphere volume and the discrete
-- lattice reaction boundary correction.
--
-- mathematical form:
--   m_p / m_e = 6.0 * pi^5 * ( 1.0 - alpha / 24.0 + (alpha^2) / pi )
--
-- where the alpha / 24 factor comes from the double integral
--   (alpha / (4*pi^2)) * \int_0^1 \int_0^1 (1 / (1 - x*y)) dx dy = alpha / 24.

generic
   type real_type is digits <>;
   with function compute_pi
     (relative_tolerance : in real_type) return real_type;
   with function compute_alpha
     (relative_tolerance : in real_type) return real_type;
package proton_electron_mass_ratio is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 1836.1 and compute'result < 1836.2;

end proton_electron_mass_ratio;
