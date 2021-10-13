with Ada.Numerics.Discrete_Random;
with Ada.Text_IO; use Ada.Text_IO;
with GNAT.SHA1;
with Ada.Streams; use Ada.Streams;

package body UUIDs is

   Hyphen    : constant Character := '-';
   Hex_Chars : constant array (0 .. 15) of Character := "0123456789abcdef";
   
   package RNG is new Ada.Numerics.Discrete_Random(Unsigned_128);
   generator : RNG.Generator;
   
   function Is_Nil(Self : in UUID) return Boolean is
   begin
      for i in Self'Range
      loop
         if Self(i) /= 0 then
            return False;
         end if;
      end loop;
      return True;
   end Is_Nil;
   
   function Version(Self : in UUID) return Version_UUID
   is
      Version_Byte : constant Unsigned_8 := Self(6) and 16#F0#;
   begin
      case Version_Byte is
         when 16#10# => return Time_Based;
         when 16#20# => return DCE_Security;
         when 16#30# => return Name_Based_MD5;
         when 16#40# => return Random_Number_Based;
         when 16#50# => return Name_Based_SHA1;
         when others => return Unknown;
      end case;
   end Version;
   
   function Variant(Self : in UUID) return Variant_UUID
   is
      Variant_Byte : constant Unsigned_8 := Self(8);
   begin
      if (Variant_Byte and 16#80#) = 0 then
         return NCS;
      elsif (Variant_Byte and 16#C0#) = 16#80# then
         return RFC_4122;
      elsif (Variant_Byte and 16#E0#) = 16#C0# then
         return Microsoft;
      else
         return Future;
      end if;
   end Variant;
   
   function To_String(Self : UUID) return String
   is
      Result : String(1 .. 36);
      Index  : Integer := Result'First;
      Item   : Integer;
   begin      
      for I in UUID'Range loop
         Item := Natural(Self(I));
         Result(Index) := Hex_Chars(Item / 16);
         Result(Index + 1) := Hex_Chars(Item mod 16);         
         Index := Index + 2;
         if I = 3 or else I = 5 or else I = 7 or else I = 9
         then
            Result(Index) := Hyphen;
            Index := Index + 1;
         end if;
      end loop;
      return Result;
   end To_String;
   
   procedure From_String
     (UUID_String : in String;
      ID          : out UUID;
      Success     : out Boolean)
   is
      Hyphen1 : constant Integer := UUID_String'First + 8;
      Hyphen2 : constant Integer := Hyphen1 + 5;
      Hyphen3 : constant Integer := Hyphen2 + 5;
      Hyphen4 : constant Integer := Hyphen3 + 5;

      Index : Integer := UUID_String'First;      
      High  : Unsigned_8;
      Low   : Unsigned_8;
      
      procedure Hex_To_Unsigned_8(Char : in Character;
                                  Result: out Unsigned_8;
                                  Success : out Boolean)
      is
      begin         
         Success := True;
         case Char is
            when '0' => Result := 16#00#;
            when '1' => Result := 16#01#;
            when '2' => Result := 16#02#;
            when '3' => Result := 16#03#;
            when '4' => Result := 16#04#;
            when '5' => Result := 16#05#;
            when '6' => Result := 16#06#;
            when '7' => Result := 16#07#;
            when '8' => Result := 16#08#;
            when '9' => Result := 16#09#;
            when 'a' | 'A' => Result := 16#0a#;
            when 'b' | 'B' => Result := 16#0b#;
            when 'c' | 'C' => Result := 16#0c#;
            when 'd' | 'D' => Result := 16#0d#;
            when 'e' | 'E' => Result := 16#0e#;
            when 'f' | 'F' => Result := 16#0f#;
            when others =>
               Result := 0;
               Success := False;
         end case;
      end Hex_To_Unsigned_8;
   
   begin
      if UUID_String'Length = 36
        and then UUID_String(Hyphen1) = Hyphen
        and then UUID_String(Hyphen2) = Hyphen
        and then UUID_String(Hyphen3) = Hyphen
        and then UUID_String(Hyphen4) = Hyphen
      then
         Index := UUID_String'First;
         for I in UUID'Range
         loop
            if Index = Hyphen1
              or else Index = Hyphen2
              or else Index = Hyphen3
              or else Index = Hyphen4
            then
               Index := Index + 1;
            end if;
            
            Hex_To_Unsigned_8(UUID_String(Index), High, Success);
            if Success
            then
               Hex_To_Unsigned_8(UUID_String(Index + 1), Low, Success);
               if Success
               Then
                  ID(I) := Shift_Left(High, 4) or Low;
                  Index := Index + 2;
               end if;
            end if;
            exit when not Success;
         end loop;
      else
         Success := False;
      end if;
   end From_String;
   
   procedure Set_Variant(ID : in out UUID) is
   begin
      -- Set variant 1
      ID(8) := (ID(8) and 16#BF#) or 16#80#;
   end Set_Variant;
   
   function Create_New_V4 return UUID
   is
      rand : Unsigned_128;
      ID   : UUID;
   begin      
      RNG.Reset(generator);
      rand := RNG.Random(generator);
      for I in UUID'Range loop
         ID(I) := Unsigned_8(rand and 16#ff#);
         rand := Shift_Right(rand, 8);
      end loop;
      Set_Variant(ID);      
      -- Set the version
      ID(6) := (ID(6) and 16#4F#) or 16#40#;      
      return ID;
   end Create_New_V4;
   
   package SHA renames GNAT.SHA1;
   
   function Create_New_V5 return UUID
   is
      Context   : SHA.Context;
      ID        : UUID;
      SHA_Value : SHA.Binary_Message_Digest;
      Index     : Stream_Element_Offset := SHA_Value'First;      
   begin
      Context := SHA.Initial_Context;
      SHA.Update(Context, To_String(Create_New_V4));
      SHA_Value := SHA.Digest(Context);      
      for I in ID'Range loop
         ID(I) := Unsigned_8(SHA_Value(Index));
         Index := Index + 1;
      end loop;
      SHA.Update(Context, SHA_Value);      
      Set_Variant(ID);      
      -- Set the version
      ID(6) := (ID(6) and 16#5F#) or 16#50#;      
      return ID;
   end Create_New_V5;
   
end UUIDs;
