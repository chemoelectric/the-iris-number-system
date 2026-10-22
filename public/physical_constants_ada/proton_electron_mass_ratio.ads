pragma ada_2022;

-- proton_electron_mass_ratio.ads
--
-- computes the dimensionless proton-to-electron mass ratio (m_p / m_e)
-- from the 3-toroid v-configuration deformed under spin stress.
--
-- mathematical form:
--   m_p / m_e = 6.0 * pi^5 * ( 1.0 + (alpha^2) / (2.0 * sqrt(2.0)) )
--             = 1836.15268...
--
-- where the alpha^2 / (2*sqrt(2)) factor is the expansion of the
-- complete elliptic integral k(sqrt(2)*alpha^2) for 3 interlinked toroids.

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
