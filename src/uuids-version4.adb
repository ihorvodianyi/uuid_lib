with Ada.Numerics.Discrete_Random;
package body UUIDs.Version4 is

   package RNG is new Ada.Numerics.Discrete_Random (Byte);
   generator : RNG.Generator;
   
   function Create_New return UUID
   is      
      ID : UUID;
   begin
      
      RNG.Reset(generator);
      for i in UUID_Byte_Array'Range loop
         ID.Data (i) := RNG.Random (generator);         
      end loop;      
      
      Set_Variant(ID);
      
      -- Set the version
      ID.Data (6) := (ID.Data (6) and 16#4F#) or 16#40#;
      
      return ID;
   end Create_New;

end UUIDs.Version4;
