unit AmEnum;
interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  AmUserType,Math;

   type
    {$REGION 'TvksFun_unittime'}
    TAmEnum_enum_unittime = ( vks_fun_unittime_none,
                           vks_fun_unittime_milliseconds,
                           vks_fun_unittime_seconds,
                           vks_fun_unittime_minutes,
                           vks_fun_unittime_hours,
                           vks_fun_unittime_days,
                           vks_fun_unittime_weeks,
                           vks_fun_unittime_moth
                                    );
    TAmEnum_unittime = record
       public
       var Value:TAmEnum_enum_unittime;
       function ToSeconds(V:Int64;valueDef:TAmEnum_enum_unittime=vks_fun_unittime_seconds):Int64;
       function ToMilliSeconds(V:Int64;valueDef:TAmEnum_enum_unittime=vks_fun_unittime_seconds):Int64;
       function ToMinutes(V:Int64;valueDef:TAmEnum_enum_unittime=vks_fun_unittime_seconds):Int64;
       function ToHours(V:Int64;valueDef:TAmEnum_enum_unittime=vks_fun_unittime_seconds):Int64;

       {$REGION 'Str'}
       /////////////////////////////////////////////////////////////////////////
       const
       s_milliseconds='milliseconds';
       s_seconds='seconds';
       s_minutes='minutes';
       s_hours='hours';
       s_days='days';
       s_weeks='weeks';
       s_moth='moth';

       Str:Array [TAmEnum_enum_unittime] of string = ('',
                                                      s_milliseconds,
                                                      s_seconds,
                                                      s_minutes,
                                                      s_hours,
                                                      s_days,
                                                      s_weeks,
                                                      s_moth
                                                      );

       ///методы конвертации работают с const Str
       function SetStr(S:string):boolean;
       function GetStr:string;
       procedure ToListAddStr(L:TStrings);
       procedure ToListStr(L:TStrings);

       /////////////////////////////////////////////////////////////////////////
       //end Str
       {$ENDREGION}
       {$REGION 'StrRuShort'}
       /////////////////////////////////////////////////////////////////////////
       const
       s_ru_short_milliseconds='мс.';
       s_ru_short_seconds='сек.';
       s_ru_short_minutes='мин.';
       s_ru_short_hours='час.';
       s_ru_short_days='дни';
       s_ru_short_weeks='нед.';
       s_ru_short_moth='мес.';

       StrRuShort:Array [TAmEnum_enum_unittime] of string = ('',
                                                      s_ru_short_milliseconds,
                                                      s_ru_short_seconds,
                                                      s_ru_short_minutes,
                                                      s_ru_short_hours,
                                                      s_ru_short_days,
                                                      s_ru_short_weeks,
                                                      s_ru_short_moth
                                                      );

       ///методы конвертации работают с const StrRuShort
       function SetStrRuShort(S:string):boolean;
       function GetStrRuShort:string;
       procedure ToListAddStrRuShort(L:TStrings);
       procedure ToListStrRuShort(L:TStrings);

       /////////////////////////////////////////////////////////////////////////
       //end StrRuShort
       {$ENDREGION}
       {$REGION 'StrRuLong'}
       /////////////////////////////////////////////////////////////////////////
       const
       s_ru_long_milliseconds='миллисекунды';
       s_ru_long_seconds='секунды';
       s_ru_long_minutes='минуты';
       s_ru_long_hours='часы';
       s_ru_long_days='дни';
       s_ru_long_weeks='недели';
       s_ru_long_moth='месяцы';

       StrRuLong:Array [TAmEnum_enum_unittime] of string = ('',
                                                      s_ru_long_milliseconds,
                                                      s_ru_long_seconds,
                                                      s_ru_long_minutes,
                                                      s_ru_long_hours,
                                                      s_ru_long_days,
                                                      s_ru_long_weeks,
                                                      s_ru_long_moth
                                                      );

       ///методы конвертации работают с const StrRuLong
       function SetStrRuLong(S:string):boolean;
       function GetStrRuLong:string;
       procedure ToListAddStrRuLong(L:TStrings);
       procedure ToListStrRuLong(L:TStrings);

       /////////////////////////////////////////////////////////////////////////
       //end StrRuLong
       {$ENDREGION}
       {$REGION 'IntSec'}
       /////////////////////////////////////////////////////////////////////////
       const
       i_sec_milliseconds=1000;
       i_sec_seconds=1;
       i_sec_minutes=60;
       i_sec_hours=60*60;
       i_sec_days=60*60*24;
       i_sec_weeks=60*60*24*7;
       i_sec_moth=60*60*24*30;

       IntSec:Array [TAmEnum_enum_unittime] of integer = (0,
                                                      i_sec_milliseconds,
                                                      i_sec_seconds,
                                                      i_sec_minutes,
                                                      i_sec_hours,
                                                      i_sec_days,
                                                      i_sec_weeks,
                                                      i_sec_moth
                                                      );

       ///методы конвертации работают с const IntSec
       function SetIntSec(S:integer):boolean;
       function GetIntSec:integer;
       procedure ToListAddIntSec(L:TStrings);
       procedure ToListIntSec(L:TStrings);

       /////////////////////////////////////////////////////////////////////////
       //end IntSec
       {$ENDREGION}

       {$REGION 'основной помошник H1 enum (функции Is и другое)'}
       function TypIsValid:boolean;
       function TypCount:integer;
       function IsMilliseconds:boolean;
       procedure SetMilliseconds;
       function IsSeconds:boolean;
       procedure SetSeconds;
       function IsMinutes:boolean;
       procedure SetMinutes;
       function IsHours:boolean;
       procedure SetHours;
       function IsDays:boolean;
       procedure SetDays;
       function IsWeeks:boolean;
       procedure SetWeeks;
       function IsMoth:boolean;
       procedure SetMoth;
       // end основной помошник H1 enum (функции Is и другое)
       {$ENDREGION}

       {$REGION 'доп помошник H2 enum (функции Typ)'}
       function  TypGetMin:TAmEnum_enum_unittime;
       function  TypGetMax:TAmEnum_enum_unittime;
       procedure TypSetMin;
       procedure TypSetMax;
       procedure TypClear;
        function  TypGetStr:string;
       function  TypGetInt:integer;
       function  TypSetStr(S:string):boolean;
       function  TypSetInt(S:integer):boolean;
        function  TypInc:boolean;
       function  TypDec:boolean;
       procedure TypToListAdd(L:TStrings);
       procedure TypToList(L:TStrings);
       // end доп помошник H2 enum (функции Typ)
       {$ENDREGION}


       end;
       {$ENDREGION}
    {$REGION 'TAmEnum_CurrencyDef'}
    TAmEnum_enum_CurrencyDef = ( sbt_CurrencyDef_none,
                           sbt_CurrencyDef_USD,
                           sbt_CurrencyDef_EUR,
                           sbt_CurrencyDef_RUB,
                           sbt_CurrencyDef_BYN,
                           sbt_CurrencyDef_PLN,
                           sbt_CurrencyDef_BTC,
                           sbt_CurrencyDef_ETH,
                           sbt_CurrencyDef_BNB,
                           sbt_CurrencyDef_TRX,
                           sbt_CurrencyDef_XRP
                                    );
    TAmEnum_CurrencyDef = record
       public
       var Value:TAmEnum_enum_CurrencyDef;
       {$REGION 'sENG'}
       /////////////////////////////////////////////////////////////////////////
       const
       s_eng_USD='USD';
       s_eng_EUR='EUR';
       s_eng_RUB='RUB';
       s_eng_BYN='BYN';
       s_eng_PLN='PLN';
       s_eng_BTC='BTC';
       s_eng_ETH='ETH';
       s_eng_BNB='BNB';
       s_eng_TRX='TRX';
       s_eng_XRP='XRP';

       SENG:Array [TAmEnum_enum_CurrencyDef] of string = ('',
                                                      s_eng_USD,
                                                      s_eng_EUR,
                                                      s_eng_RUB,
                                                      s_eng_BYN,
                                                      s_eng_PLN,
                                                      s_eng_BTC,
                                                      s_eng_ETH,
                                                      s_eng_BNB,
                                                      s_eng_TRX,
                                                      s_eng_XRP
                                                      );

       ///методы конвертации работают с const sENG
       function SetSENG(S:string):boolean;
       function GetSENG:string;
       procedure ToListAddsENG(L:TStrings);
       procedure ToListsENG(L:TStrings);

       /////////////////////////////////////////////////////////////////////////
       //end sENG
       {$ENDREGION}
       {$REGION 'sRu'}
       /////////////////////////////////////////////////////////////////////////
       const
       s_Ru_USD='Доллар';
       s_Ru_EUR='Eвро';
       s_Ru_RUB='Рубль';
       s_Ru_BYN='Бел. рубль';
       s_Ru_PLN='Польский злотый';
       s_Ru_BTC='Биткойн';
       s_Ru_ETH='Эфириум';
       s_Ru_BNB='Бинанс коин';
       s_Ru_TRX='Трон';
       s_Ru_XRP='Рипл';

       SRu:Array [TAmEnum_enum_CurrencyDef] of string = ('',
                                                      s_Ru_USD,
                                                      s_Ru_EUR,
                                                      s_Ru_RUB,
                                                      s_Ru_BYN,
                                                      s_Ru_PLN,
                                                      s_Ru_BTC,
                                                      s_Ru_ETH,
                                                      s_Ru_BNB,
                                                      s_Ru_TRX,
                                                      s_Ru_XRP
                                                      );

       ///методы конвертации работают с const sRu
       function SetSRu(S:string):boolean;
       function GetSRu:string;
       procedure ToListAddsRu(L:TStrings);
       procedure ToListsRu(L:TStrings);

       /////////////////////////////////////////////////////////////////////////
       //end sRu
       {$ENDREGION}
       {$REGION 'zENG'}
       /////////////////////////////////////////////////////////////////////////
       const
       z_ENG_USD='$';
       z_ENG_EUR='Euro';
       z_ENG_RUB='Rub';
       z_ENG_BYN='BelRub';
       z_ENG_PLN='Zloty';
       z_ENG_BTC='Bitcoin';
       z_ENG_ETH='Ethereum';
       z_ENG_BNB='BNB';
       z_ENG_TRX='TRX';
       z_ENG_XRP='XRP';

       ZENG:Array [TAmEnum_enum_CurrencyDef] of string = ('',
                                                      z_ENG_USD,
                                                      z_ENG_EUR,
                                                      z_ENG_RUB,
                                                      z_ENG_BYN,
                                                      z_ENG_PLN,
                                                      z_ENG_BTC,
                                                      z_ENG_ETH,
                                                      z_ENG_BNB,
                                                      z_ENG_TRX,
                                                      z_ENG_XRP
                                                      );

       ///методы конвертации работают с const zENG
       function SetZENG(S:string):boolean;
       function GetZENG:string;
       procedure ToListAddzENG(L:TStrings);
       procedure ToListzENG(L:TStrings);

       /////////////////////////////////////////////////////////////////////////
       //end zENG
       {$ENDREGION}

       {$REGION 'основной помошник H1 enum (функции Is и другое)'}
       function TypIsValid:boolean;
       function TypCount:integer;
       function IsUSD:boolean;
       procedure SetUSD;
       function IsEUR:boolean;
       procedure SetEUR;
       function IsRUB:boolean;
       procedure SetRUB;
       function IsBYN:boolean;
       procedure SetBYN;
       function IsPLN:boolean;
       procedure SetPLN;
       function IsBTC:boolean;
       procedure SetBTC;
       function IsETH:boolean;
       procedure SetETH;
       function IsBNB:boolean;
       procedure SetBNB;
       function IsTRX:boolean;
       procedure SetTRX;
       function IsXRP:boolean;
       procedure SetXRP;
       // end основной помошник H1 enum (функции Is и другое)
       {$ENDREGION}

       {$REGION 'доп помошник H2 enum (функции Typ)'}
       function  TypGetMin:TAmEnum_enum_CurrencyDef;
       function  TypGetMax:TAmEnum_enum_CurrencyDef;
       procedure TypSetMin;
       procedure TypSetMax;
       procedure TypClear;
        function  TypGetStr:string;
       function  TypGetInt:integer;
       function  TypSetStr(S:string):boolean;
       function  TypSetInt(S:integer):boolean;
        function  TypInc:boolean;
       function  TypDec:boolean;
       procedure TypToListAdd(L:TStrings);
       procedure TypToList(L:TStrings);
       // end доп помошник H2 enum (функции Typ)
       {$ENDREGION}


       end;
       {$ENDREGION}
    {$REGION 'TAmEnum_ContryDef'}
    TAmEnum_enum_ContryDef = ( sbt_ContryDef_none,
                           sbt_ContryDef_RU,
                           sbt_ContryDef_KZ,
                           sbt_ContryDef_UA,
                           sbt_ContryDef_BY,
                           sbt_ContryDef_CN2,
                           sbt_ContryDef_NL,
                           sbt_ContryDef_PL,
                           sbt_ContryDef_KG,
                           sbt_ContryDef_GE,
                           sbt_ContryDef_USA,
                           sbt_ContryDef_USA2
                                    );
    TAmEnum_ContryDef = record
       public
       var Value:TAmEnum_enum_ContryDef;
       {$REGION 'Seng'}
       /////////////////////////////////////////////////////////////////////////
       const
       s_eng_RU='RU';
       s_eng_KZ='KZ';
       s_eng_UA='UA';
       s_eng_BY='BY';
       s_eng_CN2='CN2';
       s_eng_NL='NL';
       s_eng_PL='PL';
       s_eng_KG='KG';
       s_eng_GE='GE';
       s_eng_USA='USA';
       s_eng_USA2='USA2';

       Seng:Array [TAmEnum_enum_ContryDef] of string = ('',
                                                      s_eng_RU,
                                                      s_eng_KZ,
                                                      s_eng_UA,
                                                      s_eng_BY,
                                                      s_eng_CN2,
                                                      s_eng_NL,
                                                      s_eng_PL,
                                                      s_eng_KG,
                                                      s_eng_GE,
                                                      s_eng_USA,
                                                      s_eng_USA2
                                                      );

       ///методы конвертации работают с const Seng
       function SetSeng(S:string):boolean;
       function GetSeng:string;
       procedure ToListAddSeng(L:TStrings);
       procedure ToListSeng(L:TStrings);

       /////////////////////////////////////////////////////////////////////////
       //end Seng
       {$ENDREGION}
       {$REGION 'Sru'}
       /////////////////////////////////////////////////////////////////////////
       const
       s_ru_RU='Россия';
       s_ru_KZ='Казахстан';
       s_ru_UA='Украина';
       s_ru_BY='Беларусь';
       s_ru_CN2='Китай';
       s_ru_NL='Нидерланды';
       s_ru_PL='Польша';
       s_ru_KG='Киргизия';
       s_ru_GE='Грузия';
       s_ru_USA='Сша';
       s_ru_USA2='Сша2';

       Sru:Array [TAmEnum_enum_ContryDef] of string = ('',
                                                      s_ru_RU,
                                                      s_ru_KZ,
                                                      s_ru_UA,
                                                      s_ru_BY,
                                                      s_ru_CN2,
                                                      s_ru_NL,
                                                      s_ru_PL,
                                                      s_ru_KG,
                                                      s_ru_GE,
                                                      s_ru_USA,
                                                      s_ru_USA2
                                                      );

       ///методы конвертации работают с const Sru
       function SetSru(S:string):boolean;
       function GetSru:string;
       procedure ToListAddSru(L:TStrings);
       procedure ToListSru(L:TStrings);

       /////////////////////////////////////////////////////////////////////////
       //end Sru
       {$ENDREGION}

       {$REGION 'основной помошник H1 enum (функции Is и другое)'}
       function TypIsValid:boolean;
       function TypCount:integer;
       function IsRU:boolean;
       procedure SetRU;
       function IsKZ:boolean;
       procedure SetKZ;
       function IsUA:boolean;
       procedure SetUA;
       function IsBY:boolean;
       procedure SetBY;
       function IsCN2:boolean;
       procedure SetCN2;
       function IsNL:boolean;
       procedure SetNL;
       function IsPL:boolean;
       procedure SetPL;
       function IsKG:boolean;
       procedure SetKG;
       function IsGE:boolean;
       procedure SetGE;
       function IsUSA:boolean;
       procedure SetUSA;
       function IsUSA2:boolean;
       procedure SetUSA2;
       // end основной помошник H1 enum (функции Is и другое)
       {$ENDREGION}

       {$REGION 'доп помошник H2 enum (функции Typ)'}
       function  TypGetMin:TAmEnum_enum_ContryDef;
       function  TypGetMax:TAmEnum_enum_ContryDef;
       procedure TypSetMin;
       procedure TypSetMax;
       procedure TypClear;
        function  TypGetStr:string;
       function  TypGetInt:integer;
       function  TypSetStr(S:string):boolean;
       function  TypSetInt(S:integer):boolean;
        function  TypInc:boolean;
       function  TypDec:boolean;
       procedure TypToListAdd(L:TStrings);
       procedure TypToList(L:TStrings);
       // end доп помошник H2 enum (функции Typ)
       {$ENDREGION}


       end;
       {$ENDREGION}
implementation
{$REGION 'TAmEnum_ContryDef'}
{$REGION 'TAmEnum_ContryDef | Seng'}
function TAmEnum_ContryDef.SetSeng(S:string):boolean;
var i:integer;
begin
   Result:= false;
   Value:= TAmEnum_enum_ContryDef(0);
   for I := 1 to TypCount-1 do
   if S=Seng[TAmEnum_enum_ContryDef(i)] then
   begin
      Value:= TAmEnum_enum_ContryDef(i);
      Result:=true;
      break;
   end;
end;

function TAmEnum_ContryDef.GetSeng:string;
begin
   Result:= Seng[Value];
end;

procedure TAmEnum_ContryDef.ToListAddSeng(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(Seng[TAmEnum_enum_ContryDef(i)]);
end;
procedure TAmEnum_ContryDef.ToListSeng(L:TStrings);
begin
   L.Clear;
   ToListAddSeng(L);
end;

// end TAmEnum_ContryDef | Seng
{$ENDREGION}
{$REGION 'TAmEnum_ContryDef | Sru'}
function TAmEnum_ContryDef.SetSru(S:string):boolean;
var i:integer;
begin
   Result:= false;
   Value:= TAmEnum_enum_ContryDef(0);
   for I := 1 to TypCount-1 do
   if S=Sru[TAmEnum_enum_ContryDef(i)] then
   begin
      Value:= TAmEnum_enum_ContryDef(i);
      Result:=true;
      break;
   end;
end;

function TAmEnum_ContryDef.GetSru:string;
begin
   Result:= Sru[Value];
end;

procedure TAmEnum_ContryDef.ToListAddSru(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(Sru[TAmEnum_enum_ContryDef(i)]);
end;
procedure TAmEnum_ContryDef.ToListSru(L:TStrings);
begin
   L.Clear;
   ToListAddSru(L);
end;

// end TAmEnum_ContryDef | Sru
{$ENDREGION}
{$REGION 'TAmEnum_ContryDef | основной помошник H1 enum (функции Is и другое)'}
function TAmEnum_ContryDef.TypIsValid:boolean;
begin
   Result:= Value <> sbt_ContryDef_none;
end;

function TAmEnum_ContryDef.TypCount:integer;
begin
   Result:= Integer(System.High(TAmEnum_enum_ContryDef))+1;
end;


function TAmEnum_ContryDef.IsRU:boolean;
begin
   Result:= Value = sbt_ContryDef_RU;
end;

procedure TAmEnum_ContryDef.SetRU;
begin
   Value:= sbt_ContryDef_RU;
end;

function TAmEnum_ContryDef.IsKZ:boolean;
begin
   Result:= Value = sbt_ContryDef_KZ;
end;

procedure TAmEnum_ContryDef.SetKZ;
begin
   Value:= sbt_ContryDef_KZ;
end;

function TAmEnum_ContryDef.IsUA:boolean;
begin
   Result:= Value = sbt_ContryDef_UA;
end;

procedure TAmEnum_ContryDef.SetUA;
begin
   Value:= sbt_ContryDef_UA;
end;

function TAmEnum_ContryDef.IsBY:boolean;
begin
   Result:= Value = sbt_ContryDef_BY;
end;

procedure TAmEnum_ContryDef.SetBY;
begin
   Value:= sbt_ContryDef_BY;
end;

function TAmEnum_ContryDef.IsCN2:boolean;
begin
   Result:= Value = sbt_ContryDef_CN2;
end;

procedure TAmEnum_ContryDef.SetCN2;
begin
   Value:= sbt_ContryDef_CN2;
end;

function TAmEnum_ContryDef.IsNL:boolean;
begin
   Result:= Value = sbt_ContryDef_NL;
end;

procedure TAmEnum_ContryDef.SetNL;
begin
   Value:= sbt_ContryDef_NL;
end;

function TAmEnum_ContryDef.IsPL:boolean;
begin
   Result:= Value = sbt_ContryDef_PL;
end;

procedure TAmEnum_ContryDef.SetPL;
begin
   Value:= sbt_ContryDef_PL;
end;

function TAmEnum_ContryDef.IsKG:boolean;
begin
   Result:= Value = sbt_ContryDef_KG;
end;

procedure TAmEnum_ContryDef.SetKG;
begin
   Value:= sbt_ContryDef_KG;
end;

function TAmEnum_ContryDef.IsGE:boolean;
begin
   Result:= Value = sbt_ContryDef_GE;
end;

procedure TAmEnum_ContryDef.SetGE;
begin
   Value:= sbt_ContryDef_GE;
end;

function TAmEnum_ContryDef.IsUSA:boolean;
begin
   Result:= Value = sbt_ContryDef_USA;
end;

procedure TAmEnum_ContryDef.SetUSA;
begin
   Value:= sbt_ContryDef_USA;
end;

function TAmEnum_ContryDef.IsUSA2:boolean;
begin
   Result:= Value = sbt_ContryDef_USA2;
end;

procedure TAmEnum_ContryDef.SetUSA2;
begin
   Value:= sbt_ContryDef_USA2;
end;

//end TAmEnum_ContryDef | основной помошник H1 enum (функции Is и другое)
{$ENDREGION}

{$REGION 'TAmEnum_ContryDef | доп помошник H2 enum (функции Typ)'}
function  TAmEnum_ContryDef.TypGetMin:TAmEnum_enum_ContryDef;
begin
   Result:= TAmEnum_enum_ContryDef(0);
end;

function  TAmEnum_ContryDef.TypGetMax:TAmEnum_enum_ContryDef;
begin
   Result:= TAmEnum_enum_ContryDef(self.TypCount-1);
end;

procedure TAmEnum_ContryDef.TypSetMin;
begin
   Value:=  TypGetMin;
end;
procedure TAmEnum_ContryDef.TypSetMax;
begin
    Value:=  TypGetMax;
end;

procedure TAmEnum_ContryDef.TypClear;
begin
    TypSetMin;
end;

function  TAmEnum_ContryDef.TypGetStr:string;
begin
   Result:= AmRecordHlp.EnumToStr(Value);
end;

function  TAmEnum_ContryDef.TypGetInt:integer;
begin
   Result:=  Integer(ord(Value));
end;

function  TAmEnum_ContryDef.TypSetStr(S:string):boolean;
begin
    Result:=TypSetInt(AmRecordHlp.EnumStrToInt<TAmEnum_enum_ContryDef>(S));
end;

function  TAmEnum_ContryDef.TypSetInt(S:integer):boolean;
begin
   Result:= (S>=0) and (S<self.TypCount);
   if Result then  Value:=TAmEnum_enum_ContryDef(S);
end;

function  TAmEnum_ContryDef.TypInc:boolean;
var S:SmallInt;
begin
     S:=ord(Value);
     Result:= S<TypCount-1;
     if Result then
     begin
      inc(S);
      Value:=  TAmEnum_enum_ContryDef(S);
     end;
end;

function  TAmEnum_ContryDef.TypDec:boolean;
var S:SmallInt;
begin
     S:=ord(Value);
     Result:= S>0;
     if Result then
     begin
      dec(S);
      Value:=  TAmEnum_enum_ContryDef(S);
     end;

end;

procedure TAmEnum_ContryDef.TypToListAdd(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(AmRecordHlp.EnumToStr(TAmEnum_enum_ContryDef(i)));
end;

procedure TAmEnum_ContryDef.TypToList(L:TStrings);
begin
    L.Clear;
    TypToListAdd(L);
end;

// end TAmEnum_ContryDef | доп помошник H2 enum (функции Typ)
{$ENDREGION}


// end TAmEnum_ContryDef
{$ENDREGION}


{$REGION 'TAmEnum_CurrencyDef'}
{$REGION 'TAmEnum_CurrencyDef | sENG'}
function TAmEnum_CurrencyDef.SetSENG(S:string):boolean;
var i:integer;
begin
   Result:= false;
   Value:= TAmEnum_enum_CurrencyDef(0);
   for I := 1 to TypCount-1 do
   if S=sENG[TAmEnum_enum_CurrencyDef(i)] then
   begin
      Value:= TAmEnum_enum_CurrencyDef(i);
      Result:=true;
      break;
   end;
end;

function TAmEnum_CurrencyDef.GetSENG:string;
begin
   Result:= sENG[Value];
end;

procedure TAmEnum_CurrencyDef.ToListAddsENG(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(sENG[TAmEnum_enum_CurrencyDef(i)]);
end;
procedure TAmEnum_CurrencyDef.ToListsENG(L:TStrings);
begin
   L.Clear;
   ToListAddsENG(L);
end;

// end TAmEnum_CurrencyDef | sENG
{$ENDREGION}
{$REGION 'TAmEnum_CurrencyDef | sRu'}
function TAmEnum_CurrencyDef.SetSRu(S:string):boolean;
var i:integer;
begin
   Result:= false;
   Value:= TAmEnum_enum_CurrencyDef(0);
   for I := 1 to TypCount-1 do
   if S=sRu[TAmEnum_enum_CurrencyDef(i)] then
   begin
      Value:= TAmEnum_enum_CurrencyDef(i);
      Result:=true;
      break;
   end;
end;

function TAmEnum_CurrencyDef.GetSRu:string;
begin
   Result:= sRu[Value];
end;

procedure TAmEnum_CurrencyDef.ToListAddsRu(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(sRu[TAmEnum_enum_CurrencyDef(i)]);
end;
procedure TAmEnum_CurrencyDef.ToListsRu(L:TStrings);
begin
   L.Clear;
   ToListAddsRu(L);
end;

// end TAmEnum_CurrencyDef | sRu
{$ENDREGION}
{$REGION 'TAmEnum_CurrencyDef | zENG'}
function TAmEnum_CurrencyDef.SetZENG(S:string):boolean;
var i:integer;
begin
   Result:= false;
   Value:= TAmEnum_enum_CurrencyDef(0);
   for I := 1 to TypCount-1 do
   if S=zENG[TAmEnum_enum_CurrencyDef(i)] then
   begin
      Value:= TAmEnum_enum_CurrencyDef(i);
      Result:=true;
      break;
   end;
end;

function TAmEnum_CurrencyDef.GetZENG:string;
begin
   Result:= zENG[Value];
end;

procedure TAmEnum_CurrencyDef.ToListAddzENG(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(zENG[TAmEnum_enum_CurrencyDef(i)]);
end;
procedure TAmEnum_CurrencyDef.ToListzENG(L:TStrings);
begin
   L.Clear;
   ToListAddzENG(L);
end;

// end TAmEnum_CurrencyDef | zENG
{$ENDREGION}
{$REGION 'TAmEnum_CurrencyDef | основной помошник H1 enum (функции Is и другое)'}
function TAmEnum_CurrencyDef.TypIsValid:boolean;
begin
   Result:= Value <> sbt_CurrencyDef_none;
end;

function TAmEnum_CurrencyDef.TypCount:integer;
begin
   Result:= Integer(System.High(TAmEnum_enum_CurrencyDef))+1;
end;


function TAmEnum_CurrencyDef.IsUSD:boolean;
begin
   Result:= Value = sbt_CurrencyDef_USD;
end;

procedure TAmEnum_CurrencyDef.SetUSD;
begin
   Value:= sbt_CurrencyDef_USD;
end;

function TAmEnum_CurrencyDef.IsEUR:boolean;
begin
   Result:= Value = sbt_CurrencyDef_EUR;
end;

procedure TAmEnum_CurrencyDef.SetEUR;
begin
   Value:= sbt_CurrencyDef_EUR;
end;

function TAmEnum_CurrencyDef.IsRUB:boolean;
begin
   Result:= Value = sbt_CurrencyDef_RUB;
end;

procedure TAmEnum_CurrencyDef.SetRUB;
begin
   Value:= sbt_CurrencyDef_RUB;
end;

function TAmEnum_CurrencyDef.IsBYN:boolean;
begin
   Result:= Value = sbt_CurrencyDef_BYN;
end;

procedure TAmEnum_CurrencyDef.SetBYN;
begin
   Value:= sbt_CurrencyDef_BYN;
end;

function TAmEnum_CurrencyDef.IsPLN:boolean;
begin
   Result:= Value = sbt_CurrencyDef_PLN;
end;

procedure TAmEnum_CurrencyDef.SetPLN;
begin
   Value:= sbt_CurrencyDef_PLN;
end;

function TAmEnum_CurrencyDef.IsBTC:boolean;
begin
   Result:= Value = sbt_CurrencyDef_BTC;
end;

procedure TAmEnum_CurrencyDef.SetBTC;
begin
   Value:= sbt_CurrencyDef_BTC;
end;

function TAmEnum_CurrencyDef.IsETH:boolean;
begin
   Result:= Value = sbt_CurrencyDef_ETH;
end;

procedure TAmEnum_CurrencyDef.SetETH;
begin
   Value:= sbt_CurrencyDef_ETH;
end;

function TAmEnum_CurrencyDef.IsBNB:boolean;
begin
   Result:= Value = sbt_CurrencyDef_BNB;
end;

procedure TAmEnum_CurrencyDef.SetBNB;
begin
   Value:= sbt_CurrencyDef_BNB;
end;

function TAmEnum_CurrencyDef.IsTRX:boolean;
begin
   Result:= Value = sbt_CurrencyDef_TRX;
end;

procedure TAmEnum_CurrencyDef.SetTRX;
begin
   Value:= sbt_CurrencyDef_TRX;
end;

function TAmEnum_CurrencyDef.IsXRP:boolean;
begin
   Result:= Value = sbt_CurrencyDef_XRP;
end;

procedure TAmEnum_CurrencyDef.SetXRP;
begin
   Value:= sbt_CurrencyDef_XRP;
end;

//end TAmEnum_CurrencyDef | основной помошник H1 enum (функции Is и другое)
{$ENDREGION}

{$REGION 'TAmEnum_CurrencyDef | доп помошник H2 enum (функции Typ)'}
function  TAmEnum_CurrencyDef.TypGetMin:TAmEnum_enum_CurrencyDef;
begin
   Result:= TAmEnum_enum_CurrencyDef(0);
end;

function  TAmEnum_CurrencyDef.TypGetMax:TAmEnum_enum_CurrencyDef;
begin
   Result:= TAmEnum_enum_CurrencyDef(self.TypCount-1);
end;

procedure TAmEnum_CurrencyDef.TypSetMin;
begin
   Value:=  TypGetMin;
end;
procedure TAmEnum_CurrencyDef.TypSetMax;
begin
    Value:=  TypGetMax;
end;

procedure TAmEnum_CurrencyDef.TypClear;
begin
    TypSetMin;
end;

function  TAmEnum_CurrencyDef.TypGetStr:string;
begin
   Result:= AmRecordHlp.EnumToStr(Value);
end;

function  TAmEnum_CurrencyDef.TypGetInt:integer;
begin
   Result:=  Integer(ord(Value));
end;

function  TAmEnum_CurrencyDef.TypSetStr(S:string):boolean;
begin
    Result:=TypSetInt(AmRecordHlp.EnumStrToInt<TAmEnum_enum_CurrencyDef>(S));
end;

function  TAmEnum_CurrencyDef.TypSetInt(S:integer):boolean;
begin
   Result:= (S>=0) and (S<self.TypCount);
   if Result then  Value:=TAmEnum_enum_CurrencyDef(S);
end;

function  TAmEnum_CurrencyDef.TypInc:boolean;
var S:SmallInt;
begin
     S:=ord(Value);
     Result:= S<TypCount-1;
     if Result then
     begin
      inc(S);
      Value:=  TAmEnum_enum_CurrencyDef(S);
     end;
end;

function  TAmEnum_CurrencyDef.TypDec:boolean;
var S:SmallInt;
begin
     S:=ord(Value);
     Result:= S>0;
     if Result then
     begin
      dec(S);
      Value:=  TAmEnum_enum_CurrencyDef(S);
     end;

end;

procedure TAmEnum_CurrencyDef.TypToListAdd(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(AmRecordHlp.EnumToStr(TAmEnum_enum_CurrencyDef(i)));
end;

procedure TAmEnum_CurrencyDef.TypToList(L:TStrings);
begin
    L.Clear;
    TypToListAdd(L);
end;

// end TAmEnum_CurrencyDef | доп помошник H2 enum (функции Typ)
{$ENDREGION}


// end TAmEnum_CurrencyDef
{$ENDREGION}





{$REGION 'TvksFun_unittime'}
function TAmEnum_unittime.ToSeconds(V:Int64;valueDef:TAmEnum_enum_unittime=vks_fun_unittime_seconds):Int64;
begin
      result:=0;
      if not TypIsValid then
       value:=valueDef;
       case value of
             vks_fun_unittime_none,
             vks_fun_unittime_seconds:begin
               Value:=vks_fun_unittime_seconds;
               Result:= V;
             end;
             vks_fun_unittime_milliseconds  : result :=  V div self.i_sec_milliseconds;
             vks_fun_unittime_minutes       : result :=  V * self.i_sec_minutes;
             vks_fun_unittime_hours         : result :=  V * self.i_sec_hours;
             vks_fun_unittime_days          : result :=  V * self.i_sec_days;
             vks_fun_unittime_weeks         : result :=  V * self.i_sec_weeks;
             vks_fun_unittime_moth          : result :=  V * self.i_sec_moth;
       end;
end;
function TAmEnum_unittime.ToMilliSeconds(V:Int64;valueDef:TAmEnum_enum_unittime=vks_fun_unittime_seconds):Int64;
begin
      result:=0;
      if not TypIsValid then
       value:=valueDef;
       case value of
             vks_fun_unittime_none,
             vks_fun_unittime_seconds:begin
               Value:=vks_fun_unittime_seconds;
               Result:= V * self.i_sec_milliseconds;
             end;
             vks_fun_unittime_milliseconds  : result :=  V ;
             vks_fun_unittime_minutes       : result :=  V * self.i_sec_minutes * i_sec_milliseconds;
             vks_fun_unittime_hours         : result :=  V * self.i_sec_hours  * i_sec_milliseconds;
             vks_fun_unittime_days          : result :=  V * self.i_sec_days   * i_sec_milliseconds;
             vks_fun_unittime_weeks         : result :=  V * self.i_sec_weeks  * i_sec_milliseconds;
             vks_fun_unittime_moth          : result :=  V * self.i_sec_moth   * i_sec_milliseconds;
       end;
end;
function TAmEnum_unittime.ToMinutes(V:Int64;valueDef:TAmEnum_enum_unittime=vks_fun_unittime_seconds):Int64;
begin
      result:=0;
      if not TypIsValid then
       value:=valueDef;
       case value of
             vks_fun_unittime_none,
             vks_fun_unittime_seconds:begin
               Value:=vks_fun_unittime_seconds;
               Result:= V * self.i_sec_minutes;
             end;
             vks_fun_unittime_milliseconds  : result :=  V div (i_sec_minutes*i_sec_milliseconds);
             vks_fun_unittime_minutes       : result :=  V ;
             vks_fun_unittime_hours         : result :=  V * i_sec_minutes;
             vks_fun_unittime_days          : result :=  V * (i_sec_days div i_sec_minutes);
             vks_fun_unittime_weeks         : result :=  V *  (i_sec_weeks div i_sec_minutes);
             vks_fun_unittime_moth          : result :=  V *  (i_sec_moth div i_sec_minutes);
       end;
end;
function TAmEnum_unittime.ToHours(V:Int64;valueDef:TAmEnum_enum_unittime=vks_fun_unittime_seconds):Int64;
begin
      result:=0;
      if not TypIsValid then
       value:=valueDef;
       case value of
             vks_fun_unittime_none,
             vks_fun_unittime_seconds:begin
               Value:=vks_fun_unittime_seconds;
               Result:= V div i_sec_hours;
             end;
             vks_fun_unittime_milliseconds  : result :=  V div (i_sec_hours*i_sec_milliseconds);
             vks_fun_unittime_minutes       : result :=  V div i_sec_minutes;
             vks_fun_unittime_hours         : result :=  V ;
             vks_fun_unittime_days          : result :=  V * (i_sec_days div i_sec_hours);
             vks_fun_unittime_weeks         : result :=  V *  (i_sec_weeks div i_sec_hours);
             vks_fun_unittime_moth          : result :=  V *  (i_sec_moth div i_sec_hours);
       end;
end;

{$REGION 'TvksFun_unittime | Str'}
function TAmEnum_unittime.SetStr(S:string):boolean;
var i:integer;
begin
   Result:= false;
   Value:= TAmEnum_enum_unittime(0);
   for I := 1 to TypCount-1 do
   if S=Str[TAmEnum_enum_unittime(i)] then
   begin
      Value:= TAmEnum_enum_unittime(i);
      Result:=true;
      break;
   end;
end;

function TAmEnum_unittime.GetStr:string;
begin
   Result:= Str[Value];
end;

procedure TAmEnum_unittime.ToListAddStr(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(Str[TAmEnum_enum_unittime(i)]);
end;
procedure TAmEnum_unittime.ToListStr(L:TStrings);
begin
   L.Clear;
   ToListAddStr(L);
end;

// end TvksFun_unittime | Str
{$ENDREGION}
{$REGION 'TvksFun_unittime | StrRuShort'}
function TAmEnum_unittime.SetStrRuShort(S:string):boolean;
var i:integer;
begin
   Result:= false;
   Value:= TAmEnum_enum_unittime(0);
   for I := 1 to TypCount-1 do
   if S=StrRuShort[TAmEnum_enum_unittime(i)] then
   begin
      Value:= TAmEnum_enum_unittime(i);
      Result:=true;
      break;
   end;
end;

function TAmEnum_unittime.GetStrRuShort:string;
begin
   Result:= StrRuShort[Value];
end;

procedure TAmEnum_unittime.ToListAddStrRuShort(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(StrRuShort[TAmEnum_enum_unittime(i)]);
end;
procedure TAmEnum_unittime.ToListStrRuShort(L:TStrings);
begin
   L.Clear;
   ToListAddStrRuShort(L);
end;

// end TvksFun_unittime | StrRuShort
{$ENDREGION}
{$REGION 'TvksFun_unittime | StrRuLong'}
function TAmEnum_unittime.SetStrRuLong(S:string):boolean;
var i:integer;
begin
   Result:= false;
   Value:= TAmEnum_enum_unittime(0);
   for I := 1 to TypCount-1 do
   if S=StrRuLong[TAmEnum_enum_unittime(i)] then
   begin
      Value:= TAmEnum_enum_unittime(i);
      Result:=true;
      break;
   end;
end;

function TAmEnum_unittime.GetStrRuLong:string;
begin
   Result:= StrRuLong[Value];
end;

procedure TAmEnum_unittime.ToListAddStrRuLong(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(StrRuLong[TAmEnum_enum_unittime(i)]);
end;
procedure TAmEnum_unittime.ToListStrRuLong(L:TStrings);
begin
   L.Clear;
   ToListAddStrRuLong(L);
end;

// end TvksFun_unittime | StrRuLong
{$ENDREGION}
{$REGION 'TvksFun_unittime | IntSec'}
function TAmEnum_unittime.SetIntSec(S:integer):boolean;
var i:integer;
begin
   Result:= false;
   Value:= TAmEnum_enum_unittime(0);
   for I := 1 to TypCount-1 do
   if S=IntSec[TAmEnum_enum_unittime(i)] then
   begin
      Value:= TAmEnum_enum_unittime(i);
      Result:=true;
      break;
   end;
end;

function TAmEnum_unittime.GetIntSec:integer;
begin
   Result:= IntSec[Value];
end;

procedure TAmEnum_unittime.ToListAddIntSec(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(IntSec[TAmEnum_enum_unittime(i)].ToString);
end;
procedure TAmEnum_unittime.ToListIntSec(L:TStrings);
begin
   L.Clear;
   ToListAddIntSec(L);
end;

// end TvksFun_unittime | IntSec
{$ENDREGION}
{$REGION 'TvksFun_unittime | основной помошник H1 enum (функции Is и другое)'}
function TAmEnum_unittime.TypIsValid:boolean;
begin
   Result:= Value <> vks_fun_unittime_none;
end;

function TAmEnum_unittime.TypCount:integer;
begin
   Result:= Integer(System.High(TAmEnum_enum_unittime))+1;
end;


function TAmEnum_unittime.IsMilliseconds:boolean;
begin
   Result:= Value = vks_fun_unittime_milliseconds;
end;

procedure TAmEnum_unittime.SetMilliseconds;
begin
   Value:= vks_fun_unittime_milliseconds;
end;

function TAmEnum_unittime.IsSeconds:boolean;
begin
   Result:= Value = vks_fun_unittime_seconds;
end;

procedure TAmEnum_unittime.SetSeconds;
begin
   Value:= vks_fun_unittime_seconds;
end;

function TAmEnum_unittime.IsMinutes:boolean;
begin
   Result:= Value = vks_fun_unittime_minutes;
end;

procedure TAmEnum_unittime.SetMinutes;
begin
   Value:= vks_fun_unittime_minutes;
end;

function TAmEnum_unittime.IsHours:boolean;
begin
   Result:= Value = vks_fun_unittime_hours;
end;

procedure TAmEnum_unittime.SetHours;
begin
   Value:= vks_fun_unittime_hours;
end;

function TAmEnum_unittime.IsDays:boolean;
begin
   Result:= Value = vks_fun_unittime_days;
end;

procedure TAmEnum_unittime.SetDays;
begin
   Value:= vks_fun_unittime_days;
end;

function TAmEnum_unittime.IsWeeks:boolean;
begin
   Result:= Value = vks_fun_unittime_weeks;
end;

procedure TAmEnum_unittime.SetWeeks;
begin
   Value:= vks_fun_unittime_weeks;
end;

function TAmEnum_unittime.IsMoth:boolean;
begin
   Result:= Value = vks_fun_unittime_moth;
end;

procedure TAmEnum_unittime.SetMoth;
begin
   Value:= vks_fun_unittime_moth;
end;

//end TvksFun_unittime | основной помошник H1 enum (функции Is и другое)
{$ENDREGION}

{$REGION 'TvksFun_unittime | доп помошник H2 enum (функции Typ)'}
function  TAmEnum_unittime.TypGetMin:TAmEnum_enum_unittime;
begin
   Result:= TAmEnum_enum_unittime(0);
end;

function  TAmEnum_unittime.TypGetMax:TAmEnum_enum_unittime;
begin
   Result:= TAmEnum_enum_unittime(self.TypCount-1);
end;

procedure TAmEnum_unittime.TypSetMin;
begin
   Value:=  TypGetMin;
end;
procedure TAmEnum_unittime.TypSetMax;
begin
    Value:=  TypGetMax;
end;

procedure TAmEnum_unittime.TypClear;
begin
    TypSetMin;
end;

function  TAmEnum_unittime.TypGetStr:string;
begin
   Result:= AmRecordHlp.EnumToStr(Value);
end;

function  TAmEnum_unittime.TypGetInt:integer;
begin
   Result:=  Integer(ord(Value));
end;

function  TAmEnum_unittime.TypSetStr(S:string):boolean;
begin
    Result:=TypSetInt(AmRecordHlp.EnumStrToInt<TAmEnum_enum_unittime>(S));
end;

function  TAmEnum_unittime.TypSetInt(S:integer):boolean;
begin
   Result:= (S>=0) and (S<self.TypCount);
   if Result then  Value:=TAmEnum_enum_unittime(S);
end;

function  TAmEnum_unittime.TypInc:boolean;
var S:SmallInt;
begin
     S:=ord(Value);
     Result:= S<TypCount-1;
     if Result then
     begin
      inc(S);
      Value:=  TAmEnum_enum_unittime(S);
     end;
end;

function  TAmEnum_unittime.TypDec:boolean;
var S:SmallInt;
begin
     S:=ord(Value);
     Result:= S>0;
     if Result then
     begin
      dec(S);
      Value:=  TAmEnum_enum_unittime(S);
     end;

end;

procedure TAmEnum_unittime.TypToListAdd(L:TStrings);
var
  I: Integer;
begin
    for I := 1 to self.TypCount-1 do
    L.Add(AmRecordHlp.EnumToStr(TAmEnum_enum_unittime(i)));
end;

procedure TAmEnum_unittime.TypToList(L:TStrings);
begin
    L.Clear;
    TypToListAdd(L);
end;

// end TvksFun_unittime | доп помошник H2 enum (функции Typ)
{$ENDREGION}


// end TvksFun_unittime
{$ENDREGION}

end.
