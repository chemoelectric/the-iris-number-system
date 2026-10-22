pragma ada_2022;

-- interplanetary_units.ads
--
-- specification for the interplanetary system of units (ip).
-- provides both ip-natural (atomic wave-knot geometry) and ip-practical
-- (canonical integer macroscopic calipers) conversions.
--
-- generic formal parameter:
--   real_type: floating-point or arbitrary-precision real type.

generic
   type real_type is digits <>;
   with function get_c return real_type;
   with function get_r_inf return real_type;
   with function get_h return real_type;
   with function compute_alpha
     (relative_tolerance : in real_type) return real_type;
package interplanetary_units is

   -- ip-practical exact canonical integers
   c_second_cycles : constant := 6_579_683_920_501_762;
   c_speed_si      : constant := 299_792_458;

   -- 5a. ip-natural base time: hydrogen chronon tau_h = 1 / (2 * c * r_inf)
   function natural_time_tau_h return real_type
   with
      post => natural_time_tau_h'result > 1.519e-16 and
              natural_time_tau_h'result < 1.520e-16;

   -- 5b. ip-natural base length: hydrogen metron lambda_h = 1 / (2 * r_inf)
   function natural_length_lambda_h return real_type
   with
      post => natural_length_lambda_h'result > 4.556e-8 and
              natural_length_lambda_h'result < 4.557e-8;

   -- 5c. ip-natural base mass: electron knot mass mu_e = m_e
   function natural_mass_mu_e
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => natural_mass_mu_e'result > 9.109e-31 and
              natural_mass_mu_e'result < 9.110e-31;

   -- 5d. ip-practical second duration in si seconds
   function practical_second_in_si return real_type
   with
      post => practical_second_in_si'result > 0.9999999 and
              practical_second_in_si'result < 1.0000001;

   -- 5e. ip-practical meter in si meters
   function practical_meter_in_si return real_type
   with
      post => practical_meter_in_si'result > 0.9999999 and
              practical_meter_in_si'result < 1.0000001;

   -- 5f. ip-practical kilogram in si kilograms
   function practical_kilogram_in_si
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => practical_kilogram_in_si'result > 0.9999999 and
              practical_kilogram_in_si'result < 1.0000001;

end interplanetary_units;
