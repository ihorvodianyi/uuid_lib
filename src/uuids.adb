package body UUIDs is

   function To_String(Self : UUID) return String is
   begin
      return "{0}";
   end To_String;
   
   function From_String(Value : String) return UUID is
   begin
      return Create_New;
   end From_String;
   
    
   
   function Create_New return UUID is
      Res : UUID;
   begin
      return Res;
   end;
       

end UUIDs;
