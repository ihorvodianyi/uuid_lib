with Interfaces; use Interfaces;
package UUIDs is 

   type UUID is private;
   type UUID1 is private;
   
   type Variant_UUID is
     (NCS,
      RFC_4122,
      Microsoft,
      Future);
   
   type Version_UUID is
     (Unknown,
      Time_Based,
      DCE_Security,
      Name_Based_MD5,
      Random_Number_Based,
      Name_Based_SHA1);
   
   function Is_Nil(Self : in UUID) return Boolean;
   function Version(Self : in UUID) return Version_UUID;
   function Variant(Self : in UUID) return Variant_UUID;
   function To_String(Self : in UUID) return String;
   procedure From_String
     (UUID_String : in String;
      ID          : out UUID;
      Success     : out Boolean);
   function Create_New_V4 return UUID;
   function Create_New_V5 return UUID;
   
private   
   type UUID_Array is array (0 .. 15) of Unsigned_8;
   
   type UUID1 is array (0 .. 15) of Integer;
   
   type UUID is
      record
         Data : UUID_Array := (others => 0);
      end record;   
   
   procedure Set_Variant(ID : in out UUID);

end UUIDs;
