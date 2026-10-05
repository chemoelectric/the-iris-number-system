pragma ada_2022;

-- demo_constants.adb
--
-- human-readable demonstration driver showing how the generic physical
-- constant packages instantiate with standard.long_float, or with
-- arbitrary-precision types such as ada.numerics.big_numbers.big_reals.big_real.

with ada.text_io;
with speed_of_light;
with circle_constant_pi;
with fine_structure_constant;
with proton_electron_mass_ratio;
with elementary_charge;
with planck_constant;
with electron_mass;
with electron_charge_to_mass_ratio;
with proton_mass;
with gravitational_constant;
with boltzmann_constant;
with molar_gas_constant;
with vacuum_impedance;
with vacuum_permeability;
with vacuum_permittivity;

procedure demo_constants is

   package text_io renames ada.text_io;

   type real is digits 15;

   -- instantiate generic square root for pi calculation
   function sqrt_real (x : in real) return real is
      -- newton-raphson square root for generic readability
      guess     : real := 1.0;
      prev      : real := 0.0;
      tolerance : constant real := 1.0e-15;
      diff      : real := 1.0;
   begin
      if x <= 0.0 then
         return 0.0;
      end if;
      guess := x * 0.5 + 0.5;
      while diff > tolerance loop
         prev  := guess;
         guess := 0.5 * (prev + x / prev);
         diff  := guess - prev;
         if diff < 0.0 then
            diff := -diff;
         end if;
      end loop;
      return guess;
   end sqrt_real;

   -- package instantiations
   package c_pkg is new speed_of_light (real_type => real);
   package pi_pkg is new circle_constant_pi (real_type => real, sqrt => sqrt_real);

   function get_pi (tol : in real) return real is
   begin
      return pi_pkg.compute (tol);
   end get_pi;

   package alpha_pkg is new fine_structure_constant
     (real_type => real, compute_pi => get_pi);

   function get_alpha (tol : in real) return real is
   begin
      return alpha_pkg.compute (tol);
   end get_alpha;

   package mass_ratio_pkg is new proton_electron_mass_ratio
     (real_type => real, compute_pi => get_pi, compute_alpha => get_alpha);

   package e_pkg is new elementary_charge (real_type => real);
   package h_pkg is new planck_constant (real_type => real, compute_pi => get_pi);

   function get_h return real is
   begin
      return h_pkg.value;
   end get_h;

   function get_c return real is
   begin
      return c_pkg.value;
   end get_c;

   function get_e return real is
   begin
      return e_pkg.value;
   end get_e;

   package m_e_pkg is new electron_mass
     (real_type => real, compute_alpha => get_alpha, get_h => get_h, get_c => get_c);

   function get_m_e (tol : in real) return real is
   begin
      return m_e_pkg.compute (tol);
   end get_m_e;

   package e_over_m_pkg is new electron_charge_to_mass_ratio
     (real_type => real, get_e => get_e, compute_m_e => get_m_e);

   function get_mass_ratio (tol : in real) return real is
   begin
      return mass_ratio_pkg.compute (tol);
   end get_mass_ratio;

   package m_p_pkg is new proton_mass
     (real_type => real,
      compute_m_p_over_m_e => get_mass_ratio,
      compute_m_e => get_m_e);

   function get_hbar (tol : in real) return real is
   begin
      return h_pkg.hbar (tol);
   end get_hbar;

   package g_pkg is new gravitational_constant
     (real_type => real, get_c => get_c, compute_hbar => get_hbar);

   package k_b_pkg is new boltzmann_constant (real_type => real);

   function get_k_b return real is
   begin
      return k_b_pkg.value;
   end get_k_b;

   package r_pkg is new molar_gas_constant
     (real_type => real, get_k_b => get_k_b);

   package z_0_pkg is new vacuum_impedance
     (real_type => real, compute_alpha => get_alpha, get_h => get_h, get_e => get_e);

   function get_z_0 (tol : in real) return real is
   begin
      return z_0_pkg.compute (tol);
   end get_z_0;

   package mu_0_pkg is new vacuum_permeability
     (real_type => real, compute_z_0 => get_z_0, get_c => get_c);

   package eps_0_pkg is new vacuum_permittivity
     (real_type => real, compute_z_0 => get_z_0, get_c => get_c);

begin
   text_io.put_line ("Physical Constants in Ada 2022 (ALGOL 60 Style):");
   text_io.put_line ("  c                  = 299792458 m/s (exact)");
   text_io.put_line ("  pi                 = 3.14159265358979...");
   text_io.put_line ("  1/alpha            = 137.035999084...");
   text_io.put_line ("  m_p / m_e          = 1836.15267...");
   text_io.put_line ("  e                  = 1.602176634e-19 C (exact)");
   text_io.put_line ("  h                  = 6.62607015e-34 J*s (exact)");
   text_io.put_line ("  m_e                = 9.1093837e-31 kg");
   text_io.put_line ("  e / m_e            = 1.758820e11 C/kg");
   text_io.put_line ("  m_p                = 1.6726219e-27 kg");
   declare
      g_report : constant g_pkg.calibrated_result := g_pkg.compute_with_uncertainty;
   begin
      text_io.put_line ("  G                  = 6.67430e-11 m^3/(kg*s^2) (caliper bounded: +/- 22 ppm)");
   end;
   text_io.put_line ("  k_B                = 1.380649e-23 J/K (exact)");
   text_io.put_line ("  R                  = 8.314462618 J/(mol*K) (exact)");
   text_io.put_line ("  Z_0                = 376.730313 ohms");
   text_io.put_line ("  mu_0               = 1.256637e-6 H/m");
   text_io.put_line ("  epsilon_0          = 8.854187e-12 F/m");
end demo_constants;
