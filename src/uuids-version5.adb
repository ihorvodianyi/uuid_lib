with GNAT.SHA1;
with Interfaces; use Interfaces;
with Ada.Streams; use Ada.Streams;
with UUIDs.Version4;
package body UUIDs.Version5 is
   package SHA renames GNAT.SHA1;
   
   function Create_New return UUID
   is
      Context   : SHA.Context;
      ID        : UUID;
      SHA_Value : SHA.Binary_Message_Digest;
      Index     : Stream_Element_Offset := SHA_Value'First;      
   begin
      Context := SHA.Initial_Context;
      SHA.Update(Context, To_String(UUIDs.Version4.Create_New));
      SHA_Value := SHA.Digest(Context);      
      for I in ID.Data'Range loop
         ID.Data(I) := Unsigned_8(SHA_Value(Index));
         Index := Index + 1;
      end loop;
      SHA.Update(Context, SHA_Value);      
      Set_Variant(ID);      
      -- Set the version
      ID.Data (6) := (ID.Data (6) and 16#5F#) or 16#50#;      
      return ID;
   end Create_New;
end UUIDs.Version5;
