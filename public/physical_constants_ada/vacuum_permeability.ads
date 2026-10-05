pragma ada_2022;

-- vacuum_permeability.ads
--
-- magnetic permeability mu_0 in H / m (or N / A^2).
--
-- mathematical form:
--   mu_0 = Z_0 / c = (2.0 * alpha * R_K) / c

generic
   type real_type is digits <>;
   with function compute_z_0
     (relative_tolerance : in real_type) return real_type;
   with function get_c return real_type;
package vacuum_permeability is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 1.256e-6 and compute'result < 1.257e-6;

end vacuum_permeability;
