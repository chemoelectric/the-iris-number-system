pragma ada_2022;

-- planck_constant.ads
--
-- exact planck constant (action per cycle of a localized wave circulation).
-- in the modern si system, h is defined as an exact fundamental constant:
--   h = 6.62607015e-34 J*s (or J/Hz)
-- and the reduced circulation action per radian is:
--   hbar = h / (2 * pi)
--
-- generic formal parameter:
--   real_type: floating-point or arbitrary-precision real type.

generic
   type real_type is digits <>;
   with function compute_pi
     (relative_tolerance : in real_type) return real_type;
package planck_constant is

   -- returns exact h = 6.62607015e-34 J*s
   function value return real_type
   with
      post => value'result > 0.0 and value'result < 1.0e-33;

   -- returns circulation action per radian: hbar = h / (2 * pi)
   function hbar
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => hbar'result > 0.0 and hbar'result < value;

end planck_constant;
