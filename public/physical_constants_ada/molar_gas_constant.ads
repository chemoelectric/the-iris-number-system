pragma ada_2022;

-- molar_gas_constant.ads
--
-- exact molar gas constant R in J / (mol * K).
-- in the modern si system, R = N_A * k_B, where:
--   N_A = 6.02214076e23 mol^(-1) (exact avogadro constant)
--   k_B = 1.380649e-23 J/K       (exact boltzmann constant)
--
-- exact product:
--   R = 8.31446261815324 J / (mol * K)

generic
   type real_type is digits <>;
   with function get_k_b return real_type;
package molar_gas_constant is

   function value return real_type
   with
      post => value'result > 8.314 and value'result < 8.315;

end molar_gas_constant;
