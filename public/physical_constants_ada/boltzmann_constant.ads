pragma ada_2022;

-- boltzmann_constant.ads
--
-- exact boltzmann constant k_B in J / K.
-- in the modern si system, k_B is an exact fundamental conversion constant:
--   k_B = 1.380649e-23 J/K
--
-- generic formal parameter:
--   real_type: floating-point or arbitrary-precision real type.

generic
   type real_type is digits <>;
package boltzmann_constant is

   function value return real_type
   with
      post => value'result > 0.0 and value'result < 1.0e-22;

end boltzmann_constant;
