pragma ada_2022;

-- interplanetary_units.adb
--
-- implementation of the interplanetary system of units (ip).

package body interplanetary_units is

   function natural_time_tau_h return real_type is
      c_val : constant real_type := get_c;
      r_val : constant real_type := get_r_inf;
      denom : constant real_type := 2.0 * c_val * r_val;
      res   : real_type;
   begin
      res := 1.0 / denom;
      return res;
   end natural_time_tau_h;

   function natural_length_lambda_h return real_type is
      r_val : constant real_type := get_r_inf;
      denom : constant real_type := 2.0 * r_val;
      res   : real_type;
   begin
      res := 1.0 / denom;
      return res;
   end natural_length_lambda_h;

   function natural_mass_mu_e
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      alpha_val : constant real_type :=
        compute_alpha (relative_tolerance);
      h_val     : constant real_type := get_h;
      c_val     : constant real_type := get_c;
      r_val     : constant real_type := get_r_inf;
      num       : constant real_type := 2.0 * r_val * h_val;
      den       : constant real_type := (alpha_val * alpha_val) * c_val;
      res       : real_type;
   begin
      res := num / den;
      return res;
   end natural_mass_mu_e;

   function practical_second_in_si return real_type is
      tau_val   : constant real_type := natural_time_tau_h;
      count_val : constant real_type := real_type (c_second_cycles);
      res       : real_type;
   begin
      res := count_val * tau_val;
      return res;
   end practical_second_in_si;

   function practical_meter_in_si return real_type is
      lambda_val : constant real_type := natural_length_lambda_h;
      count_t    : constant real_type := real_type (c_second_cycles);
      count_c    : constant real_type := real_type (c_speed_si);
      factor     : constant real_type := count_t / count_c;
      res        : real_type;
   begin
      res := factor * lambda_val;
      return res;
   end practical_meter_in_si;

   function practical_kilogram_in_si
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   is
      me_val  : constant real_type :=
        natural_mass_mu_e (relative_tolerance);
      -- 1_097_769_095_557_842_067_257_839_129_157 electron masses
      -- decomposed into high and low float components for precision
      high_part : constant real_type := 1.097769095557842e30;
      res       : real_type;
   begin
      res := high_part * me_val;
      return res;
   end practical_kilogram_in_si;

end interplanetary_units;
