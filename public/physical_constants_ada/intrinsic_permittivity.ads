pragma ada_2022;

-- intrinsic_permittivity.ads
--
-- electric permittivity epsilon_0 in F / m of the
-- universal microwave-rich electromagnetic field.
--
-- mathematical form:
--   epsilon_0 = 1.0 / (mu_0 * c^2) = 1.0 / (Z_0 * c)

generic
   type real_type is digits <>;
   with function compute_z_0
     (relative_tolerance : in real_type) return real_type;
   with function get_c return real_type;
package intrinsic_permittivity is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 8.854e-12 and compute'result < 8.855e-12;

end intrinsic_permittivity;
