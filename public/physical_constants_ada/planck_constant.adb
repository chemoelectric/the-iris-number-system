pragma ada_2022;

package body planck_constant is

   function value return real_type is
      h_exact : constant real_type := 6.62607015e-34;
   begin
      return h_exact;
   end value;

   function hbar
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      pi_val   : constant real_type := compute_pi (relative_tolerance * 0.1);
      hbar_val : real_type := 0.0;
   begin
      hbar_val := value / (2.0 * pi_val);
      return hbar_val;
   end hbar;

end planck_constant;
