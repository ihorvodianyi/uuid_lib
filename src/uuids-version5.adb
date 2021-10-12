with GNAT.SHA1; use GNAT.SHA1;
with Interfaces; use Interfaces;
with Ada.Streams; use Ada.Streams;
with UUIDs.Version4;
package body UUIDs.Version5 is
   
   function Create_New return UUID
   is
      C: GNAT.SHA1.Context;
      ID : UUID;
      SA11 : GNAT.SHA1.Binary_Message_Digest;
      Index : Stream_Element_Offset := SA11'First;
      
   begin
      GNAT.SHA1.Update(C, To_String(UUIDs.Version4.Create_New));
      SA11 := GNAT.SHA1.Digest(C);      
      for I in ID.Data'Range loop
         ID.Data(I) := Unsigned_8(SA11(Index));
         Index := Index + 1;
      end loop;
      GNAT.SHA1.Update(C, SA11);      
      Set_Variant(ID);      
      -- Set the version
      ID.Data (6) := (ID.Data (6) and 16#5F#) or 16#50#;      
      return ID;
   end Create_New;
end UUIDs.Version5;
