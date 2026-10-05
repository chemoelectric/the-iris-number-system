pragma ada_2022;

-- vacuum_impedance.ads
--
-- characteristic impedance of electromagnetic wave propagation Z_0 in ohms.
--
-- in closed form:
--   Z_0 = 2.0 * alpha * R_K
-- where R_K is the von klitzing constant (exact quantum Hall impedance):
--   R_K = h / (e^2) = 25812.807459... ohms

generic
   type real_type is digits <>;
   with function compute_alpha
     (relative_tolerance : in real_type) return real_type;
   with function get_h return real_type;
   with function get_e return real_type;
package vacuum_impedance is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 376.7 and compute'result < 376.8;

end vacuum_impedance;
