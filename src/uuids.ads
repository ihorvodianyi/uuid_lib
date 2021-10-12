package UUIDs is

   type UUID is private;
   
   type Variant_UUID is (
                         NCS,
                         RFC_4122,
                         Microsoft,
                         Future
                        );
   
   type Version_UUID is (
                         Unknown,
                         Time_Based,
                         DCE_Security,
                         Name_Based_MD5,
                         Random_Number_Based,
                         Name_Based_SHA1
                        );
   
   function Create_New return UUID;
   
   function Is_Nil(Self : in UUID) return Boolean;
   function Get_Version(Self : in UUID) return Version_UUID;
   function Get_Variant(Self : in UUID) return Variant_UUID;
   function To_String(Self : in UUID) return String;
   function From_String(UUID_String : in String; ID : in out UUID) return Boolean;
   
private
   
   type Byte is mod 2 ** 8;
   for Byte'Size use 8;
   
   --UUID_Size : constant Integer := 16;   
   type UUID_Byte_Array is array (0 .. 15) of Byte;
   
   type UUID is record
      Data : UUID_Byte_Array := (others => 0);
   end record;
   
   procedure Set_Variant(ID : in out UUID);

end UUIDs;
