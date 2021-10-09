with Interfaces; use Interfaces;

package UUIDs is

   type UUID is private;
   
   function Create_New return UUID;
   function To_String(Self : UUID) return String;
   function From_String(Value : String) return UUID;
   
private
   
   UUID_Size : constant Integer := 16;
   
   type ByteArray is array (0 .. UUID_Size - 1) of Unsigned_8;
   
   type UUID is record
      Data : ByteArray := (others => 0);
   end record;

end UUIDs;
