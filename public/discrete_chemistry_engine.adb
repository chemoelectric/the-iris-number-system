pragma Ada_2022;

with Ada.Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;

procedure Discrete_Chemistry_Engine is
   type Real is digits 12;
   package Math is new Ada.Numerics.Generic_Elementary_Functions (Real);
   use Math;

   -- Physical Constants in Atomic Units (a_0, e, m_e = 1)
   Debye_Conversion : constant Real := 2.541746; -- a.u. dipole to Debye

   type Vector_3D is record
      X : Real := 0.0;
      Y : Real := 0.0;
      Z : Real := 0.0;
   end record;

   function Dot (A, B : in Vector_3D) return Real is
   begin
      return A.X * B.X + A.Y * B.Y + A.Z * B.Z;
   end Dot;

   function Norm (A : in Vector_3D) return Real is
   begin
      return Sqrt (Dot (A, A));
   end Norm;

   -- Compute Molecular Dipole Moment of Polar Diatomic (e.g. HF)
   function Compute_HF_Dipole
     (R_Equilibrium : in Real;
      Z_Fluorine    : in Real;
      Z_Hydrogen    : in Real;
      Valence_Shift : in Real) return Real
     with Pre => R_Equilibrium > 0.0 and Valence_Shift >= 0.0
   is
      Z_F_Pos : constant Real := -0.52;
      Z_H_Pos : constant Real := Z_F_Pos + R_Equilibrium;
      
      -- Centroid of the shared bonding electron pair
      Z_Bond_Centroid : constant Real := Z_F_Pos + Valence_Shift;
      
      -- Dipole moment along the Z axis
      Dipole_AU : Real;
   begin
      Dipole_AU := Z_Hydrogen * Z_H_Pos + 
                   (Z_Fluorine - 8.0) * Z_F_Pos - 
                   2.0 * Z_Bond_Centroid;
      return Dipole_AU * Debye_Conversion;
   end Compute_HF_Dipole;

   -- Discrete Partition Function and Entropy Calculation
   type Energy_Array is array (Positive range <>) of Real;

   procedure Compute_MaxEnt_Thermodynamics
     (Energies    : in  Energy_Array;
      Temperature : in  Real;
      Z_Partition : out Real;
      Entropy     : out Real)
     with Pre => Temperature > 0.0 and Energies'Length > 0
   is
      Beta : constant Real := 1.0 / (0.0019872 * Temperature); -- kcal/mol
      Prob : Energy_Array (Energies'Range);
      Sum_Z : Real := 0.0;
      S_Val : Real := 0.0;
   begin
      for I in Energies'Range loop
         Prob (I) := Exp (-Beta * Energies (I));
         Sum_Z := Sum_Z + Prob (I);
      end loop;

      for I in Energies'Range loop
         Prob (I) := Prob (I) / Sum_Z;
         if Prob (I) > 1.0e-15 then
            S_Val := S_Val - Prob (I) * Log (Prob (I));
         end if;
      end loop;

      Z_Partition := Sum_Z;
      Entropy     := S_Val;
   end Compute_MaxEnt_Thermodynamics;

   -- Test execution
   HF_Bond_Length : constant Real := 1.733; -- a_0 (~0.917 Angstrom)
   HF_Shift       : constant Real := 0.42;  -- a_0 from Fluorine nucleus
   Calculated_Dipole : Real;

   Vib_Levels : constant Energy_Array (1 .. 4) := 
     (0.0, 11.85, 23.40, 34.65); -- kcal/mol for HF
   Z_Sum : Real;
   S_Info : Real;
begin
   Calculated_Dipole := Compute_HF_Dipole
     (R_Equilibrium => HF_Bond_Length,
      Z_Fluorine    => 9.0,
      Z_Hydrogen    => 1.0,
      Valence_Shift => HF_Shift);

   Ada.Text_IO.Put_Line ("==================================================");
   Ada.Text_IO.Put_Line ("Discrete Physical Chemistry Engine on Grid G_N");
   Ada.Text_IO.Put_Line ("==================================================");
   Ada.Text_IO.Put_Line ("Hydrogen Fluoride (HF) Bond Analysis:");
   Ada.Text_IO.Put_Line ("  Equilibrium Bond Length: " & Real'Image (HF_Bond_Length) & " a_0");
   Ada.Text_IO.Put_Line ("  Calculated Dipole Moment:" & Real'Image (Calculated_Dipole) & " Debye");

   Compute_MaxEnt_Thermodynamics
     (Energies    => Vib_Levels,
      Temperature => 298.15,
      Z_Partition => Z_Sum,
      Entropy     => S_Info);

   Ada.Text_IO.Put_Line ("Finite MaxEnt Vibrational Thermodynamics (T = 298.15 K):");
   Ada.Text_IO.Put_Line ("  Vibrational Partition Sum Z: " & Real'Image (Z_Sum));
   Ada.Text_IO.Put_Line ("  Discrete Shannon Entropy S:  " & Real'Image (S_Info));
   Ada.Text_IO.Put_Line ("==================================================");
end Discrete_Chemistry_Engine;
