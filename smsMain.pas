unit smsMain;

interface
uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  math,
  JsonDataObjects,
  DateUtils,
  RegularExpressions,
  AmSystemBase,
  AmSystemObject,
  AmUserType,
  AmHandleObject,
  AmInterfaceBase,
  AmList,
  AmHttp,
  smsTypes,
  AmEnum,
  sms_SimSmsOrg,
  sms_SmsHubOrg,
  sms_5SimNet;
  type
    // глобальные события создания и удаления объектов
    smsOperation = class(AmOperation)
      public
       const  User = AmOperation.User+3000;
       const  CreateContext = User+1;     // L = TsmsContext
       const  DestroyContext = User+2;    // L = TsmsContext
       const  CreateSite = User+3;     // L = TsmsSiteCmd  тоже что и IsmsSite
       const  DestroySite = User+4;    // L = TsmsSiteCmd  тоже что и IsmsSite
       const  CreateMain = User+5;     // L = TsmsMain
       const  DestroyMain = User+6;    // L = TsmsMain
       const  ClearBeforeMain = User+7;    // L = TsmsMain
       const  StatusChangeSite = User+8;    // W = IsmsSite  L = TsmsContextNumber
    end;








    // список сайтов enum
    TsmsTypeSite = (smsSiteNone,smsSimSmsOrg,smsSmsHubOrg,sms5SimNet);

    // главный класс со список сайтов
    // содержит разные поля сайтов
    TsmsMain = class;

    // базовый класс одного сайта
    TsmsSiteCmd = class;
    TsmsSiteCmdClass = class of TsmsSiteCmd;

    // базовый класс заказа нормера телефона подходит для всех сайтов
    TsmsContextNumberClass =class of TsmsContextNumber;
    TsmsContextNumber=class;

    // сайт  SimSms.Org
    TsmsSimSmsOrg  = class;
    TsmsSmsHubOrg  = class;


     // проведет анализ сайтов и если что то найден то закажет номер
     // все логи передадутся в  Main:TsmsMain; в нем должны быть указаны ключи api (токены)
     // в  TArray указывается приоритет проверки
     // Product и Contries должен иметь хотябы 1 елемент
     // smsAuto используется при автоматизаций действий в потоке
     // в TsmsMain есть события которые можно ипользовать что какото в гл поток передать инфу  см smsOperation
    TsmsAuto = class  (TAmObjectNotify)
      type
       TPrm = record
         Main:TsmsMain;
         Product:TArray<TsmsAutoProduct>;
         Contries:TArray<TsmsAutoContry>;
         maxPriceNumber:double; //макс цена за которую можно покупать
         minCountNumber:integer; // минимальное колво доступных номеров если больше то покупать можно
         PriortySite:TArray<TsmsTypeSite>; // если  = 0 то все по очереди проверит
       end;
       PPrm = ^TPrm;
     protected
       procedure Notification(Source:TAmObjectNotify; Msg:TAmOperation; W,L:Cardinal); override;
     public
       Context:TsmsContextNumber;
       // если не хватает этих операций то в   TsmsContextNumber их больше
       // после полечения 1й запустить SmsNext а затем сразу SmsWaitFor елси только  TsmsGetClear.StatusGood true
       // после  NewContext запустить SmsWaitFor
       function NewContext(P:PPrm): TsmsContextNumber;
       function Cancel():TsmsCancel;
       procedure Delete;
       function IsAlive:boolean;
       function SmsWaitFor(MaxTimeOutSeconds:Cardinal):TsmsGetSms;
       function SmsNext():TsmsGetClear;
       constructor Create;
       destructor Destroy; override;


       class procedure AutoProductToList(L:TStrings);
       class procedure AutoContryToList(L:TStrings);
    end;


    // интерфейс одного сайта смс активаций    класс  TsmsCmd и его наследники
    IsmsSite =   Interface
      procedure OnLogSet(Value:TProcDefaultError);
      function OnLogGet:TProcDefaultError;

      property OnLog: TProcDefaultError read OnLogGet write OnLogSet;
      // для настройки проксей или соединния  с сайтом
      function HttpGet: TamHttp;
      // нет необходимости устанавливать HttpSet но если надо то вот
      procedure HttpSet(const Value: TamHttp);

      property Http: TamHttp read HttpGet write HttpSet;

      function TokenGet:string;
      procedure TokenSet(const Value:string);
      property Token: string read TokenGet write TokenSet;

      function ProxyStringGet: string;
      procedure ProxyStringSet(const Value: string);
      property ProxyString: string read ProxyStringGet write ProxyStringSet;

      function TypGet: TsmsTypeSite;
      function TypStrGet: string;

      procedure SaveToJson(J:TJsonObject);
      procedure LoadFromJson(J:TJsonObject);


      // индексы просто хранят integer и все
      function IndexContextGet: integer;
      procedure IndexContextSet(const Value: integer);
      function IndexContryGet: integer;
      procedure IndexContrySet(const Value: integer);
      function IndexServiceGet: integer;
      procedure IndexServiceSet(const Value: integer);

      property IndexContry: integer read IndexContryGet write IndexContrySet;
      property IndexService: integer read IndexServiceGet write IndexServiceSet;
      property IndexContext: integer read IndexContextGet write IndexContextSet;

      //  время жизни номера
      function MinutesTimeLifeNumbers:Integer;

      // какой класс контекса создавать при запросе GetNumberNew GetNumberOld
      function  ContextNumberClassGet:TsmsContextNumberClass;
      procedure ContextNumberClassSet(const Value:TsmsContextNumberClass);

      // упрвление списом контектов список заказаных номеров
      procedure ContextClearAll;
      function  ContextCount:integer;
      function  ContextIndex(Index:integer): TsmsContextNumber;
      function  ContextObject(AId:Cardinal): TsmsContextNumber;

      // баланс на сайте
      function GetBalance:TsmsBalance;

      // список стран на сайте
      function GetContries(L:PsmsContryList):boolean;
      function GetContriesToList(L:TStrings):boolean;

      // список сервисов на сайте
      function GetServies(L:PsmsServisList):boolean;
      function GetServiesToList(L:TStrings):boolean;


      //инфа о телефонах и балансе к строке
      function GetInfo(Servis,Contry:string):string;

      // получить кол-во доступных номеров сейчас
      function GetCountNumb(Servis,Contry:string):TsmsCountNumbers;

      // получить цену номера
      function GetPrice(Servis,Contry:string):TsmsPriceNumb;


      //  получение номер Result  =  контекст заказа
      // получить новый номер елси не удачно то Result=nil а ошибка в  ResultPost
      function GetNumberNew(Servis,Contry:string;ResultPost:PsmsGetNumb=nil):TsmsContextNumber;

      // получить старый номер (через большой промежуток времяни)
      //еcси не удачно то Result=nil а ошибка в  ResultPost
      function GetNumberOld(Servis,Contry,CodeContryNumber,Number:string;ResultPost:PsmsGetNumb=nil):TsmsContextNumber;

        // для массовго вызова действий
       // отменяет все заказы
       procedure GroupCancel;
       // отменяет все заказы и удаляет объекты
       procedure GroupClear;
       //проверяет пришла ли смс
       function GroupSms:integer;


       function AutoProductToId(Value:TsmsAutoProduct):string;
       function AutoContryToId(Value:TsmsAutoContry):string;
    end;


    TsmsChangeStatus = procedure (Main:TsmsMain;Site:IsmsSite; AContext:TsmsContextNumber) of object;

    TsmsMain  = class (TAmObject)
     private
      class function SiteClassGet(Typ: TsmsTypeSite): TsmsSiteCmdClass; static;

      var FSite:array  [TsmsTypeSite] of IsmsSite;
      FOnChangeStatus:TsmsChangeStatus;
      FOnLoadSetting:TNotifyEvent;
      FClass:TsmsContextNumberClass;
       function GetIndexSite(const Index: TsmsTypeSite): IsmsSite;
      function SiteNameGet(TypEnumStr: string): IsmsSite;
      function SiteTypGet(Typ: TsmsTypeSite): IsmsSite;
      procedure SiteTypSet(Typ: TsmsTypeSite; const Value: IsmsSite);
      procedure SiteNameSet(TypEnumStr: string; const Value: IsmsSite);
     protected
       procedure SiteInit;virtual;
       procedure Log(S:string;E:Exception=nil);override;
       procedure ChangeStatusContextNumber(ASite:IsmsSite;AContext:TsmsContextNumber);virtual;
     public
      class function EnumTo(Value:string):TsmsTypeSite;
      class function EnumToStr(Value:TsmsTypeSite):string;
      class function EnumCount:integer;
      class function SiteNew(AOwner:TsmsMain;Typ: TsmsTypeSite;AToken:string): IsmsSite;  overload;
      class function SiteNew(AOwner:TsmsMain;TypStr: string;AToken:string): IsmsSite;     overload;
      class procedure SiteToList(L:TStrings);

      procedure SiteClear;virtual;
      // отменяет все заказы
      procedure GroupCancel;
      // отменяет все заказы и удаляет объекты
      procedure GroupClear;
       //проверяет пришла ли смс для всех заказов Result кол-во активных заказов которые ждут смс
      function GroupSms:integer;

      class property SiteClass  [Typ:TsmsTypeSite] : TsmsSiteCmdClass read SiteClassGet;
      property SiteTyp  [Typ:TsmsTypeSite] : IsmsSite read SiteTypGet write SiteTypSet;
      property SiteName [TypEnumStr:string]: IsmsSite read SiteNameGet write SiteNameSet;

      property SimSmsOrg:  IsmsSite  index smsSimSmsOrg read GetIndexSite;
      property SmsHubOrg:  IsmsSite  index smsSmsHubOrg read GetIndexSite;
      property Sms5SimNet: IsmsSite  index sms5SimNet read GetIndexSite;


      procedure SaveToJson(J:TJsonObject);
      procedure LoadFromJson(J:TJsonObject);
      procedure LoadFromSms(Source:TsmsMain);
      procedure SaveToFile(FileName:string);
      procedure SaveToSms(Desc:TsmsMain);
      procedure LoadFromFile(FileName:string);
      property ContextNumberClass: TsmsContextNumberClass read FClass write FClass;
      property OnChangeStatus: TsmsChangeStatus read FOnChangeStatus write FOnChangeStatus;
      property OnLoadSetting: TNotifyEvent read FOnLoadSetting write FOnLoadSetting;

      // инфо
      function GetInfoBalance():string;

      constructor  Create();virtual;
      destructor Destroy; override;
      procedure AfterConstruction; override;
      procedure BeforeDestruction;override;
    end;






    TsmsSiteBase = class abstract (TAmInterfacedObject)
      private
        FClassContext:TsmsContextNumberClass;
        FToken:string;
        FHttp:TamHttp;
        FTyp:TsmsTypeSite;
        FIndexContry:integer;
        FIndexService:integer;
        FIndexContext:integer;
        FProxyString:string;
        function HttpGet: TamHttp;
        function ContextNumberClassGet:TsmsContextNumberClass;
        procedure  ContextNumberClassSet(const Value:TsmsContextNumberClass);
        function NameTypGet: string;
        function ObjectOwnGet: TsmsMain;
        procedure ObjectOwnSet(const Value: TsmsMain);
        procedure OnLogSet(Value:TProcDefaultError);
        function OnLogGet:TProcDefaultError;
        function TypGet: TsmsTypeSite;
        function TypStrGet: string;
        function IndexContextGet: integer;
        procedure IndexContextSet(const Value: integer);
        function IndexContryGet: integer;
        procedure IndexContrySet(const Value: integer);
        function IndexServiceGet: integer;
        procedure IndexServiceSet(const Value: integer);

      protected
        procedure Log(S:string;E:Exception=nil);override;
        procedure ObjectOwnerChanging(const Old, New: TObject);override;
        procedure ObjectOwnerChange(const Old, New: TObject);override;
        property HttpVar: TamHttp read FHttp;
        function UrlBaseGet:string;virtual;abstract;
        procedure TokenSet(const Value:string);virtual;
        function TokenGet:string;virtual;
        procedure HttpSet(const Value: TamHttp); virtual;
        function ProxyStringGet: string;   virtual;
        procedure ProxyStringSet(const Value: string);  virtual;
      public
       property ObjectOwner: TsmsMain read ObjectOwnGet write ObjectOwnSet;
       property Typ: TsmsTypeSite read TypGet;
       property NameTyp: string read NameTypGet;
       property Token: string read TokenGet write TokenSet;
       property ProxyString: string read ProxyStringGet write ProxyStringSet;
       property UrlBase: string read UrlBaseGet;
       property Http: TamHttp read HttpGet write HttpSet;
       property ContextNumberClass: TsmsContextNumberClass read ContextNumberClassGet write ContextNumberClassSet;
       property IndexContry: integer read IndexContryGet write IndexContrySet;
       property IndexService: integer read IndexServiceGet write IndexServiceSet;
       property IndexContext: integer read IndexContextGet write IndexContextSet;
       procedure SaveToJson(J:TJsonObject);  virtual;
       procedure LoadFromJson(J:TJsonObject); virtual;

       constructor  Create(AOwner:TsmsMain;ATyp:TsmsTypeSite;AToken:string);virtual;
       destructor Destroy; override;
       procedure AfterConstruction; override;
       procedure BeforeDestruction;override;
    end;





    // абстрактый класс для наследования разных сайтов получения смс активаций
    TsmsSiteCmd = class abstract (TsmsSiteBase,IsmsSite)
     private
        FListContext: TList<TsmsContextNumber>;
        FIdCounter:Cardinal;
        FOnChangeStatusContextNumber:TsmsChangeStatus;
        procedure AddMi(C:TsmsContextNumber);
        procedure RemoveMi(C:TsmsContextNumber);
        function GetNewId:Cardinal;
     protected
        procedure ChangeStatusContextNumber(AContext:TsmsContextNumber);virtual;
     private

        /////////////////////////////////////////////////////////////////
        // запросы которые выполняются с контекста заказа
       // сдедать запрос на сайт и получить номер
        function ExpNumb(Servis,Contry,CodeContryNumberOld,NumberOld:string):TsmsGetNumb;virtual;abstract;
        //  сдедать запрос на сайт и отменить заказ
        function ExpCancelNumb(Context:TsmsContextNumber):TsmsCancel;virtual;abstract;
        //  сдедать запрос на сайт и отменить заказ и забанить номер
        function ExpCancelBanNumb(Context:TsmsContextNumber):TsmsCancel;virtual;abstract;
        //  сдедать запрос на сайт и узнать прищла ли смс
        function ExpSms(Context:TsmsContextNumber):TsmsGetSms;virtual;abstract;
        //  сдедать запрос на сайт и очистить смс что бы можно было получить следущую
        function ExpNextSms(Context:TsmsContextNumber):TsmsGetClear;virtual;abstract;
        //  сдедать запрос на сайт и потвердить что смс пришла и закончить работу с номеров
        function ExpSmsCancelOk(Context:TsmsContextNumber):TsmsCancel;virtual;abstract;
        //  время жизни номера
        function MinutesTimeLifeNumbers:Integer; virtual;abstract;
        //////////////////////////////////////////////////////////

        function  ExpBalance:TsmsBalance;virtual;abstract;
        function ExpContries(L:PsmsContryList):boolean;virtual;abstract;
        function ExpContriesToList(L:TStrings):boolean;virtual;abstract;
        function ExpServies(L:PsmsServisList):boolean;virtual;abstract;
        function ExpServiesToList(L:TStrings):boolean; virtual;abstract;
        function  ExpCountNumb(Servis,Contry:string):TsmsCountNumbers;virtual;abstract;
        function  ExpPrice(Servis,Contry:string):TsmsPriceNumb;virtual;abstract;
    protected
       /////////////////////////////////////////////////////////////////
       ///запросы которые выполняются без заказа
        function GetBalance:TsmsBalance;
        function GetContries(L:PsmsContryList):boolean;
        function GetContriesToList(L:TStrings):boolean;
        function GetServies(L:PsmsServisList):boolean;
        function GetServiesToList(L:TStrings):boolean;

        function GetInfo(Servis,Contry:string):string;
        function GetCountNumb(Servis,Contry:string):TsmsCountNumbers;
        function GetPrice(Servis,Contry:string):TsmsPriceNumb;
       /////////////////////////////////////////////////////////////////
       // запросы на получение номера и контекса заказа
        function GetNumberNew(Servis,Contry:string;ResultPost:PsmsGetNumb=nil):TsmsContextNumber;
        function GetNumberOld(Servis,Contry,CodeContryNumber,Number:string;ResultPost:PsmsGetNumb=nil):TsmsContextNumber;
      /////////////////////////////////////////////////////////////////


      /// Список заказов
        procedure ContextClearAll;
        function  ContextCount:integer;
        function  ContextIndex(Index:integer): TsmsContextNumber;
        function  ContextObject(AId:Cardinal): TsmsContextNumber;

       // отменяет все заказы
       procedure GroupCancel;
       // отменяет все заказы и удаляет объекты
       procedure GroupClear;
       //проверяет пришла ли смс для всех заказов Result кол-во активных заказов которые ждут смс
       function GroupSms:integer;

       function AutoProductToId(Value:TsmsAutoProduct):string; virtual;abstract;
       function AutoContryToId(Value:TsmsAutoContry):string;  virtual;abstract;
     public
        constructor  Create(AOwner:TsmsMain;ATyp:TsmsTypeSite;AToken:string);override;
        destructor Destroy; override;
        property OnChangeStatus: TsmsChangeStatus read FOnChangeStatusContextNumber write FOnChangeStatusContextNumber;
    end;



    TsmsContextNumberBase = class abstract(TAmObject)
     private
      FId:Cardinal;
      FDateCreate:TDateTime;
      function ObjectOwnGet: TsmsSiteCmd;
      procedure ObjectOwnSet(const Value: TsmsSiteCmd);
     protected
      procedure ObjectOwnerChanging(const Old,New:TObject);override;
      procedure ObjectOwnerChange(const Old, New: TObject);override;
      procedure Log(S:string;E:Exception=nil);override;
     public
      constructor  Create(AOwner:TsmsSiteCmd);
      destructor Destroy; override;
      procedure AfterConstruction; override;
      procedure BeforeDestruction;override;
      property ObjectOwner: TsmsSiteCmd read ObjectOwnGet write ObjectOwnSet;
      property  Id: Cardinal read FId;
      property DateCreate: TDateTime read FDateCreate;
    end;




    // контект одного номера (одного заказа)
    // для разных сайтов подойдет этот класс
    TsmsContextNumber = class(TsmsContextNumberBase)
     private
      FServis:string;
      FContry:string;
      FSeanseId:string;
      FCodeContryNumber:string;
      FNumber:string;
      FLast: TsmsCancel;
      FSmsLastValue:string;
      FListSms:TsmsListValueSms;
      FStatused:TsmsStatus_sms;
      FOnChangeStatus:TNotifyEvent;
      FDatePostSms:TDateTime;
      FDataPostMs:integer;
      FHasGettedSms:boolean;
      FExpiresOrderLocal:TDateTime;
      procedure  StatusUpdate(Value:TsmsStatus_sms);
      function   DateExpiresGet:TDateTime;
      function NumberFullGet: string;
     protected
      procedure Log(S:string;E:Exception=nil);override;
      procedure ChangeStatus();virtual;
      function  IsAliveErr:string;
      function  IsValidIdErr:string;
     public
      constructor  Create(AOwner:TsmsSiteCmd;Response:PsmsGetNumb);virtual;
      destructor Destroy; override;
      // контекст заказа
      property Status: TsmsStatus_sms read FStatused;
      property  Servis: string read FServis;
      property  Contry: string read FContry;
      property  SeanseId: string read FSeanseId;
      property  Number: string read FNumber;
      property  CodeContryNumber: string read FCodeContryNumber;
      property  DateExpires: TDateTime read DateExpiresGet;
      property  NumberFull: string read NumberFullGet;

      function IsAlive:boolean; virtual; // Существует ли заказ
      function IsValidId:boolean; virtual;  // жив ли заказ еще
      function CancelTry:TsmsCancel; // проверит и отменит если нужно заказ

      // отмена заказа  когда еше не пришла смс
      function  CancelNumbIs:boolean;virtual;
      function  CancelNumbErr:string;
      function  CancelNumb:TsmsCancel; virtual;

      // забанить номер телефона и отменить заказ
      function  BanNumbIs:boolean;virtual;
      function  BanNumbErr:string;
      function  BanNumb:TsmsCancel;  virtual;

      // отмена заказа  если уже получили смс
      function  CancelNumbOkIs:boolean;virtual;
      function  CancelNumbOkErr:string;
      function  CancelNumbOk:TsmsCancel; virtual;

      //запрос на получение смс
      function  SmsGet:TsmsGetSms; virtual;
      function  SmsGetErr:string;
      // можно ли выполять запросы на получение смс  в этом заказе
      function  SmsGetIs: boolean;virtual;
      // можно ли выполнить запрос прямо сейчас на получение смс
      function  SmsGetNowIs: boolean;virtual;



      // запрос на очистку смс что бы можно было получить следущую смс на этотже номер
      function  SmsNextIs:boolean; virtual;
      function  SmsNextErr:string;
      function  SmsNext:TsmsGetClear; virtual;

      //как выполнился последний запрос
      property  LastPost: TsmsCancel read FLast;
      // последняя полученая смс
      property  SmsLastValue: string read FSmsLastValue;

      // была ли получена хоть 1 смс
      property  SmsHas: boolean read FHasGettedSms;

      // список всех смс в рамках текущего заказа
      property  SmsList: TsmsListValueSms read FListSms;
      procedure SmsListToList(L:TStrings);


      // текущий объект к строке
      function ToString:string;  override;
    end;
     {
    TsmsContextNumberComp = class (TsmsContextNumber)
     public
      constructor  Create(AOwner:TsmsSiteCmd;ACodeContryNumber,ANumber,AServis,AContry,ASeanseId:string);virtual;
      destructor Destroy; override;
    end;  }




    // SimSms.Org
    TsmsSimSmsOrg = class (TsmsSiteCmd)
    private
      F:TObjSimSmsOrg;
    protected
      procedure HttpSet(const Value: TamHttp); override;
      procedure TokenSet(const Value:string);override;
      function  UrlBaseGet:string;override;

      function  ExpNumb(Servis,Contry,CodeContryNumberOld,NumberOld:string):TsmsGetNumb;override;
      function  ExpCancelNumb(Context:TsmsContextNumber):TsmsCancel;override;
      function  ExpCancelBanNumb(Context:TsmsContextNumber):TsmsCancel;override;
      function  ExpSms(Context:TsmsContextNumber):TsmsGetSms;override;
      function  ExpNextSms(Context:TsmsContextNumber):TsmsGetClear;override;
      function  ExpSmsCancelOk(Context:TsmsContextNumber):TsmsCancel;override;

      function  ExpBalance:TsmsBalance;override;
      function ExpContries(L:PsmsContryList):boolean;override;
      function ExpServies(L:PsmsServisList):boolean;override;
      function ExpContriesToList(L:TStrings):boolean;override;
      function ExpServiesToList(L:TStrings):boolean; override;
      function  ExpCountNumb(Servis,Contry:string):TsmsCountNumbers;override;
      function  ExpPrice(Servis,Contry:string):TsmsPriceNumb;override;
      function  MinutesTimeLifeNumbers:Integer; override;
      function AutoProductToId(Value:TsmsAutoProduct):string; override;
      function AutoContryToId(Value:TsmsAutoContry):string;  override;
    public
      constructor  Create(AOwner:TsmsMain;ATyp:TsmsTypeSite;AToken:string);override;
      destructor Destroy; override;
    end;

    // SmsHub.Org
    TsmsSmsHubOrg = class (TsmsSiteCmd)
    private
      F:TObjSmsHubOrg;
    protected
      procedure HttpSet(const Value: TamHttp); override;
      procedure TokenSet(const Value:string);override;
      function  UrlBaseGet:string;override;

      function  ExpNumb(Servis,Contry,CodeContryNumberOld,NumberOld:string):TsmsGetNumb;override;
      function  ExpCancelNumb(Context:TsmsContextNumber):TsmsCancel;override;
      function  ExpCancelBanNumb(Context:TsmsContextNumber):TsmsCancel;override;
      function  ExpSms(Context:TsmsContextNumber):TsmsGetSms;override;
      function  ExpNextSms(Context:TsmsContextNumber):TsmsGetClear;override;
      function  ExpSmsCancelOk(Context:TsmsContextNumber):TsmsCancel;override;

      function  ExpBalance:TsmsBalance;override;
      function  ExpContries(L:PsmsContryList):boolean;override;
      function  ExpServies(L:PsmsServisList):boolean;override;
      function  ExpContriesToList(L:TStrings):boolean;override;
      function  ExpServiesToList(L:TStrings):boolean; override;
      function  ExpCountNumb(Servis,Contry:string):TsmsCountNumbers;override;
      function  ExpPrice(Servis,Contry:string):TsmsPriceNumb;override;
      function  MinutesTimeLifeNumbers:Integer; override;

      function AutoProductToId(Value:TsmsAutoProduct):string; override;
      function AutoContryToId(Value:TsmsAutoContry):string;  override;
    public
      constructor  Create(AOwner:TsmsMain;ATyp:TsmsTypeSite;AToken:string);override;
      destructor Destroy; override;
    end;

    // 5sim.net
    Tsms5SimNet = class (TsmsSiteCmd)
    private
      F:TObj5SimNet;
    protected
      procedure HttpSet(const Value: TamHttp); override;
      procedure TokenSet(const Value:string);override;
      function  UrlBaseGet:string;override;

      function  ExpNumb(Servis,Contry,CodeContryNumberOld,NumberOld:string):TsmsGetNumb;override;
      function  ExpCancelNumb(Context:TsmsContextNumber):TsmsCancel;override;
      function  ExpCancelBanNumb(Context:TsmsContextNumber):TsmsCancel;override;
      function  ExpSms(Context:TsmsContextNumber):TsmsGetSms;override;
      function  ExpNextSms(Context:TsmsContextNumber):TsmsGetClear;override;
      function  ExpSmsCancelOk(Context:TsmsContextNumber):TsmsCancel;override;

      function  ExpBalance:TsmsBalance;override;
      function  ExpContries(L:PsmsContryList):boolean;override;
      function  ExpServies(L:PsmsServisList):boolean;override;
      function  ExpContriesToList(L:TStrings):boolean;override;
      function  ExpServiesToList(L:TStrings):boolean; override;
      function  ExpCountNumb(Servis,Contry:string):TsmsCountNumbers;override;
      function  ExpPrice(Servis,Contry:string):TsmsPriceNumb;override;
      function  MinutesTimeLifeNumbers:Integer; override;
      function AutoProductToId(Value:TsmsAutoProduct):string; override;
      function AutoContryToId(Value:TsmsAutoContry):string;  override;
    public
      constructor  Create(AOwner:TsmsMain;ATyp:TsmsTypeSite;AToken:string);override;
      destructor Destroy; override;
    end;


implementation
   const FLocSiteClass :  array  [TsmsTypeSite] of TsmsSiteCmdClass = (nil,TsmsSimSmsOrg,TsmsSmsHubOrg,Tsms5SimNet);
{ AmSms }


constructor TsmsMain.Create();
begin
    inherited;
    FClass:=nil;
    SiteInit;
end;

destructor TsmsMain.Destroy;
begin
  inherited Destroy;
end;
procedure TsmsMain.AfterConstruction;
begin
   inherited AfterConstruction;
   TAmObjectNotify.DefaultThread.SendMessage(smsOperation.CreateMain,0,Cardinal(self));
end;
procedure TsmsMain.BeforeDestruction;
begin
   SiteClear;
   TAmObjectNotify.DefaultThread.SendMessage(smsOperation.DestroyMain,0,Cardinal(self));
   inherited BeforeDestruction;
end;
procedure TsmsMain.ChangeStatusContextNumber(ASite:IsmsSite;AContext: TsmsContextNumber);
begin
   if Assigned(FOnChangeStatus) then
   FOnChangeStatus(self,ASite,AContext);
end;

class function TsmsMain.EnumCount: integer;
begin
  Result:= Integer(System.High(TsmsTypeSite))+1;
end;

class function TsmsMain.EnumTo(Value: string): TsmsTypeSite;
begin
   Result:= AmRecordHlp.EnumToEnum<TsmsTypeSite>(Value);
end;
class function TsmsMain.EnumToStr(Value:TsmsTypeSite):string;
begin
   Result:=AmRecordHlp.EnumToStr(Value);
end;


procedure TsmsMain.LoadFromFile(FileName: string);
var J: TJsonObject;
begin
    J:= AmJson.LoadObjectFile(FileName);
    try
         LoadFromJson(J);
    finally
      J.Free;
    end;
end;
procedure TsmsMain.LoadFromSms(Source:TsmsMain);
var J: TJsonObject;
begin
     J:= TJsonObject.Create;
     try
        Source.SaveToJson(J);
        LoadFromJson(J);
     finally
       J.Free;
     end;
end;

procedure TsmsMain.LoadFromJson(J: TJsonObject);
var i:integer;
A:TJsonArray;
N:TJsonObject;
Typ:TsmsTypeSite;
begin
  A:=J.A['List'];
  for I := 0 to A.Count-1 do
  begin
      N:= A.Items[i].ObjectValue;
      Typ:=  EnumTo(N['Typ'].Value);
      if Typ<>smsSiteNone then
       SiteTyp[Typ].LoadFromJson(N);
  end;
  if Assigned(FOnLoadSetting) then
  FOnLoadSetting(self);
end;
procedure TsmsMain.SaveToFile(FileName: string);
var J: TJsonObject;
begin
    J:= TJsonObject.Create;
    try
         SaveToJson(J);
         J.SaveToFile(FileName);
    finally
      J.Free;
    end;
end;
procedure TsmsMain.SaveToSms(Desc:TsmsMain);
var J: TJsonObject;
begin
     J:= TJsonObject.Create;
     try
        SaveToJson(J);
        Desc.LoadFromJson(J);
     finally
       J.Free;
     end;
end;

procedure TsmsMain.SaveToJson(J: TJsonObject);
var i:integer;
A:TJsonArray;
N:TJsonObject;
begin
  A:=J.A['List'];
  A.Clear;
  for I := 1 to length(FSite)-1 do
  begin
      if FSite[TsmsTypeSite(i)]<>nil then
      begin
       N:=A.AddObject;
       N['Typ'].Value:=EnumToStr(TsmsTypeSite(i));
       FSite[TsmsTypeSite(i)].SaveToJson(N);
      end;
  end;
    
end;


procedure TsmsMain.Log(S: string; E: Exception);
begin
  inherited Log('[sms] '+S,E);
end;

class procedure TsmsMain.SiteToList(L: TStrings);
var
  I,TypCount: Integer;
begin
   L.BeginUpdate;
   try
     L.Clear;
     TypCount:=EnumCount;
     for I := 1 to TypCount-1 do
       L.Add(EnumToStr(TsmsTypeSite(i)));
   finally
     L.EndUpdate;
   end;
end;
class function TsmsMain.SiteNew(AOwner:TsmsMain;Typ: TsmsTypeSite;AToken:string): IsmsSite;
begin
   Result:=nil;
   if SiteClass[Typ]<>nil then
        Result:= SiteClass[Typ].Create(AOwner,Typ,AToken);
end;
class function TsmsMain.SiteNew(AOwner:TsmsMain;TypStr: string;AToken:string): IsmsSite;
begin
   Result:=SiteNew(AOwner,EnumTo(TypStr),AToken);
end;

procedure TsmsMain.SiteInit;
var I,C:integer;
begin
    C:=length(FSite);
    for I := 0 to C-1 do
    FSite[TsmsTypeSite(i)]:=nil;
end;

class function TsmsMain.SiteClassGet(Typ: TsmsTypeSite): TsmsSiteCmdClass;
begin
  Result:= FLocSiteClass[Typ];
end;

procedure TsmsMain.SiteClear;
var I,C:integer;
   ASite:IsmsSite;
begin
    TAmObjectNotify.DefaultThread.SendMessage(smsOperation.ClearBeforeMain,0,Cardinal(self));
    C:=length(FSite);
    for I := 0 to C-1 do
    begin
      ASite:=FSite[TsmsTypeSite(i)];
      FSite[TsmsTypeSite(i)]:=nil;
      if Assigned(ASite) and (TObject(ASite) is TsmsSiteCmd) then
      begin
         if TsmsSiteCmd(ASite).RefCount<>1 then
         raise Exception.Create('Error TsmsMain.SiteClear Вы не удалили все ссылки на IsmsSite');
      end;
      ASite:=nil;
    end;
end;
function TsmsMain.GetIndexSite(const Index: TsmsTypeSite): IsmsSite;
begin
    Result:=SiteTyp[Index];
end;

function TsmsMain.GetInfoBalance: string;
var
  I: Integer;
  B:TsmsBalance;
  S:string;
  Site:IsmsSite;
begin
  Result:='';
  for I := 0 to self.EnumCount-1 do
  begin
    Site:=  SiteTyp[TsmsTypeSite(I)];
    if Site = nil then
    continue;
    if Site.TokenGet='' then
    continue;
   B:=Site.GetBalance;
   S:=Site.TypStrGet;
   if B.IsGood then
   S:=S+' : ' +B.Value.ToString
   else S:=S+' : ' +B.Error;
   TAmString(Result).Apped(S,#13#10);
  end;
end;

procedure TsmsMain.GroupCancel;
var I: Integer;
begin
    for I := length(FSite)-1 downto 0 do
    if Assigned(FSite[TsmsTypeSite(i)]) then     
    FSite[TsmsTypeSite(i)].GroupCancel;
end;

procedure TsmsMain.GroupClear;
begin
     SiteClear;
end;

function TsmsMain.GroupSms: integer;
var I: Integer;
begin
    Result:=0;
    for I := length(FSite)-1 downto 0 do
    if Assigned(FSite[TsmsTypeSite(i)]) then
    Result:= Result + FSite[TsmsTypeSite(i)].GroupSms;
end;


function TsmsMain.SiteNameGet(TypEnumStr: string): IsmsSite;
begin
    Result:=SiteTypGet(EnumTo(TypEnumStr));
end;
procedure TsmsMain.SiteNameSet(TypEnumStr: string; const Value: IsmsSite);
begin
   SiteTypSet(EnumTo(TypEnumStr),Value);
end;

function TsmsMain.SiteTypGet(Typ: TsmsTypeSite): IsmsSite;
begin
    if (Typ<>smsSiteNone) and (FSite[Typ] = nil) then
    Result:= SiteNew(self,Typ,'')
    else Result:=FSite[Typ];
end;
procedure TsmsMain.SiteTypSet(Typ: TsmsTypeSite; const Value: IsmsSite);
begin
    if (Typ<>smsSiteNone) then
    begin
      FSite[Typ]:= Value;
      if Assigned(FSite[Typ]) then
      FSite[Typ].ContextNumberClassSet(FClass);
    end
    else FSite[Typ]:=nil;
end;







{ TsmsBase }

constructor TsmsSiteBase.Create(AOwner:TsmsMain;ATyp:TsmsTypeSite;AToken:string);
begin
   FClassContext:=  nil;
   inherited Create;
   FIndexContry:=-1;
   FIndexService:=-1;
   FIndexContext:=-1;
   FProxyString:='';
   FClassContext:=  TsmsContextNumber;
   FHttp:=nil;
   FTyp:= ATyp;
   FToken:= AToken;
   ObjectOwner:= AOwner;

end;

destructor TsmsSiteBase.Destroy;
begin
   if Assigned(FHttp) and (FHttp.ObjectOwner = self) then
   FreeAndNil(FHttp);
   ObjectOwner:=nil;
  inherited;
end;
procedure TsmsSiteBase.AfterConstruction;
begin
  inherited;
  TAmObjectNotify.DefaultThread.SendMessage(smsOperation.CreateSite,0,Cardinal(self));
end;
procedure TsmsSiteBase.BeforeDestruction;
begin
   TAmObjectNotify.DefaultThread.SendMessage(smsOperation.DestroySite,0,Cardinal(self));
   inherited BeforeDestruction;
end;

procedure TsmsSiteBase.SaveToJson(J:TJsonObject);
begin
   J['Token'].Value         := FToken;
   J['ProxyString'].Value   := FProxyString;
   J['IndexContry'].Value   := FIndexContry.ToString;
   J['IndexService'].Value  := FIndexService.ToString;
   J['IndexContext'].Value  := FIndexContext.ToString;

end;
procedure TsmsSiteBase.LoadFromJson(J:TJsonObject);
begin
   Token:=J['Token'].Value;
   ProxyString:=J['ProxyString'].Value;
   FIndexContry:=   AmInt(J['IndexContry'].Value,-1);
   FIndexService:=  AmInt(J['IndexService'].Value,-1);
   FIndexContext:=  AmInt(J['IndexContext'].Value,-1);
end;

function TsmsSiteBase.ContextNumberClassGet: TsmsContextNumberClass;
begin
 Result:=  FClassContext;
end;

procedure  TsmsSiteBase.ContextNumberClassSet(const Value:TsmsContextNumberClass);
begin
  FClassContext:= Value;
  if FClassContext = nil then
  FClassContext:= TsmsContextNumber;
end;

function TsmsSiteBase.TokenGet:string;
begin
  Result:= FToken;
end;

procedure TsmsSiteBase.TokenSet(const Value: string);
begin
  FToken:= Value;
end;

function TsmsSiteBase.TypGet: TsmsTypeSite;
begin
  Result:= FTyp;
end;

function TsmsSiteBase.TypStrGet: string;
begin
  Result:= TsmsMain.EnumToStr(TypGet);
end;

function TsmsSiteBase.HttpGet: TamHttp;
begin
   Result:= FHttp;
   if Result = nil  then
   begin
       Result:= TAmHttp.Create;
       Result.ObjectOwner:= self;
       try
        Result.Proxy.FormatDefault:=  Result.Proxy.CONST_FORMAT_PROXY_2;
        Result.Proxy.ProxyString:= FProxyString;
        Result.ProxySetAndCheck(false);
       except
         Result.Proxy.ProxyString:='';
         Result.ProxySetAndCheck(false);
       end;
      HttpSet(Result);
   end;
end;

procedure TsmsSiteBase.HttpSet(const Value: TamHttp);
begin
   if Assigned(FHttp) and (FHttp.ObjectOwner = self) then
   FreeAndNil(FHttp);
   FHttp:= Value;
end;

function TsmsSiteBase.IndexContextGet: integer;
begin
  Result:= FIndexContext;
end;

procedure TsmsSiteBase.IndexContextSet(const Value: integer);
begin
   FIndexContext:= Value;
end;

function TsmsSiteBase.IndexContryGet: integer;
begin
   Result:= FIndexContry;
end;

procedure TsmsSiteBase.IndexContrySet(const Value: integer);
begin
    FIndexContry:= Value;
end;

function TsmsSiteBase.IndexServiceGet: integer;
begin
   Result:= FIndexService;
end;

procedure TsmsSiteBase.IndexServiceSet(const Value: integer);
begin
   FIndexService:= Value;
end;

procedure TsmsSiteBase.Log(S: string; E: Exception);
begin
  S:= '[Name:'+NameTyp+'] ' + S;
  if Assigned(ObjectOwner) then
  ObjectOwner.Log(S,E);
  inherited;
end;

function TsmsSiteBase.NameTypGet: string;
begin
    Result:= TsmsMain.EnumToStr(FTyp);
end;

procedure TsmsSiteBase.ObjectOwnerChanging(const Old, New: TObject);
begin
  if Assigned(New) and not (New is TsmsMain) then
  AmRaise.__Program('Error  TsmsBase.ObjectOwnerChange not (New is TsmsMain)');
 inherited ;
end;
procedure TsmsSiteBase.ObjectOwnerChange(const Old, New: TObject);
begin
  if Assigned(Old) then
    (Old as TsmsMain).SiteTyp[FTyp]:=nil;
  if Assigned(New) then
    (New as TsmsMain).SiteTyp[FTyp]:= self as TsmsSiteCmd;
  inherited ;
end;

function TsmsSiteBase.ObjectOwnGet: TsmsMain;
begin
    Result:= inherited ObjectOwner as TsmsMain;
end;

procedure TsmsSiteBase.ObjectOwnSet(const Value: TsmsMain);
begin
   inherited ObjectOwner:=  Value;
end;

function TsmsSiteBase.OnLogGet: TProcDefaultError;
begin
  Result:= OnLog;
end;

procedure TsmsSiteBase.OnLogSet(Value: TProcDefaultError);
begin
  OnLog:=  Value;
end;

function TsmsSiteBase.ProxyStringGet: string;
begin
   Result:= FProxyString;
end;

procedure TsmsSiteBase.ProxyStringSet(const Value: string);
begin
  if FProxyString = Value  then  exit;
  FProxyString:= Value;
  if Assigned(FHttp) then
  begin
     try
      FHttp.Proxy.FormatDefault:=  FHttp.Proxy.CONST_FORMAT_PROXY_2;
      FHttp.Proxy.ProxyString:= FProxyString;
      FHttp.ProxySetAndCheck(false);
     except
       FHttp.Proxy.ProxyString:='';
       FHttp.ProxySetAndCheck(false);
     end;
  end;
end;

{ TsmsCmd }

constructor TsmsSiteCmd.Create(AOwner:TsmsMain;ATyp:TsmsTypeSite;AToken:string);
begin
  inherited Create(AOwner,ATyp,AToken);
  FListContext:= TList<TsmsContextNumber>.Create;
  FIdCounter:=0;
end;
destructor TsmsSiteCmd.Destroy;
begin
  ContextClearAll;
  inherited;
end;

procedure TsmsSiteCmd.ChangeStatusContextNumber(AContext: TsmsContextNumber);
begin
    TAmObjectNotify.DefaultThread.SendMessage(smsOperation.StatusChangeSite,Cardinal(self),Cardinal(AContext));
    if Assigned(ObjectOwner) then
    ObjectOwner.ChangeStatusContextNumber(self,AContext);
    
    if Assigned(FOnChangeStatusContextNumber) then
    FOnChangeStatusContextNumber(ObjectOwner,self,AContext);
end;


procedure TsmsSiteCmd.GroupCancel;
var i:integer;
begin
  for I := FListContext.Count-1 downto 0 do
    FListContext[i].CancelTry;
end;

procedure TsmsSiteCmd.GroupClear;
begin
    ContextClearAll;
end;

function TsmsSiteCmd.GroupSms:integer;
var i:integer;
begin
  Result:=0;
  for I := FListContext.Count-1 downto 0 do
  begin
    if FListContext[i].SmsGetIs then
     inc(Result);
    if FListContext[i].SmsGetNowIs then
     FListContext[i].SmsGet;
  end;
end;
procedure TsmsSiteCmd.ContextClearAll;
var I: Integer;
begin
  for I := FListContext.Count-1 downto 0 do
    FListContext[i].Free;
  FreeAndNil(FListContext);
end;
function TsmsSiteCmd.ContextCount: integer;
begin
   Result:= FListContext.Count;
end;

function TsmsSiteCmd.ContextIndex(Index:integer): TsmsContextNumber;
begin
 Result:= FListContext[Index];
end;

function TsmsSiteCmd.ContextObject(AId: Cardinal): TsmsContextNumber;
var  I: Integer;
begin
   for I := 0 to FListContext.Count-1 do
   if FListContext[I].Id = AId then
   begin
      Result:= FListContext[I];
      exit;
   end;
   Result:=nil;
end;

function TsmsSiteCmd.GetBalance: TsmsBalance;
begin
    Result:= ExpBalance;
    if Result.IsGood then
    Log('Баланс получен '+Result.Value.ToString +' '+Result.Currency.GetSRu)
    else  Log('Не удалось получить баланс');
end;



function TsmsSiteCmd.GetCountNumb(Servis, Contry: string): TsmsCountNumbers;
begin
    Result:= ExpCountNumb(Servis, Contry);
    if Result.IsGood then
    Log('Кол-во номеров '+Result.Online.ToString)
    else  Log('Не удалось получить Кол-во номеров');
end;

function TsmsSiteCmd.GetInfo(Servis, Contry: string): string;
var Balance:TsmsBalance;
    CountNumbers:TsmsCountNumbers;
    PriceNumb:TsmsPriceNumb;

var VBalance:string;
    VCountNumbers:string;
    VPriceNumb:string;
begin
   Balance:=GetBalance;
   CountNumbers:=GetCountNumb(Servis,Contry);
   PriceNumb:=GetPrice(Servis,Contry);

   if Balance.IsGood then
   VBalance:=Balance.Value.ToString +' '+Balance.Currency.GetSRu
   else VBalance:= Balance.Error;

   if CountNumbers.IsGood then
   VCountNumbers:=  CountNumbers.Online.ToString +' / '+CountNumbers.Total.ToString +' | '+ CountNumbers.Country +' | '+CountNumbers.Service
   else VCountNumbers:= CountNumbers.Error;

   if PriceNumb.IsGood then
   VPriceNumb:=PriceNumb.Price.ToString +' '+PriceNumb.Currency.GetSRu
   else VPriceNumb:= PriceNumb.Error;


 Result:=
  'Баланс :'+VBalance+#13#10+
  'Кол-во номеров :'+VCountNumbers+#13#10+
  'Цена номера :'+VPriceNumb;
end;

function TsmsSiteCmd.GetNewId: Cardinal;
begin
 Result:= AmAtomic.NewId(FIdCounter);
end;

function TsmsSiteCmd.GetNumberNew(Servis, Contry: string; ResultPost: PsmsGetNumb): TsmsContextNumber;
begin
   Result:=GetNumberOld(Servis,Contry,'','',ResultPost);
end;
function TsmsSiteCmd.GetNumberOld(Servis,Contry,CodeContryNumber,Number:string;ResultPost:PsmsGetNumb=nil):TsmsContextNumber;
var N:TsmsGetNumb;
begin
   Result:=nil;
   if Assigned(ResultPost) then
     AmRecordHlp.RecFinal(ResultPost^);
   if Servis.IsEmpty or Contry.IsEmpty then
   begin
     Log('GetNumber параметры пусты');
     exit;
   end;
   N:=ExpNumb(Servis, Contry, CodeContryNumber, Number);
   if N.IsGood and (N.Number<>'') and (N.SeanseId<>'') then
   begin
    Log('GetNumber Номер получен '+N.CodeContry + N.Number);
    Result:=ContextNumberClass.Create(self,@N);
   end
   else
   begin
     Log('GetNumber Не удалось получить Номер '+N.Error);
   end;
   if Assigned(ResultPost) then
    ResultPost^:= N;
end;

function TsmsSiteCmd.GetPrice(Servis, Contry: string): TsmsPriceNumb;
begin
    Result:= ExpPrice(Servis,Contry);
    if Result.IsGood then
    Log('Цена нормера '+Result.Price.ToString)
    else  Log('Не удалось получить Цену номера');
end;

function TsmsSiteCmd.GetServies(L: PsmsServisList):boolean;
begin
   Result:=ExpServies(L);
   if not Result then
   Log('Не удалось получить список сервисов');
end;

function TsmsSiteCmd.GetServiesToList(L: TStrings):boolean;
begin
   Result:=ExpServiesToList(L);
   if not Result then
   Log('Не удалось получить список сервисов в лист');
end;



function TsmsSiteCmd.GetContries(L: PsmsContryList):boolean;
begin
   Result:=ExpContries(L);
   if not Result then
   Log('Не удалось получить список стран');
end;

function TsmsSiteCmd.GetContriesToList(L: TStrings):boolean;
begin
   Result:=ExpContriesToList(L);
   if not Result then
   Log('Не удалось получить список стран в лист');
end;


procedure TsmsSiteCmd.AddMi(C: TsmsContextNumber);
begin
  if FListContext.IndexOf(C)<0 then
  begin
    FListContext.Add(C);
    C.FId:= GetNewId;
  end
  else if C.FId = 0 then
    C.FId:= GetNewId;
end;

procedure TsmsSiteCmd.RemoveMi(C: TsmsContextNumber);
begin
  FListContext.Remove(C);
end;







{ TsmsContextNumberBase }


constructor TsmsContextNumberBase.Create(AOwner: TsmsSiteCmd);
begin
   if AOwner=nil then
   AmRaise.__Program('Error TsmsContextNumberBase.Create AOwner=nil');
   inherited Create;
   FDateCreate:=now;
   FId:=0;
   self.ObjectOwner:= AOwner;
end;

destructor TsmsContextNumberBase.Destroy;
begin
  self.ObjectOwner:= nil;
  inherited;
end;

procedure TsmsContextNumberBase.AfterConstruction;
begin
  inherited;
  TAmObjectNotify.DefaultThread.SendMessage(smsOperation.CreateContext,0,Cardinal(self));
end;
procedure TsmsContextNumberBase.BeforeDestruction;
begin
   TAmObjectNotify.DefaultThread.SendMessage(smsOperation.DestroyContext,0,Cardinal(self));
   inherited BeforeDestruction;
end;

procedure TsmsContextNumberBase.Log(S: string; E: Exception);
begin
  S:= '[ContextId:'+Id.ToString+'] ' + S;
  if Assigned(ObjectOwner) then
  ObjectOwner.Log(S,E);
  inherited;
end;

procedure TsmsContextNumberBase.ObjectOwnerChanging(const Old, New: TObject);
begin
  if Assigned(New) and not (New is TsmsSiteCmd) then
  AmRaise.__Program('Error  TsmsContextNumberBase.ObjectOwnerChange not (New is TsmsCmd)');
  inherited ;
end;
procedure  TsmsContextNumberBase.ObjectOwnerChange(const Old, New: TObject);
begin
  if Assigned(Old) then
    (Old as TsmsSiteCmd).RemoveMi(self as TsmsContextNumber);
  if Assigned(New) then
    (New as TsmsSiteCmd).AddMi(self as TsmsContextNumber);
  inherited ;
end;

function TsmsContextNumberBase.ObjectOwnGet: TsmsSiteCmd;
begin
    Result:= inherited ObjectOwner as TsmsSiteCmd;
end;

procedure TsmsContextNumberBase.ObjectOwnSet(const Value: TsmsSiteCmd);
begin
   inherited ObjectOwner:=  Value;
end;


{ TsmsContext }


constructor TsmsContextNumber.Create(AOwner: TsmsSiteCmd;Response:PsmsGetNumb);
begin
   if Response = nil then
   AmRaise.__Program('Error TsmsContextNumber.Create Response = nil');
   if not Response.IsGood then
   AmRaise.__Program('Error TsmsContextNumber.Create not Response.IsGood');
   if Response.SeanseId.IsEmpty or Response.Service.IsEmpty
   or Response.Country.IsEmpty or Response.Number.IsEmpty then
   AmRaise.__Program('Error TsmsContextNumber.Create Empty Fields');

   inherited Create(AOwner);
   FListSms:=TsmsListValueSms.Create;
   FHasGettedSms:=false;
   FDatePostSms:=now;
   FDataPostMs:=math.RandomRange(10,30);

   FCodeContryNumber:=  Response.CodeContry;
   FNumber   :=         Response.Number;
   FServis   :=         Response.Service;
   FContry   :=         Response.Country;
   FSeanseId :=         Response.SeanseId;
   FExpiresOrderLocal:= Response.ExpiresOrderLocal;

   FLast.IsGood:=true;
   FLast.Error:='';
   FSmsLastValue:='';
   FStatused.SetSmsWaitFor;
end;

destructor TsmsContextNumber.Destroy;
begin
  CancelTry;
  FreeAndNil(FListSms);
  inherited Destroy;
end;

procedure TsmsContextNumber.Log(S: string; E: Exception);
begin
  inherited Log('[Numb:'+FCodeContryNumber+FNumber+'] '+S,E);
end;
function TsmsContextNumber.NumberFullGet: string;
begin
   Result:=Trim(FCodeContryNumber +  FNumber);
   if Result<>'' then
   begin
    Result:=Result.Replace(' ','');
    Result:=Result.Replace('-','')
   end;
   if (Result<>'') and (Result[1]<>'+') then
   Result:= '+'+Result;

end;

function   TsmsContextNumber.DateExpiresGet:TDateTime;
begin
     if FExpiresOrderLocal.IsValidUnix then
     Result:= FExpiresOrderLocal
     else if Assigned(ObjectOwner) then
      Result:= DateUtils.IncMinute(FDateCreate,ObjectOwner.MinutesTimeLifeNumbers)
      else
       Result:= DateUtils.IncMinute(FDateCreate,10);
end;


function TsmsContextNumber.IsValidIdErr:string;
begin
    if not IsValidId then
    Result:='Номер был отменен ранее'
    else Result:='';
end;
function TsmsContextNumber.IsValidId:boolean;
begin
   Result:= FSeanseId <> '';
end;
function TsmsContextNumber.IsAliveErr:string;
begin
    Result:=IsValidIdErr;
    if Result.IsEmpty and not IsAlive then
    Result:=' Время жизни заказа истекло';
end;
function TsmsContextNumber.IsAlive:boolean;
begin
   Result:= IsValidId  and (Now < DateExpires);
end;

function TsmsContextNumber.CancelTry:TsmsCancel;
begin
  if CancelNumbIs then         Result := CancelNumb
  else if CancelNumbOkIs then  Result := CancelNumbOk
  else
  begin
   Result.IsGood:=true;
   Result.Error:='';
  end;
end;

function TsmsContextNumber.CancelNumbIs: boolean;
begin
   Result := IsAlive and not FHasGettedSms;
end;
function  TsmsContextNumber.CancelNumbErr:string;
begin
     Result:= IsAliveErr;
     if Result.IsEmpty  and  FHasGettedSms then
     Result:= 'Нельзя отменить заказ когда была получена смс  завершите работу с номером';
end;
function TsmsContextNumber.CancelNumb: TsmsCancel;
var ANewStatus: TsmsStatus_sms;
begin
   ANewStatus.SetError;
   Result.Error:=  CancelNumbErr;
   if Result.Error.IsEmpty then
   begin
      Result:=ObjectOwner.ExpCancelNumb(self);
      FLast.IsGood:= Result.IsGood;
      FLast.Error:=  Result.Error;
      if Result.IsGood then
      begin
        FSeanseId:='';
        ANewStatus.SetNumberCancel;
        Log('Номер отменен '+self.CodeContryNumber+''+self.Number);
      end
      else  Log('Не удалось Отменить номер '+Result.Error);
   end
   else Log(Result.Error);
   StatusUpdate(ANewStatus);
end;

function  TsmsContextNumber.BanNumbIs:boolean;
begin
    Result := IsAlive and not FHasGettedSms;
end;
function  TsmsContextNumber.BanNumbErr:string;
begin
     Result:= IsAliveErr;
     if Result.IsEmpty  and FHasGettedSms then
     Result:= 'Нельзя забанить номер когда была получена смс  завершите работу с номером';
end;
function TsmsContextNumber.BanNumb: TsmsCancel;
var ANewStatus: TsmsStatus_sms;
begin
   ANewStatus.SetError;
   Result.Error:=  BanNumbErr;
   if Result.Error.IsEmpty then
   begin
        Result:=ObjectOwner.ExpCancelBanNumb(self);
        FLast.IsGood:= Result.IsGood;
        FLast.Error:=  Result.Error;
        if Result.IsGood then
        begin
          FSeanseId:='';
          ANewStatus.SetNumberCancel;
          Log('Забанен номер');
        end
        else  Log('Не удалось Забанить номер '+Result.Error);
   end
   else Log(Result.Error);
   StatusUpdate(ANewStatus);
end;
function  TsmsContextNumber.CancelNumbOkIs:boolean;
begin
    Result := IsAlive and FHasGettedSms;
end;
function  TsmsContextNumber.CancelNumbOkErr:string;
begin
     Result:= IsAliveErr;
     if Result.IsEmpty  and not FHasGettedSms then
     Result:= 'Нельзя завершить работу с номеров пока не пришла хоть 1 смс Выполнить отмену заказа';
end;
function  TsmsContextNumber.CancelNumbOk:TsmsCancel;
var ANewStatus: TsmsStatus_sms;
begin
   ANewStatus.SetError;
   Result.Error:=  CancelNumbOkErr;
   if Result.Error.IsEmpty then
   begin
      Result:=ObjectOwner.ExpSmsCancelOk(self);
      FLast.IsGood:= Result.IsGood;
      FLast.Error:=  Result.Error;
      if Result.IsGood  then
      begin
        FSeanseId:='';
        ANewStatus.SetNumberCancelOk;
        Log('Завершена работа с номером '+self.CodeContryNumber+self.Number);
      end
      else
      begin
       Log('Не удалось выполнить запрос SmsCancelOk  '+Result.Error);
      end;
   end
   else Log(Result.Error);
   StatusUpdate(ANewStatus);
end;

function TsmsContextNumber.SmsGetIs: boolean;
begin
   Result:= IsAlive and (FSmsLastValue='');
end;
function TsmsContextNumber.SmsGetNowIs: boolean;
begin
   Result:= SmsGetIs and (DateUtils.SecondsBetween(now,FDatePostSms)>FDataPostMs);
end;
function TsmsContextNumber.SmsGetErr:string;
begin
   Result:= IsAliveErr;
   if Result.IsEmpty and (FSmsLastValue<>'') then
   Result:='Нельзя Выполнить запрос SmsGet Смс уже была получена сделайте запрос на получение следущей смс';
   if Result.IsEmpty and (DateUtils.SecondsBetween(now,FDatePostSms)<FDataPostMs) then
   Result:='Не удалось выполнить запрос SmsGet между запросами должно быть задержка в 30 сек';
end;
function TsmsContextNumber.SmsGet: TsmsGetSms;
var ANewStatus: TsmsStatus_sms;
begin
   ANewStatus.SetError;
   Result.Error:=  SmsGetErr;
   if Result.Error.IsEmpty then
   begin

      FDatePostSms:=now;
      FDataPostMs:=math.RandomRange(10,30);
      Result:=ObjectOwner.ExpSms(self);
      FLast.IsGood:= Result.IsGood;
      FLast.Error:=  Result.Error;
      if Result.IsGood and Result.StatusGood then
      begin
        FSmsLastValue:=  Result.Sms.SmsCode;
        FHasGettedSms:=true;
        if not Result.Sms.DateLocal.IsValidUnix then
        Result.Sms.DateLocal:=now;
        FListSms.Add(Result.Sms);
        ANewStatus.SetSmsGetted;
        Log('Cмс Получена Value = '+FSmsLastValue);
      end
      else if Result.IsGood and not Result.StatusGood then
      begin
           ANewStatus.SetSmsWaitFor;
           Log('Ждем смс...');
      end
      else Log('Не удалось выполнить запрос SmsGet  '+Result.Error);

   end
   else Log(Result.Error);
   StatusUpdate(ANewStatus);
end;

function TsmsContextNumber.SmsNextIs:boolean;
begin
    Result := IsAlive and FHasGettedSms;
end;
function TsmsContextNumber.SmsNextErr:string;
begin
     Result:= IsAliveErr;
     if Result.IsEmpty  and not FHasGettedSms then
     Result:= 'Нельзя получить 2ю Еще не была получена 1я смс';
end;
function  TsmsContextNumber.SmsNext:TsmsGetClear;
var ANewStatus: TsmsStatus_sms;
begin
   ANewStatus.SetError;
   Result.Error:=  SmsNextErr;
   if Result.Error.IsEmpty then
   begin

      Result:=ObjectOwner.ExpNextSms(self);
      FLast.IsGood:= Result.IsGood;
      FLast.Error:=  Result.Error;
      if Result.IsGood and Result.StatusGood then
      begin
        FSmsLastValue:= '';
        ANewStatus.SetSmsClear;
        Log('Выполнена очистка смс перед получением новой');
      end
      else if Result.IsGood and not Result.StatusGood then
      begin
           Log('Не удалось выполнить очистку смс перед получением новой');
      end
      else Log('Не удалось выполнить запрос SmsNext  '+Result.Error);

   end
   else Log(Result.Error);
   StatusUpdate(ANewStatus);
end;



procedure  TsmsContextNumber.StatusUpdate(Value:TsmsStatus_sms);
begin
   if (FStatused.Value <> Value.Value) or FStatused.IsError then
   begin
      FStatused.Value:= Value.Value;
      ChangeStatus;
   end;
end;
procedure TsmsContextNumber.ChangeStatus;
begin
  if not self.DestroyingObject then
  begin
    if Assigned(ObjectOwner) then
    ObjectOwner.ChangeStatusContextNumber(self);
    if Assigned(FOnChangeStatus) then
    FOnChangeStatus(self);
  end;
end;
procedure TsmsContextNumber.SmsListToList(L: TStrings);
var i:integer;
begin
   L.BeginUpdate;
   try
    L.Clear;
    for I := 0 to FListSms.Count-1 do
      L.Add('[Дата:'+FListSms.List[i].DateLocal.ToString+'][SmsText:'+FListSms.List[i].SmsText+']');
   finally
      L.EndUpdate;
   end;
end;

function TsmsContextNumber.ToString: string;
begin
   Result:= 'Id:'+FId.ToString+#13#10+
            'DateCreate:'+FDateCreate.ToString+#13#10+
            'DateExpires:'+DateExpires.ToString+#13#10+
            'Status:'+FStatused.GetStrRu+#13#10+
            'SeanseId:'+FSeanseId+#13#10+
            'Servis:'+FServis+#13#10+
            'Contry:'+FContry+#13#10+
            'Number:'+FCodeContryNumber+FNumber+#13#10+
            'SmsValue:'+FSmsLastValue+#13#10+
            'SmsWas:'+FHasGettedSms.ToString+#13#10+
            'LastPost:'+FLast.IsGood.ToString+#13#10+
            'Error:'+FLast.Error;
end;

{ TsmsSimSmsOrg }

function TsmsSimSmsOrg.AutoContryToId(Value: TsmsAutoContry): string;
begin
   F.Http:=self.Http;
   Result:=F.AutoContryToId(Value);
end;

function TsmsSimSmsOrg.AutoProductToId(Value: TsmsAutoProduct): string;
begin
   F.Http:=self.Http;
   Result:=F.AutoProductToId(Value);
end;

constructor TsmsSimSmsOrg.Create(AOwner:TsmsMain;ATyp:TsmsTypeSite;AToken:string);
begin
  inherited Create(AOwner,ATyp,AToken);
   F:=TObjSimSmsOrg.Create;
   F.Http:=self.HttpVar;
   F.ApiToken:= Token;
end;

destructor TsmsSimSmsOrg.Destroy;
begin
  inherited Destroy;
  FreeAndNil(F);
end;

procedure TsmsSimSmsOrg.TokenSet(const Value: string);
begin
  inherited;
   F.ApiToken:=  Value;
end;

procedure TsmsSimSmsOrg.HttpSet(const Value: TamHttp);
begin
  inherited;
  F.Http:=self.Http;
end;

function TsmsSimSmsOrg.ExpCancelBanNumb(Context: TsmsContextNumber): TsmsCancel;
begin
  F.Http:=self.Http;
  Result:= F.CancelBanNumb(Context.Servis,Context.Contry,Context.SeanseId);
end;

function TsmsSimSmsOrg.ExpCancelNumb(Context: TsmsContextNumber): TsmsCancel;
begin
  F.Http:=self.Http;
  Result:= F.CancelNumb(Context.Servis,Context.Contry,Context.SeanseId);
end;

function TsmsSimSmsOrg.ExpBalance: TsmsBalance;
begin
 F.Http:=self.Http;
 Result:= F.GetBalance;
end;

function TsmsSimSmsOrg.ExpContries(L: PsmsContryList):boolean;
begin
  F.Http:=self.Http;
  F.GetContries(L);
  Result:=true;
end;

function TsmsSimSmsOrg.ExpContriesToList(L: TStrings):boolean;
begin
   F.Http:=self.Http;
   F.GetContriesToList(L);
   Result:=true;
end;

function TsmsSimSmsOrg.ExpCountNumb(Servis, Contry: string): TsmsCountNumbers;
begin
  F.Http:=self.Http;
  Result:=F.GetCountNumb(Servis,Contry);
end;

function TsmsSimSmsOrg.ExpNumb(Servis,Contry,CodeContryNumberOld,NumberOld:string):TsmsGetNumb;
var G:TsmsCheckOldNumb;
begin
  F.Http:=self.Http;
  if NumberOld<>'' then
  begin
     G:=F.GetNumbOldCheck(Servis,Contry,NumberOld);
     if G.IsGood and (G.SeanseIdOld<>'') then
      Result:= F.GetNumbOld(Servis,Contry,CodeContryNumberOld,NumberOld)
      else
      begin
        AmRecordHlp.RecFinal(Result);
        Result.IsGood:= false;
        Result.Error:= G.Error;
      end;
  end
  else
  Result:=F.GetNumbNew(Servis,Contry);
end;

function TsmsSimSmsOrg.ExpPrice(Servis, Contry: string): TsmsPriceNumb;
begin
  F.Http:=self.Http;
  Result:=F.GetPrice(Servis,Contry);
end;

function TsmsSimSmsOrg.ExpServies(L: PsmsServisList):boolean;
begin
  F.Http:=self.Http;
  F.GetServies(L);
  Result:=true;
end;

function TsmsSimSmsOrg.ExpServiesToList(L: TStrings):boolean;
begin
  F.Http:=self.Http;
  F.GetServiesToList(L);
  Result:=true;
end;

function TsmsSimSmsOrg.ExpSms(Context: TsmsContextNumber): TsmsGetSms;
begin
  F.Http:=self.Http;
  Result:= F.GetSms(Context.Servis,Context.Contry,Context.SeanseId);
end;

function TsmsSimSmsOrg.ExpNextSms(Context:TsmsContextNumber):TsmsGetClear;
begin
  F.Http:=self.Http;
  Result:= F.GetClearSms(Context.Servis,Context.Contry,Context.SeanseId);
end;
function  TsmsSimSmsOrg.ExpSmsCancelOk(Context:TsmsContextNumber):TsmsCancel;
begin
   Result.IsGood:=true;
end;

function TsmsSimSmsOrg.MinutesTimeLifeNumbers: Integer;
begin
  Result:=15;
end;
function TsmsSimSmsOrg.UrlBaseGet: string;
begin
   Result:= F.LinkUrl;
end;



{ TsmsSmsHubOrg }


constructor TsmsSmsHubOrg.Create(AOwner:TsmsMain;ATyp:TsmsTypeSite;AToken:string);
begin
  inherited Create(AOwner,ATyp,AToken);
   F:=TObjSmsHubOrg.Create;
   F.Http:=self.HttpVar;
   F.ApiToken:= Token;
end;

destructor TsmsSmsHubOrg.Destroy;
begin
  inherited Destroy;
  FreeAndNil(F);
end;

function TsmsSmsHubOrg.AutoContryToId(Value: TsmsAutoContry): string;
begin
   F.Http:=self.Http;
   Result:=F.AutoContryToId(Value);
end;

function TsmsSmsHubOrg.AutoProductToId(Value: TsmsAutoProduct): string;
begin
   F.Http:=self.Http;
   Result:=F.AutoProductToId(Value);
end;

procedure TsmsSmsHubOrg.TokenSet(const Value: string);
begin
  inherited;
   F.ApiToken:=  Value;
end;

procedure TsmsSmsHubOrg.HttpSet(const Value: TamHttp);
begin
  inherited;
  F.Http:=self.Http;
end;

function TsmsSmsHubOrg.ExpCancelBanNumb(Context: TsmsContextNumber): TsmsCancel;
begin
  F.Http:=self.Http;
  Result:= F.CancelBanNumb(Context.Servis,Context.Contry,Context.SeanseId);
end;

function TsmsSmsHubOrg.ExpCancelNumb(Context: TsmsContextNumber): TsmsCancel;
begin
  F.Http:=self.Http;
  Result:= F.CancelNumb(Context.Servis,Context.Contry,Context.SeanseId);
end;

function TsmsSmsHubOrg.ExpBalance: TsmsBalance;
begin
 F.Http:=self.Http;
 Result:= F.GetBalance;
end;

function TsmsSmsHubOrg.ExpContries(L: PsmsContryList):boolean;
begin
  F.Http:=self.Http;
  F.GetContries(L);
  Result:=true;
end;

function TsmsSmsHubOrg.ExpContriesToList(L: TStrings):boolean;
begin
   F.Http:=self.Http;
   F.GetContriesToList(L);
   Result:=true;
end;

function TsmsSmsHubOrg.ExpCountNumb(Servis, Contry: string): TsmsCountNumbers;
begin
  F.Http:=self.Http;
  Result:=F.GetCountNumb(Servis,Contry);
end;

function TsmsSmsHubOrg.ExpNumb(Servis,Contry,CodeContryNumberOld,NumberOld:string):TsmsGetNumb;
var G:TsmsCheckOldNumb;
begin
  F.Http:=self.Http;
  if NumberOld<>'' then
  begin
     G:=F.GetNumbOldCheck(Servis,Contry,NumberOld);
     if G.IsGood and (G.SeanseIdOld<>'') then
      Result:= F.GetNumbOld(Servis,Contry,CodeContryNumberOld,NumberOld)
      else
      begin
        AmRecordHlp.RecFinal(Result);
        Result.IsGood:= false;
        Result.Error:= G.Error;
      end;
  end
  else
  Result:=F.GetNumbNew(Servis,Contry);
end;

function TsmsSmsHubOrg.ExpPrice(Servis, Contry: string): TsmsPriceNumb;
begin
  F.Http:=self.Http;
  Result:=F.GetPrice(Servis,Contry);
end;

function TsmsSmsHubOrg.ExpServies(L: PsmsServisList):boolean;
begin
  F.Http:=self.Http;
  F.GetServies(L);
  Result:=true;
end;

function TsmsSmsHubOrg.ExpServiesToList(L: TStrings):boolean;
begin
  F.Http:=self.Http;
  F.GetServiesToList(L);
  Result:=true;
end;

function TsmsSmsHubOrg.ExpSms(Context: TsmsContextNumber): TsmsGetSms;
begin
  F.Http:=self.Http;
  Result:= F.GetSms(Context.Servis,Context.Contry,Context.SeanseId);
end;

function TsmsSmsHubOrg.ExpNextSms(Context:TsmsContextNumber):TsmsGetClear;
begin
  F.Http:=self.Http;
  Result:= F.GetClearSms(Context.Servis,Context.Contry,Context.SeanseId);
end;
function  TsmsSmsHubOrg.ExpSmsCancelOk(Context:TsmsContextNumber):TsmsCancel;
begin
  F.Http:=self.Http;
  Result:= F.CancelOkNumb(Context.Servis,Context.Contry,Context.SeanseId);
end;

function TsmsSmsHubOrg.MinutesTimeLifeNumbers: Integer;
begin
  Result:=15;
end;
function TsmsSmsHubOrg.UrlBaseGet: string;
begin
   Result:= F.LinkUrl;
end;



{ Tsms5SimNet }
function Tsms5SimNet.AutoContryToId(Value: TsmsAutoContry): string;
begin
   F.Http:=self.Http;
   Result:=F.AutoContryToId(Value);
end;

function Tsms5SimNet.AutoProductToId(Value: TsmsAutoProduct): string;
begin
   F.Http:=self.Http;
   Result:=F.AutoProductToId(Value);
end;

constructor Tsms5SimNet.Create(AOwner:TsmsMain;ATyp:TsmsTypeSite;AToken:string);
begin
  inherited Create(AOwner,ATyp,AToken);
   F:=TObj5SimNet.Create;
   F.Http:=self.HttpVar;
   F.ApiToken:= Token;
end;

destructor Tsms5SimNet.Destroy;
begin
  inherited Destroy;
  FreeAndNil(F);
end;

procedure Tsms5SimNet.TokenSet(const Value: string);
begin
  inherited;
   F.ApiToken:=  Value;
end;

procedure Tsms5SimNet.HttpSet(const Value: TamHttp);
begin
  inherited;
  F.Http:=self.Http;
end;

function Tsms5SimNet.ExpCancelBanNumb(Context: TsmsContextNumber): TsmsCancel;
begin
  F.Http:=self.Http;
  Result:= F.CancelBanNumb(Context.SeanseId);
end;

function Tsms5SimNet.ExpCancelNumb(Context: TsmsContextNumber): TsmsCancel;
begin
  F.Http:=self.Http;
  Result:= F.CancelNumb(Context.SeanseId);
end;

function Tsms5SimNet.ExpBalance: TsmsBalance;
begin
 F.Http:=self.Http;
 Result:= F.GetBalance;
end;

function Tsms5SimNet.ExpContries(L: PsmsContryList):boolean;
begin
  F.Http:=self.Http;
  F.GetContries(L);
  Result:=true;
end;

function Tsms5SimNet.ExpContriesToList(L: TStrings):boolean;
begin
   F.Http:=self.Http;
   F.GetContriesToList(L);
   Result:=true;
end;

function Tsms5SimNet.ExpCountNumb(Servis, Contry: string): TsmsCountNumbers;
begin
  F.Http:=self.Http;
  Result:=F.GetCountNumb(Servis,Contry);
end;

function Tsms5SimNet.ExpNumb(Servis,Contry,CodeContryNumberOld,NumberOld:string):TsmsGetNumb;
//var G:TsmsCheckOldNumb;
begin
  F.Http:=self.Http;
 if NumberOld<>'' then
  begin
      Result:= F.GetNumbOld(Servis,Contry,CodeContryNumberOld,NumberOld);
  end
  else
  Result:=F.GetNumbNew(Servis,Contry);
end;

function Tsms5SimNet.ExpPrice(Servis, Contry: string): TsmsPriceNumb;
begin
  F.Http:=self.Http;
  Result:=F.GetPrice(Servis,Contry);
end;

function Tsms5SimNet.ExpServies(L: PsmsServisList):boolean;
begin
  F.Http:=self.Http;
  F.GetServies(L);
  Result:=true;
end;

function Tsms5SimNet.ExpServiesToList(L: TStrings):boolean;
begin
  F.Http:=self.Http;
  F.GetServiesToList(L);
  Result:=true;
end;

function Tsms5SimNet.ExpSms(Context: TsmsContextNumber): TsmsGetSms;
begin
  F.Http:=self.Http;
  Result:= F.GetSms(Context.SmsList,Context.SeanseId);
end;

function Tsms5SimNet.ExpNextSms(Context:TsmsContextNumber):TsmsGetClear;
begin
  F.Http:=self.Http;
  Result:= F.GetClearSms(Context.SeanseId);
end;
function  Tsms5SimNet.ExpSmsCancelOk(Context:TsmsContextNumber):TsmsCancel;
begin
  F.Http:=self.Http;
  Result:= F.CancelOkNumb(Context.SeanseId);
end;

function Tsms5SimNet.MinutesTimeLifeNumbers: Integer;
begin
  Result:=15;
end;
function Tsms5SimNet.UrlBaseGet: string;
begin
   Result:= F.LinkUrl;
end;

{ smsAuto }
constructor TsmsAuto.Create;
begin
  inherited ;
  Context:=nil;
  DefaultThread.Subscribe(self);
end;

procedure TsmsAuto.Delete;
begin
  if Assigned(Context) then
  FreeAndNil(Context);
end;

destructor TsmsAuto.Destroy;
begin
  Delete;
  inherited;
end;

function TsmsAuto.IsAlive: boolean;
begin
  Result:= Assigned(Context) and Context.IsAlive;
end;

function TsmsAuto.NewContext(P: PPrm): TsmsContextNumber;
var IndexSite:integer;
   procedure LocLog(s:string);
   begin
    P.Main.Log('[smsAuto.NewContext] '+s );
   end;
   function LocGetNextSite:ISmsSite;
   begin
      Result:=nil;
      try
        if length(P.PriortySite)>0 then
        begin
          while IndexSite < length(P.PriortySite)   do
          begin
             if P.PriortySite[IndexSite] <> smsSiteNone then
             begin
               Result:=P.Main.SiteTyp[P.PriortySite[IndexSite]];
               if Result<>nil then
               break;
             end;
             inc(IndexSite);
          end;
        end
        else
        begin
          if IndexSite<1 then
          IndexSite:=1;
          while IndexSite < P.Main.EnumCount   do
          begin
              Result:=P.Main.SiteTyp[TsmsTypeSite(IndexSite)];
              if Result<>nil then
              break;
             inc(IndexSite);
          end;
        end;
      finally
         inc(IndexSite);
      end;
   end;
   var Site:ISmsSite;
       Servis,Contry:string;
       prd,cnt:integer;
       Balance:TsmsBalance;
       CountNumb:TsmsCountNumbers;
       Price:TsmsPriceNumb;
begin
   Result:=nil;
   Delete;
   try

      IndexSite:=0;
      if not Assigned(P) then exit;
      if Length(P.Product)<=0 then exit;
      if Length(P.Contries)<=0 then exit;
      if not Assigned(P.Main) then exit;
      if P.maxPriceNumber<=0 then exit;
      if P.minCountNumber<=0 then exit;

      while True do
      begin
        if self.GetThreadTerminated then
        exit;
        Site:=LocGetNextSite;
        if not Assigned(Site) then break;

        if Trim(Site.TokenGet)='' then
        continue;

        Balance:=Site.GetBalance;
        if not Balance.IsGood then
        begin
          locLog('не получен баланс для Site.Typ = ' +P.Main.EnumToStr(Site.TypGet) );
          continue;
        end;
        if Balance.Value<3 then
        begin
          locLog('баланс меньше 3р. для Site.Typ = ' +P.Main.EnumToStr(Site.TypGet) );
          continue;
        end;

        for prd := 0 to length(P.Product)-1 do
        for cnt := 0 to length(P.Contries)-1 do
        begin
           if self.GetThreadTerminated then
           exit;

            sleep(math.RandomRange(500,1500));
            Servis:=   Site.AutoProductToId(P.Product[prd]);
            Contry:=   Site.AutoContryToId(P.Contries[cnt]);
            if Servis.IsEmpty or Contry.IsEmpty then
            begin
              locLog('не распознан сервис страна для Site.Typ = ' +P.Main.EnumToStr(Site.TypGet) );
              continue;
            end;
            CountNumb:=Site.GetCountNumb(Servis,Contry);
            if not CountNumb.IsGood then
            begin
                locLog('не получено кол-во номеров  для Site.Typ = ' +P.Main.EnumToStr(Site.TypGet) +' Servis='+Servis+' Contry='+Contry );
                continue;
            end;
            if CountNumb.Online<P.minCountNumber then
            continue;
            Price:=Site.GetPrice(Servis,Contry);
            if not Price.IsGood then
            begin
                locLog('не получена цена номера  для Site.Typ = ' +P.Main.EnumToStr(Site.TypGet) +' Servis='+Servis+' Contry='+Contry );
                continue;
            end;
            if Price.Price>P.maxPriceNumber then
            continue;
            if Balance.Value<Price.Price then
             continue;
            Result:=Site.GetNumberNew(Servis,Contry);
            if Result<>nil then
            exit;
        end;
      end;

   finally
    Context:=Result;
   end;
end;

procedure TsmsAuto.Notification(Source: TAmObjectNotify; Msg: TAmOperation; W,
  L: Cardinal);
begin
  inherited Notification(Source,Msg,W,L);
  if (Source = self.DefaultThread) and ( smsOperation.DestroyContext = Msg)  and (TsmsContextNumber(L) = Context) then
  Context:=nil;
end;

class procedure TsmsAuto.AutoContryToList(L: TStrings);
var C:integer;
  I: Integer;
begin
   C:= Integer(System.High(TsmsAutoContry))+1;
   L.BeginUpdate;
   try
      L.Clear;
      for I := 0 to C-1 do
      L.Add(AmRttiConvectrer.EnumToString(TsmsAutoContry(i)));
   finally
     L.EndUpdate;
   end;
end;

class procedure TsmsAuto.AutoProductToList(L: TStrings);
var C:integer;
  I: Integer;
begin
   C:= Integer(System.High(TsmsAutoProduct))+1;
   L.BeginUpdate;
   try
      L.Clear;
      for I := 0 to C-1 do
      L.Add(AmRttiConvectrer.EnumToString(TsmsAutoProduct(i)));
   finally
     L.EndUpdate;
   end;
end;

function TsmsAuto.Cancel(): TsmsCancel;
begin
   AmRecordHlp.RecFinal(Result);
   if Context = nil  then
   begin
      Result.Error:='Нет Context';
      exit;
   end;
  Result:= Context.CancelTry;
end;

function TsmsAuto.SmsNext(): TsmsGetClear;
begin
   AmRecordHlp.RecFinal(Result);
   if Context = nil  then
   begin
      Result.Error:='Нет Context';
      exit;
   end;
   Result:= Context.SmsNext;
end;

function TsmsAuto.SmsWaitFor( MaxTimeOutSeconds: Cardinal): TsmsGetSms;
var i:Cardinal;
begin
   AmRecordHlp.RecFinal(Result);
   if Context = nil  then
   begin
      Result.Error:='Нет Context';
      exit;
   end;
   i:=0;
   while i< MaxTimeOutSeconds do
   begin

      if self.GetThreadTerminated then
      exit;
      if not Context.IsAlive then
      begin
         Result.IsGood:=false;
         Result.StatusGood:=false;
         Result.Error:='Время получения смс истекло';
        exit;
      end;

      Result.IsGood:=true;
      Result.StatusGood:=false;
      if Context.SmsGetNowIs then
      begin
        Result:= Context.SmsGet;
        if Result.IsGood and Result.StatusGood then
        break;
      end;
      sleep(1000);
      inc(i);
   end;
   if i>=MaxTimeOutSeconds then
   begin
      if not Result.IsGood or not  Result.StatusGood then
      Result.Error:=  Result.Error+'Вышло время ожидания получения смс';
   end;
end;

initialization
begin

  TAmObjectNotify.RegGlobalNew(smsOperation.User,'AmOperation.User');
  TAmObjectNotify.RegGlobalNew(smsOperation.CreateContext,'smsOperation.CreateContext');
  TAmObjectNotify.RegGlobalNew(smsOperation.DestroyContext,'smsOperation.DestroyContext');
  TAmObjectNotify.RegGlobalNew(smsOperation.CreateSite,'smsOperation.CreateSite');
  TAmObjectNotify.RegGlobalNew(smsOperation.DestroySite,'smsOperation.DestroySite');
  TAmObjectNotify.RegGlobalNew(smsOperation.CreateMain,'smsOperation.CreateMain');
  TAmObjectNotify.RegGlobalNew(smsOperation.DestroyMain,'smsOperation.DestroyMain');
  TAmObjectNotify.RegGlobalNew(smsOperation.ClearBeforeMain,'smsOperation.ClearBeforeMain');
  TAmObjectNotify.RegGlobalNew(smsOperation.StatusChangeSite,'smsOperation.StatusChangeSite');
end;

end.
