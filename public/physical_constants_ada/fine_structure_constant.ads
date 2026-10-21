pragma ada_2022;

-- fine_structure_constant.ads
--
-- computes the fine-structure constant alpha from first principles
-- of conformal geometric algebra (cga) and discrete lattice reaction.
--
-- mathematical form:
--   alpha_0_inv = 4.0 * pi^3 + pi^2 + pi
--   alpha_inv   = alpha_0_inv - 1.0 / (24.0 * alpha_0_inv)
--   alpha       = 1.0 / alpha_inv
--   alpha     ~ 0.007297352535...
--   alpha_inv ~ 137.03599973...

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
