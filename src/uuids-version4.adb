with Ada.Numerics.Discrete_Random;
package body UUIDs.Version4 is

   package RNG is new Ada.Numerics.Discrete_Random(Unsigned_128);
   generator : RNG.Generator;
   
   function Create_New return UUID
   is
      rand : Unsigned_128;
      ID   : UUID;
   begin      
      RNG.Reset(generator);
      rand := RNG.Random(generator);
      for I in UUID_Array'Range loop
         ID.Data(I) := Unsigned_8(rand and 16#ff#);
         rand := Shift_Right(rand, 8);
      end loop;
      Set_Variant(ID);      
      -- Set the version
      ID.Data (6) := (ID.Data (6) and 16#4F#) or 16#40#;      
      return ID;
   end Create_New;

end UUIDs.Version4;
