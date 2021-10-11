package body UUIDs is
   
   Hyphen : constant Character := '-';
   Hex_Chars : constant array (0 .. 15) of Character := "0123456789abcdef";
   
   function Get_Version (Self : in UUID) return Version_UUID is
      Version_Byte : constant Byte := Self.data (6) and 16#F0#;
   begin
      case Version_Byte is
         when 16#10# => return Time_Based;
         when 16#20# => return DCE_Security;
         when 16#30# => return Name_Based_MD5;
         when 16#40# => return Random_Number_Based;
         when 16#50# => return Name_Based_SHA1;
         when others => return Unknown;
      end case;
   end Get_Version;
   
   function Get_Variant (Self : in UUID) return Variant_UUID is
      Variant_Byte : constant Byte := Self.data (8);
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
   end Get_Variant;
   
   function To_String(Self : UUID) return String is
      Result : String(1 .. 36);
      Index_Result : Integer := Result'First;
      Item : Natural;
   begin
      
      for I in UUID_Byte_Array'Range loop
         Item := Natural(Self.Data(I));
         Result(Index_Result) := Hex_Chars(Item / 16);
         Result(Index_Result + 1) := Hex_Chars(item mod 16);
         Index_Result := Index_Result + 2;

         if I = 3 or else I = 5 or else I = 7 or else I = 9 then
            Result(Index_Result) := Hyphen;
            Index_Result := Index_Result + 1;
         end if;
      end loop;
      return Result;
   end To_String;
   
   function From_String(UUID_String : String; Result : out UUID) return Boolean is
      Index : Integer := UUID_String'First;
      ID : UUID;
      
      function Convert (High : Character;
                        Low : Character;
                        Result : in out Byte) return Boolean
      is
         Bool_Result : Boolean := True;
         High_Byte, Low_Byte : Byte;
      begin
         Result := 0;
         case High is
            when '0' => High_Byte := 16#0f#;
            when '1' => High_Byte := 16#1f#;
            when '2' => High_Byte := 16#2f#;
            when '3' => High_Byte := 16#3f#;
            when '4' => High_Byte := 16#4f#;
            when '5' => High_Byte := 16#5f#;
            when '6' => High_Byte := 16#6f#;
            when '7' => High_Byte := 16#7f#;
            when '8' => High_Byte := 16#8f#;
            when '9' => High_Byte := 16#9f#;
            when 'a' | 'A' => High_Byte := 16#af#;
            when 'b' | 'B' => High_Byte := 16#bf#;
            when 'c' | 'C' => High_Byte := 16#cf#;
            when 'd' | 'D' => High_Byte := 16#df#;
            when 'e' | 'E' => High_Byte := 16#ef#;
            when 'f' | 'F' => High_Byte := 16#ff#;
            when others => Bool_Result := False;
         end case;
         if Bool_Result then
            case Low is
               when '0' => Low_Byte := 16#f0#;
               when '1' => Low_Byte := 16#f1#;
               when '2' => Low_Byte := 16#f2#;
               when '3' => Low_Byte := 16#f3#;
               when '4' => Low_Byte := 16#f4#;
               when '5' => Low_Byte := 16#f5#;
               when '6' => Low_Byte := 16#f6#;
               when '7' => Low_Byte := 16#f7#;
               when '8' => Low_Byte := 16#f8#;
               when '9' => Low_Byte := 16#f9#;
               when 'a' | 'A' => Low_Byte := 16#fa#;
               when 'b' | 'B' => Low_Byte := 16#fb#;
               when 'c' | 'C' => Low_Byte := 16#fc#;
               when 'd' | 'D' => Low_Byte := 16#fd#;
               when 'e' | 'E' => Low_Byte := 16#fe#;
               when 'f' | 'F' => Low_Byte := 16#ff#;
               when others => Bool_Result := False;
            end case;
            if Bool_Result then
               Result := High_Byte and Low_Byte;
            else
               Result := 0;
            end if;
         end if;
         return Bool_Result;
      end Convert;     
      
   begin
      if UUID_String'Length /= 36 then
         return False;
      end if;
      
      Index := UUID_String'First;
      for I in UUID_Byte_Array'Range loop
         if Index = 9 or else Index = 14 or else Index = 19 or else Index = 24
         then
            if UUID_String(Index) /= Hyphen then
               return False;
            end if;
            Index := Index + 1;
         end if;
         
         if not Convert(UUID_String(Index), UUID_String(Index + 1), ID.Data(I))
         then
            return False;
         end if;
         Index := Index + 2;
      end loop;
            
      Result := ID;
      return True;
   end From_String;
   
   function Create_New return UUID is
      Res : UUID;
   begin
      return Res;
   end;       

end UUIDs;
