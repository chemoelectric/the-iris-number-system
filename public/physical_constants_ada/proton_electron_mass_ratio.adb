pragma ada_2022;

package body proton_electron_mass_ratio is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      pi_val    : constant real_type := compute_pi (relative_tolerance * 0.1);
      alpha_val : constant real_type := compute_alpha (relative_tolerance * 0.1);
      pi_sq     : constant real_type := pi_val * pi_val;
      pi_5      : constant real_type := pi_sq * pi_sq * pi_val;
      recoil    : constant real_type := 1.0 - (alpha_val / 24.0) +
                                        ((alpha_val * alpha_val) / pi_val);
      ratio_val : real_type := 0.0;
   begin
      ratio_val := 6.0 * pi_5 * recoil;
      return ratio_val;
   end compute;

end proton_electron_mass_ratio;
