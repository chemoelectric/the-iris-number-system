pragma ada_2022;

-- gravitational_constant.ads
--
-- newton's gravitational coupling constant G in m^3 / (kg * s^2)
-- derived by classical wave refraction in the universal electromagnetic field.
--
-- physical & metrological reality:
--   in the unified field theory, gravitation is classical wave refraction
--   with field susceptibility:
--     kappa = (8.0 * pi * G) / (c^4)
--   and dimensionless proton coupling:
--     alpha_G = (G * m_p^2) / (hbar * c)
--
--   unlike the fine-structure constant alpha or proton-to-electron mass
--   ratio m_p / m_e, which are exact geometric invariants of the field,
--   G is expressed in conventional SI units (m^3 / (kg * s^2)) that
--   are calibrated to macroscopic terrestrial artifacts.
--
--   consequently, the numerical evaluation of G in SI units is strictly
--   bounded by empirical caliper measurements of gravitational
--   acceleration and macroscopic mass (relative uncertainty ~ 2.2e-5).
--
--   calling compute with a relative_tolerance tighter than the
--   empirical caliper bound (empirical_precision_limit) clamps to the
--   empirical caliper boundary, warning the caller that conventional
--   metrology cannot ground additional digits.

generic
   type real_type is digits <>;
   with function get_c return real_type;
   with function compute_hbar
     (relative_tolerance : in real_type) return real_type;
package gravitational_constant is

   -- standard codata 2018/2022 relative uncertainty of m_planck and G (~2.2e-5)
   empirical_relative_uncertainty : constant real_type := 2.2e-5;

   -- empirical precision bound: beyond this, NIST/CODATA SI calibration fails
   empirical_precision_limit : constant real_type := 1.0e-5;

   type calibrated_result is record
      nominal_value        : real_type;
      absolute_uncertainty : real_type;
      relative_uncertainty : real_type;
      caliper_bounded      : boolean;
   end record;

   -- computes nominal G using the best available empirical caliper of m_planck.
   -- if requested tolerance is tighter than empirical_precision_limit,
   -- the result is explicitly clamped to the empirical caliper boundary.
   function compute
     (relative_tolerance : in real_type := empirical_precision_limit)
      return real_type
   with
      pre  => relative_tolerance > 0.0,
      post => compute'result > 6.674e-11 and compute'result < 6.675e-11;

   -- full metrological report including uncertainty propagation
   function compute_with_uncertainty
     (m_planck_caliper : in real_type := 2.176_434e-8;
      m_planck_rel_err : in real_type := 1.1e-5)
      return calibrated_result
   with
      pre => m_planck_caliper > 0.0 and m_planck_rel_err >= 0.0;

end gravitational_constant;
