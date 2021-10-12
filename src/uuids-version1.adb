package body UUIDs.Version1 is   
   
   function Create_New return UUID
   is
      ID : UUID;
   begin
      
      Set_Variant(ID);
      
      -- Set the version
      ID.Data (6) := (ID.Data (6) and 16#1F#) or 16#10#;
      
      return ID;
   end Create_New;
   
end UUIDs.Version1;
