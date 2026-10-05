pragma ada_2022;

-- fine_structure_constant.ads
--
-- computes the fine-structure constant alpha from the aspect-ratio
-- complete elliptic integral of the toroidal wave vortex in cl(4,1,1).
--
-- mathematical form:
--   k0_sq = 1.0 - 1.0 / (4.0 * pi * pi)
--   alpha = (1.0 / 4.0) * sum_{n=0..inf} [ (2n)! / (2^(2n) * (n!)^2) ]^2 * (k0_sq)^n
--
-- evaluation stops when the next term in the hypergeometric series
-- is less than relative_tolerance * current_sum.

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

   -- convenience function returning inverse fine-structure constant ~ 137.036
   function compute_inverse
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute_inverse'result > 137.0 and compute_inverse'result < 137.1;

end fine_structure_constant;
