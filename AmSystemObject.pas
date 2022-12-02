unit AmSystemObject;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Controls,Forms,
  Dialogs, SyncObjs, Winapi.WinSock,IOUtils,math,
  System.Generics.Collections,
  ShellApi,System.WideStrUtils,
  AmSystemBase,Rtti,AmInterfaceBase;

 type

   TFilerHelp = class helper for TFiler
   end;
   TWriterHelp = class helper for TWriter
     private
       function PropPathGet: string;
       procedure PropPathSet(const Value: string);
     public
       property PropPath: string read PropPathGet write PropPathSet;
   end;
   TAmWriter = class (TWriter)
    public
     procedure WriteDescendentAm(const C,ARoot,AAncestor: TComponent);
   end;

   TAmMutex =class(TMutex);

   TAmEvent = class(tevent)
      public
        function Inp:TWaitResult;
        Procedure Outs;
        class function  InpHandle(H:Cardinal):TWaitResult;
        class Procedure  OutsHandle(H:Cardinal);
        constructor Create(ManualReset:boolean=false);overload;

        // если нужно управлять вручную cs ManualReset=true
        {
          ResetEvent
          тогда WaitFor(INFINITE); ждет SetEvent

          если SetEvent был то не будет ждать
          WaitFor(INFINITE);
          WaitFor(INFINITE);
          WaitFor(INFINITE);

          .........................................


          ManualReset=false
          WaitFor(INFINITE); ждет SetEvent
          WaitFor(INFINITE); ждет SetEvent
        }

   end;
  TAmCs=class(TCriticalSection)
  private
    function SectionGet: PRTLCriticalSection;
     public
      property Section: PRTLCriticalSection read SectionGet;
      class procedure EnterPrm(Prm:PRTLCriticalSection);
      class procedure LeavePrm(Prm:PRTLCriticalSection);
      class function  TryEnterPrm(Prm:PRTLCriticalSection): Boolean;
   end;



 type



  TAmObject = class (TObject)
   private
    FOnLog: TProcDefaultError;
    FOnTerminated:TProcTerminated;
    FOnDestroy:TnotifyEvent;
    FOnDestroyBefore:TnotifyEvent;
    FDestroyingObject:Boolean;
    FObjectOwner:TObject;
     function DestroyingObjectGet: boolean;
     function   FOnLogGet:TProcDefaultError;
     procedure  FOnLogSet(Value:TProcDefaultError);
     function   FOnGetThreadTerminatedGet:TProcTerminated;
     procedure  FOnGetThreadTerminatedSet(Value:TProcTerminated);
    protected
     procedure   Log(S:string;E:Exception=nil);Virtual;
     procedure   LogEvent(Sender:TObject;const S:string;E:Exception=nil); Virtual;
     procedure   LogProc(Sender:TObject;const S:string;E:Exception=nil); Virtual;
     function    GetThreadTerminated():boolean; Virtual;
     procedure   GetThreadTerminatedProc(S:Tobject;var IsNeedBreak:boolean); Virtual;
     function    GetThreadTerminatedSleep(AFrom,ATo:Cardinal):boolean; Virtual;
     procedure   DoDestroyBefore;virtual;

     function    ObjectOwnerGet:TObject;virtual;
     procedure   ObjectOwnerSet(const Value:TObject);virtual;
     procedure   ObjectOwnerChanging(const Old,New:TObject);virtual;
     procedure   ObjectOwnerChange(const Old,New:TObject);virtual;
    public
     class procedure FreeObject(Var Obj); static;
     property DestroyingObject: boolean read DestroyingObjectGet;
     procedure BeforeDestruction;override;

     // Кто удалит этот объект
     // списка нет Owner в destroy должен проверить если  My.ObjectOwner = self то удалить My
     // иначе ObjectOwner  можно использовать как угодно этот класс его никак не использует
     property ObjectOwner: TObject read ObjectOwnerGet write ObjectOwnerSet;


     property OnLog: TProcDefaultError read FOnLog write FOnLog;
     property OnDestroy: TnotifyEvent read FOnDestroy write FOnDestroy;
     property OnDestroyBefore: TnotifyEvent read FOnDestroyBefore write FOnDestroyBefore;
     // для объектов которые работают в потоке и хотят получить значение потока Terminated
     property OnGetThreadTerminated: TProcTerminated read FOnTerminated write FOnTerminated;
     destructor Destroy; override;
     constructor Create;
  end;


  IAmLog =  interface
    procedure Log(S:string;E:Exception=nil);
    procedure LogProc(Sender:TObject;const S:string;E:Exception=nil);
    function  FOnLogGet:TProcDefaultError;
    procedure FOnLogSet(Value:TProcDefaultError);
    property  OnLog: TProcDefaultError read FOnLogGet write FOnLogSet;
  end;
  IAmTerminated =  interface
    function    GetThreadTerminated():boolean;
     procedure  GetThreadTerminatedProc(S:Tobject;var IsNeedBreak:boolean);
     function   FOnGetThreadTerminatedGet:TProcTerminated;
     procedure  FOnGetThreadTerminatedSet(Value:TProcTerminated);
     property  OnGetThreadTerminated: TProcTerminated read FOnGetThreadTerminatedGet write FOnGetThreadTerminatedSet;
  end;
  IAmTerminatedSleep = interface (IAmTerminated)
    function   GetThreadTerminatedSleep(AFrom,ATo:Cardinal):boolean;
  end;

  TAmInterfacedObject = class (TInterfacedObject,IAmLog,IAmTerminated,IAmBase)
   private
     FOnLog: TProcDefaultError;
     FOnTerminated:TProcTerminated;
     FOnDestroy:TnotifyEvent;
     FOnDestroyBefore:TnotifyEvent;
     FDestroyingObject:Boolean;
     FObjectOwner:TObject;
     function DestroyingObjectGet: boolean;

     function   FOnLogGet:TProcDefaultError;
     procedure  FOnLogSet(Value:TProcDefaultError);
     function   FOnGetThreadTerminatedGet:TProcTerminated;
     procedure  FOnGetThreadTerminatedSet(Value:TProcTerminated);

    protected
     procedure   Log(S:string;E:Exception=nil);Virtual;
     procedure   LogEvent(Sender:TObject;const S:string;E:Exception=nil); Virtual;
     procedure   LogProc(Sender:TObject;const S:string;E:Exception=nil); Virtual;
     function    GetThreadTerminated():boolean; Virtual;
     procedure   GetThreadTerminatedProc(S:Tobject;var IsNeedBreak:boolean); Virtual;
     function    GetThreadTerminatedSleep(AFrom,ATo:Cardinal):boolean; Virtual;
     procedure   DoDestroyBefore;virtual;
     procedure   DestroyingObjectSet;

     function    ObjectOwnerGet:TObject;virtual;
     procedure   ObjectOwnerSet(const Value:TObject);virtual;
     procedure   ObjectOwnerChanging(const Old,New:TObject);virtual;
     procedure   ObjectOwnerChange(const Old,New:TObject);virtual;
    public
     class procedure FreeObject(Var Obj); static;

     function IsMyChildObject(ACheckObject:TObject):boolean; dynamic;

     property DestroyingObject: boolean read DestroyingObjectGet;
     procedure BeforeDestruction;override;
     // Кто удалит этот объект
     // списка нет Owner в destroy должен проверить если  My.ObjectOwner = self то удалить My
     // иначе ObjectOwner  можно использовать как угодно этот класс его никак не использует
     property ObjectOwner: TObject read ObjectOwnerGet write ObjectOwnerSet;


     property OnLog: TProcDefaultError read FOnLog write FOnLog;
     property OnDestroy: TnotifyEvent read FOnDestroy write FOnDestroy;
     property OnDestroyBefore: TnotifyEvent read FOnDestroyBefore write FOnDestroyBefore;
     // для объектов которые работают в потоке и хотят получить значение потока Terminated
     property OnGetThreadTerminated: TProcTerminated read FOnTerminated write FOnTerminated;
     destructor Destroy; override;
     constructor Create;
  end;


  // Intf не ведет подсчет ссылок на объекты и не удалятся на автомате когда =0
  // что бы явно удалить объект нужно вызвать  Release или Free;
  IAmIntf  = Interface(IInterface)
    procedure Free;
    procedure Release;
  end;
  TAmInf = class (TAmObject, IAmIntf,IAmLog,IAmTerminated)
  protected
    { IInterface }
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    procedure Release; virtual;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    procedure AfterConstruction; override;
    procedure BeforeDestruction;override;
  end;

  TAmPers = class(TPersistent)
   private
     FOnLog: TProcDefaultError;
     FOnTerminated:TProcTerminated;
     FOnDestroy:TnotifyEvent;
     FOnDestroyBefore:TnotifyEvent;
     FDestroyingObject:Boolean;
     function DestroyingObjectGet: boolean;
    protected
     procedure   Log(S:string;E:Exception=nil);Virtual;
     procedure   LogEvent(Sender:TObject;const S:string;E:Exception=nil); Virtual;
     procedure   LogProc(Sender:TObject;const S:string;E:Exception=nil); Virtual;
     function    GetThreadTerminated():boolean; Virtual;
     procedure   GetThreadTerminatedProc(S:Tobject;var IsNeedBreak:boolean); Virtual;
     procedure   DoDestroyBefore;virtual;
     procedure   DestroyingObjectSet;

    public
     class procedure FreeObject(Var Obj); static;
     property DestroyingObject: boolean read DestroyingObjectGet;
     procedure BeforeDestruction;override;

     property OnLog: TProcDefaultError read FOnLog write FOnLog;
     property OnDestroy: TnotifyEvent read FOnDestroy write FOnDestroy;
     property OnDestroyBefore: TnotifyEvent read FOnDestroyBefore write FOnDestroyBefore;
     // для объектов которые работают в потоке и хотят получить значение потока Terminated
     property OnGetThreadTerminated: TProcTerminated read FOnTerminated write FOnTerminated;
     destructor Destroy; override;
     constructor Create;
  end;

  // если режим разработки должен знать об объекте T но этот объект не TPersistent
  // тогда просто в объекте T создайте  TAmPersDesingNotifyHelp и укажите событие для получения Owner
  // объект будет отправлять уведомления в режим разработки о создании и удалении вашего T
   TAmPersDesingNotifyHelp = class(TPersistent)
     type
       TOnGetOwner = procedure (Sender:TObject;var AOwner:TPersistent) of object;
   private
     FOnGetOwner:TOnGetOwner;
   protected
     function GetOwner: TPersistent; override;
   public
     property OnGetOwner: TOnGetOwner read FOnGetOwner;
     constructor Create(AOnGetOwner:TOnGetOwner);
     destructor Destroy; override;
  end;


  TAmPersInf = class (TInterfacedPersistent,IAmIntf,IAmLog,IAmTerminated,IAmBase)
   private
     FOnLog: TProcDefaultError;
     FOnTerminated:TProcTerminated;
     FOnDestroy:TnotifyEvent;
     FOnDestroyBefore:TnotifyEvent;
     FDestroyingObject:Boolean;
     function DestroyingObjectGet: boolean;

     function   FOnLogGet:TProcDefaultError;
     procedure  FOnLogSet(Value:TProcDefaultError);
     function   FOnGetThreadTerminatedGet:TProcTerminated;
     procedure  FOnGetThreadTerminatedSet(Value:TProcTerminated);

    protected
     procedure   Log(S:string;E:Exception=nil);Virtual;
     procedure   LogEvent(Sender:TObject;const S:string;E:Exception=nil); Virtual;
     procedure   LogProc(Sender:TObject;const S:string;E:Exception=nil); Virtual;
     function    GetThreadTerminated():boolean; Virtual;
     procedure   GetThreadTerminatedProc(S:Tobject;var IsNeedBreak:boolean); Virtual;
     procedure   DoDestroyBefore;virtual;
     procedure   DestroyingObjectSet;

    public
     procedure Release; virtual;
     class procedure FreeObject(Var Obj); static;
     function IsMyChildObject(ACheckObject:TObject):boolean; dynamic;
     property DestroyingObject: boolean read DestroyingObjectGet;
     procedure BeforeDestruction;override;

     property OnLog: TProcDefaultError read FOnLog write FOnLog;
     property OnDestroy: TnotifyEvent read FOnDestroy write FOnDestroy;
     property OnDestroyBefore: TnotifyEvent read FOnDestroyBefore write FOnDestroyBefore;
     // для объектов которые работают в потоке и хотят получить значение потока Terminated
     property OnGetThreadTerminated: TProcTerminated read FOnTerminated write FOnTerminated;
     destructor Destroy; override;
     constructor Create;
  end;




  TAmComponent = class(TComponent,IAmLog,IAmBase)
   private
     FOnLog: TProcDefaultError;
     function   FOnLogGet:TProcDefaultError;
     procedure  FOnLogSet(Value:TProcDefaultError);
    protected
     procedure   Log(S:string;E:Exception=nil);Virtual;
     procedure   LogEvent(Sender:TObject;const S:string;E:Exception=nil); Virtual;
     procedure   LogProc(Sender:TObject;const S:string;E:Exception=nil); Virtual;
    public
     class procedure FreeObject(Var Obj); static;
     function IsMyChildObject(ACheckObject:TObject):boolean; dynamic;
     property OnLog: TProcDefaultError read FOnLog write FOnLog;
     destructor Destroy; override;
     constructor Create(AOwner:TComponent);override;
  end;


  TamHandleObject = class (TAmObject)
  private
    FHandle: HWND;
    FOnWndMessage:TWndMethod;
    FIsWndMsgNotSend:boolean;
    procedure WndProc(var Msg: TMessage);
    function GetHandle: HWND;
  protected
    procedure DoWndMessage(var Msg: TMessage);
  public
    property Handle: HWND read GetHandle;
    property IsWndMsgNotSend :boolean read FIsWndMsgNotSend write FIsWndMsgNotSend;
    property OnWndMessage: TWndMethod read FOnWndMessage write FOnWndMessage;
    class function PostMessageNotDudlicat(Handle,Msg,W,L,FiltrMsgMin,FiltrMsgMax:Cardinal):TBoolTri;overload;
    class function PostMessageNotDudlicat(Handle,Msg,W,L:Cardinal):TBoolTri;overload;
    constructor Create;
    destructor Destroy; override;
  end;


 type
  TAmOperation = Cardinal;

  AmOperationBase = class
  end;


  // все сообщения которые унаследованы от этого класса
  // нужно зарегать в глобальном списке   TAmObjectNotify.RegGlobalNew
  AmOperation  = class (AmOperationBase)
   type
    TMoveIndex = record
      Old,New:integer;
      Source:Pointer;
    end;
    TMove = record
      Old,New:integer;
      Source1:Pointer;
      Source2:Pointer;
    end;
  public
   const  User = 10000; // свободно с User + 5000
   const  Create = 1;
   const  Destroy = 2;
   const  Subscribe =3;
   const  UnSubscribe =4;
   const  MainFormClose =5;
  end;
 type
  TAmObjectNotify = class;
  TAmObjectNotifyNessage  =procedure (Sender,Source:TAmObjectNotify;Msg:TAmOperation;W,L:Cardinal)of object;


  // ретрансляторы сообщений событий
  // исполняется в том потоке который вызвал TAmObjectNotify.SendMessage
  // если нужна синхрониция ее делать отдельно
  IAmObjectNotify = interface

  end;

  TAmObjectNotify = class(TAmPersInf)
    private
     FOnNotifyEvent:TAmObjectNotifyNessage;
     FListObject: TList<TAmObjectNotify>;
     FTyp: Cardinal;
     FId: Cardinal;

     class var FCsNotify:TAmCs;
     class var FNotifyCounterId:Cardinal;
     class var FDefault:TAmObjectNotify;
     class var FDefaultThread:TAmObjectNotify;
     class var FRegGlobalMessage: TDictionary<TAmOperation,string>;
     class function CsNotifyGet: TAmCs; static;
     class function DefaultGet: TAmObjectNotify; static;
     class function DefaultThreadGet: TAmObjectNotify; static;
     procedure NotificationInternal(Source:TAmObjectNotify; Msg:TAmOperation; W,L:Cardinal);
     procedure Remove(Source:TAmObjectNotify);
     function  Insert(Source:TAmObjectNotify):boolean;
     function IdGet: Cardinal;
     procedure IdSet(const Value: Cardinal);
     function TypGet: Cardinal;
     procedure TypSet(const Value: Cardinal);

    protected
     class property CsNotify: TAmCs read CsNotifyGet;
     procedure Notification(Source:TAmObjectNotify; Msg:TAmOperation; W,L:Cardinal); virtual;
     constructor CreateSystem(ATyp:Cardinal;dummy:integer=0);
     constructor CreateCustom(ATyp:Cardinal);
     procedure SendCreate;
     class function GetNewId:Cardinal;
    public
     constructor Create;
     destructor Destroy; override;
     procedure AfterConstruction; override;
     procedure BeforeDestruction; override;


     // индефикаторы текушего объекта
     // Typ 1 2 заняты системой  Default и DefaultThread и их установить нельзя
     //id любое ваше произвольное значение при создании объекта устанавливается самостоятельно это глобальное значение для всей проги
     property Typ: Cardinal read TypGet write  TypSet;
     property Id: Cardinal read IdGet write IdSet;



     // позволяет зарегистрировать сообщение что бы небыло дубликатов или 2яково значения константы
     // нужно это делать если не уверены что ваше сообщение уникально
     class procedure RegGlobalNew(Msg:TAmOperation;Caption:string);
     class procedure RegGlobalDelete(Msg:TAmOperation;Caption:string);
     class function  RegGlobalIs(Msg:TAmOperation):boolean;
     class function  RegGlobalCaption(Msg:TAmOperation):string;
     class function  RegGlobalCaptionTry(Msg:TAmOperation):string;


     // подписатся на уведомления
     procedure Subscribe(Sub:TAmObjectNotify);
     procedure UnSubscribe(Sub:TAmObjectNotify);

     // отправить новое уведомление  оно будет разослано все кто подписался
     procedure SendMessage(Msg:TAmOperation; W,L:Cardinal); virtual;


     property OnNotifyEvent: TAmObjectNotifyNessage read FOnNotifyEvent write FOnNotifyEvent;



     // глобальные ретрансляторы сообщений
     // разделил на 2 группы один для гланого потока другой обший
     // что бы для главного потока не получать кучу сообщений с других потоков
     // куда отправлять рещаете сами но куда отправляете туда и нужно подписатся что бы получить
     // все сообщения точно отправляются в главном потоке
     class property Default: TAmObjectNotify read DefaultGet;
     // могут в главном потоке работать а могут в других
     class property DefaultThread: TAmObjectNotify read DefaultThreadGet;
  end;



 TAmObjectCs =class(TAmObject)
  private
    FCs:TAmCs;
    function CsGet: TAmCs;
  public
    function LockTry:boolean;
    property Cs: TAmCs  read CsGet;
    procedure Lock;
    procedure Unlock;
    constructor Create;
    destructor  Destroy;Override;
  end;

  TamHandleObjectCs = class (TamHandleObject)
  private
   FCs:TAmCs;
  public
    procedure Lock;
    function  LockTry:boolean;
    procedure Unlock;
    constructor Create;
    destructor  Destroy;Override;
  end;



  // один Эксемпляр на всю прогу для приема сообщений и их пересылки и синхронизации с главным потоком
  TamMainPotHandleObject = class (TamHandleObject)
    const NEW_MSG_PROC_REF = WM_USER+1;
    private
      class var FInstance: TamMainPotHandleObject;
      class function GetInstance:TamMainPotHandleObject;
      procedure SendProcRefMsg(var Msg:TMessage);message NEW_MSG_PROC_REF;
    public
      // исполняет процедуру в главном потоке дожидаясь ее завершения
      class function SendProcRefM(Func:TAmFuncRef;Error:PAmRecMsgError;TimeOut:Cardinal):LResult;
  end;




implementation

{ TWriterHelp }

function TWriterHelp.PropPathGet: string;
begin
 with self do Result:= FPropPath;
end;

procedure TWriterHelp.PropPathSet(const Value: string);
begin
  with self do FPropPath:= Value;
end;


 {

function TFilerHelp.RootGet: TComponent;
begin
    with self do Result:= FRoot;
end;

procedure TFilerHelp.RootSet(const Value: TComponent);
begin
   with self do FRoot:= Value;
end;}

procedure TAmWriter.WriteDescendentAm(const C,ARoot,AAncestor: TComponent);
var
  Context: TRttiContext;
begin
  RootAncestor := AAncestor;
  Ancestor := AAncestor;
  Root := ARoot;
  WriteSignature;
  Context := TRttiContext.Create;
  try
    WriteComponent(C);
  finally
    Context.Free;
  end;
end;

constructor  TAmComponent.Create(AOwner:TComponent);
begin
   inherited Create(AOwner);
   FOnLog:=nil;
end;
destructor TAmComponent.Destroy;
begin
    FOnLog:=nil;
    inherited;
end;

function TAmComponent.FOnLogGet:TProcDefaultError;
begin
  Result:= FOnLog;
end;
procedure TAmComponent.FOnLogSet(Value:TProcDefaultError);
begin
  FOnLog:= Value;
end;

class procedure TAmComponent.FreeObject(Var Obj);
var Temp:TObject;
begin
     Temp := TObject(Obj);
     Pointer(Obj) := nil;
     if Assigned(Temp) then
     FreeAndNil(Temp);
end;
function TAmComponent.IsMyChildObject(ACheckObject: TObject): boolean;
var i:integer;
begin
  Result:=false;
  if ACheckObject = nil then exit();
  for I := 0 to self.ComponentCount-1 do
  if self.Components[i] = ACheckObject then
   begin
     Result:=true;
     exit;
   end;
end;

procedure   TAmComponent.Log(S:string;E:Exception=nil);
begin
    if Assigned(FOnLog) then
    FOnLog(self,S,E);
end;
procedure   TAmComponent.LogEvent(Sender:TObject;const S:string;E:Exception=nil);
begin
    if Assigned(FOnLog) then
    FOnLog(Sender,S,E);
end;
procedure TAmComponent.LogProc(Sender: TObject; const S: string; E: Exception);
begin
    Log(S,E);
end;

       { TAmPersInf }
constructor  TAmPersInf.Create;
begin
   inherited;
    FDestroyingObject:=false;
    FOnLog:=nil;
    FOnTerminated:=nil;
    FOnDestroy:=nil;
end;
destructor TAmPersInf.Destroy;
begin
    if Assigned(FOnDestroy) then
    FOnDestroy(self);
    FOnLog:=nil;
    FOnTerminated:=nil;
    FOnDestroy:=nil;
    inherited;
end;
function TAmPersInf.DestroyingObjectGet: boolean;
begin
   Result:= AmAtomic.Getter(FDestroyingObject);
end;

procedure TAmPersInf.DestroyingObjectSet;
begin
   AmAtomic.Setter(FDestroyingObject,true);
end;

procedure TAmPersInf.DoDestroyBefore;
begin
   if Assigned(FOnDestroyBefore) then
   FOnDestroyBefore(self);
end;

procedure TAmPersInf.BeforeDestruction;
begin
   AmAtomic.Setter(FDestroyingObject,true);
   DoDestroyBefore;
   inherited;
end;
function TAmPersInf.FOnLogGet:TProcDefaultError;
begin
  Result:= FOnLog;
end;
procedure TAmPersInf.FOnLogSet(Value:TProcDefaultError);
begin
  FOnLog:= Value;
end;
function TAmPersInf.FOnGetThreadTerminatedGet:TProcTerminated;
begin
    Result:= FOnTerminated;
end;
procedure TAmPersInf.FOnGetThreadTerminatedSet(Value:TProcTerminated);
begin
   FOnTerminated:= Value;
end;
class procedure TAmPersInf.FreeObject(Var Obj);
var Temp:TObject;
begin
     Temp := TObject(Obj);
     Pointer(Obj) := nil;
     if Assigned(Temp) then
     FreeAndNil(Temp);
end;
procedure   TAmPersInf.Log(S:string;E:Exception=nil);
begin
    if Assigned(FOnLog) then
    FOnLog(self,S,E);
end;
procedure   TAmPersInf.LogEvent(Sender:TObject;const S:string;E:Exception=nil);
begin
    if Assigned(FOnLog) then
    FOnLog(Sender,S,E);
end;
procedure TAmPersInf.LogProc(Sender: TObject; const S: string; E: Exception);
begin
    Log(S,E);
end;
procedure TAmPersInf.Release;
begin
 Free;
end;

procedure TAmPersInf.GetThreadTerminatedProc(S:Tobject;var IsNeedBreak:boolean);
begin
  IsNeedBreak:= GetThreadTerminated;
end;
function TAmPersInf.IsMyChildObject(ACheckObject: TObject): boolean;
begin
 Result:=false;
end;

function    TAmPersInf.GetThreadTerminated():boolean;
begin
   Result:=false;
   if Assigned(FOnTerminated) then
   FOnTerminated(self,Result);
end;


     { TAmPers }
constructor  TAmPers.Create;
begin
   inherited;
    FDestroyingObject:=false;
    FOnLog:=nil;
    FOnTerminated:=nil;
    FOnDestroy:=nil;
end;
destructor TAmPers.Destroy;
begin
    if Assigned(FOnDestroy) then
    FOnDestroy(self);
    FOnLog:=nil;
    FOnTerminated:=nil;
    FOnDestroy:=nil;
    inherited;
end;
function TAmPers.DestroyingObjectGet: boolean;
begin
   Result:= AmAtomic.Getter(FDestroyingObject);
end;
procedure   TAmPers.DestroyingObjectSet;
begin
  AmAtomic.Setter(FDestroyingObject,true);
end;

procedure TAmPers.DoDestroyBefore;
begin
   if Assigned(FOnDestroyBefore) then
   FOnDestroyBefore(self);
end;

procedure TAmPers.BeforeDestruction;
begin
   AmAtomic.Setter(FDestroyingObject,true);
   DoDestroyBefore;
   inherited;
end;
{
function TAmPers.FOnLogGet:TProcDefaultError;
begin
  Result:= FOnLog;
end;
procedure TAmPers.FOnLogSet(Value:TProcDefaultError);
begin
  FOnLog:= Value;
end;
function TAmPers.FOnGetThreadTerminatedGet:TProcTerminated;
begin
    Result:= FOnTerminated;
end;
procedure TAmPers.FOnGetThreadTerminatedSet(Value:TProcTerminated);
begin
   FOnTerminated:= Value;
end;
}
class procedure TAmPers.FreeObject(Var Obj);
var Temp:TObject;
begin
     Temp := TObject(Obj);
     Pointer(Obj) := nil;
     if Assigned(Temp) then
     FreeAndNil(Temp);
end;
procedure   TAmPers.Log(S:string;E:Exception=nil);
begin
    if Assigned(FOnLog) then
    FOnLog(self,S,E);
end;
procedure   TAmPers.LogEvent(Sender:TObject;const S:string;E:Exception=nil);
begin
    if Assigned(FOnLog) then
    FOnLog(Sender,S,E);
end;
procedure TAmPers.LogProc(Sender: TObject; const S: string; E: Exception);
begin
    Log(S,E);
end;
procedure TAmPers.GetThreadTerminatedProc(S:Tobject;var IsNeedBreak:boolean);
begin
  IsNeedBreak:= GetThreadTerminated;
end;
function    TAmPers.GetThreadTerminated():boolean;
begin
   Result:=false;
   if Assigned(FOnTerminated) then
   FOnTerminated(self,Result);
end;


        { TAmInf }
procedure TAmInf.AfterConstruction;
begin
  inherited;
end;

procedure TAmInf.BeforeDestruction;
begin
  inherited;
end;

function TAmInf.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
    if GetInterface(IID, Obj) then Result := S_OK
    else Result := E_NOINTERFACE;
end;

procedure TAmInf.Release;
begin
  if Self <> nil then
    Free;
end;

function TAmInf._AddRef: Integer;
begin
   Result := -1
end;

function TAmInf._Release: Integer;
begin
   Result := -1
end;
{ TamHandleObjectCs }

constructor TamHandleObjectCs.Create;
begin
    inherited;
    Fcs:= TAmCs.Create;
end;

destructor TamHandleObjectCs.Destroy;
begin
  inherited;
  FreeAndNil(FCs);
end;

procedure TamHandleObjectCs.Lock;
begin
   Fcs.Enter;
end;

function TamHandleObjectCs.LockTry: boolean;
begin
  Result:= Fcs.TryEnter;
end;

procedure TamHandleObjectCs.Unlock;
begin
   Fcs.Leave;
end;


{TAmObjectCs}
constructor TAmObjectCs.Create;
begin
  inherited ;
  FCs:=TAmCs.Create;
end;
function TAmObjectCs.CsGet: TAmCs;
begin
 Result:=AmAtomic.Getter<TAmCs>(FCs);
end;

destructor  TAmObjectCs.Destroy;
begin
   inherited;
   FreeAndNil(FCs);
end;
procedure TAmObjectCs.Lock;
begin
  Cs.Enter;
end;
function TAmObjectCs.LockTry: boolean;
begin
   Result:=Cs.TryEnter;
end;

procedure TAmObjectCs.Unlock;
begin
  Cs.Leave;
end;


             {TamEvent}

constructor TamEvent.Create(ManualReset:boolean=false);
begin
  inherited Create(nil, ManualReset, true, '');
end;
function TamEvent.Inp:TWaitResult;
begin
  Result:=WaitFor(INFINITE);
end;
class function TAmEvent.InpHandle(H: Cardinal): TWaitResult;
begin
    case WaitForMultipleObjectsEx(1, @H, True, INFINITE, False) of
      WAIT_ABANDONED: Result := wrAbandoned;
      WAIT_OBJECT_0: Result := wrSignaled;
      WAIT_TIMEOUT: Result := wrTimeout;
      WAIT_FAILED:
        begin
          Result := wrError;

        end;
    else
      Result := wrError;
    end;
end;
class procedure TAmEvent.OutsHandle(H: Cardinal);
begin
    Windows.SetEvent(H);
end;

Procedure TamEvent.Outs;
begin
 SetEvent;
end;
{ TAmCs }

function TAmCs.SectionGet: PRTLCriticalSection;
begin
    Result:= @FSection;
end;
class procedure TAmCs.EnterPrm(Prm:PRTLCriticalSection);
begin
  EnterCriticalSection(Prm^);
end;

class procedure TAmCs.LeavePrm(Prm:PRTLCriticalSection);
begin
  LeaveCriticalSection(Prm^);
end;

class function TAmCs.TryEnterPrm(Prm:PRTLCriticalSection): Boolean;
begin
  Result := TryEnterCriticalSection(Prm^);
end;

{ TamHandleObject }

constructor TamHandleObject.Create;
begin
  inherited create;
  FIsWndMsgNotSend:=false;
  FHandle := AllocateHWnd(WndProc);//AllocateHWnd(WndProc);Dispatch

end;

destructor TamHandleObject.Destroy;
begin
  if FHandle <> 0 then
  begin
    DeallocateHWnd(FHandle);
    FHandle := 0;
  end;
  inherited;
end;
procedure TamHandleObject.DoWndMessage(var Msg: TMessage);
begin
    if Assigned(OnWndMessage) then
    OnWndMessage(Msg);
end;
function TamHandleObject.GetHandle: HWND;
begin
  // Lock;
   try
     Result:=  AmAtomic.Getter(FHandle);
   finally
      //UnLock;
   end;
end;



procedure TamHandleObject.WndProc(var Msg: TMessage);
begin

  try
    DoWndMessage(Msg);
    if not  FIsWndMsgNotSend then
    Dispatch(Msg);
  except
    Application.HandleException(Self);
  end;
end;
class function TamHandleObject.PostMessageNotDudlicat(Handle, Msg, W, L: Cardinal): TBoolTri;
begin
    Result:= PostMessageNotDudlicat(Handle, Msg, W, L, Msg, Msg);
end;
class function TamHandleObject.PostMessageNotDudlicat(Handle,Msg,W,L,FiltrMsgMin,FiltrMsgMax:Cardinal):TBoolTri;
var  ms: TMSG;
begin
   Result:=bnot;
   if not PeekMessage(ms,Handle,FiltrMsgMin,FiltrMsgMax,PM_NOREMOVE) then
    Result.SetValue(Boolean(PostMessage(Handle,Msg,W,L)));

end;


     {TAmObject}
constructor  TAmObject.Create;
begin
   inherited;
    FDestroyingObject:=false;
    FOnLog:=nil;
    FOnTerminated:=nil;
    FOnDestroy:=nil;
    FObjectOwner:=nil;
end;
destructor TAmObject.Destroy;
begin
    if Assigned(FOnDestroy) then
    FOnDestroy(self);
    FOnLog:=nil;
    FOnTerminated:=nil;
    FOnDestroy:=nil;
    FObjectOwner:=nil;
    inherited;
end;
function TAmObject.DestroyingObjectGet: boolean;
begin
   Result:= AmAtomic.Getter(FDestroyingObject);
end;

procedure TAmObject.DoDestroyBefore;
begin
   if Assigned(FOnDestroyBefore) then
   FOnDestroyBefore(self);
end;

procedure TAmObject.BeforeDestruction;
begin
   AmAtomic.Setter(FDestroyingObject,true);
   DoDestroyBefore;
   inherited;
end;
function TAmObject.FOnLogGet:TProcDefaultError;
begin
  Result:= FOnLog;
end;
procedure TAmObject.FOnLogSet(Value:TProcDefaultError);
begin
  FOnLog:= Value;
end;
function TAmObject.FOnGetThreadTerminatedGet:TProcTerminated;
begin
    Result:= FOnTerminated;
end;
procedure TAmObject.FOnGetThreadTerminatedSet(Value:TProcTerminated);
begin
   FOnTerminated:= Value;
end;

class procedure TAmObject.FreeObject(Var Obj);
var Temp:TObject;
begin
     Temp := TObject(Obj);
     Pointer(Obj) := nil;
     if Assigned(Temp) then
     FreeAndNil(Temp);
end;
procedure   TAmObject.Log(S:string;E:Exception=nil);
begin
    if Assigned(FOnLog) then
    FOnLog(self,S,E);
end;
procedure   TAmObject.LogEvent(Sender:TObject;const S:string;E:Exception=nil);
begin
    if Assigned(FOnLog) then
    FOnLog(Sender,S,E);
end;
procedure TAmObject.LogProc(Sender: TObject; const S: string; E: Exception);
begin
    Log(S,E);
end;
procedure   TAmObject.ObjectOwnerChanging(const Old,New:TObject);
begin
end;
procedure TAmObject.ObjectOwnerChange(const Old, New: TObject);
begin
end;

function TAmObject.ObjectOwnerGet: TObject;
begin
   Result:= AmAtomic.Getter<TObject>(FObjectOwner);
end;

procedure TAmObject.ObjectOwnerSet(const Value: TObject);
var V:TObject;
begin
  V:= ObjectOwnerGet;
  if V<>Value then
  begin
      ObjectOwnerChanging(V,Value);
      AmAtomic.Setter(FObjectOwner,Value);
      ObjectOwnerChange(V,Value);
  end;
end;

procedure TAmObject.GetThreadTerminatedProc(S:Tobject;var IsNeedBreak:boolean);
begin
  IsNeedBreak:= GetThreadTerminated;
end;

function    TAmObject.GetThreadTerminated():boolean;
begin
   Result:=false;
   if Assigned(FOnTerminated) then
   FOnTerminated(self,Result);
end;
function TAmObject.GetThreadTerminatedSleep(AFrom, ATo: Cardinal): boolean;
var Tim:Int64;
    C:Cardinal;
begin
   Result:= GetThreadTerminated;
   if Result then  exit;
   Tim:= math.RandomRange(AFrom,ATo);
   while Tim>0 do
   begin
      Result:= GetThreadTerminated;
      if Result then  break;
      C:= min(500,Tim);
      if C<1 then
      C:=1;
      sleep(C);
      dec(Tim,C);
   end;


end;
     {TAmInterfacedObject}
constructor  TAmInterfacedObject.Create;
begin
   inherited;
    FDestroyingObject:=false;
    FOnLog:=nil;
    FOnTerminated:=nil;
    FOnDestroy:=nil;
    FObjectOwner:=nil;
end;
destructor TAmInterfacedObject.Destroy;
begin
    if Assigned(FOnDestroy) then
    FOnDestroy(self);
    FOnLog:=nil;
    FOnTerminated:=nil;
    FOnDestroy:=nil;
    FObjectOwner:=nil;
    inherited;
end;

function TAmInterfacedObject.FOnLogGet:TProcDefaultError;
begin
  Result:= FOnLog;
end;
procedure TAmInterfacedObject.FOnLogSet(Value:TProcDefaultError);
begin
  FOnLog:= Value;
end;
function TAmInterfacedObject.FOnGetThreadTerminatedGet:TProcTerminated;
begin
    Result:= FOnTerminated;
end;
procedure TAmInterfacedObject.FOnGetThreadTerminatedSet(Value:TProcTerminated);
begin
   FOnTerminated:= Value;
end;
function TAmInterfacedObject.DestroyingObjectGet: boolean;
begin
   Result:= AmAtomic.Getter(FDestroyingObject);
end;

procedure TAmInterfacedObject.DoDestroyBefore;
begin
   if Assigned(FOnDestroyBefore) then
   FOnDestroyBefore(self);
end;
procedure TAmInterfacedObject.DestroyingObjectSet;
begin
  AmAtomic.Setter(FDestroyingObject,true);
end;
procedure TAmInterfacedObject.BeforeDestruction;
begin
   DestroyingObjectSet;
   DoDestroyBefore;
   inherited BeforeDestruction;
end;
class procedure TAmInterfacedObject.FreeObject(Var Obj);
begin
     TAmObject.FreeObject(Obj);
end;
procedure   TAmInterfacedObject.Log(S:string;E:Exception=nil);
begin
    if Assigned(FOnLog) then
    FOnLog(self,S,E);
end;
procedure   TAmInterfacedObject.LogEvent(Sender:TObject;const S:string;E:Exception=nil);
begin
    if Assigned(FOnLog) then
    FOnLog(Sender,S,E);
end;
procedure TAmInterfacedObject.LogProc(Sender: TObject; const S: string; E: Exception);
begin
    Log(S,E);
end;

procedure TAmInterfacedObject.ObjectOwnerChange(const Old, New: TObject);
begin
end;

procedure TAmInterfacedObject.ObjectOwnerChanging(const Old, New: TObject);
begin
end;

function TAmInterfacedObject.ObjectOwnerGet: TObject;
begin
   Result:= AmAtomic.Getter<TObject>(FObjectOwner);
end;

procedure TAmInterfacedObject.ObjectOwnerSet(const Value: TObject);
var V:TObject;
begin
  V:= ObjectOwnerGet;
  if V<>Value then
  begin
      ObjectOwnerChanging(V,Value);
      AmAtomic.Setter(FObjectOwner,Value);
      ObjectOwnerChange(V,Value);
  end;
end;

procedure TAmInterfacedObject.GetThreadTerminatedProc(S:Tobject;var IsNeedBreak:boolean);
begin
  IsNeedBreak:= GetThreadTerminated;
end;

function    TAmInterfacedObject.GetThreadTerminated():boolean;
begin
   Result:=false;
   if Assigned(FOnTerminated) then
   FOnTerminated(self,Result);
end;
function TAmInterfacedObject.GetThreadTerminatedSleep(AFrom, ATo: Cardinal): boolean;
var Tim:Int64;
    C:Cardinal;
begin
   Result:= GetThreadTerminated;
   if Result then  exit;
   Tim:= math.RandomRange(AFrom,ATo);
   while Tim>0 do
   begin
      Result:= GetThreadTerminated;
      if Result then  break;
      C:= min(500,Tim);
      if C<1 then
      C:=1;
      sleep(C);
      dec(Tim,C);
   end;
end;






function TAmInterfacedObject.IsMyChildObject(ACheckObject: TObject): boolean;
begin
 Result:=false;
end;

{ TAmObjectFreeNotify }
   {
procedure TAmObjectFreeNotify.Notification(AComponent: TComponent;  Operation: TOperation);
begin

end; }

{ TAmObjectNotify }

constructor TAmObjectNotify.Create;
begin
  CreateCustom(0);
  SendCreate;
end;
constructor TAmObjectNotify.CreateCustom(ATyp:Cardinal);
begin
  inherited Create;
  FListObject:= TList<TAmObjectNotify>.Create;
  FTyp:=ATyp;
  FId:=GetNewId;
end;
constructor TAmObjectNotify.CreateSystem(ATyp:Cardinal;dummy:integer=0);
begin
  CreateCustom(ATyp);
end;
destructor TAmObjectNotify.Destroy;
begin
  //showmessage(FListObject.Count.ToString);
  FreeAndNil(FListObject);
  inherited;
end;

procedure TAmObjectNotify.AfterConstruction;
begin
   inherited;
   SendCreate;
end;
procedure TAmObjectNotify.BeforeDestruction;
begin
  SendMessage(AmOperation.Destroy,0,0);
  UnSubscribe(self);
 inherited;
end;
procedure TAmObjectNotify.SendCreate;
var  Def:TAmObjectNotify;
begin
   if AmPotId.IsMain then
   begin
       Def:= AmAtomic.Getter<TAmObjectNotify>(FDefault);
       if Assigned(Def) and (Def <> self) then
       Def.SendMessage(AmOperation.Create,0,0);
   end;
   Def:= AmAtomic.Getter<TAmObjectNotify>(FDefaultThread);
   if Assigned(Def) and (Def <> self) then
   Def.SendMessage(AmOperation.Create,0,0);
end;

class function TAmObjectNotify.GetNewId: Cardinal;
begin
   Result:=AmAtomic.NewId(FNotifyCounterId);
end;


function TAmObjectNotify.IdGet: Cardinal;
begin
   Result:= AmAtomic.Getter(FId);
end;

procedure TAmObjectNotify.IdSet(const Value: Cardinal);
begin
  AmAtomic.Setter(FId,Value);
end;

function TAmObjectNotify.TypGet: Cardinal;
begin
   Result:= AmAtomic.Getter(FTyp);
end;

procedure TAmObjectNotify.TypSet(const Value: Cardinal);
begin
  if Value in [1,2] then
  AmRaiseBase.__Program('Error TAmObjectNotify.TypSet нельзя установить  Typ = [1,2]');
  AmAtomic.Setter(FTyp,Value);
end;

class function TAmObjectNotify.CsNotifyGet: TAmCs;
begin
 Result:= AmAtomic.Getter<TAmCs>(FCsNotify);
end;

class function TAmObjectNotify.DefaultGet: TAmObjectNotify;
begin
    Result:=AmAtomic.GetterObject<TAmObjectNotify>(FDefault, function :TAmObjectNotify
    begin
       Result := TAmObjectNotify.CreateSystem(1);
    end);
end;
class function TAmObjectNotify.DefaultThreadGet: TAmObjectNotify;
begin
    Result:=AmAtomic.GetterObject<TAmObjectNotify>(FDefaultThread, function :TAmObjectNotify
    begin
       Result := TAmObjectNotify.CreateSystem(2);
    end);
end;



procedure TAmObjectNotify.SendMessage( Msg: TAmOperation; W, L: Cardinal);
var Index:integer;
  procedure loInit;
  begin
     CsNotify.Enter;
     try
       Index:= FListObject.Count-1;
     finally
       CsNotify.Leave;
     end;
  end;
  function  LoNext:TAmObjectNotify;
  begin
     CsNotify.Enter;
     try
       Result:= FListObject.List[Index];
       dec(Index);
     finally
       CsNotify.Leave;
     end;
  end;
  var Item:TAmObjectNotify;
begin
  loInit;
  while Index>=0 do
  begin
    Item:= LoNext;
    if Assigned(Item) then
    Item.NotificationInternal(self,Msg,W,L);
  end;
end;
class function TAmObjectNotify.RegGlobalCaption(Msg: TAmOperation): string;
begin
 CsNotify.Enter;
 try
    if FRegGlobalMessage.ContainsKey(Msg) then
    Result:=FRegGlobalMessage.Items[Msg]
    else AmRaiseBase.__Program('Error TAmObjectNotify.RegCaption нельзя получить Caption '+
    'т.к сообщение не зарегистрировано Msg='+Cardinal(Msg).ToString);
 finally
   CsNotify.Leave;
 end;
end;
class function  TAmObjectNotify.RegGlobalCaptionTry(Msg:TAmOperation):string;
begin
 CsNotify.Enter;
 try
    if FRegGlobalMessage.ContainsKey(Msg) then
    Result:=FRegGlobalMessage.Items[Msg]
    else Result:='';
 finally
   CsNotify.Leave;
 end;
end;

class procedure TAmObjectNotify.RegGlobalDelete(Msg: TAmOperation; Caption: string);
begin
 CsNotify.Enter;
 try
    FRegGlobalMessage.Remove(Msg);
 finally
   CsNotify.Leave;
 end;
end;

class function TAmObjectNotify.RegGlobalIs(Msg: TAmOperation): boolean;
begin
 CsNotify.Enter;
 try
    Result:= FRegGlobalMessage.ContainsKey(Msg);
 finally
   CsNotify.Leave;
 end;
end;

class procedure TAmObjectNotify.RegGlobalNew(Msg: TAmOperation; Caption: string);
begin
 CsNotify.Enter;
 try
    if not FRegGlobalMessage.ContainsKey(Msg) then
    FRegGlobalMessage.Add(Msg,Caption)
    else AmRaiseBase.__Program('Error TAmObjectNotify.RegNew дубликат сообщения '+
    Cardinal(Msg).ToString +' Caption='+Caption +' конфликс с '+FRegGlobalMessage.Items[Msg]);
 finally
   CsNotify.Leave;
 end;
end;

procedure TAmObjectNotify.Remove(Source:TAmObjectNotify);
begin
    if Source <> nil then
    begin
       CsNotify.Enter;
       try
         if FListObject.Count>0 then
         begin
            if FListObject.Last = Source  then
            FListObject.Delete(FListObject.Count-1)
            else FListObject.Remove(Source);
         end;
       finally
         CsNotify.Leave;
       end;
    end;
end;


function TAmObjectNotify.Insert(Source:TAmObjectNotify):boolean;
begin
    if Source <> nil then
    begin
       CsNotify.Enter;
       try
          Result:= FListObject.IndexOf(Source)<0 ;
          if Result then
          FListObject.Add(Source);
       finally
         CsNotify.Leave;
       end;
    end
    else Result:=false;
end;
procedure TAmObjectNotify.NotificationInternal(Source:TAmObjectNotify; Msg:TAmOperation; W,L:Cardinal);
begin
   if (Source <> nil) then
   begin
       if (Msg = AmOperation.UnSubscribe) then
       begin
         CsNotify.Enter;
         try
          Remove(Source);
          Source.Remove(self);
         finally
            CsNotify.Leave;
         end;
       end;
       Notification(Source,Msg,W,L);
   end;
end;
procedure TAmObjectNotify.Notification(Source:TAmObjectNotify; Msg:TAmOperation; W,L:Cardinal);
begin
   if Assigned(FOnNotifyEvent) then
   FOnNotifyEvent(self,Source,Msg,W,L);
end;
procedure TAmObjectNotify.Subscribe(Sub: TAmObjectNotify);
begin
   if  (Sub <> nil) and  Insert(Sub) then
   begin
    Sub.Subscribe(self);
   // SendMessage(aopSubscribe,0,Cardinal(Sub));
   end;
end;


procedure TAmObjectNotify.UnSubscribe(Sub: TAmObjectNotify);
begin
   if  (Sub <> nil) then
   SendMessage(AmOperation.UnSubscribe,0,Cardinal(Sub));
end;

{ TamMainPotHandleObject }

class function TamMainPotHandleObject.GetInstance: TamMainPotHandleObject;
begin
  Result:= AmAtomic.Getter<TamMainPotHandleObject>(FInstance);
end;

class function TamMainPotHandleObject.SendProcRefM(Func: TAmFuncRef;Error:PAmRecMsgError;TimeOut:Cardinal): LResult;
begin
   if Assigned(Error) then
   Error.Clear;
   Result:= AmSendMessageBase.SendTimeOut(GetInstance.Handle,
                                        NEW_MSG_PROC_REF,
                                        WPARAM(Error),
                                        LPARAM(Pointer(@Func)),
                                        TimeOut);
end;

procedure TamMainPotHandleObject.SendProcRefMsg(var Msg: TMessage);
var Error:PAmRecMsgError;
begin
    Error:=nil;
    try
        Error:= PAmRecMsgError(Msg.WParam);
        Msg.Result:=0;
        if Msg.LParam<>0 then
        Msg.Result:= TAmFuncRef(Pointer(Msg.LParam)^)();
    except
         on e:exception do
         begin
           if Assigned(Error) then
           begin
              Error.IsError:=true;
              Error.Msg:=e.Message;
              Error.StackTraceAM:=e.StackTrace;
           end
           else raise;
         end;
    end;
end;





{ TAmPersDesingNotifyHelp }

constructor TAmPersDesingNotifyHelp.Create(AOnGetOwner:TOnGetOwner);
begin
   inherited Create;
   FOnGetOwner:=  AOnGetOwner;
   if AmDesing.IsDesingTime then
   AmDesing.NotifyAdd(self);
end;

destructor TAmPersDesingNotifyHelp.Destroy;
begin
   if AmDesing.IsDesingTime then
   AmDesing.NotifyRemove(self);
  inherited;
end;

function TAmPersDesingNotifyHelp.GetOwner: TPersistent;
begin
  Result:=nil;
  if Assigned(FOnGetOwner) then
  FOnGetOwner(self,Result);
  if Result = nil then
  Result:=  inherited  GetOwner;
end;

initialization
begin
  TAmObjectNotify.FCsNotify:=TAmCs.Create;
  TAmObjectNotify.FNotifyCounterId  :=0;
  TAmObjectNotify.FDefault:=nil;
  TAmObjectNotify.FDefaultThread:=nil;
  TAmObjectNotify.FRegGlobalMessage:= TDictionary<TAmOperation,string>.Create;
  TAmObjectNotify.Default;
  TAmObjectNotify.RegGlobalNew(AmOperation.User,'AmOperation.User');
  TAmObjectNotify.RegGlobalNew(AmOperation.Create,'AmOperation.Create');
  TAmObjectNotify.RegGlobalNew(AmOperation.Destroy,'AmOperation.Destroy');
  TAmObjectNotify.RegGlobalNew(AmOperation.Subscribe,'AmOperation.Subscribe');
  TAmObjectNotify.RegGlobalNew(AmOperation.UnSubscribe,'AmOperation.UnSubscribe');
  TAmObjectNotify.RegGlobalNew(AmOperation.MainFormClose,'AmOperation.MainFormClose');

  TamMainPotHandleObject.FInstance := TamMainPotHandleObject.Create;


end;
finalization
begin

   if Assigned(TamMainPotHandleObject.FInstance) then
   FreeAndNil(TamMainPotHandleObject.FInstance);

   if Assigned(TAmObjectNotify.FDefault) then
   FreeAndNil(TAmObjectNotify.FDefault);

   if Assigned(TAmObjectNotify.FDefaultThread) then
   FreeAndNil(TAmObjectNotify.FDefaultThread);

   if Assigned(TAmObjectNotify.FRegGlobalMessage) then
   FreeAndNil(TAmObjectNotify.FRegGlobalMessage);

   if Assigned(TAmObjectNotify.FCsNotify) then
   FreeAndNil(TAmObjectNotify.FCsNotify);

end;

end.
