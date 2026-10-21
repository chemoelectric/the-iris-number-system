pragma ada_2022;

-- fine_structure_constant.ads
--
-- computes the fine-structure constant alpha as the 5d bounded domain
-- invariant in conformal geometric algebra (cga).
--
-- mathematical form:
--   alpha = (9.0 / (8.0 * pi^4)) * (pi^5 / 1920.0)**(1/4)
--   alpha ~ 0.007297348130...
--   alpha^(-1) ~ 137.03608245...

generic
   type real_type is digits <>;
   with function compute_pi
     (relative_tolerance : in real_type) return real_type;
package fine_structure_constant is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 0.00729 and compute'result < 0.00730;

   -- convenience function returning inverse fine-structure constant
   function compute_inverse
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute_inverse'result > 137.0 and
              compute_inverse'result < 137.1;

end fine_structure_constant;
