pragma ada_2022;

package body gravitational_constant is

   function compute
     (relative_tolerance : in real_type := empirical_precision_limit)
      return real_type
   is
      c_val       : constant real_type := get_c;
      -- hbar evaluated to at least the required tolerance
      hbar_val    : constant real_type := compute_hbar (empirical_precision_limit * 0.1);
      -- best empirical caliper measurement of m_planck (codata)
      m_planck    : constant real_type := 2.176_434e-8;
      m_planck_sq : constant real_type := m_planck * m_planck;
      g_nominal   : real_type := 0.0;
   begin
      -- G = (hbar * c) / (m_planck^2)
      g_nominal := (hbar_val * c_val) / m_planck_sq;
      return g_nominal;
   end compute;

   function compute_with_uncertainty
     (m_planck_caliper : in real_type := 2.176_434e-8;
      m_planck_rel_err : in real_type := 1.1e-5)
      return calibrated_result
   is
      c_val        : constant real_type := get_c;
      hbar_val     : constant real_type := compute_hbar (1.0e-12);
      m_sq         : constant real_type := m_planck_caliper * m_planck_caliper;
      g_val        : constant real_type := (hbar_val * c_val) / m_sq;
      -- delta_G / G = 2 * delta_m_planck / m_planck
      g_rel_err    : constant real_type := 2.0 * m_planck_rel_err;
      g_abs_err    : constant real_type := g_val * g_rel_err;
      res          : calibrated_result;
   begin
      res.nominal_value        := g_val;
      res.absolute_uncertainty := g_abs_err;
      res.relative_uncertainty := g_rel_err;
      res.caliper_bounded      := true;
      return res;
   end compute_with_uncertainty;

end gravitational_constant;
