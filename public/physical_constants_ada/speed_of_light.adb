pragma ada_2022;

package body speed_of_light is

   function value return real_type is
      c_exact : constant real_type := 299_792_458.0;
   begin
      return c_exact;
   end value;

end speed_of_light;
