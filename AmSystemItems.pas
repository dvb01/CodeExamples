unit AmSystemItems;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Controls,Forms,
  Dialogs, SyncObjs, Winapi.WinSock,IOUtils,math,
  System.Generics.Collections,
  ShellApi,System.WideStrUtils,
  AmSystemBase,AmSystemObject,
  AmInterfaceBase,AmSystemListBase;

type



  TAmItemObject =class;
  TAmItemClass =   class of TAmItemObject;

  TAmItemsEnum = (lcInvalid,
                lcChangeCustom,//любое другое изменение листа
                lcChangeItem,//изменение в самом одном итеме
                lcClassItem,
                lcChildItemAdd,
                lcChildItemRemoving,
                lcChildItemRemoved,
                lcSetCountB,
                lcSetCount,
                lcUpdate,
                lcClearB,
                lcClear,
                lcDeleteB,
                lcDelete,
                lcExtractB,
                lcExtract,
                lcExchangeB,
                lcExchange,
                lcInsertB,
                lcInsert,
                lcMoveB,
                lcMove,
                lcPutB,
                lcPut,
                lcAssignB,
                lcAssign);
  PAmItemsPrm =^TAmItemsPrm;
  TAmItemsPrm = record
     var Enum:TAmItemsEnum;
         procedure Clear;
     case TAmItemsEnum of
          lcInvalid,lcClearB,lcClear,lcChangeCustom:();
          lcSetCount,lcSetCountB:(CountOld,CountNew:integer);
          lcChildItemAdd,lcChildItemRemoving,lcChildItemRemoved: (ItemChild:TObject);
          lcChangeItem:(Operation:integer;Item:TObject);
          lcClassItem :(AClass:TAmItemClass);
          lcUpdate:(Updating:boolean);
          lcDeleteB,lcDelete,lcExtractB,lcExtract:(Index:integer);
          lcInsertB,lcInsert,lcPutB,lcPut: (IndexVar:integer;PVar:PPointer{Pinterface});
          lcExchangeB,lcExchange,lcMoveB,lcMove:(Index1{cur},Index2{new}: Integer);
       //   lcAssignB,lcAssign: (Source:IAmListEmulObject);

   end;




  IAmListItemOwner =  interface;
  IAmListItemOwnerPointer  = Pointer; // = IAmListItemOwner


  IAmItem =  interface (IAmBase)
  ['{1E5C41F9-031B-4690-878B-0B002B5D8470}']
   //private
      function  ListGet: IAmListItemOwner;
      procedure ListSet(const Value: IAmListItemOwner);
      function  ItemIdGet:Cardinal;
      procedure ItemIdSet(const Value:Cardinal);
      function  ItemIndexFieldGet: Integer;
      procedure ItemIndexFieldSet(const Value: Integer);
      function  ItemIndexGet: Integer;
      procedure ItemIndexSet(const Value: Integer);
      function  ItemIndivGet: integer;
      procedure ItemIndivSet(const Value: integer);
   //protected
      procedure Changed(Operation:Integer);
      procedure ListRelease; // используется для List=nil или Tobject.Free что именно  решается в самом объекте
      procedure Loaded;// событие после загрузки с ресурса формы вызовется у компонента а сюда лист передаст
   //public
      property List: IAmListItemOwner read ListGet write ListSet;
      property ItemId: Cardinal read ItemIdGet write ItemIdSet;
      property ItemIndex: Integer read ItemIndexGet write ItemIndexSet;
      property ItemIndiv: integer read ItemIndivGet write ItemIndivSet;

      //help  можно вернуть все 0
      function AsPers:TPersistent; // если нужно что бы сохранялось и загружалось на автомате то вернуть что то
      function AsObj:TObject;
      function AsRef(Value:Cardinal):Cardinal;// произвольное получение чего то с объекта
  end;

   // интерфейс списка для внешнего использования
  IAmListItem =  interface (IAmListBase<IAmItem>)
  ['{04813327-BCE6-43C8-A301-1ABD9E050C6B}']
     function EmulListOwner:IAmListItemOwner;
     function IndexOfId(AId:Cardinal): Integer;
  end;

  // внутрениий интерфейс списка внешне не использать
  // разве что можно вызывать GetList
  IAmListItemOwner  =  interface (IAmListEmulEx<IAmItem>)
  ['{FE613C18-56F1-4DBA-B4EF-F304A1582EC5}']
    function  GetList:IAmListItem;
    procedure EmulAdd(Item:IAmItem);
    procedure EmulRemove(Item:IAmItem);
    function  EmulGetNextId:Cardinal;
    procedure EmulChangeItem(Item:IAmItem;Operation:integer);
  end;



  // события которые происходят в Item
  // можно унаследоватся что бы расщирить своими
  AmItemOperation = class
    const  IndexChange = 1;
    const  IndexSet= 2;
    const  ChangeListAfter= 3;
    const  ChangeListBefore= 4;
    const  IndivSet= 5;
    const  Loaded= 6;
  end;
  // для упрощенного создания объекта с интерфесом IAmItem
  // можно тупо скопировать код с TAmItemObject или  TAmItemPersInf
  AmItemHelp =class
   private
    class procedure IndexCurrentSetter(Item:IAmItem);
   public
    //IAmItem
    class procedure ListRelease(Item:IAmItem);
    class function  ListSet(Item:IAmItem;var Field:IAmListItemOwnerPointer; const NewValue: IAmListItemOwner):boolean;
    class function  IndexGet(Item:IAmItem): Integer;
    class procedure IndexSet(Item:IAmItem;const Value: Integer);
    class procedure Changed(Item:IAmItem;Operation:Integer);

    class function GetComponentOwner(Item:IAmItem):TComponent;
    class function GetControlParent(Item:IAmItem):TWinControl;
    class function GetSelfPers(Item:IAmItem):TPersistent;
    class function GetSelfObj(Item:IAmItem):TObject;
  end;


  // ниже разные IAmItem для разных целей
  // разница меж ними что они унаследованы от разных классов
  // которые имеют разный функциолал управления подсчета ссылок
  TAmItemObject =class (TAmInterfacedObject,IAmItem)
    private
      FId:Cardinal;
      FIndex:Integer;
      FIndiv:Integer;
      FList:IAmListItemOwnerPointer;

      //IAmItem
      function  IAmItem.ListGet           = iListGet;
      procedure IAmItem.ListSet           = iListSet;
      function  IAmItem.ItemIdGet         = iItemIdGet;
      procedure IAmItem.ItemIdSet         = iItemIdSet;
      function  IAmItem.ItemIndexFieldGet = iItemIndexFieldGet;
      procedure IAmItem.ItemIndexFieldSet = iItemIndexFieldSet;
      function  IAmItem.ItemIndexGet      = iItemIndexGet;
      procedure IAmItem.ItemIndexSet      = iItemIndexSet;
      function  IAmItem.ItemIndivGet      = iItemIndivGet;
      procedure IAmItem.ItemIndivSet      = iItemIndivSet;
      procedure IAmItem.ListRelease       = ListRelease;
      procedure IAmItem.Loaded            = iLoaded;
      procedure IAmItem.Changed           = ItemChanged;
      function  IAmItem.AsPers            = iAsPers;
      function  IAmItem.AsObj             = iAsObj;
      function  IAmItem.AsRef             = iAsRef;
      function  iListGet: IAmListItemOwner;
      procedure iListSet(const Value: IAmListItemOwner);
      function  iItemIdGet:Cardinal;
      procedure iItemIdSet(const Value:Cardinal);
      function  iItemIndexFieldGet: Integer;
      procedure iItemIndexFieldSet(const Value: Integer);
      function  iItemIndexGet: Integer;
      procedure iItemIndexSet(const Value: Integer);
      function  iItemIndivGet: Integer;
      procedure iItemIndivSet(const Value: Integer);
      procedure iLoaded;
    protected
      function iAsPers:TPersistent;dynamic;
      function iAsObj:TObject; dynamic;
      function iAsRef(Value:Cardinal):Cardinal; dynamic;
      //IAmItem используется когда что то в объекте поменялось
      procedure ItemChanged(Operation:Integer); virtual;
    public
      constructor  Create(AListOwner:IAmListItemOwner);virtual;
      destructor Destroy; override;
      procedure ListRelease;  virtual;
      property ItemId: Cardinal read iItemIdGet;
      property List: IAmListItemOwner read iListGet write iListSet;
      property Index: Integer read iItemIndexGet write iItemIndexSet;
      property Indiv: Integer read iItemIndivGet write iItemIndivSet;
  end;

  TAmItemPersInf = class (TAmPersInf,IAmItem)
    private
      FId:Cardinal;
      FIndex:Integer;
      FIndiv:Integer;
      FList:IAmListItemOwnerPointer;

      //IAmItem
      function  IAmItem.ListGet           = iListGet;
      procedure IAmItem.ListSet           = iListSet;
      function  IAmItem.ItemIdGet         = iItemIdGet;
      procedure IAmItem.ItemIdSet         = iItemIdSet;
      function  IAmItem.ItemIndexFieldGet = iItemIndexFieldGet;
      procedure IAmItem.ItemIndexFieldSet = iItemIndexFieldSet;
      function  IAmItem.ItemIndexGet      = iItemIndexGet;
      procedure IAmItem.ItemIndexSet      = iItemIndexSet;
      function  IAmItem.ItemIndivGet      = iItemIndivGet;
      procedure IAmItem.ItemIndivSet      = iItemIndivSet;
      procedure IAmItem.ListRelease       = ListRelease;
      procedure IAmItem.Changed           = ItemChanged;
      procedure IAmItem.Loaded            = iLoaded;
      function  IAmItem.AsPers            = iAsPers;
      function  IAmItem.AsObj             = iAsObj;
      function  IAmItem.AsRef             = iAsRef;

      function  iListGet: IAmListItemOwner;
      procedure iListSet(const Value: IAmListItemOwner);
      function  iItemIdGet:Cardinal;
      procedure iItemIdSet(const Value:Cardinal);
      function  iItemIndexFieldGet: Integer;
      procedure iItemIndexFieldSet(const Value: Integer);
      function  iItemIndexGet: Integer;
      procedure iItemIndexSet(const Value: Integer);
      function  iItemIndivGet: Integer;
      procedure iItemIndivSet(const Value: Integer);
      procedure iLoaded;
    protected
      function iAsPers:TPersistent;dynamic;
      function iAsObj:TObject; dynamic;
      function iAsRef(Value:Cardinal):Cardinal; dynamic;

      //IAmItem используется когда что то в объекте поменялось
      procedure ItemChanged(Operation:Integer); virtual;
    public
      constructor  Create(AListOwner:IAmListItemOwner);virtual;
      destructor Destroy; override;
      procedure ListRelease;  virtual;
      property ItemId: Cardinal read iItemIdGet;
      property List: IAmListItemOwner read iListGet write iListSet;
      property Index: Integer read iItemIndexGet write iItemIndexSet;
    published
      property Indiv: Integer read iItemIndivGet write iItemIndivSet;
  end;
  {
  TAmItemInf = class (TAmInf,IAmItem)

  end;}

  TAmItemComponent = class (TAmComponent,IAmItem)
    private
      FId:Cardinal;
      FIndex:Integer;
      FIndiv:Integer;
      FList:IAmListItemOwnerPointer;

      //IAmItem
      function  IAmItem.ListGet           = iListGet;
      procedure IAmItem.ListSet           = iListSet;
      function  IAmItem.ItemIdGet         = iItemIdGet;
      procedure IAmItem.ItemIdSet         = iItemIdSet;
      function  IAmItem.ItemIndexFieldGet = iItemIndexFieldGet;
      procedure IAmItem.ItemIndexFieldSet = iItemIndexFieldSet;
      function  IAmItem.ItemIndexGet      = iItemIndexGet;
      procedure IAmItem.ItemIndexSet      = iItemIndexSet;
      function  IAmItem.ItemIndivGet      = iItemIndivGet;
      procedure IAmItem.ItemIndivSet      = iItemIndivSet;
      procedure IAmItem.ListRelease       = ListRelease;
      procedure IAmItem.Changed           = ItemChanged;
      procedure IAmItem.Loaded            = iLoaded;
      function  IAmItem.AsPers            = iAsPers;
      function  IAmItem.AsObj             = iAsObj;
      function  IAmItem.AsRef             = iAsRef;
      function  iListGet: IAmListItemOwner;
      procedure iListSet(const Value: IAmListItemOwner);
      function  iItemIdGet:Cardinal;
      procedure iItemIdSet(const Value:Cardinal);
      function  iItemIndexFieldGet: Integer;
      procedure iItemIndexFieldSet(const Value: Integer);
      function  iItemIndexGet: Integer;
      procedure iItemIndexSet(const Value: Integer);
      function  iItemIndivGet: Integer;
      procedure iItemIndivSet(const Value: Integer);
      procedure iLoaded;
    protected
      function iAsPers:TPersistent;dynamic;
      function iAsObj:TObject; dynamic;
      function iAsRef(Value:Cardinal):Cardinal; dynamic;

      //IAmItem используется когда что то в объекте поменялось
      procedure ItemChanged(Operation:Integer); virtual;
    public
      constructor  Create(AOwner:TComponent);override;
      destructor Destroy; override;
      procedure ListRelease;  virtual;
      property ItemId: Cardinal read iItemIdGet;
      property List: IAmListItemOwner read iListGet write iListSet;
      property Index: Integer read iItemIndexGet write iItemIndexSet;
    published
      property Indiv: Integer read iItemIndivGet write iItemIndivSet;
  end;



 // универсальный лист для разных пронумарованных объектов
 // 1. имеет события на каждое действие
 // 2. может хранит все что угодно унаследованное от  IAmItem
 // IAmItem оч просто создается в любом вашем классе можно посмотеть пример TAmItemObject
 // 3. выше есть часто используемые классы Которые можно впихивать в  TAmListItem
 // 4. Если вы не пользуетесь IAmListItem то используйте  TAmListItemObj иначе  TAmListItemInf
 // TAmListItemObj удаляется только через TObject.Free;
 // TAmListItemInf через кол-во ссылок interface(TAmListItemInf) =nil
 // 5. в листе не может быть дубликатов
 // 6. лист напрямую не удаляет свои итемы а вызывает IAmItem.ListRelease  а там уже сами делаете нужно действие free например или List :=nil
  TAmListItemCustom = class abstract (TAmListBaseInterfaced<IAmItem>,IAmListItem,IAmListItemOwner)
    type
     TEventCreate = procedure (var NewItem:IAmItem)of object;
   private
   //  FItemClass:TAmItemClass;
     FList: TList<IAmItem>;
     FIdCounter:Cardinal;
     FNeedEvent:boolean;
     FEventCreate:TEventCreate;
     FLockChange:Integer;
    //IAmListItemOwner
     function EmulGetNextId:Cardinal;
     procedure EmulAdd(Item:IAmItem);
     procedure EmulRemove(Item:IAmItem);
     function EmulIndexOf(Value:IAmItem):integer;
     function EmulGetCount:integer;
     function EmulGet(Index:integer):IAmItem;
     function EmulHas(Index:integer):boolean;
     procedure EmulMove(CurIndex, NewIndex: Integer);
     function EmulListOwner:IAmListItemOwner;
     procedure EmulChangeItem(Item:IAmItem;Operation:integer);
     function IAmListItemOwner.GetList = EmulGetList;
     function EmulGetList:IAmListItem;

     procedure InternalItemCreate(var NewItem:IAmItem);
     procedure InternalInsert(Index: Integer; const Item: IAmItem);
     procedure InternalPut(Index: Integer; const Item: IAmItem);
     procedure InternalDelete(Index: Integer);
    // procedure InternalRemove(NewItem:IAmItem);
     function  InternalExtract(Index: Integer):IAmItem;
     procedure InternalClear;

     procedure ChangeLock;
     procedure ChangeUnLock;
   protected
     procedure Changed(Prm:PAmItemsPrm);virtual;
     procedure DoChanged(Prm:PAmItemsPrm); virtual;
     //IAmListBase
     function Get(Index: Integer): IAmItem; override;
     function GetCount: Integer; override;
     procedure Put(Index: Integer; Item: IAmItem);override;
     procedure SetCount(NewCount: Integer); override;
     function UpdateCountGet:integer;override;
    // procedure LockCs; override;
    // function LockTryCs:boolean;override;
    // procedure UnLockCs; override;
     //
     procedure DoUpdate; override;
     procedure ItemCreate(var NewItem:IAmItem);virtual;
   public
   // property ItemClass: TAmItemClass read FItemClass write FItemClass;
    property NeedEvent: boolean read FNeedEvent write FNeedEvent;
    constructor  Create();
    destructor Destroy; override;
    procedure BeforeDestruction;override;
    function IsMyChildObject(ACheckObject:TObject):boolean; override;
    function SupObjToItem(Obj:TObject;IsError:boolean=true):IAmItem;virtual;
    procedure Clear;override;
    function Has(Index:integer):boolean;
    procedure Delete(Index: Integer); override;
    function Extract(Index: Integer):IAmItem; virtual;
    procedure Exchange(Index1, Index2: Integer); override;
    procedure Move(CurIndex, NewIndex: Integer); override;
    procedure Insert(Index: Integer;Item: IAmItem); override;
    function InsertNew(Index:integer) :IAmItem; override;
    function IndexOf(Item: IAmItem): Integer; override;
    function IndexOfId(AId:Cardinal): Integer;
    function Add(Item: IAmItem): Integer; override;
    function AddNew :IAmItem;override;
    function NewItem:IAmItem;virtual;
    function Remove(Item: IAmItem): Integer;override;
    procedure UpdateBegin;override;
    procedure UpdateEnd;override;
    property Count: integer read GetCount write SetCount;
    property Items[Index:integer]: IAmItem read Get write Put; default;
    property UpdateCount: integer read UpdateCountGet;

    // в событии нужно создать один элемент
    property OnItemCreate: TEventCreate read FEventCreate write FEventCreate;
  end;

  // если нужно что бы при удалении объекта не проверялось кол-во ссылок на интерфейс
  // т.е когда основная ссылка на объект это  TAmListItemObj
  // тогда (т.е его надо удалять явно через free)
  TAmListItemObj = class (TAmListItemCustom)
    private
    public
     procedure AfterConstruction; override;
     procedure BeforeDestruction;override;
  end;
  // иначе  (этот сам удалится )
  TAmListItemInf = class (TAmListItemCustom)
  end;

  //TAmListItemPers его надо удалять явно через free
  // имеет способность сохранять в файл формы все итемы если они TPersistent и выше
  // что бы выполнялось сох и загрузка запустить в root компонете когда у него вызывается DefineProperties

  TAmListItemPers = class (TAmListItemObj)//IAmListColection
    private type
         TLocWriter =class (TWriter);
         TLocReader =class (TReader);
    protected
      procedure ReadData(Reader: TReader); virtual;
      procedure WriteData(Writer: TWriter);virtual;
      // когда   IAmItem не TPersistent то сохр самому и вернуть было ли сохранено   если верунть false то сохранится или загрузится nil
      function WriteInvalidClass(Index:integer;Item:IAmItem;Writer: TWriter):boolean; virtual;
      function ReadCreateItem(AClassName:string;AClass:TClass):IAmItem; virtual;
      procedure ReadInvalidClass(Item:IAmItem;Reader: TReader); virtual;
    public
      procedure Loaded;virtual; //запустить в root при  TComponent.Loaded
      procedure DefineProperties(СonsequenceNameProperty:string;Filer: TFiler); virtual;
  end;


  //TAmListItemColection также поддерживает интерфейс IAmListColection для управления итемами в режиме разработки
  //IAmListColection  если not  item[index] is TPersistent  то вернет nil
  // а добавлять можно любые итемы  IAmItem
  // если добавить TPersistent который не поддерживает IAmItem будет ошибка
  // удалять так
  // FPersDesingNotify.Free;
  // FPersDesingNotify:=nil;

  TAmListItemColection = class (TAmListItemPers,IAmListColection)
   private
      FPersDesingNotify:TAmPersDesingNotifyHelp;
      procedure PersDesingNotifyGetOwner(Sender:TObject;var AOwner:TPersistent);

     //IAmListColection
      function IAmListColection.Get = wcGet;
      procedure IAmListColection.Put = wcPut;
      function IAmListColection.IndexOf = wcIndexOf;
      function IAmListColection.Remove = wcRemove;
      function IAmListColection.Add = wcAdd;
      function IAmListColection.AddNew = wcAddNew;
      procedure IAmListColection.Insert = wcInsert;
      function IAmListColection.InsertNew = wcInsertNew;

      function wcGet(Index: Integer): TPersistent;
      procedure wcPut(Index: Integer; Item: TPersistent);
      function wcIndexOf(Item: TPersistent): Integer;
      function wcAdd(Item: TPersistent): Integer;
      function wcAddNew :TPersistent;
      procedure wcInsert(Index: Integer; Item: TPersistent);
      function wcInsertNew(Index:integer) :TPersistent;
      function wcRemove(Item: TPersistent): Integer;
      function AsPersDesingNotify:TPersistent;
   protected
     procedure Changed(Prm:PAmItemsPrm);override;
     procedure DoChanged(Prm:PAmItemsPrm); override;

     //IAmListColection
      // в наследниках перекрыть
     function GetComponentRoot:TComponent; virtual;
     function GetOwner:TPersistent;   virtual;

     //////////////////////////////////////

     
   public
      constructor Create;
      Destructor Destroy;override;
      function IsMyChildObject(ACheckObject:TObject):boolean; override;
  end;






  //////////////////////////////////////////////////////////////////////////////
  ///
  ///                           Grid
  ///
  //////////////////////////////////////////////////////////////////////////////
  IAmGridLine  = interface;
  IAmGrid  = interface;

   IAmGridBase =  interface (IAmBase)
     ['{0B6469AB-8436-4B8B-AD85-0EC14370AD5D}']
      // вернуть self объект или же см IAmListColection и TAmPersDesingNotifyHelp
      function AsPersDesingNotify:TPersistent;
      function AsItem:IAmItem;
      function IdGet:Cardinal;
      function RectClientGet:TRect;
      property Id: Cardinal read IdGet;
      procedure Release;
      property RectClient: TRect read RectClientGet;

   end;
   IAmGridItem = interface (IAmGridBase)
   ['{12E78FF8-0EDE-4FFC-B8FF-EAB8E2A98934}']
      function IndexLineGet:integer;
      procedure IndexLineSet(const Value:integer);
      function IndexItemGet:integer;
      procedure IndexItemSet(const Value:integer);
      function ControlGet:TControl;
      procedure ControlSet(const Value:TControl);
      function WidthGet:integer;
      procedure WidthSet(const Value:integer);
      function HeightGet:integer;
      procedure HeightSet(const Value:integer);
      function TextGet:string;
      procedure TextSet(const Value:string);
      function ParentLineGet:IAmGridLine;

      property IndexLine: integer read IndexLineGet write IndexLineSet;
      property IndexItem: integer read IndexItemGet write IndexItemSet;
      property Control: TControl read ControlGet write ControlSet;
      property Width: integer read WidthGet write WidthSet;
      property Height: integer read HeightGet write HeightSet;
      property Text: string read TextGet write TextSet;

      property ParentLine: IAmGridLine read ParentLineGet;
   end;
   IAmGridLine =  interface (IAmGridBase)
   ['{FD63AFC9-52CC-4294-B4EB-7536F8B8E6A0}']
      function IndexLineGet:integer;
      procedure IndexLineSet(const Value:integer);
      function WidthGet:integer;
      procedure WidthSet(const Value:integer);
      function HeightGet:integer;
      procedure HeightSet(const Value:integer);
      function PaddingGet:integer;
      procedure PaddingSet(const Value:integer);
      function CountGet:integer;
      procedure CountSet(const Value:integer);
      function ItemsGet(index:integer):IAmGridItem;
      function ParentGridGet:IAmGrid;


      procedure Delete(AIndexItem:Integer);
      procedure Clear;
      function Insert(AIndexItem:Integer):IAmGridItem;
      function Add():IAmGridItem;
      property Width: integer read WidthGet write WidthSet;
      property Height: integer read HeightGet write HeightSet;
      property Padding: integer read PaddingGet write PaddingSet;
      property Count: integer read CountGet write CountSet;
      property Items[index:integer]: IAmGridItem read ItemsGet;
      property IndexLine: integer read IndexLineGet write IndexLineSet;
      function ItemIndexOfId(AId:Cardinal): Integer;
      function ItemIndexOf(AItem:IAmGridItem): Integer;
      property ParentGrid: IAmGrid read ParentGridGet;
   end;

   IAmGrid =  interface (IAmGridBase)
     ['{3958300C-5292-44A9-BC63-8E634F56F5EA}']
      function CellGet(AIndexLine,AIndexItem:Integer):IAmGridItem;
      function CountItemGet(AIndexLine:integer):integer;
      procedure CountItemSet(AIndexLine:integer; const Value:integer);
      function CountLineGet:integer;
      procedure CountLineSet(const Value:integer);
      function LineGet(AIndexLine:Integer):IAmGridLine;
      function ParentControlGet:TWinControl;

      procedure Update;
      property Cell[AIndexLine,AIndexItem:Integer]: IAmGridItem read CellGet;
      property CountItem[AIndexLine:Integer]: integer read CountItemGet write CountItemSet;
      property CountLine: integer read CountLineGet write CountLineSet;
      procedure Delete(AIndexLine,AIndexItem:Integer);
      procedure Clear;
      function Insert(AIndexLine,AIndexItem:Integer):IAmGridItem;
      function Add(AIndexLine:integer):IAmGridItem;

      property Line[AIndexLine:Integer]: IAmGridLine read LineGet;
      function LineAdd:IAmGridLine;
      function LineInsert(ARow:integer):IAmGridLine;
      procedure LineDelete(AIndexLine:integer);
      function LineIndexOfId(AId:Cardinal): Integer;
      function LineIndexOf(ALine:IAmGridLine): Integer;
      property ParentControl: TWinControl read ParentControlGet;


   end;




implementation



class procedure AmItemHelp.ListRelease(Item:IAmItem);
begin
  if Item<>nil then
  Item.List:=nil;
end;
class function AmItemHelp.ListSet(Item:IAmItem;var Field:IAmListItemOwnerPointer;const NewValue: IAmListItemOwner):boolean;
var L:IAmListItemOwner;
Aid:Cardinal;
begin

  Result:= (Item <> nil) and (IAmListItemOwner(AmAtomic.Getter(Field)) <> NewValue);
  if not  Result then  exit;
  Item.Changed(AmItemOperation.ChangeListBefore);
  try
    L:= IAmListItemOwner(Field);
    //AmAtomic.Setter(Field,nil);

    if L <> nil then
       L.EmulRemove(Item);

    AmAtomic.Setter(Field,pointer(NewValue));

    if NewValue <> nil then
    begin
      Aid:= NewValue.EmulGetNextId;
      Item.ItemId:= Aid;
      NewValue.EmulAdd(Item);

      if Item.ItemId <> AId then
      AmRaiseBase.__Program('Error  AmItemHelp.ListSet 2 Не верная логика вашего класса при установке List Item.ItemId <> AId');
    end
    else Item.ItemId:=0;

    if IAmListItemOwner(AmAtomic.Getter(Field)) <> NewValue then
    AmRaiseBase.__Program('Error  AmItemHelp.ListSet Не верная логика вашего класса при установке List Field<>NewValue');

  finally
    Item.Changed(AmItemOperation.ChangeListAfter);
  end;
end;


class procedure AmItemHelp.IndexCurrentSetter(Item:IAmItem);
var L:IAmListItemOwner;
index:Integer;
begin
    L:= Item.List;
    index:=  Item.ItemIndexFieldGet;
    if Assigned(L)
    and (index>=0)
    and (index<L.EmulGetCount)
    and (L.EmulGet(index) = Item) then
    begin
    end
    else  if Assigned(L) then
    begin
      Item.ItemIndexFieldSet(L.EmulIndexOf(Item));
      index:=  Item.ItemIndexFieldGet;
      if (index>=0) and (index<L.EmulGetCount) then
      begin
      end
      else Item.ItemIndexFieldSet(-1);
    end
    else Item.ItemIndexFieldSet(-1);
end;
class procedure AmItemHelp.Changed(Item: IAmItem; Operation: Integer);
begin
    if Item.List<>nil then
    Item.List.EmulChangeItem(Item,Operation);
end;
class function  AmItemHelp.IndexGet(Item:IAmItem): Integer;
begin
    IndexCurrentSetter(Item);
    Result:= Item.ItemIndexFieldGet;
end;
class procedure AmItemHelp.IndexSet(Item:IAmItem;const Value: Integer);
var Index: Integer;
    L:IAmListItemOwner;
begin
   L:= Item.List;
   if Assigned(L) then
   begin
     IndexCurrentSetter(Item);
     Index:=  Item.ItemIndexFieldGet;
     if (Index >= 0) and (Index <> Value) then
     begin
      L.EmulMove(Index, Value);
      Item.ItemIndexFieldSet(Value);
      Item.Changed(AmItemOperation.IndexSet);
     end;
   end
   else Item.ItemIndexFieldSet(-1);
end;

 type TLocTPersistent=class(TPersistent);
class function AmItemHelp.GetComponentOwner(Item: IAmItem): TComponent;
var P:TPersistent;
begin
    Result:=nil;
    P:=  GetSelfPers(Item);
    while (Result = nil) and (P<>nil) do
    begin
       if P is TControl  then
          P:= TControl(P).Parent
       else if P is TComponent then
         P:= TComponent(P).Owner
       else P:= TLocTPersistent(P).GetOwner;

       if (P<>nil) and (P is TComponent) then
       Result:= TComponent(P);
    end;
end;

class function AmItemHelp.GetControlParent(Item: IAmItem): TWinControl;
var P:TPersistent;
begin
    Result:=nil;
    P:=  GetSelfPers(Item);
    while (Result = nil) and (P<>nil) do
    begin
       if P is TControl  then
          P:= TControl(P).Parent
       else if P is TComponent then
         P:= TComponent(P).Owner
       else P:= TLocTPersistent(P).GetOwner;

       if (P<>nil) and (P is TWinControl) then
       Result:= TWinControl(P);
    end;
end;

class function AmItemHelp.GetSelfObj(Item: IAmItem): TObject;
begin
 Result:= Item as  TObject;
end;

class function AmItemHelp.GetSelfPers(Item: IAmItem): TPersistent;
begin
  if (Item<>nil) and (TObject(Item) is TPersistent) then
   Result:= TPersistent(Item)
  else Result:=nil;
end;

{ TAmItemComponent }
constructor TAmItemComponent.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  iItemIdSet(0);
  FList:=nil;
  FIndex:=-1;
  FIndiv:=0;
end;
destructor TAmItemComponent.Destroy;
begin
  AmItemHelp.ListRelease(self);
  inherited;
end;
procedure TAmItemComponent.ItemChanged(Operation: Integer);
begin
  AmItemHelp.Changed(self,Operation);
end;
procedure TAmItemComponent.ListRelease;
begin
   AmItemHelp.ListRelease(self);
end;
function TAmItemComponent.iItemIndexGet: Integer;
begin
  Result:=AmItemHelp.IndexGet(self)
end;
procedure TAmItemComponent.iItemIndexSet(const Value: Integer);
begin
 AmItemHelp.IndexSet(self,Value);
end;
function  TAmItemComponent.iItemIndexFieldGet: Integer;
begin
   Result:=  AmAtomic.Getter(FIndex);
end;
procedure TAmItemComponent.iItemIndexFieldSet(const Value: Integer);
begin
  if iItemIndexFieldGet<>Value then
  begin
    AmAtomic.Setter(FIndex,Value);
    ItemChanged(AmItemOperation.IndexChange);
  end;
end;
function TAmItemComponent.iItemIndivGet: Integer;
begin
  Result:= AmAtomic.Getter(FIndiv);
end;
procedure TAmItemComponent.iItemIndivSet(const Value: integer);
begin
  if iItemIndivGet <> Value then
  begin
   AmAtomic.Setter(FIndiv,Value);
   ItemChanged(AmItemOperation.IndivSet);
  end;
end;
function TAmItemComponent.iListGet: IAmListItemOwner;
begin
  Result:= IAmListItemOwner(AmAtomic.Getter(FList));
end;
procedure TAmItemComponent.iListSet(const Value: IAmListItemOwner);
begin
  AmItemHelp.ListSet(self,FList,Value);
end;
procedure TAmItemComponent.iLoaded;
begin
   ItemChanged(AmItemOperation.Loaded);
end;

function TAmItemComponent.iItemIdGet: Cardinal;
begin
  Result:= AmAtomic.Getter(FId);
end;
procedure TAmItemComponent.iItemIdSet(const Value:Cardinal);
begin
   AmAtomic.Setter(FId,Value);
end;
function TAmItemComponent.iAsPers: TPersistent;
begin
    Result:= AmItemHelp.GetSelfPers(self);
end;
function TAmItemComponent.iAsRef(Value:Cardinal):Cardinal;
begin
  Result:= 0;
end;
function TAmItemComponent.iAsObj: TObject;
begin
  Result:= self;
end;


{ TAmItemPersInf }
constructor TAmItemPersInf.Create(AListOwner: IAmListItemOwner);
begin
  inherited Create;
  iItemIdSet(0);
  FList:=nil;
  FIndex:=-1;
  FIndiv:=0;
  List:= AListOwner;

end;
destructor TAmItemPersInf.Destroy;
begin
  AmItemHelp.ListRelease(self);
  inherited Destroy;
end;
procedure TAmItemPersInf.ItemChanged(Operation: Integer);
begin
  AmItemHelp.Changed(self,Operation);
end;
procedure TAmItemPersInf.ListRelease;
begin
   AmItemHelp.ListRelease(self);
end;
function TAmItemPersInf.iItemIndexGet: Integer;
begin
  Result:=AmItemHelp.IndexGet(self)
end;
procedure TAmItemPersInf.iItemIndexSet(const Value: Integer);
begin
 AmItemHelp.IndexSet(self,Value);
end;
function  TAmItemPersInf.iItemIndexFieldGet: Integer;
begin
   Result:=  AmAtomic.Getter(FIndex);
end;
procedure TAmItemPersInf.iItemIndexFieldSet(const Value: Integer);
begin
  if iItemIndexFieldGet<>Value then
  begin
    AmAtomic.Setter(FIndex,Value);
    ItemChanged(AmItemOperation.IndexChange);
  end;
end;
function TAmItemPersInf.iItemIndivGet: Integer;
begin
  Result:= AmAtomic.Getter(FIndiv);
end;
procedure TAmItemPersInf.iItemIndivSet(const Value: integer);
begin
  if iItemIndivGet <> Value then
  begin
   AmAtomic.Setter(FIndiv,Value);
   ItemChanged(AmItemOperation.IndivSet);
  end;
end;
function TAmItemPersInf.iListGet: IAmListItemOwner;
begin
  Result:= IAmListItemOwner(AmAtomic.Getter(FList));
end;
procedure TAmItemPersInf.iListSet(const Value: IAmListItemOwner);
begin
  AmItemHelp.ListSet(self,FList,Value);
end;
procedure TAmItemPersInf.iLoaded;
begin
  ItemChanged(AmItemOperation.Loaded);
end;
function TAmItemPersInf.iItemIdGet: Cardinal;
begin
  Result:= AmAtomic.Getter(FId);
end;
procedure TAmItemPersInf.iItemIdSet(const Value:Cardinal);
begin
   AmAtomic.Setter(FId,Value);
end;
function TAmItemPersInf.iAsPers: TPersistent;
begin
    Result:= AmItemHelp.GetSelfPers(self);
end;
function TAmItemPersInf.iAsRef(Value:Cardinal):Cardinal;
begin
  Result:= 0;
end;
function TAmItemPersInf.iAsObj: TObject;
begin
  Result:= self;
end;
{ TAmItemObject }
constructor TAmItemObject.Create(AListOwner: IAmListItemOwner);
begin
  inherited Create;
  iItemIdSet(0);
  FList:=nil;
  FIndex:=-1;
  FIndiv:=0;
  List:= AListOwner;
end;
destructor TAmItemObject.Destroy;
begin
  AmItemHelp.ListRelease(self);
  inherited;
end;
procedure TAmItemObject.ItemChanged(Operation: Integer);
begin
  AmItemHelp.Changed(self,Operation);
end;
procedure TAmItemObject.ListRelease;
begin
   AmItemHelp.ListRelease(self);
end;
function TAmItemObject.iItemIndexGet: Integer;
begin
  Result:=AmItemHelp.IndexGet(self)
end;
procedure TAmItemObject.iItemIndexSet(const Value: Integer);
begin
 AmItemHelp.IndexSet(self,Value);
end;
function  TAmItemObject.iItemIndexFieldGet: Integer;
begin
   Result:=  AmAtomic.Getter(FIndex);
end;
procedure TAmItemObject.iItemIndexFieldSet(const Value: Integer);
begin
  if iItemIndexFieldGet<>Value then
  begin
    AmAtomic.Setter(FIndex,Value);
    ItemChanged(AmItemOperation.IndexChange);
  end;
end;
function TAmItemObject.iItemIndivGet: Integer;
begin
  Result:= AmAtomic.Getter(FIndiv);
end;
procedure TAmItemObject.iItemIndivSet(const Value: integer);
begin
  if iItemIndivGet <> Value then
  begin
   AmAtomic.Setter(FIndiv,Value);
   ItemChanged(AmItemOperation.IndivSet);
  end;
end;
function TAmItemObject.iListGet: IAmListItemOwner;
begin
  Result:= IAmListItemOwner(AmAtomic.Getter(FList));
end;
procedure TAmItemObject.iListSet(const Value: IAmListItemOwner);
begin
  AmItemHelp.ListSet(self,FList,Value);
end;
procedure TAmItemObject.iLoaded;
begin
   ItemChanged(AmItemOperation.Loaded);
end;

function TAmItemObject.iItemIdGet: Cardinal;
begin
  Result:= AmAtomic.Getter(FId);
end;
procedure TAmItemObject.iItemIdSet(const Value:Cardinal);
begin
   AmAtomic.Setter(FId,Value);
end;
function TAmItemObject.iAsRef(Value:Cardinal):Cardinal;
begin
  Result:= 0;
end;
function TAmItemObject.iAsPers: TPersistent;
begin
  Result:= nil;
end;
function TAmItemObject.iAsObj: TObject;
begin
  Result:= self;
end;
 { TAmListItem<T> }

constructor TAmListItemCustom.Create;
begin
 inherited Create;
 FList:= TList<IAmItem>.Create;
 FIdCounter:=0;
 FNeedEvent:=true;
 FLockChange:=0;
end;

destructor TAmListItemCustom.Destroy;
begin
  InternalClear;
  inherited Destroy;
  FreeAndNil(FList);
end;


procedure TAmListItemCustom.BeforeDestruction;
begin
    inherited BeforeDestruction;
end;

function TAmListItemCustom.IsMyChildObject(ACheckObject: TObject): boolean;
var Item:IAmItem;
begin
   Result:=false;
   if ACheckObject = nil then exit;
   Result:= inherited IsMyChildObject(ACheckObject);
   if not Result then
   begin
      Item:=  SupObjToItem(ACheckObject,false);
      if Item<>nil then Result:=  Item.List = IAmListItemOwner(self);       
   end;
end;

function TAmListItemCustom.SupObjToItem(Obj: TObject; IsError: boolean): IAmItem;
begin
   Result:=nil;
   if Obj <> nil then
   begin
    if (not Supports(Obj,IAmItem,Result) or (Result = nil)) and IsError then
    raise Exception.Create('Error TAmListItemCustom.SupObjToItem объект ['+Obj.ClassName+'] не поддерживает interface IAmItem');
   end;
end;

procedure TAmListItemCustom.EmulAdd(Item: IAmItem);
var Prm:TAmItemsPrm;
begin
  ChangeLock;
  try
    if Item = nil then
    Exception.Create('Error TAmListItemCustom.EmulAdd Item = nil');
    if Item.List <> IAmListItemOwner(self) then
    raise Exception.Create('Error TAmListItemCustom.EmulAdd Item.List <> IAmListItemOwner(self)');

    FList.Add(Item);
    if  FNeedEvent then
    begin
     Prm.Clear;
     Prm.Enum:= lcChildItemAdd;
     Prm.ItemChild:= TObject(Item);
     DoChanged(@Prm);
    end;

    
  finally
    ChangeUnLock;
  end;

end;

procedure TAmListItemCustom.EmulChangeItem(Item: IAmItem; Operation: integer);
var Prm:TAmItemsPrm;
begin
  ChangeLock;
  try
    if FNeedEvent then
    begin
     Prm.Clear;
     Prm.Enum:= lcChangeItem;
     Prm.Item:= TObject(Item);
     Prm.Operation:= Operation;
     DoChanged(@Prm);
    end;
  finally
    ChangeUnLock;
  end;

end;

procedure TAmListItemCustom.EmulRemove(Item: IAmItem);
var Prm:TAmItemsPrm;
i:integer;
begin
  ChangeLock;
  try
    if Item = nil then
    Exception.Create('Error TAmListItemCustom.EmulRemove Item = nil');
    if Count>0 then
    begin

      if FNeedEvent then
      begin
       Prm.Clear;
       Prm.Enum:= lcChildItemRemoving;
       Prm.ItemChild:= TObject(Item);
       DoChanged(@Prm);
      end;

      i:= Item.ItemIndex;
      if (i>=0) and (i<Count) and (FList[i]  = Item) then
        FList.Delete(i)
      else if  FList.Last = Item then
        FList.Delete(Count-1)
      else
        FList.Remove(Item);

      if FNeedEvent then
      begin
       Prm.Clear;
       Prm.Enum:= lcChildItemRemoved;
       Prm.ItemChild:= TObject(Item);
       DoChanged(@Prm);
      end;

    end;
  finally
    ChangeUnLock;
  end;
end;

function TAmListItemCustom.EmulIndexOf(Value:IAmItem):integer;
begin
  if Value <> nil then
  Result:= FList.IndexOf(Value)
  else Result:= -1;
end;
function TAmListItemCustom.EmulListOwner: IAmListItemOwner;
begin
 Result:= self;
end;

function TAmListItemCustom.EmulGetCount:integer;
begin
   Result := FList.Count;
end;
function TAmListItemCustom.EmulGetList: IAmListItem;
begin
 Result:= self;
end;

function TAmListItemCustom.EmulGet(Index:integer):IAmItem;
begin
   Result:= FList[Index];
end;
function TAmListItemCustom.EmulHas(Index:integer):boolean;
begin
  Result:= Has(Index);
end;
procedure TAmListItemCustom.EmulMove(CurIndex, NewIndex: Integer);
begin
   Move(CurIndex,NewIndex);
end;

function TAmListItemCustom.EmulGetNextId: Cardinal;
begin
   Result:= AmAtomic.NewId(FIdCounter);
end;

function TAmListItemCustom.Has(Index: integer): boolean;
begin
  Result:= (Index>=0) and (Index<FList.Count)
end;

procedure TAmListItemCustom.DoChanged(Prm: PAmItemsPrm);
begin
    if( (FLockChange<=1) or (Prm.Enum = lcUpdate) ) and not self.DestroyingObject then
      Changed(Prm);
end;

procedure TAmListItemCustom.Changed(Prm: PAmItemsPrm);
begin
end;

procedure TAmListItemCustom.ChangeLock;
begin
   inc(FLockChange);
end;

procedure TAmListItemCustom.ChangeUnLock;
begin
   dec(FLockChange);
end;

procedure TAmListItemCustom.ItemCreate(var NewItem: IAmItem);
begin
  if Assigned(FEventCreate) then
  FEventCreate(NewItem);
end;

procedure TAmListItemCustom.InternalItemCreate(var NewItem:IAmItem);
begin
   if NewItem<>nil then exit;
   ItemCreate(NewItem);
   if NewItem = nil then
    AmRaiseBase.__Program('TAmListItem<T>.InternalItemCreate NewItem = nil');
end;
procedure TAmListItemCustom.InternalClear;
var i:integer;
begin
 if (FList<>nil) and (FList.Count>0) then
 begin
    for I := FList.Count-1 downto 0 do
      if FList[i]<>nil then
      FList[i].ListRelease;
   FList.Clear;
 end;
end;
procedure TAmListItemCustom.InternalInsert(Index: Integer; const Item: IAmItem);
begin
   if Item<>nil then
   begin
     if Item.List <> IAmListItemOwner(self) then
     begin
       Item.List:=self;

       if Item.ItemIndex <> Index then
       begin
        FList.Move(Item.ItemIndex,Index);
        FList[Index].ItemIndexFieldSet(Index);
        FList[Index].Changed(AmItemOperation.IndexSet);
       end;
     end
    // else raise Exception.Create('Error  TAmListItemCustom.InternalInsert повтроное добавление IAmItem в лист');
   end
   else
   FList.Insert(Index,Item);
end;
procedure TAmListItemCustom.InternalPut(Index: Integer; const Item: IAmItem);
begin
   InternalDelete(Index);
   InternalInsert(Index,Item);
end;


procedure TAmListItemCustom.InternalDelete(Index: Integer);
var Item:IAmItem;
begin
   Item:= FList[Index];
   if Item <> nil then
    Item.ListRelease
   else FList.Delete(Index);
end;
function TAmListItemCustom.InternalExtract(Index: Integer):IAmItem;
begin
   Result:= FList[Index];
   if Result <> nil then
    Result.List:=nil
   else FList.Delete(Index);
end;

function TAmListItemCustom.AddNew: IAmItem;
begin
   Result:=InsertNew(Count);
end;

function TAmListItemCustom.Add(Item: IAmItem): Integer;
begin
   Result:= Count;
   Insert(Result,Item);
end;

procedure TAmListItemCustom.Clear;
var Prm:TAmItemsPrm;
begin

  ChangeLock;
  try
    if FNeedEvent then
    begin
    Prm.Clear;
    Prm.Enum:= lcClearB;
    DoChanged(@Prm);
    end;
    if FList.Count > 0 then
    begin
      UpdateBegin;
      try
         InternalClear;
      finally
        UpdateEnd;
      end;
    end;
    if FNeedEvent then
    begin
    Prm.Enum:= lcClear;
    DoChanged(@Prm);
    end;
  finally
    ChangeUnLock;
  end;
end;

procedure TAmListItemCustom.Delete(Index: Integer);
var Prm:TAmItemsPrm;
begin
  ChangeLock;
  try
    if FNeedEvent then
    begin
     Prm.Clear;
     Prm.Enum:= lcDeleteB;
     Prm.Index:= Index;
     DoChanged(@Prm);
    end;

      self.InternalDelete(Prm.Index);

    if FNeedEvent then
    begin
     Prm.Enum:= lcDelete;
     DoChanged(@Prm);
    end;
  finally
    ChangeUnLock;
  end;
end;
function TAmListItemCustom.Extract(Index: Integer):IAmItem;
var Prm:TAmItemsPrm;
begin
  ChangeLock;
  try
      if FNeedEvent then
      begin
       Prm.Clear;
       Prm.Enum:= lcExtractB;
       Prm.Index:= Index;
       DoChanged(@Prm);
      end;

       Result:=self.InternalExtract(Prm.Index);

      if FNeedEvent then
      begin
       Prm.Enum:= lcExtract;
       DoChanged(@Prm);
      end;
  finally
    ChangeUnLock;
  end;
end;
procedure TAmListItemCustom.Exchange(Index1, Index2: Integer);
var Prm:TAmItemsPrm;
begin
  if Index1 = Index2 then  exit;
  ChangeLock;
  try
      if FNeedEvent then
      begin
       Prm.Clear;
       Prm.Enum:= lcExchangeB;
       Prm.Index1:= Index1;
       Prm.Index2:= Index2;
       DoChanged(@Prm);
      end;

       FList.Exchange(Prm.Index1,Prm.Index2);
       if FList[Prm.Index1]<>nil then
       begin
       FList[Prm.Index1].ItemIndexFieldSet(Prm.Index1);
       FList[Prm.Index1].Changed(AmItemOperation.IndexSet);
       end;
       if FList[Prm.Index2]<>nil then
       begin
       FList[Prm.Index2].ItemIndexFieldSet(Prm.Index2);
       FList[Prm.Index2].Changed(AmItemOperation.IndexSet);
       end;

      if FNeedEvent then
      begin
       Prm.Enum:= lcExchange;
       DoChanged(@Prm);
      end;
  finally
    ChangeUnLock;
  end;
end;

function TAmListItemCustom.Get(Index: Integer): IAmItem;
begin
  Result:= FList[Index];
end;

function TAmListItemCustom.GetCount: Integer;
begin
  Result:= FList.Count;
end;

function TAmListItemCustom.IndexOf(Item:IAmItem): Integer;
begin
  if Item <> nil then
  Result:= FList.IndexOf(Item)
  else Result:= -1;
end;

function TAmListItemCustom.IndexOfId(AId: Cardinal): Integer;
begin
    for Result := 0 to FList.Count-1 do
    if FList[Result].ItemId = AId then exit;
    Result:=-1;
end;

procedure TAmListItemCustom.Insert(Index: Integer;Item: IAmItem);
var Prm:TAmItemsPrm;
begin
  // AmDesing.Log('TAmListItemCustom.Insert');
  if (Item<>nil) and (Item.List = IAmListItemOwner(self)) then exit;
  ChangeLock;
  try
    if FNeedEvent then
    begin
     Prm.Clear;
     Prm.Enum:= lcInsertB;
     Prm.IndexVar:= Index;
     Prm.PVar:=  @Item;
     DoChanged(@Prm);
    end;
       //  AmDesing.Log('TAmListItemCustom.InternalInsert');
     InternalInsert(Prm.IndexVar,Item);

    if FNeedEvent then
    begin
     Prm.Enum:= lcInsert;
     DoChanged(@Prm);
    end;
  finally
    ChangeUnLock;
  end;
end;
function TAmListItemCustom.NewItem:IAmItem;
begin
   Result:=nil;
   InternalItemCreate(Result);
end;
function TAmListItemCustom.InsertNew(Index: integer): IAmItem;
begin
   Result:= NewItem;
   Insert(Index,Result);
end;
procedure TAmListItemCustom.Move(CurIndex, NewIndex: Integer);
var Prm:TAmItemsPrm;
begin
  if CurIndex = NewIndex then  exit;
  
  ChangeLock;
  try
      if FNeedEvent then
      begin
       Prm.Clear;
       Prm.Enum:= lcMoveB;
       Prm.Index1:= CurIndex;
       Prm.Index2:=  NewIndex;
       DoChanged(@Prm);
      end;
       FList.Move(Prm.Index1,Prm.Index2);
       if FList[Prm.Index2]<>nil then
       begin
       FList[Prm.Index2].ItemIndexFieldSet(Prm.Index2);
       FList[Prm.Index2].Changed(AmItemOperation.IndexSet);
       end;
      if FNeedEvent then
      begin
       Prm.Enum:= lcMove;
       DoChanged(@Prm);
      end;
  finally
    ChangeUnLock;
  end;
end;
procedure TAmListItemCustom.Put(Index: Integer; Item: IAmItem);
var Prm:TAmItemsPrm;
begin
  if IAmItem(FList[Index]) = IAmItem(Item) then exit;
  if (Item<>nil) and (Item.List = IAmListItemOwner(self)) then exit;
  raise Exception.Create('Error TAmListItemCustom.Put IAmItem уже находится в этом листе выполните move exchange или listSet(nil)');
  ChangeLock;
  try
      if FNeedEvent then
      begin
       Prm.Clear;
       Prm.Enum:= lcPutB;
       Prm.IndexVar:= Index;
       Prm.PVar:=  @Item;
       DoChanged(@Prm);
      end;

       if FList[Index] <> Item then
        InternalPut(Prm.IndexVar,Item);
      if FNeedEvent then
      begin
       Prm.Enum:= lcPut;
       DoChanged(@Prm);
      end;
  finally
    ChangeUnLock;
  end;
end;
      {
procedure TAmListItemCustom<T>.PutCreateRange(CountOld,CountNew: integer);
var i:integer;
begin
  for I :=CountOld  to CountNew-1 do
      self.InternalInsert(I,NewItem);
end; }

function TAmListItemCustom.Remove(Item: IAmItem): Integer;
begin
  if Item= nil then exit(-1);
  
  if IAmItem(Item) = IAmItem(FList.Last) then
  begin
    Result:= FList.Count - 1;
    Delete(Result);
  end
  else
  begin
   Result:=FList.IndexOf(Item);
   if Result>=0 then
    Delete(Result);
  end;
end;
procedure TAmListItemCustom.SetCount(NewCount: Integer);
var Prm:TAmItemsPrm;
Old,i:integer;
begin
  ChangeLock;
  try
    if FList.Count<>NewCount then
    begin
        if FNeedEvent then
        begin
         Prm.Clear;
         Prm.Enum:= lcSetCountB;
         Prm.CountOld:= FList.Count;
         Prm.CountNew:=  NewCount;
         DoChanged(@Prm);
         NewCount:=  Prm.CountNew;
        end;
        if FList.Count<>NewCount then
        begin
          Old:= FList.Count;
          if NewCount<Old then
          begin
            for I :=  Old-1 downto NewCount do
            InternalDelete(I);
          end
          else
          begin
            for I := Old  to NewCount-1 do
                self.InternalInsert(I,NewItem);
          end;
         // FList.Count:= NewCount;
          //if NewCount>Old then

          if FNeedEvent then
          begin
           Prm.Clear;
           Prm.Enum:= lcSetCount;
           Prm.CountOld:= Old;
           Prm.CountNew:=  FList.Count;
           DoChanged(@Prm);
          end;
        end;
    end;
  finally
    ChangeUnLock;
  end;
end;


procedure TAmListItemCustom.UpdateBegin;
//var Prm:TAmItemsPrm;
begin
 { if UpdateCountGet = 0 then
  begin
    if FNeedEvent then
    begin
     Prm.Clear;
     Prm.Enum:= lcUpdate;
     Prm.Updating:= true;
     DoChanged(@Prm);
    end;
  end; }
  inherited UpdateBegin;
end;

function TAmListItemCustom.UpdateCountGet: integer;
begin
  Result:= inherited UpdateCountGet;
end;
procedure TAmListItemCustom.DoUpdate;
var Prm:TAmItemsPrm;
begin
  inherited DoUpdate;
    if FNeedEvent then
    begin
     Prm.Clear;
     Prm.Enum:= lcUpdate;
     Prm.Updating:= false;
     DoChanged(@Prm);
    end;
end;
procedure TAmListItemCustom.UpdateEnd;
begin
  inherited UpdateEnd;
end;

{ TAmListItemObj<T> }

procedure TAmListItemObj.AfterConstruction;
begin
 // inherited AfterConstruction;
 //AtomicDecrement(FRefCount);
end;
procedure TAmListItemObj.BeforeDestruction;
begin
    DestroyingObjectSet;
    DoDestroyBefore;
end;



{ TAmItemsPrm }

procedure TAmItemsPrm.Clear;
begin
    AmRecordHlpBase.RecFinal(self);
    Enum:=lcInvalid;
end;



{ TAmListItemPers<T> }

procedure TAmListItemPers.DefineProperties(СonsequenceNameProperty: string; Filer: TFiler);
begin
  Filer.DefineProperty(СonsequenceNameProperty, ReadData, WriteData, Count > 0);
end;

procedure TAmListItemPers.Loaded;
var I: Integer;
begin
   for I := 0 to count-1 do
   if Items[i]<>nil then
   Items[i].Loaded;
end;

procedure TAmListItemPers.ReadData(Reader: TReader);
var
  VTyp,VTypValue:string;

  procedure LocAddObject(ANameClass:string);
  var Item:IAmItem;
  AClass:TClass;
  begin
      AClass:= System.Classes.GetClass(ANameClass);
      Item:=ReadCreateItem(ANameClass,AClass);
      if (Item <> nil) and (Item.AsPers<>nil)  then
      begin
          while not Reader.EndOfList do
          TLocReader(Reader).ReadProperty(Item.AsPers);
      end
      else ReadInvalidClass(Item,Reader);
      Add(Item);
  end;
begin
  self.UpdateBegin;
  try
    if Reader.NextValue <> vaCollection then
    raise Exception.Create('Error TAmListItemColection.ReadData invalid property');
    Reader.ReadValue;
    if not Reader.EndOfList then
    Clear;
    while not Reader.EndOfList do
    begin
      if Reader.NextValue in [vaCollection,vaInt8, vaInt16, vaInt32] then
      Reader.ReadInteger;
      Reader.ReadListBegin;
      VTyp:=Reader.ReadStr;
      VTypValue:=Reader.ReadString;
      //   VCap:=Reader.ReadStr;
      //   VCapValue:=Reader.ReadString;
      if (VTyp = 'typsys') and (VTypValue<>'nil') then
         LocAddObject(VTypValue)
      else if (VTyp = 'typsys') and (VTypValue='nil') then
         Add(nil);

     Reader.ReadListEnd;
    end;
    Reader.ReadListEnd;
  finally
    self.UpdateEnd;
  end;
end;

function TAmListItemPers.ReadCreateItem(AClassName:string;AClass:TClass):IAmItem;
begin
   Result:=nil;
   InternalItemCreate(Result);
end;
procedure TAmListItemPers.ReadInvalidClass(Item:IAmItem;Reader: TReader);
var C:string;
begin
   if Item<>nil then C:=TObject(Item).ClassName
   else              C:='nil';
   raise Exception.Create('Error TAmListItemColection.ReadInvalidClass ['+C+']');
end;

procedure TAmListItemPers.WriteData(Writer: TWriter);
var
  I: Integer;
  OldAncestor: TPersistent;
  SavePropPath:string;
  P:IAmItem;
begin
  OldAncestor := Writer.Ancestor;
  Writer.Ancestor := nil;
  SavePropPath := Writer.PropPath;
  Writer.PropPath := '';
  try
      TLocWriter(Writer).WriteValue(vaCollection);
      for I := 0 to GetCount - 1 do
      begin
        Writer.WriteListBegin;
        try
            P:= Items[I];
            TLocWriter(Writer).WritePropName('typsys');
            if (P <> nil) and (P.AsPers<>nil)  then
            begin
              Writer.WriteString(P.AsPers.ClassName);
              //TLocWriter(Writer).WritePropName('capsys');
              //Writer.WriteString(Get(I));
              TLocWriter(Writer).WriteProperties(P.AsPers);
            end
            else if not WriteInvalidClass(I,P,Writer) then
            begin
              Writer.WriteString('nil');
              //TLocWriter(Writer).WritePropName('capsys');
              //Writer.WriteString(Get(I));
              //WriteData_SetItemClass(Writer,'nil');
            end;
        finally
            Writer.WriteListEnd;
        end;
      end;
      Writer.WriteListEnd;
  finally
    Writer.Ancestor := OldAncestor;
    Writer.PropPath := SavePropPath;
  end;
end;



function TAmListItemPers.WriteInvalidClass(Index:integer;Item: IAmItem; Writer: TWriter): boolean;
var C:string;
begin
   Result:=false;
   if Item<>nil then C:=TObject(Item).ClassName
   else              C:='nil';
   if C<>'' then   
   raise Exception.Create('Error TAmListItemColection.ReadInvalidClass [Index:'+Index.ToString+' Class:'+C+']');
end;

{ TAmListItemColection }

constructor TAmListItemColection.Create;
begin
    inherited Create;
    FPersDesingNotify:=TAmPersDesingNotifyHelp.Create(PersDesingNotifyGetOwner);
end;
destructor TAmListItemColection.Destroy;
begin
  InternalClear;
  FPersDesingNotify.Free;
  FPersDesingNotify:=nil;
  inherited Destroy;
end;
function TAmListItemColection.GetComponentRoot: TComponent;
begin
 Result:=nil;
end;
function TAmListItemColection.GetOwner: TPersistent;
begin
  Result:=nil;
end;
function TAmListItemColection.IsMyChildObject(ACheckObject: TObject): boolean;
begin
  Result:=false;
  if ACheckObject = nil then exit;  
  Result:=  FPersDesingNotify = ACheckObject;  
  if not Result then
       Result:= inherited ;
end;

procedure TAmListItemColection.PersDesingNotifyGetOwner(Sender: TObject;
  var AOwner: TPersistent);
begin
   AOwner:= GetOwner;
end;
function TAmListItemColection.AsPersDesingNotify: TPersistent;
begin
   Result:= FPersDesingNotify;
end;
function TAmListItemColection.wcAdd(Item: TPersistent): Integer;
begin
  Result:= inherited Add(SupObjToItem(Item));
end;
function TAmListItemColection.wcAddNew: TPersistent;
var Item:IAmItem;
begin
   Result:= nil;
   Item:= inherited AddNew();
   if Item<>nil then
    Result:= Item.AsPers;
end;
procedure TAmListItemColection.Changed(Prm: PAmItemsPrm);
begin
  //showmessage('Changed');
 // AmDesing.Log('Modified list begin');
   inherited Changed(Prm);
   if AmDesing.IsDesingTime then
   case Prm.Enum of
               // lcInvalid,
                //lcChangeCustom,//любое другое изменение листа
               // lcChangeItem,//изменение в самом одном итеме
              //  lcClassItem,
               // lcChildItemAdd,
              //  lcChildItemRemoving,
               // lcSetCountB,
                lcSetCount,
                lcUpdate,
               // lcClearB,
                lcClear,
                //lcDeleteB,
                lcDelete,
               // lcExtractB,
                lcExtract,
                //lcExchangeB,
                lcExchange,
                //lcInsertB,
                lcInsert,
                //lcMoveB,
                lcMove,
                //lcPutB,
                lcPut,
                //lcAssignB,
                lcAssign:begin

                  //AmDesing.Log('Modified list exp');
                  AmDesing.Modified(FPersDesingNotify);
                  //AmDesing.Log('Modified list end');
                end;
   end;
end;

procedure TAmListItemColection.DoChanged(Prm: PAmItemsPrm);
var AItem:TPersistent;
    function LocGetItem:TPersistent;
    begin

      // Amdesing.Log(Prm.ItemChild.ClassName);

       if (Prm.ItemChild<>nil) and (Prm.ItemChild is TPersistent) then
       Result:= TPersistent(Prm.ItemChild)
       else Result:=nil;
    end;
begin
   if AmDesing.IsDesingTime  then
   case Prm.Enum of
        lcChildItemAdd:begin
         // Amdesing.Log('Add '+ boolean(FPersDesingNotify<>nil).tostring +' '+ boolean(FPersDesingNotify<>nil).tostring);
          AItem:=LocGetItem;
          AmDesing.NotifyItemAdd(FPersDesingNotify,AItem);
        end;
        lcChildItemRemoving:begin
          //Amdesing.Log('removing');
          AItem:=LocGetItem;
         //Amdesing.Log('TAmListItemCustom.lcChildItemRemoving self:'+self.ClassName+
        // ' owner:'+ FPersDesingNotify.ClassName +
        // ' item:'+AItem.ClassName);
          AmDesing.NotifyItemRemove(FPersDesingNotify,AItem);
        end;
   end;

   inherited DoChanged(Prm);
end;

function TAmListItemColection.wcInsertNew(Index: integer): TPersistent;
var Item:IAmItem;
begin
   Result:= nil;
   Item:= inherited InsertNew(Index);
   if Item<>nil then
    Result:= Item.AsPers;
end;
procedure TAmListItemColection.wcInsert(Index: Integer; Item: TPersistent);
begin
   inherited Insert(Index,SupObjToItem(Item));
end;

function TAmListItemColection.wcGet(Index: Integer): TPersistent;
var Item:IAmItem;
begin
   Result:= nil;
   Item:= inherited Get(Index);
   if Item<>nil then
    Result:= Item.AsPers;
end;

function TAmListItemColection.wcIndexOf(Item: TPersistent): Integer;
begin
    Result:= inherited IndexOf(SupObjToItem(Item,false));
end;

procedure TAmListItemColection.wcPut(Index: Integer; Item: TPersistent);
begin
   inherited Put(Index,SupObjToItem(Item));
end;

function TAmListItemColection.wcRemove(Item: TPersistent): Integer;
begin
    Result:= inherited Remove(SupObjToItem(Item,false));
end;


end.
