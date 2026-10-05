pragma ada_2022;

-- speed_of_light.ads
--
-- exact kinematic speed of electromagnetic influences in vacuo.
-- in the si system, this value is an exact integer constant.
--
-- generic formal parameter:
--   real_type: any floating-point or arbitrary-precision real type
--              (such as standard.long_float or ada.numerics.big_numbers.big_reals.big_real)

generic
   type real_type is digits <>;
package speed_of_light is

   -- returns the exact value of c: 299_792_458.0 m/s
   function value return real_type
   with
      post => value'result > 0.0;

end speed_of_light;
