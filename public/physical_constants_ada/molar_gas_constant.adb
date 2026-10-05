pragma ada_2022;

package body molar_gas_constant is

   function value return real_type is
      n_a     : constant real_type := 6.02214076e23;
      k_b_val : constant real_type := get_k_b;
      r_val   : real_type := 0.0;
   begin
      r_val := n_a * k_b_val;
      return r_val;
   end value;

end molar_gas_constant;
