package body UUIDs.Version2 is

   function Create_New return UUID
   is
      ID : UUID;
   begin
      Set_Variant(ID);
      
      -- Set the version
      ID.Data (6) := (ID.Data (6) and 16#2F#) or 16#20#;
      
      return ID;
   end Create_New;

end UUIDs.Version2;
