package body UUIDs.Version4 is

   function Create_New return UUID
   is
      ID : UUID;
   begin
      Set_Variant(ID);
      
      -- Set the version
      ID.Data (6) := (ID.Data (6) and 16#4F#) or 16#40#;
      
      return ID;
   end Create_New;

end UUIDs.Version4;
