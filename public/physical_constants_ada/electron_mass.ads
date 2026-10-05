pragma ada_2022;

-- electron_mass.ads
--
-- computes the rest mass of the electron m_e in kilograms from the
-- exact definition of the rydberg constant and the fine-structure constant.
--
-- in metrology:
--   m_e = (2.0 * R_inf * h) / (alpha^2 * c)
--
-- where:
--   R_inf = 10973731.568160 m^(-1) (rydberg constant)
--   h     = 6.62607015e-34 J*s     (exact planck constant)
--   c     = 299792458.0 m/s        (exact speed of electromagnetic waves)
--   alpha = fine_structure_constant

generic
   type real_type is digits <>;
   with function compute_alpha
     (relative_tolerance : in real_type) return real_type;
   with function get_h return real_type;
   with function get_c return real_type;
package electron_mass is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 9.109e-31 and compute'result < 9.110e-31;

end electron_mass;
