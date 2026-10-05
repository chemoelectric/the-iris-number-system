pragma ada_2022;

-- elementary_charge.ads
--
-- exact elementary charge of the electron in coulombs.
-- in the modern si system (2019 redefinition), the elementary charge e
-- is an exact fundamental constant:
--   e = 1.602176634e-19 C
--
-- generic formal parameter:
--   real_type: floating-point or arbitrary-precision real type.

generic
   type real_type is digits <>;
package elementary_charge is

   function value return real_type
   with
      post => value'result > 0.0 and value'result < 1.0e-18;

end elementary_charge;
