pragma ada_2022;

-- circle_constant_pi.ads
--
-- computes the circle ratio pi to a prescribed relative tolerance
-- using the classical brent-salamin (gauss-legendre) agm algorithm.
-- each iteration doubles the number of correct digits.
--
-- generic formal parameter:
--   real_type: floating-point or arbitrary-precision real type.

generic
   type real_type is digits <>;
   with function sqrt (x : in real_type) return real_type is <>;
package circle_constant_pi is

   -- computes pi such that |pi_computed - pi_true| / pi_true <= tol
   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 3.14159265;

end circle_constant_pi;
