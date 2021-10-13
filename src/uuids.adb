package body UUIDs is

   Hyphen    : constant Character := '-';
   Hex_Chars : constant array (0 .. 15) of Character := "0123456789abcdef";
   
   function Is_Nil(Self : in UUID) return Boolean is
   begin
      for i in Self.Data'Range
      loop
         if Self.Data (i) /= 0 then
            return False;
         end if;
      end loop;
      return True;
   end Is_Nil;
   
   function Version(Self : in UUID) return Version_UUID
   is
      Version_Byte : constant Unsigned_8 := Self.data (6) and 16#F0#;
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
      Variant_Byte : constant Unsigned_8 := Self.data (8);
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
      Item   : Natural;
   begin      
      for I in UUID_Array'Range loop
         Item := Natural(Self.Data(I));
         Result(Index) := Hex_Chars(Item / 16);
         Result(Index + 1) := Hex_Chars(item mod 16);
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
         Result := 0;
         Success := True;
         case Char is
            when '0' => Result := 16#f0#;
            when '1' => Result := 16#f1#;
            when '2' => Result := 16#f2#;
            when '3' => Result := 16#f3#;
            when '4' => Result := 16#f4#;
            when '5' => Result := 16#f5#;
            when '6' => Result := 16#f6#;
            when '7' => Result := 16#f7#;
            when '8' => Result := 16#f8#;
            when '9' => Result := 16#f9#;
            when 'a' | 'A' => Result := 16#fa#;
            when 'b' | 'B' => Result := 16#fb#;
            when 'c' | 'C' => Result := 16#fc#;
            when 'd' | 'D' => Result := 16#fd#;
            when 'e' | 'E' => Result := 16#fe#;
            when 'f' | 'F' => Result := 16#ff#;
            when others => Success := False;
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
         for I in UUID_Array'Range
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
                  ID.Data(I) := Shift_Left(High, 8) and Low;
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
      ID.Data(8) := (ID.Data(8) and 16#BF#) or 16#80#;
   end Set_Variant;
end UUIDs;
