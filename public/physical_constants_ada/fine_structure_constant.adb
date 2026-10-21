pragma ada_2022;

package body fine_structure_constant is

   function compute_inverse
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      pi_val      : constant real_type :=
        compute_pi (relative_tolerance * 0.01);
      pi_sq       : constant real_type := pi_val * pi_val;
      pi_cube     : constant real_type := pi_sq * pi_val;
      alpha_0_inv : constant real_type :=
        4.0 * pi_cube + pi_sq + pi_val;
      reaction    : constant real_type :=
        1.0 / (24.0 * alpha_0_inv);
      res         : real_type := 0.0;
   begin
      res := alpha_0_inv - reaction;
      return res;
   end compute_inverse;

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      inv_val : constant real_type :=
        compute_inverse (relative_tolerance);
      res     : real_type := 0.0;
   begin
      res := 1.0 / inv_val;
      return res;
   end compute;

end fine_structure_constant;
