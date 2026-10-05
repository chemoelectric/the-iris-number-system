pragma ada_2022;

-- intrinsic_impedance.ads
--
-- characteristic intrinsic wave impedance Z_0 in ohms of the
-- universal microwave-rich electromagnetic field.
--
-- the universe is not an empty vacuum; it is filled with a dynamic,
-- microwave-rich electromagnetic field with finite wave impedance.
--
-- in closed form:
--   Z_0 = 2.0 * alpha * R_K
-- where R_K is the von klitzing constant (fundamental circulation impedance):
--   R_K = h / (e^2) = 25812.807459... ohms

generic
   type real_type is digits <>;
   with function compute_alpha
     (relative_tolerance : in real_type) return real_type;
   with function get_h return real_type;
   with function get_e return real_type;
package intrinsic_impedance is

   function compute
     (relative_tolerance : in real_type := 1.0e-15)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 376.7 and compute'result < 376.8;

end intrinsic_impedance;
