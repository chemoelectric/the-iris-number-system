pragma ada_2022;

package body boltzmann_constant is

   function value return real_type is
      k_b_exact : constant real_type := 1.380649e-23;
   begin
      return k_b_exact;
   end value;

end boltzmann_constant;
