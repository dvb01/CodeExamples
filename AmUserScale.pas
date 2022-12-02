unit AmUserScale;


interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Math;
 type
  TAmPosControl = record
    L,//left
    T,//top
    W,//ширина
    H,//высота
    F:Integer;//TFont.Size
    procedure Clear;

  end;

  AmScale = class
    private
      class procedure SetScaleAppCustom(New,Old:integer);
    public
     //хранит значение  маштаба по умолчанию
     //  AppScaleDesing рекомедую выстовить в 100 при создании формы а не здесь
     //  WinScaleDPIDesing рекомедую выстовить в 96 при создании формы что равно WinApi.Windows.USER_DEFAULT_SCREEN_DPI  а не здесь
     // эти значения нужно выставить после AmScale.Init;

     //если вы разрабатываете прогу и у вас на компе глобальный маштаб 120 то его и установите по умолчанию в WinScaleDPIDesing
     // если у вас всегда глобальный маштаб 96 то ничего устанавливать не нужно см initialization и  AmScale.Init;

      class var AppScaleDesing:Integer; //  какой маштаб был на этапе разработки
      class var AppScaleNow:Integer;    //какой маштаб сейчас в приложении
      class var WinScaleDPIDesing:Integer; //какой глобальный маштаб системы был  на этапе разработки
      class var WinScaleDPINow:Integer; //какой глобальный маштаб системы сейчас в приложении
      class var IsInit:boolean;     //Init была выполнены
      class var IsShow:boolean;     //Show была выполнены
      class var IsShowning:boolean; // сейчас выполняется Show
      class var IsAppScaled:boolean; // сейчас выполняется SetScaleAppCustom
      class var IsWinScaled:boolean; // сейчас выполняется WinScaled есть 2 события на форме к ним подключится FormAfterMonitorDpiChanged FormBeforeMonitorDpiChanged

      // при создании главной формы запустить Init
      // можно передать параметр сохраненного маштаба приложения например с какой то базы данных
      // это процент от 30 до 200 обычно это 100 процентов от размера приложения на этапе разработки
      class procedure Init(ASavedProcent:Integer=100);

      // в собыитии FormShow запустить Show
      class procedure Show;
      //  запустить в событии главной формы FormBeforeMonitorDpiChanged
      // проиходит когда в системе глобально меняется маштаб
      class procedure BeforeMonitorDpiChanged(NewDPI,OldDPI:integer);
      //  запустить в событии главной формы FormAfterMonitorDpiChanged
      // проиходит когда в системе глобально меняется маштаб
      class procedure AfterMonitorDpiChanged(NewDPI,OldDPI:integer);

      //.............................................................
      // Dinamic использовать для динамически создоваемых контролов
      // вначале контролу установить parent а потом value
      // получить новое значение размера для числа val смотрите ниже описание
      // если кратко то  P:=Tpanel.create(self); P.height:=  AmScale.DinamicValue(88);
      class function DinamicValue(val:integer;ForControl:TControl=nil):integer; static;
      //для font.Height := AmScale.DinamicValueFontSize(10);
      // получилось сделать только для font.Height c входным параметром  Font.Size
      // т.к все уперается в матиматику  округления  маленький диапозон  Font.Size  и формулу Font.Size и  font.Height
      class function DinamicValueFontHeight(FontSize:integer;ForControl:TControl=nil):integer; static;
     // .........................................................


      // value с плавающей запятой
      class function DinamicValueNoRound(val:Double;ForControl:TControl=nil):Double; static;

      // если не использовали для каждого значения DinamicValue
      // то по окнчанию создания контрола вызвать
      // DinamicScaleApp это маштаб приложения
      // DinamicScaleWin глобальный маштаб
      class procedure DinamicScaleApp(Control:TWinControl); static;
      class procedure DinamicScaleWin(Control:TWinControl); static;

       // что бы font не был огромным можно его скоректировать
      class function DinamicValueFontSizeCorrect(val:integer):integer; static;

      // конвертация font для текущего маштаба
      class function FontSizeToHeight(val:integer):integer; static;
      class function FontHeightToSize(val:integer):integer; static;



      // ChangeScaleValue
      // есть случаи когда в вами написаном контроле есть какие то переменные
      // которые не изменяются при изменении маштаба хотя в вашей логике это заложено
      // например некая переменная ширины другого контрола в текущем или какая константа высоты всех элементов скрол бокса
      // в этот случаи в этот контроле нужно в protected перегрузить процедуру
      {
        protected
             procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
      }
      // и посчитать новое значение
      {
        inherited;
        HTest:= AmScale.ChangeScaleValue(HTest,M, D);
      }
      class function ChangeScaleValue(valOld:integer;M, D: Integer):integer; static;


      // если хотим поменять мастаб всего приложения  SetScaleApp(120,100) увеличится на 20%
      class procedure SetScaleApp(New:integer;Old:integer=0);

      // получить список для юзера возможных маштабов приложения
      class procedure GetAppToList(L:TStrings);

      // у вас есть значение но не знаете индек его в списке  = найдите
      class function GetIndexFromList(L:TStrings;value:integer=0):integer;

      // получить значение с строки которая была  получена в GetAppToList
      class function GetValueFromStr(S:String):integer;
      // изменить маштаб когда юзер выбрал новое значение из списка
      class procedure SetAppFromListInt(New:Integer);
      //передать одну линию со списка полученного в GetAppToList
      class procedure SetAppFromList(S:String);
  end;

  function UserMainScale(val:integer):integer;
  function AmScaleV(ValuePosition:integer;ForControl:TControl=nil):integer;
  function AmScaleD(ValuePosition:Double;ForControl:TControl=nil):Double;
  function AmScaleF(FontSize:integer;ForControl:TControl=nil):integer;
{
  ЭТО СТАРОЕ ОПИСАНИЕ СМЫСЛ ТОТ ЖЕ просто имена процедур изменены

  получает маштаб экрана у пользователя на форм create занести значение в UserMainScaleGetConst

 где
 Width_now это ширина формы когда програ запускается
 Width_debag это ширина формы на этапе разработки
 в ответ приходит процент изменения , т.е маштаб
USER_MAIN_SCALE_CREATE:= UserMainScaleGetConst(MyForm.Width,500);
USER_MAIN_SCALE_CREATE хранит текуший маштаб наример 125.67 но обычно 100

далее если создаем компоненты диначимичеки то указываем ширину и высоту и отступы как
P:=Tpanel.create(self);
P.parent:=self;
P.height:=  UserMainScale(88);  //хотя раньше бы писали как  P.height:=  88;
P.font.size:=  UserMainScale(10);


  небольшое замечание по динамическому созданию котролов
  после TWinControl.Create
  и до уставновки Parent
  нужно ставить значения высот обычно т.е
  P:=TPanel.Create(self);
  P.ParentFont:=false;
  P.parent:=self;
  после установки  Parent
  P.height:=  UserMainScale(88);
  P.Font.Height := AmScale.DinamicValueFontHeight(8); 8 это Forn.Size
}

implementation
 type TLocContrrol =class(TControl);

procedure TAmPosControl.Clear;
begin
    L:=0;//left
    T:=0;//top
    W:=0;//ширина
    H:=0;//высота
    F:=0;//TFont.Size
end;





{ AmScale }
function UserMainScale(val:integer):integer;
begin
   Result:=AmScale.DinamicValue(val);
end;
function AmScaleV(ValuePosition:integer;ForControl:TControl=nil):integer;
begin
   Result:=AmScale.DinamicValue(ValuePosition,ForControl);
end;
function AmScaleD(ValuePosition:Double;ForControl:TControl=nil):Double;
begin
   Result:=AmScale.DinamicValueNoRound(ValuePosition,ForControl);
end;
function AmScaleF(FontSize:integer;ForControl:TControl=nil):integer;
begin
  Result:=AmScale.DinamicValueFontHeight(FontSize,ForControl);
end;
class procedure AmScale.GetAppToList(L: TStrings);
begin
    L.Clear;
    if not IsInit then exit;
   // L.Add('50 %');
    L.Add('75 %');
   // L.Add('85 %');
    L.Add('100 % (рекомедуется)');
   // L.Add('115 %');
    L.Add('125 %');
    L.Add('150 %');
    L.Add('175 %');
    L.Add('200 %');
end;
class function AmScale.GetIndexFromList(L: TStrings; value: integer=0): integer;
begin
    Result:=-1;
    if not IsInit then exit;
    if value<30 then
    value:= AppScaleNow;
    for Result := 0 to L.Count-1 do
    if GetValueFromStr(L[Result]) = value then exit;
    Result:=-1;
end;

class function AmScale.GetValueFromStr(S: String): integer;
var tok:integer;
begin
    Result:=0;
    if not IsInit then exit;
    tok:=  pos(' ',S);
    if (tok<>1) and (tok<>0) then
    begin
       S:=s.Split([' '])[0];
       TryStrToInt(S,Result);
    end;
end;

class procedure AmScale.SetAppFromList(S: String);
begin
    if not IsInit then exit;
    SetAppFromListInt(GetValueFromStr(S));
end;
class procedure AmScale.SetAppFromListInt(New: Integer);
begin
   if not IsInit then exit;
   SetScaleApp(New,AppScaleNow);
end;

class procedure AmScale.SetScaleApp(New:integer;Old:integer=0);
begin
   if not IsInit then exit;
   if New<30 then exit;
   if Old<30 then
   Old:= AppScaleNow;
   if Old<30 then exit;

   if New<>AppScaleNow then
   begin
       AppScaleNow:= New;
       SetScaleAppCustom(New,Old);
   end;
end;
class procedure AmScale.SetScaleAppCustom(New, Old: integer);
var i:integer;
begin
    if IsAppScaled then exit;    
    IsAppScaled:=true;
    try
     for  I := 0 to Screen.FormCount-1 do
     Screen.Forms[i].ScaleBy(New,Old);
    finally
       IsAppScaled:=false;
    end;
end;

class procedure AmScale.Show;
begin
    if not IsInit then exit;

    if not IsShow then
    begin
      IsShow:=true;
      if IsShowning then exit;
      
      IsShowning:=true;
      try

         SetScaleAppCustom(AppScaleNow,AppScaleDesing);
      finally
         IsShowning:=false;
      end;

    end;


end;

class procedure AmScale.BeforeMonitorDpiChanged(NewDPI,OldDPI:integer);
begin
  IsWinScaled:=true;
  WinScaleDPINow:= NewDPI;
end;
class procedure AmScale.AfterMonitorDpiChanged(NewDPI, OldDPI: integer);
begin
   WinScaleDPINow:= NewDPI;
   IsWinScaled:=false;
end;
class procedure AmScale.Init(ASavedProcent:Integer=100);
var LMonitor:TMonitor;
//    LForm: TForm;
//    LPlacement: TWindowPlacement;
begin
      if ASavedProcent<=30 then
      ASavedProcent:=100;
      if ASavedProcent<30 then  ASavedProcent:=30;
      if ASavedProcent>300 then  ASavedProcent:=300;

      AppScaleDesing:=100;
      AppScaleNow:=ASavedProcent;



      WinScaleDPINow:=USER_DEFAULT_SCREEN_DPI;
      WinScaleDPIDesing:=USER_DEFAULT_SCREEN_DPI;

      if (Application<>nil) and (Screen<>nil) then
      begin
        LMonitor := Screen.MonitorFromWindow(Application.Handle);
        if LMonitor <> nil then
          WinScaleDPINow := LMonitor.PixelsPerInch
        else
         WinScaleDPINow := Screen.PixelsPerInch;
         {
        LForm := Application.MainForm;
        if (LForm <> nil)  then
        WinScaleDPIDesing := LForm.PixelsPerInch;
        }


      end
      else if (Screen<>nil) and (Mouse<>nil) then
      begin
        LMonitor := Screen.MonitorFromPoint(Mouse.CursorPos);
        if LMonitor <> nil then
          WinScaleDPINow := LMonitor.PixelsPerInch
        else
         WinScaleDPINow := Screen.PixelsPerInch;
         {
        LForm := Application.MainForm;
        if (LForm <> nil)  then
        WinScaleDPIDesing := LForm.PixelsPerInch;
        }
      end;


      IsInit:=true;

      //ScaleForPPI(GetParentCurrentDpi);

end;



class procedure AmScale.DinamicScaleWin(Control: TWinControl);
begin
   if not IsInit then exit;
   if (Control.Parent<>nil) and (WinScaleDPINow<>WinScaleDPIDesing)  then
   Control.ScaleBy(WinScaleDPINow,WinScaleDPIDesing);
end;
class procedure AmScale.DinamicScaleApp(Control: TWinControl);
begin
    if not IsInit then exit;
    if IsShow and (AppScaleNow<>AppScaleDesing) then
    Control.ScaleBy(AppScaleNow,AppScaleDesing);
end;


function __ControlWindowCreate(Control:TControl):boolean;
begin
   Result:=false;
   if Assigned(Control) then
   begin
       if Control is TWinControl then
          Result:=  TWinControl(Control).HandleAllocated
       else if Control.Parent <> nil then
          Result:= Control.Parent.HandleAllocated;
   end;

end;
class function AmScale.DinamicValue(val: integer;ForControl:TControl=nil): integer;
begin
    Result:= val;
    if not IsInit then exit;
    if Assigned(ForControl) and not  __ControlWindowCreate(ForControl) then  exit;

    if  (WinScaleDPINow<>WinScaleDPIDesing) then
    Result:=MulDiv(Result,WinScaleDPINow,WinScaleDPIDesing);

    if IsShow and (AppScaleNow<>AppScaleDesing) then
    Result:=MulDiv(Result,AppScaleNow,AppScaleDesing);

end;
class function AmScale.DinamicValueNoRound(val:Double;ForControl:TControl=nil):Double;
begin
    Result:= val;
    if not IsInit then exit;
    if Assigned(ForControl) and not  __ControlWindowCreate(ForControl) then  exit;

    if  (WinScaleDPINow<>WinScaleDPIDesing) then
    Result:=Result*WinScaleDPINow/WinScaleDPIDesing;

    if IsShow and (AppScaleNow<>AppScaleDesing) then
    Result:=Result*AppScaleNow/AppScaleDesing;

end;

class function AmScale.DinamicValueFontHeight(FontSize: integer;ForControl:TControl=nil): integer;
var D,N:integer;
//r:real;
begin
    if not IsInit then
    begin
        Result:=FontSizeToHeight(FontSize);
        exit;
    end;
    if Assigned(ForControl) and not  __ControlWindowCreate(ForControl) then
    begin
      Result:=FontSizeToHeight(FontSize);
      exit;
    end;
//    D:=WinScaleDPIDesing;


    D:=WinScaleDPIDesing;
    N:=WinScaleDPINow;
    Result:=-MulDiv(FontSize, D ,72); // convert Font.Size to Font.Height

    if  (N<>D) then
    Result:=MulDiv(Result,N,D);

    if IsShow and (AppScaleNow<>AppScaleDesing) then
    begin
       Result:=MulDiv(Result,AppScaleNow,AppScaleDesing);
     //  Result := -MulDiv(Result, 72, Screen.PixelsPerInch);
      // Result:=-MulDiv(val, Screen.PixelsPerInch ,72);
      // Result:=MulDiv(Result,AppScaleNow,AppScaleDesing);
      //Result:=-20;
    end ;

   // Result := -MulDiv(Result, 72, Screen.PixelsPerInch);// convert  Font.Height To Font.Size с учетом маштаба при запуске программы

   // D:=-MulDiv(Result, Screen.PixelsPerInch, 72);
  //  r:=-(val*Screen.PixelsPerInch/72); // convert Font.Size to Font.Height
  //  r:=SimpleRoundTo(r,0);
  //  r:=DinamicValueNoRound(r);
  //  r:=SimpleRoundTo(r,0);
  //  Result:=Round(r);
  //  Result:= -MulDiv(Result, 72, Screen.PixelsPerInch);
   // r := -(r*72/Screen.PixelsPerInch);// convert  Font.Height To Font.Size с учетом маштаба при запуске программы
   // Result := Round( SimpleRoundTo(r,0) );
    {
    D:=WinScaleDPIDesing;
    Result:=-MulDiv(val, D ,72); // convert Font.Size to Font.Height
    Result:=DinamicValue(Result);
    Result := -MulDiv(Result, 72, Screen.PixelsPerInch);// convert  Font.Height To Font.Size с учетом маштаба при запуске программы

     }
end;

class function  AmScale.DinamicValueFontSizeCorrect(val:integer):integer;
var D:integer;
begin
    D:=WinScaleDPIDesing;
    Result:=-MulDiv(val, D ,72); // convert Font.Size to Font.Height
    Result := -MulDiv(Result, 72, Screen.PixelsPerInch);// convert  Font.Height To Font.Size с учетом маштаба при запуске программы

end;
class function AmScale.ChangeScaleValue(valOld:integer;M, D: Integer):integer;
begin
    if not IsInit then exit(valOld);
    result:=MulDiv(valOld, M, D);
end;

 class function AmScale.FontHeightToSize(val: integer): integer;
begin
  Result:= val;
  Result:=-MulDiv(Result, 72, Screen.PixelsPerInch);// convert  Font.Height To Font.Size
end;
class function AmScale.FontSizeToHeight(val: integer): integer;
begin
    Result:=-MulDiv(val, Screen.PixelsPerInch ,72); // convert Font.Size to Font.Height
end;



{
class procedure AmScale.Start(Width_now, Width_debag: real);
begin

     USER_SCALE:=100;
   if Width_debag=0 then exit;
   USER_SCALE:=(Width_now/Width_debag)*100;

 c:=TMonitor.Create;
 c.PixelsPerInch

end;}
initialization
begin

   AmScale.AppScaleDesing:=100;
   AmScale.AppScaleNow:=100;
   AmScale.WinScaleDPIDesing:= WinApi.Windows.USER_DEFAULT_SCREEN_DPI;
   AmScale.WinScaleDPINow:=    WinApi.Windows.USER_DEFAULT_SCREEN_DPI;
   AmScale.IsInit:=false;
   AmScale.IsShow:=false;
   AmScale.IsShowning:=false;
   AmScale.IsAppScaled:=false;
   AmScale.IsWinScaled:=false;
end;
end.



