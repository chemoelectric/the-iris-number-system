pragma ada_2022;

package body elementary_charge is

   function value return real_type is
      e_exact : constant real_type := 1.602176634e-19;
   begin
      return e_exact;
   end value;

end elementary_charge;
