unit AmListBox;

interface
uses
  Winapi.Windows,Winapi.Messages,Winapi.CommCtrl, System.SysUtils,Types, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.jpeg, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Imaging.pngimage, Vcl.ExtCtrls,
  System.Generics.Collections,AmCheckBox,Math,AmButton,TypInfo,Vcl.ImageCollection,
  System.Messaging,
  Vcl.BaseImageCollection,
  AmUserScale,AmScrollBar,AmScrollBarTypes,AmLayBase,AmPanel,
  AmSystemBase,
  AmSystemObject,
  AmImageList,
  AmStringTypesFile,
  AmControlClasses,
   AmGraphic.Obj,ES.ExGraphics,

   AmGraphic.Help,
   AmGraphic.Canvas.Help,
   AmInterfaceBase,
   AmSystemListBase;

  const
   AM_LB_ITEMS_CHANGE = WM_USER+7644;
  type
    TamListBoxNoScroll = class;
    TAmListBox = class;
    TAmListBoxObjects= class;
    TAmLbItem = class;
    TAmListBoxClass = class of TAmListBox;

  //  TStringlistLoc= class (TStringlist);



    {
     начиная с  TAmListBoxObjects ( Items is  TAmStringsLBLocal  )
     если лисбокс ниже  TAmListBoxObjects то  Items is TStrings or  custom vcl

     TamListBoxNoScroll = удален скрол и добалено пару позезных property

     TAmListBox = class (TListBox) class (TamListBoxNoScroll)
     добален скрол разукрашка


     TAmListBoxObjects = class (TAmListBox)
       и выше создает не только строки но доп объекты на элементе
      кнопки картики слоеные текста и т.д
      и каждый   TAmListBoxObjects.Items.Object[index] имеет объект который пренедлежит этому лист боксу
      эти объекты унаследованы от TAmListBoxItem

      есть чек боксы
      есть кнопки закрытия
      есть иконки фона и аватарки и иконки мини  (для вставки картики в картинку)

      //лист бокс файлы и директории в этом модуле не будет см AmControls там есть



    }



    TAmCustomListBoxHelper = class helper for TCustomListBox
      private
        function ItemsListBoxGet: TStrings;
        procedure ItemsListBoxSet(const Value: TStrings);
         function SaveItemsGet: TStrings;
      public
       property ItemsListBoxReplace: TStrings read ItemsListBoxGet write ItemsListBoxSet;
       property SaveItems: TStrings read SaveItemsGet;
      end;




    TamListBoxNoScroll = class(TListBox)
      private
          FOnItemsChange:TAmEventStringsProcControl;
          FColorItemMouseMovi:Tcolor;
          FColorItemSelect:Tcolor;
          FItemIndexMouseMove:integer;
          FTextItemCorrectX:integer;
          FOnChangeMoveMouse,
          FOnChangeSelect: TNotifyEvent;
          FOnClearListBox:TNotifyEvent;
          FScrollVStandart: boolean;
          FScrollHStandart: boolean;
          FSaveSelectClickIndex:integer;
          procedure CMMouseLeave(var Message: Winapi.Messages.TMessage); message CM_MOUSELEAVE;
          procedure AmLbItemsChangePost(var Message: Winapi.Messages.TMessage); message AM_LB_ITEMS_CHANGE;
          procedure ColorItemMouseMoviSet(const Value: Tcolor);
          procedure ColorItemSelectSet(const Value: Tcolor);
          procedure TextItemCorrectXSet(const Value: integer);
          procedure ScrollHStandartSet(const Value: boolean);
          procedure ScrollVStandartSet(const Value: boolean);
          function ItemIndexCaptionGet: string;
          procedure ItemIndexCaptionSet(const Value: string);
          function ItemHeightGet: integer;
          procedure ItemHeightSet( Value: integer);
          function ItemIndexTextIdGet: TAmTextId;
          function ItemTextIdGet(Index: integer): TAmTextId;
          function ItemIndexTextSdGet: TAmTextSd;
          function ItemTextSdGet(Index: integer): TAmTextSd;
         // function ListObjectGet: TList;

      protected
           MousePointMove:TPoint;
           // после изменений listbox запускается чрез PostMessage
           procedure ItemsChangePost(WasCmd:Cardinal);virtual;
           // во время изменений может многократно вызыватся
           procedure ItemsChangeCall(WasCmd:Cardinal); virtual;
           // если  ListBox is  TAmListBoxObjects то это работает
           // получаем уведомления о конкретном событии
           procedure ItemsEvent(Sender:TStrings;Prm:PAmEventStringsPrm);virtual;
           procedure InvalidDateRectIndex(Index: Integer);
           procedure ResetContent; override;
         // procedure Click;  override;
           procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
           procedure MouseDown(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);override;
           procedure Click;override;
           procedure DoChangeClickSelect( X, Y: Integer);virtual;
           procedure DoChangeSelect( X, Y: Integer);virtual;

           procedure DrawItem(Index: Integer; Rect: TRect;State: TOwnerDrawState); override;
           procedure DrawItem_Background(Index: Integer; Rect: TRect;State: TOwnerDrawState;ItemObject:TAmLbItem); virtual;
           procedure DrawItem_CorrectRect(Index: Integer;var Rect:TRect;ItemObject:TAmLbItem); virtual;
           procedure DrawItemAfter(Index: Integer; Rect: TRect;State: TOwnerDrawState);virtual;
           procedure DrawItemElements(Index: Integer;Rect: TRect;ItemObject:TAmLbItem); virtual;
           procedure DrawItemElements_Caption(Index: Integer;Rect: TRect;ItemObject:TAmLbItem); virtual;

           function  DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;  override;
           procedure CreateParams(var Params: TCreateParams); override;
           procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
       public
           procedure Clear; override;
           constructor Create(AOwner: TComponent);Override;
           destructor Destroy; override;
           procedure DefaultHandler(var Message); override;
           procedure StringsAssign(Source:TStrings);virtual;
           procedure StringsAdd(Source:TStrings);virtual;
           property  ItemIndexCaption: string read ItemIndexCaptionGet write ItemIndexCaptionSet;
           property  ItemIndexTextId: TAmTextId read ItemIndexTextIdGet;
           property  ItemTextId[Index:integer]: TAmTextId read ItemTextIdGet;
           property  ItemIndexTextSd: TAmTextSd read ItemIndexTextSdGet;
           property  ItemTextSd[Index:integer]: TAmTextSd read ItemTextSdGet;
       published
           property  ItemHeight: integer read ItemHeightGet write ItemHeightSet;
           property  ColorItemMouseMovi : Tcolor read FColorItemMouseMovi write ColorItemMouseMoviSet;
           property  ColorItemSelect : Tcolor read FColorItemSelect write ColorItemSelectSet;
           property  ItemIndexMouseMove : integer read FItemIndexMouseMove;
           property  TextItemCorrectX : integer read FTextItemCorrectX write TextItemCorrectXSet;
           property  ScrollVStandart: boolean read FScrollVStandart write ScrollVStandartSet;
           property  ScrollHStandart: boolean read FScrollHStandart write ScrollHStandartSet;           
           property  OnChangeSelectMoveMouse: TNotifyEvent read FOnChangeMoveMouse write FOnChangeMoveMouse;
           property  OnChangeSelect: TNotifyEvent read FOnChangeSelect write FOnChangeSelect;
           property  OnClearListBox : TNotifyEvent read FOnClearListBox write FOnClearListBox;
           property  OnItemsChange : TAmEventStringsProcControl read FOnItemsChange write FOnItemsChange;

           property DoubleBuffered default True;
           property ParentDoubleBuffered default False;
    end;

    TAmListBox = class(TamListBoxNoScroll)
       private
         FVScroll: TAmScrollBar;
         FVScrollLock:integer;
         FVScrollLockPos:integer;
         FScrollVNotVisible:boolean;
         procedure VScrollSet(const Value: TAmScrollBar);
         procedure VScrollChangePosition(Sender: TObject; OldPosition,NewPosition: Int64);
         procedure Wnd_LB_SETTOPINDEX(var Msg: Winapi.Messages.TMessage);message LB_SETTOPINDEX;
         procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
         procedure WMWindowParentChanged(var Message: Winapi.Messages.TMessage); message AM_CONTROL_PARENT_CHANGE;

         procedure CMVisibleChanged(var Message:  Winapi.Messages.TMessage); message CM_VISIBLECHANGED;
         procedure CMEnabledChanged(var Message:  Winapi.Messages.TMessage); message CM_ENABLEDCHANGED;
         procedure ScrollVNotVisibleSet(const Value: boolean);
         procedure ScrollVResize(Sender: TObject);
         procedure ScrollChangeVisible(Sender: TObject);
       protected
         procedure SetParent(W:TWinControl);override;
         procedure ItemsEvent(Sender:TStrings;Prm:PAmEventStringsPrm);override;
         procedure ItemsChangePost(WasCmd:Cardinal);override;
         procedure CreateWnd;override;
         procedure DrawItem_CorrectRect(Index: Integer;var Rect:TRect;ItemObject:TAmLbItem); override;
         procedure DrawItemAfter(Index: Integer; Rect: TRect;State: TOwnerDrawState); override;

         procedure UpadateScrollV;virtual;
         procedure UpadateScrollVPos;virtual;
         procedure SetName(const NewName: TComponentName);override;
         procedure Resize;override;
         procedure SetZOrder(TopMost: Boolean); override;
       public
         constructor Create(AOwner: TComponent);Override;
         destructor Destroy; override;

       published
         property ScrollV: TAmScrollBar read FVScroll write VScrollSet;
         property ScrollVNotVisible: boolean read FScrollVNotVisible write ScrollVNotVisibleSet;
    end;


    TAmStringsLB  =class (TAmStringsObject)
      private
        ListBox: TAmListBoxObjects;
      protected
        function  ControlOwnerGet:TWinControl;override;
        procedure EvPut(Index: Integer; const S: string);override;
       // procedure EvPutObject(Index: Integer; AObject: TObject);override;
       //function  EvGetObject(Index: Integer): TObject; override;
      //  procedure EvSetUpdateState(Updating: Boolean);override;
        function  EvAdd(const S: string): Integer;override;
        procedure EvClear;override;
        procedure EvDelete(Index: Integer);override;
        procedure EvExchange(Index1, Index2: Integer);override;
        procedure EvInsert(Index: Integer; const S: string);override;
        procedure EvMove(CurIndex, NewIndex: Integer);override;
        function Get(Index: Integer): string; override;
        function GetCount: Integer; override;
      public
        function IndexOf(const S: string): Integer; override;
        constructor Create();
        destructor Destroy; override;
    end;


     //используется на предодок для объектов ListBox.Items.Object[index]
     // только этот тип данных удаляется при очистке и удалении ListBox
    TAmLbItemClass = class of TAmLbItem;
    TAmLbItem = class (TAmStringsObjectItem)
       private
        [weak]FListBox:TAmListBoxObjects;
         FButtonCloseVisible:boolean;
         procedure ButtonCloseVisibleSet(const Value: boolean);
       protected
         RectButtonClose:TRect;
         function  ControlOwnerGet:TWinControl;override;
         procedure ControlOwnerSet(const Value: TWinControl); override;
       public
         constructor Create(AStringsOwner:TAmStrings);override;
         destructor Destroy; override;
         procedure Assign(ASource:TPersistent); override;
         property  ListBox: TAmListBoxObjects read FListBox;
       published
         property ButtonCloseVisible: boolean read FButtonCloseVisible write ButtonCloseVisibleSet default false;
    end;
    TamListBoxEventClose = procedure (Sender:TObject;Index:integer;var CanDelete:Boolean) of object;

    TAmListBoxObjects = class (TAmListBox)
        private
          FButtonClose:TAmButtonClose;
          FOnClickClose:TamListBoxEventClose;
          function ListItemsGet: TAmStringsObject;
          function ObjectItemCountGet: integer;
          function ObjectItemIndexGet(Index: Integer): TAmLbItem;
          procedure ObjectItemIndexSet(Index: Integer; const Value: TAmLbItem);
          function ButtonCloseVisibleGet: boolean;
          procedure ButtonCloseVisibleSet(const Value: boolean);
          function ItemsEmulGet: IAmListColection;
          function ItemClassGet: TAmLbItemClass;
          procedure ItemClassSet(const Value: TAmLbItemClass);
       protected
          procedure SetName(const NewName: TComponentName);override;

          procedure ButtonCloseChanged(Sender:TObject);

           //event items
          procedure ItemsEvent(Sender:TStrings;Prm:PAmEventStringsPrm);override;
          function ObjectItemAddCustom(Index:PInteger=nil):TAmLbItem;virtual;
          function ObjectItemInsertCustom(Index:integer):TAmLbItem;virtual;
          procedure MouseUp(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);override;
          procedure DoClickClose(Index:integer);virtual;
          procedure DrawItemElements(Index: Integer;Rect: TRect;ItemObject:TAmLbItem); override;
          procedure DrawItemElements_ButtonClose(Index: Integer;Rect: TRect;ItemObject:TAmLbItem); virtual;
       public
          procedure Clear; override;
          constructor Create(AOwner: TComponent);Override;
          destructor Destroy; override;
          property ListItems: TAmStringsObject read ListItemsGet;
          //  property ListObject: TList read ListObjectGet;
          property ObjectItemCount: integer read ObjectItemCountGet;
          property ObjectItemIndex[Index:Integer]: TAmLbItem read ObjectItemIndexGet write ObjectItemIndexSet;
          function ObjectItemAdd(Index:PInteger=nil):TAmLbItem;
          function ObjectItemInsert(Index:integer):TAmLbItem;
          class function GetClassListBoxItem:TAmLbItemClass; virtual;
          property  ItemsList: TAmStringsObject read ListItemsGet;
          property ItemClass: TAmLbItemClass read ItemClassGet write ItemClassSet;
       published
          property  ItemsEmul: IAmListColection read ItemsEmulGet;
          property  ButtonCloseVisible: boolean read ButtonCloseVisibleGet write ButtonCloseVisibleSet;
          property  ButtonClose: TAmButtonClose read FButtonClose;
          property  OnClickClose : TamListBoxEventClose read FOnClickClose write FOnClickClose;
          property  ParentDoubleBuffered default false;
          property  DoubleBuffered default true;
    end;


    TAmLbItemCB = class (TAmLbItem)
       private
         FChecked:boolean;
         FCheckedVisible:boolean;
         procedure CheckedSet(const Value: boolean);
         procedure CheckedVisibleSet(const Value: boolean);
       protected
         RectCheckBox:TRect;
       public
         procedure Assign(ASource:TPersistent); override;
         constructor Create(AStringsOwner:TAmStrings);override;
         destructor Destroy; override;
       published
         property Checked: boolean read FChecked write CheckedSet default false;
         property CheckedVisible: boolean read FCheckedVisible write CheckedVisibleSet  default true;
    end;

    TAmListBoxCheck = class (TAmListBoxObjects)
      private
        FCheckedPlaceIndex:integer;
        FCheckedOpt:TAmCheckBoxOpt;
        FOnClickChecked:TNotifyEvent2;
        function CheckedGet(index: integer): boolean;
        procedure CheckedSet(index: integer; const Value: boolean);
        procedure ObjectItemIndexSet(Index: Integer;  const Value: TAmLbItemCB);
        function ObjectItemIndexGet(Index: Integer): TAmLbItemCB;

        function CheckedVisibleGet(index: integer): boolean;
        procedure CheckedVisibleSet(index: integer; const Value: boolean);
        procedure CheckedPlaceIndexSet(const Value: integer);
        procedure CheckedOptSet(const Value: TAmCheckBoxOpt);
      protected
        procedure ItemsEvent(Sender:TStrings;Prm:PAmEventStringsPrm);override;

        procedure DrawItemElements(Index: Integer;Rect: TRect;ItemObject:TAmLbItem); override;
        procedure DrawItemElements_Checked(Index: Integer;Rect: TRect;ItemObject:TAmLbItemCB); virtual;

        procedure DoChangeClickSelect( X, Y: Integer);override;
        procedure DoChangeClickChecked(Item:TAmLbItemCB; X, Y: Integer);virtual;
        procedure CheckedOptOnChanged(Sender:TObject;PVar:Pointer);dynamic;
        procedure CreateWnd; override;
      public
        class function GetClassListBoxItem:TAmLbItemClass; override;
        procedure CheckAllSet(Value:boolean);
        property Checked[index:integer]: boolean read CheckedGet write CheckedSet;
        property CheckedVisible[index:integer]: boolean read CheckedVisibleGet write CheckedVisibleSet;
        property ObjectItemIndex[Index:Integer]: TAmLbItemCB read ObjectItemIndexGet write ObjectItemIndexSet;
        constructor Create(AOwner: TComponent);Override;
        destructor Destroy; override;
      published
        property CheckedPlaceIndex: integer read FCheckedPlaceIndex write CheckedPlaceIndexSet;
        property CheckedOpt:TAmCheckBoxOpt read FCheckedOpt write CheckedOptSet;
        property OnClickChecked: TNotifyEvent2 read FOnClickChecked write  FOnClickChecked;

    end;



    TAmListBoxIco = class;

    TAmLbPictureItem = class (TAmDoublePictureLeft)
      private
       [weak]FListBox:TAmListBoxIco;
         function storedOffset:boolean;
      protected
         procedure ChangedUse;override;
      public
         constructor Create(AOptOwner:TAmVclOpt);override;
         destructor Destroy; override;
      published
       property SizeProcent default 80; //SizeFix
       property Stretch default false;
       property Offset stored storedOffset;
       property TransparentRect default false;
       property UpDelay default false;
       property BolderColor default $00FFFF80;
       property BolderSize default 0;
       property BolderOffset default 0;
    end;



    TAmLbIcoMini = class (TAmLbPictureItem)
      protected
       procedure DoGetSizeUse(var ASiz: TSize);override;
    end;
    TAmLbIcoBig = class (TAmLbPictureItem)
      protected
       procedure DoGetSizeUse(var ASiz: TSize);override;
    end;
    TAmLbIcoBigHide = class (TAmLbPictureItem)
      protected
         procedure ChangedUse;override;
         procedure DoGetSizeUse(var ASiz: TSize);override;
         procedure Changed(Sender:TAmVclOpt;PVar:Pointer);override;
         function ChangedNoneAfter():boolean;
      public
         constructor Create(AOptOwner:TAmVclOpt);override;
    end;
    TAmLbIcoListEnumerator =class (TAmListPersistentEnumerator)
     private
      [weak]FListBox:TAmListBoxIco;
     public
      constructor Create(AListBox:TAmListBoxIco);
      function Get(Index:integer):TPersistent; override;
      function Has(Index:integer):boolean;  override;
    end;



    TAmLbItemICO = class (TAmLbItemCB)
       private
         FIco:TAmLbIcoBig;
         FIcoMiniVisible:boolean;
         procedure IcoSet(const Value: TAmLbIcoBig);
         function storedIco: Boolean;
         procedure IcoMiniVisibleSet(const Value: boolean);
       protected
         RectIco:TRect;
         RectIcoMini:TRect;
        // procedure DefineProperties(Filer: TFiler); override;
         procedure ItemUpdate;override;
       public
         procedure Assign(ASource:TPersistent); override;
         constructor Create(AStringsOwner:TAmStrings);override;
         destructor Destroy; override;
       published
         property Ico: TAmLbIcoBig read FIco write IcoSet stored storedIco;
         property IcoMiniVisible: boolean read FIcoMiniVisible write IcoMiniVisibleSet default false;
    end;





    TAmListBoxIco = class (TAmListBoxCheck)
      private
         FIcoMini:TAmLbIcoMini;
         FIcoBig:TAmLbIcoBigHide;
         [weak]FIcoImageCollection: TImageCollection;
         FIcoImageCollectionDefault:boolean;
         FIcoImageCollectionIsListenMannager:boolean;
         FIcoImageCollectionUpdateLock:integer;
         FOnClickIcoMini:TNotifyEvent2;
         FOnClickIcoBig: TNotifyEvent2;

         // image collection
         procedure IcoImageCollectionSet( Value: TImageCollection);
         procedure IcoImageCollectionDefaultSet(const Value: boolean);
         procedure IcoImageCollectionIsListenMannagerSet(const Value: boolean);
         procedure IcoImageCollectionListenMannagerChange(const Sender: TObject; const M: System.Messaging.TMessage);
         //слушает ли событие о изменении  TImageCollection
         property IcoImageCollectionIsListenMannager: boolean read FIcoImageCollectionIsListenMannager write IcoImageCollectionIsListenMannagerSet;

         // ico mini big
         procedure IcoMiniSet(const Value: TAmLbIcoMini);
         procedure IcoBigSet(const Value: TAmLbIcoBigHide);
         procedure IcoMiniChange(Sender:TObject;PVar:Pointer);
         procedure IcoBigChange(Sender:TObject;PVar:Pointer);
         // index
         function ObjectItemIndexGet(Index:Integer):TAmLbItemICO;
         procedure ObjectItemIndexSet( Index:Integer;const Value: TAmLbItemICO) ;
         function IcoIndexImageGet(Index: Integer): TAmLbIcoBig;
      protected
         procedure ItemsEvent(Sender:TStrings;Prm:PAmEventStringsPrm);override;
         procedure DrawItemElements(Index: Integer;Rect: TRect;ItemObject:TAmLbItem); override;
         procedure CreateWnd; override;
         procedure DoChangeClickSelect( X, Y: Integer);override;
         procedure DoClickIcoMini(Item:TAmLbItemICO; X, Y: Integer);dynamic;
         procedure DoClickIcoBig(Item:TAmLbItemICO; X, Y: Integer);dynamic;
      public
        constructor Create(AOwner: TComponent);Override;
        destructor Destroy; override;
        class function GetClassListBoxItem:TAmLbItemClass; override;
        // вернет картинку индекса в списке items
        property  IcoIndexImage[Index:Integer]: TAmLbIcoBig read IcoIndexImageGet;
        // очистит все картинки в индексах
        procedure IcoIndexImageClear;
        // обновить размеры свех картинок
        procedure IcoIndexImageUpdateSize;virtual;
        // обновить и сопоставить картинки в коллекции и индексах
        procedure IcoImageCollectionUpdate;
        // объект индекса
        property ObjectItemIndex[Index:Integer]: TAmLbItemICO read ObjectItemIndexGet write ObjectItemIndexSet;
        // добавить новый
        function ObjectItemAdd(Index:PInteger=nil):TAmLbItemICO;
        function ObjectItemInsert(Index:integer):TAmLbItemICO;

      published
        // мини иконка на каждом индексе одна для всех
        property IcoMini: TAmLbIcoMini read FIcoMini write IcoMiniSet;
        // большая иконка индекса
        //именно этот объект никак не рисуется но если его изменить то он скопируется на все индексы
        // а каждый индекс уже по свойму нарисуется
        property IcoBig: TAmLbIcoBigHide read FIcoBig write IcoBigSet;

        // по умолчанию  IcoImageCollection сделан только для design - time
        //но если нужно что в реал тайме
        // происходили изменения в лист боксе если помелся  TImageCollection то
       // в  IcoImageCollectionIsDefault = true
        property IcoImageCollectionDefault: boolean read FIcoImageCollectionDefault write IcoImageCollectionDefaultSet;
        property IcoImageCollection: TImageCollection read FIcoImageCollection write IcoImageCollectionSet;

        property OnClickIcoMini: TNotifyEvent2 read FOnClickIcoMini write FOnClickIcoMini;
        property OnClickIcoBig: TNotifyEvent2 read FOnClickIcoBig write FOnClickIcoBig;
    end;
             


    // отображает одну папку или произвольные файлы с разных мест
   TAmLbItemFile = class (TAmLbItemICO)
    private
      FFileName: TAmFileName;
      FFileNameLock:integer;
      procedure AFileNameSet(const Value: TAmFileName);
      function storedFileName: Boolean;
     protected
      procedure Changed(IndexVar:Integer);override;
     public
      constructor Create(AStringsOwner:TAmStrings);override;
      destructor Destroy; override;
     published
       property  FileName: TAmFileName read FFileName write AFileNameSet  stored storedFileName;
       property Ico stored false;
   end;

    TAmListBoxFilesCustom = class (TAmListBoxIco)
     private
       FPathPictureDefault: TPicture;
       FPathRoot:TAmDirName;
       FSaveItemHeidth:integer;
       function ItemHeightFileGet: integer;
       function ObjectItemIndexGet(Index: Integer): TAmLbItemFile;
       procedure PathPictureDefaultSet(const Value: TPicture);
       procedure PathRootSet(const Value: TAmDirName);
     protected
       procedure ItemsEvent(Sender:TStrings;Prm:PAmEventStringsPrm);override;
       procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);override;
       procedure DrawItemElements(Index: Integer;Rect: TRect;ItemObject:TAmLbItem); override;
       procedure ItemHeightFileSet( Value: integer);virtual;
       procedure SetParent(W:TWinControl);override;
       procedure CreateWnd; override;
     public
       class function GetClassListBoxItem:TAmLbItemClass; override;
       function   LoadFileNameToItem(AItem:TAmLbItemFile;AFileName:string):boolean;
       procedure  UpdateFileIcoItems;
       Procedure  LoadPath(APath:string);

       function   AddFileGraf(AFileName:string;var Obj:TAmLbItemFile):boolean;
       function   AddFile(FullFileName:string):TAmLbItemFile;
       Procedure  DeleteFile(index:integer);


       property   ItemHeightFile: integer read ItemHeightFileGet write ItemHeightFileSet;
       property   ObjectItemIndex[Index:Integer]: TAmLbItemFile read ObjectItemIndexGet;
       function   ObjectItemAdd(Index:PInteger=nil):TAmLbItemFile;
       function   ObjectItemInsert(Index:integer):TAmLbItemFile;
       constructor Create(AOwner: TComponent);Override;
       destructor Destroy; override;
     published
       property PathRoot: TAmDirName read FPathRoot write PathRootSet;
       property PathPictureDefault: TPicture read FPathPictureDefault write PathPictureDefaultSet;
    end;

   TAmLbItemMyFile = class (TAmLbItemFile)
    protected
        RectFileName:TRect;
        RectNameRu:TRect;
        procedure Changed(IndexVar:integer); override;
     public 
        constructor Create(AStringsOwner:TAmStrings);override;   
   end;

    TAmListBoxMyFiles = class (TAmListBoxFilesCustom)
    private
       FmyFileNameFont:TFont;
       FmyNameRuFont:TFont;
       FmyFileNameOffset:TAmPointVclOpt; 
       FmyNameRuOffset:TAmPointVclOpt; 
       FOnClickFileName:TNotifyEvent2;  
       FOnClickNameRu: TNotifyEvent2;      
      function ObjectItemIndexGets(Index: Integer): TAmLbItemMyFile;
      procedure myFileNameFontSet(const Value: TFont);
      procedure myFileNameOffsetSet(const Value: TAmPointVclOpt);
      procedure myNameRuFontSet(const Value: TFont);
      procedure myNameRuOffsetSet(const Value: TAmPointVclOpt);
      procedure myFontChange(S:TObject);
      procedure myOffsetChange(Sender:TObject;PVar:Pointer);
    protected
      procedure DrawItemElements_Caption(Index: Integer;Rect: TRect;ItemObject:TAmLbItem); override;
      procedure DoChangeClickSelect( X, Y: Integer);override;
      procedure DoClickFileName(Item:TAmLbItemMyFile;X, Y:integer);dynamic;
      procedure DoClickNameRu(Item:TAmLbItemMyFile;X, Y:integer);dynamic;
    public
       constructor Create(AOwner: TComponent);Override;
       destructor Destroy; override;    
       class function GetClassListBoxItem:TAmLbItemClass; override;
       property   ObjectItemIndex[Index:Integer]: TAmLbItemMyFile read ObjectItemIndexGets;
       function   ObjectItemAdd(Index:PInteger=nil):TAmLbItemMyFile;
       function   ObjectItemInsert(Index:integer):TAmLbItemMyFile;
    published
       property myFileNameFont: TFont read FmyFileNameFont write myFileNameFontSet;
       property myNameRuFont: TFont read FmyNameRuFont write myNameRuFontSet;       
       property myFileNameOffset: TAmPointVclOpt read FmyFileNameOffset write myFileNameOffsetSet; 
       property myNameRuOffset: TAmPointVclOpt read FmyNameRuOffset write myNameRuOffsetSet;  
       property OnClickFileName: TNotifyEvent2 read FOnClickFileName write FOnClickFileName;  
       property OnClickNameRu: TNotifyEvent2 read FOnClickNameRu write FOnClickNameRu; 
    end;

      

    // подобие аккаунта  для мелких операций
  TAmLbItemUser = class (TAmLbItemICO)
    private
      FUserInfo: string;
      FUserName: string;
      FUserColor:TColor;
      FObjectFree,FObjectBusy:Tobject;
      procedure UserInfoSet(const Value: string);
      procedure UserNameSet(const Value: string);
      procedure UserColorSet(const Value: TColor);
    protected
      RectUserName:TRect;
      RectUserInfo:TRect;
    public
      constructor Create(AStringsOwner:TAmStrings);override;
      destructor Destroy; override;
      property ObjectFree: TOBject read FObjectFree write FObjectFree;
      property ObjectBusy: TOBject read FObjectBusy write FObjectBusy;
    published
      property UserName: string read FUserName write UserNameSet;
      property UserInfo: string read FUserInfo write UserInfoSet;
      property UserColor: TColor read FUserColor write UserColorSet;
   end;
    TAmPointVclOptLoc = class (TAmPointVclOpt);

    TAmListBoxUsers = class (TAmListBoxIco)
     private
       FUserNameFont:TFont;
       FUserInfoFont:TFont;
       FUserNameOffset:TAmPointVclOpt;
       FUserInfoOffset:TAmPointVclOpt;
       FOnClickNameUser: TNotifyEvent2;
       FOnClickInfoUser: TNotifyEvent2;
       procedure UFontChange(Sender:TObject);
       procedure UOffsetChange(Sender:TObject;PVar:Pointer);
       procedure UserInfoFontSet(const Value: TFont);
       procedure UserInfoOffsetSet(const Value: TAmPointVclOpt);
       procedure UserNameFontSet(const Value: TFont);
       procedure UserNameOffsetSet(const Value: TAmPointVclOpt);
       function UserAddTestDesignGet: boolean;
       procedure UserAddTestDesignSet(const Value: boolean);
       function ObjectItemIndexGet(Index: Integer): TAmLbItemUser;
     protected
       procedure ItemsEvent(Sender:TStrings;Prm:PAmEventStringsPrm);override;
       procedure DrawItemElements(Index: Integer;Rect: TRect;ItemObject:TAmLbItem); override;
       procedure DrawItem_Background(Index: Integer; Rect: TRect;State: TOwnerDrawState;ItemObject:TAmLbItem); override;
       procedure DrawItemElements_Caption(Index: Integer;Rect: TRect;ItemObject:TAmLbItem); override;
       procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
       procedure DoChangeClickSelect( X, Y: Integer);override;
       procedure DoClickNameUser(Item:TAmLbItemUser;X, Y:integer);dynamic;
       procedure DoClickInfoUser(Item:TAmLbItemUser;X, Y:integer);dynamic;
     public
       class function GetClassListBoxItem:TAmLbItemClass; override;
       property   ObjectItemIndex[Index:Integer]: TAmLbItemUser read ObjectItemIndexGet;
       function   ObjectItemAdd(Index:PInteger=nil):TAmLbItemUser;
       function   ObjectItemInsert(Index:integer):TAmLbItemUser;
       constructor Create(AOwner: TComponent);Override;
       destructor Destroy; override;
     published
       property UserNameFont: TFont read FUserNameFont write UserNameFontSet;
       property UserInfoFont: TFont read FUserInfoFont write UserInfoFontSet;
       property UserNameOffset: TAmPointVclOpt read FUserNameOffset write UserNameOffsetSet;
       property UserInfoOffset: TAmPointVclOpt read FUserInfoOffset write UserInfoOffsetSet;
       property UserAddTestDesign: boolean read UserAddTestDesignGet write UserAddTestDesignSet;
       property OnClickNameUser: TNotifyEvent2 read FOnClickNameUser write FOnClickNameUser;
       property OnClickInfoUser: TNotifyEvent2 read FOnClickInfoUser write FOnClickInfoUser;
    end;
 

implementation
   const
  SAmListBoxIndexError = 'Нет такого индекса в ListBox';

  type
   TLocComponent = class(TComponent);
   TLocWinControl = class(TWinControl);
   TLocGraphic= class(TGraphic);
   TLocAmCheckBoxOpt = class (TAmCheckBoxOpt);



{ TAmListBoxFilesItem }

procedure TAmLbItemFile.AFileNameSet(const Value: TAmFileName);
begin
  if FFileName <> Value then
  begin
     FFileName := Value;
     if FFileNameLock=0 then
     begin
        if Assigned(ListBox) and (ListBox is TAmListBoxFilesCustom) then
        TAmListBoxFilesCustom(ListBox).LoadFileNameToItem(self,FFileName)
     end;
     Changed(integer(@FFileName));
  end;
end;

procedure TAmLbItemFile.Changed(IndexVar: Integer);
begin
  inherited;
end;

constructor TAmLbItemFile.Create(AStringsOwner:TAmStrings);
begin
  inherited;
  FFileName:='';
  FFileNameLock:=0;
end;

destructor TAmLbItemFile.Destroy;
begin
  inherited;
end;
function TAmLbItemFile.storedFileName: Boolean;
begin
  Result:=  FFileName<>'';
end;

{TAmClientListBoxFilesCustom}

constructor TAmListBoxFilesCustom.Create(AOwner: TComponent);
begin
   inherited create(AOwner);
   FSaveItemHeidth:=0;
   FPathPictureDefault:=TPicture.Create;
   BorderStyle:=  bsNone;
   ParentColor:=false;
   Font.Color:=clwhite;
   Font.Size:=10;
   Color:= $00423129;
   ColorItemMouseMovi:= $00513D33;
   //ScrollV.AThumbColorBack:= clGray;
   //ScrollV.AThumbColor:=$0085EB14;
   //ScrollV.AColorBorder:= $009D7357;
   //ScrollV.AreaColor:=$004D392B;
   ItemHeightFile:=45;
   FPathRoot:='';
   self.ScrollV.ATheme.StyleHelp.MainLiteBlack;
   self.ScrollV.ATheme.ThumbFillColorAuto:= clAqua;
   self.ScrollV.ATheme.ThumbRounded:=true;
   self.IcoBig.FBolderSize:=0;

 //  GetDir(0, FPathRoot);
   {
   Popap:= TAmClientPopapMenuCustom.Create(TWincontrol(AOwner));
   Popap.ControlSave:=nil;
   Popap.Color:=$00453830;
   Popap.Constraints.MinHeight:=20;
   Popap.Constraints.MaxHeight:=300;
   }
end;
destructor TAmListBoxFilesCustom.Destroy;
begin
     if Assigned(FPathPictureDefault) then
     FreeAndNil(FPathPictureDefault);
     inherited ;
end;
   {
procedure TAmListBoxFilesCustom.RunFile(FileName:string);
begin
   if FileName<>'' then
     ShellExecute(Application.Handle, 'open', PChar(FileName), '', nil,SW_SHOWNORMAL)
end;
procedure TAmListBoxFilesCustom.RunPapkaSelectFile(FileName:string);
begin
   if FileName<>'' then
     ShellExecute(Application.Handle, nil, 'explorer.exe', PChar('/select,' + FileName), nil, SW_SHOWNORMAL);
end;  }
procedure TAmListBoxFilesCustom.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   inherited MouseUp(Button,Shift,X, Y);
   if Button = mbRight then
   //Popap.Open(self,0);
end;
function TAmListBoxFilesCustom.ObjectItemAdd(Index: PInteger): TAmLbItemFile;
begin
   Result :=  inherited ObjectItemAdd(Index)  as TAmLbItemFile;
end;

function TAmListBoxFilesCustom.ObjectItemInsert(Index: integer): TAmLbItemFile;
begin
   Result :=  inherited ObjectItemInsert(Index)  as TAmLbItemFile;
end;

procedure TAmListBoxFilesCustom.PathRootSet(const Value: TAmDirName);
begin
  FPathRoot := Value;
  self.Clear;
 //  if not  (csDesigning in self.ComponentState) then
  LoadPath(FPathRoot);
end;

procedure TAmListBoxFilesCustom.SetParent(W: TWinControl);
begin
  inherited;
end;

function TAmListBoxFilesCustom.ObjectItemIndexGet(Index: Integer): TAmLbItemFile;
var O:TObject;
begin
   O:= inherited ObjectItemIndex[Index];
   if Assigned(O) and ( O is TAmLbItemFile)  then
    Result:=  TAmLbItemFile(O)
    else
    Result:=nil;
end;

procedure TAmListBoxFilesCustom.DrawItemElements(Index: Integer;Rect: TRect;ItemObject:TAmLbItem);
begin
   inherited DrawItemElements(Index,Rect,ItemObject);
end;
procedure TAmListBoxFilesCustom.ItemsEvent(Sender:TStrings;Prm:PAmEventStringsPrm);
begin
    inherited;
end;
procedure TAmListBoxFilesCustom.CreateWnd;
begin
   inherited;
   if FSaveItemHeidth<> ItemHeightFile then
   begin
      FSaveItemHeidth:= ItemHeightFile;
       UpdateFileIcoItems;
   end;

end;
procedure  TAmListBoxFilesCustom.UpdateFileIcoItems;
var
  I: Integer;
begin
   Items.BeginUpdate;
   try
    for I := 0 to self.ObjectItemCount-1 do
     LoadFileNameToItem(self.ObjectItemIndex[i],ObjectItemIndex[i].FileName);
   finally
     Items.EndUpdate;
   end;
end;
function TAmListBoxFilesCustom.LoadFileNameToItem(AItem:TAmLbItemFile;AFileName:string):boolean;
begin
   Items.BeginUpdate;
   try
     Result:=false;
     if Length(AFileName)>0 then
     begin
     if AFileName[length(AFileName)]='\' then
     delete(AFileName,length(AFileName),1);
     end;
       inc(AItem.FFileNameLock);
       try
         AItem.FileName:= AFileName;
         AItem.Caption:= AmFileBase.ExtractFileName(AFileName);
         if AmFileBase.IsFile(AFileName) or AmFileBase.IsPath(AFileName) then
          begin
             AmIcoFileSystem.LoadToPicture(AItem.Ico.Picture,AFileName,ItemHeightFile -1);
             if not Assigned(AItem.Ico.Picture.Graphic) and Assigned(FPathPictureDefault) then
             AItem.Ico.Picture:=FPathPictureDefault
             else Result:=true;
          end;
       finally
         dec(AItem.FFileNameLock);
       end;

   finally
      Items.EndUpdate;
   end;
end;
function TAmListBoxFilesCustom.AddFileGraf(AFileName:string;var Obj:TAmLbItemFile):boolean;
begin
   self.Items.BeginUpdate;
   try
       Obj:= ObjectItemAdd;
       Result:= LoadFileNameToItem(Obj,AFileName);
   finally
     self.Items.EndUpdate;
   end;
end;
function TAmListBoxFilesCustom.AddFile(FullFileName:string):TAmLbItemFile;
begin
    AddFileGraf(FullFileName,Result);
end;
Procedure TAmListBoxFilesCustom.DeleteFile(index:integer);
begin
    Items.Delete(index);
end;
class function TAmListBoxFilesCustom.GetClassListBoxItem: TAmLbItemClass;
begin
   Result:= TAmLbItemFile;
end;

procedure TAmListBoxFilesCustom.PathPictureDefaultSet(const Value: TPicture);
begin
   if not Assigned(FPathPictureDefault) then
   FPathPictureDefault:= TPicture.Create;
   FPathPictureDefault.Assign(Value);
end;

function TAmListBoxFilesCustom.ItemHeightFileGet: integer;
begin
    Result:= ItemHeight;
end;

procedure TAmListBoxFilesCustom.ItemHeightFileSet( Value: integer);
begin
   if Value<25 then
   Value:=25;
   if Value>200 then
   Value:=200;
   Value:=AmScaleV(Value);
   ItemHeight:= Value;
   self.Repaint;
end;

procedure TAmListBoxFilesCustom.LoadPath(APath: string);
var i:integer;
L:TStringlist;
begin
  //APath:= AmFileBase.GetFullPathFile(APath);
  APath:=APath;
  L:=TStringlist.Create;
  try
     if APath<>'' then
     begin
        APath:= APath.Replace('/','\');
        if APath<>'' then
        if APath[Length(APath)]<>'\' then
        APath:=APath+'\';
     end;
     AmFileBase.ListFileAndDir(APath,L,true);
    Items.BeginUpdate;
    try
    for I := 0 to L.Count-1 do
     AddFile(APath+L[i]);
    finally
     Items.EndUpdate;
    end;
    ItemIndex:=-1;
  finally
    L.Free;
  end;
end;











                 { TamListBoxNoScroll }
constructor TamListBoxNoScroll.Create(AOwner: TComponent);
begin
   inherited create(AOwner);
   MousePointMove:=Point(-1,-1);



   FScrollVStandart:=false;
   FScrollHStandart:=false;
   FItemIndexMouseMove:=-1;
   FSaveSelectClickIndex:=-1;
   self.style:=lbOwnerDrawFixed;
   ItemHeight := AmScaleV(30);
   FColorItemMouseMovi:= $00513D33;
   FColorItemMouseMovi:= $00FFFFDF;
   FColorItemSelect:= $00BEB545;
   FTextItemCorrectX:=AmScaleV(7);
   BorderStyle:=  bsNone;
   //self.DoubleBuffered:=true;

   ParentDoubleBuffered := False;
   DoubleBuffered:= True;


end;
destructor TamListBoxNoScroll.Destroy;
begin
   inherited Destroy;
end;
procedure TamListBoxNoScroll.DefaultHandler(var Message);
begin
  inherited DefaultHandler(Message);
  case Winapi.Messages.TMessage(Message).Msg of
    LB_RESETCONTENT, LB_DELETESTRING, LB_ADDSTRING, LB_SETITEMDATA, LB_INSERTSTRING :begin
        ItemsChangeCall(Winapi.Messages.TMessage(Message).Msg);
    end;
    WM_SETREDRAW:begin
      if Boolean(Winapi.Messages.TMessage(Message).WParam) then
      ItemsChangeCall(Winapi.Messages.TMessage(Message).Msg);
    end;
  end;
end;
procedure TamListBoxNoScroll.ItemsChangeCall(WasCmd:Cardinal);
begin
   TamHandleObject.PostMessageNotDudlicat(self.WindowHandle,AM_LB_ITEMS_CHANGE,0,WasCmd,AM_LB_ITEMS_CHANGE,AM_LB_ITEMS_CHANGE);
end;
procedure TamListBoxNoScroll.AmLbItemsChangePost(var Message: Winapi.Messages.TMessage); //message AM_LB_ITEMS_CHANGE;
begin
  ItemsChangePost(Message.LParam);
end;
procedure TamListBoxNoScroll.ItemsChangePost(WasCmd:Cardinal);
begin
   if not (TObject(self) is TAmListBoxObjects) then
   begin
    if Assigned(FOnItemsChange) then
    FOnItemsChange(self,Items,nil);
   end;
end;
procedure TamListBoxNoScroll.ItemsEvent(Sender: TStrings;Prm: PAmEventStringsPrm);
begin
    if Assigned(FOnItemsChange) then
    FOnItemsChange(self,Sender,Prm);
end;







procedure TamListBoxNoScroll.StringsAdd(Source: TStrings);
var I:integer;
    L:TStringList;
begin

 self.Items.BeginUpdate;
 try
    L:=TStringList.Create;
   try
     L.Assign(Source);
     for I := 0 to L.Count-1 do
     L.Objects[i]:=nil;
     self.Items.AddStrings(L);
   finally
      L.Free;
   end;

 finally
   Items.EndUpdate;
 end;
end;

procedure TamListBoxNoScroll.StringsAssign(Source: TStrings);
var I:integer;
    L:TStringList;
begin
 self.Items.BeginUpdate;
 try
    L:=TStringList.Create;
   try
     L.Assign(Source);
     for I := 0 to L.Count-1 do
     L.Objects[i]:=nil;
     self.Items.Clear;
     self.Items.Assign(L);
   finally
      L.Free;
   end;

 finally
   Items.EndUpdate;
 end;
end;

procedure TamListBoxNoScroll.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  FTextItemCorrectX:= AmScale.ChangeScaleValue(FTextItemCorrectX,M, D);
end;

procedure TamListBoxNoScroll.Clear;
begin
     //if WindowHandle<>0 then
     if not (csDestroying in self.ComponentState)  then
     inherited Clear;
     FItemIndexMouseMove:=-1;
     if Assigned(FOnChangeMoveMouse) then
     FOnChangeMoveMouse(self);
     if Assigned(FOnChangeSelect) then
     FOnChangeSelect(self);

      if (WindowHandle<>0) and  Assigned(FOnClearListBox) then
     FOnClearListBox(self);  
end;

procedure TamListBoxNoScroll.Click;
begin
  inherited Click; 
end;

procedure TamListBoxNoScroll.CMMouseLeave(var Message: Winapi.Messages.TMessage);
var I:integer;
begin
   inherited;
     I:= FItemIndexMouseMove;
     FItemIndexMouseMove:= -1;
     InvalidDateRectIndex(I);
     MousePointMove:=Point(-1, -1);
     if Assigned(FOnChangeMoveMouse) then
     FOnChangeMoveMouse(self);
     MousePointMove:= Point(-1,-1);
end;
procedure TamListBoxNoScroll.ColorItemMouseMoviSet(const Value: Tcolor);
begin
  FColorItemMouseMovi := Value;
  InvalidDateRectIndex(FItemIndexMouseMove);
end;

procedure TamListBoxNoScroll.ColorItemSelectSet(const Value: Tcolor);
begin
  FColorItemSelect := Value;
   self.Repaint;
end;

procedure TamListBoxNoScroll.CreateParams(var Params: TCreateParams);
begin
    inherited;
    if not FScrollHStandart and not FScrollVStandart then
    Params.Style := Params.Style xor WS_VSCROLL xor WS_HSCROLL
    else if not FScrollVStandart then
    Params.Style := Params.Style xor WS_VSCROLL
    else if not FScrollHStandart then
    Params.Style := Params.Style xor WS_HSCROLL;
end;


procedure TamListBoxNoScroll.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  FSaveSelectClickIndex:=-1;
  inherited;
  DoChangeClickSelect(X, Y);
end;


procedure TamListBoxNoScroll.MouseMove(Shift: TShiftState; X, Y: Integer);
var I:integer;
begin
  MousePointMove:=Point(X, Y);
  inherited MouseMove(Shift,X, Y);
  I:= ItemAtPos(Point(X, Y), True);
  if i<>FItemIndexMouseMove then
  begin
    // InvalidDateRectIndex(FItemIndexMouseMove);
     FItemIndexMouseMove:= i;
     InvalidDateRectIndex(FItemIndexMouseMove);
     if Assigned(FOnChangeMoveMouse) then
     FOnChangeMoveMouse(self);
  end;

end;



procedure TamListBoxNoScroll.ResetContent;
begin
  inherited ResetContent;
end;

procedure TamListBoxNoScroll.ScrollHStandartSet(const Value: boolean);
begin
  FScrollHStandart := Value;
  self.RecreateWnd;
end;

procedure TamListBoxNoScroll.ScrollVStandartSet(const Value: boolean);
begin
  FScrollVStandart := Value;
  self.RecreateWnd;
end;

procedure TamListBoxNoScroll.TextItemCorrectXSet(const Value: integer);
begin
  FTextItemCorrectX := Value;
  self.Repaint;
end;

procedure TamListBoxNoScroll.DoChangeClickSelect( X, Y: Integer);
begin
  if FSaveSelectClickIndex<>ItemIndex then
  begin
     FSaveSelectClickIndex:= ItemIndex;
     DoChangeSelect(X, Y);
  end;
end;
procedure TamListBoxNoScroll.DoChangeSelect( X, Y: Integer);
begin
    if Assigned(FOnChangeSelect) then
     FOnChangeSelect(self);
end;


function TamListBoxNoScroll.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  REsult:=  inherited DoMouseWheel(Shift,WheelDelta, MousePos);

  if WheelDelta>0 then TopIndex:= TopIndex-1
  else TopIndex:= self.TopIndex+1;


end;

procedure TamListBoxNoScroll.DrawItem_CorrectRect(Index: Integer; var Rect: TRect;ItemObject:TAmLbItem);
begin
end;





procedure TamListBoxNoScroll.InvalidDateRectIndex(Index: Integer);
//var   R: TRect;
begin
    self.Repaint;
  {  exit;
    if (Index < 0) or (Index > Count) then
    begin

    exit;
    end;

    R := ItemRect(Index);
    InvalidateRect(Handle, R, not (csOpaque in ControlStyle));
    UpdateWindow(Handle);   }
end;

function TamListBoxNoScroll.ItemHeightGet: integer;
begin
 Result:= inherited ItemHeight;
end;

procedure TamListBoxNoScroll.ItemHeightSet( Value: integer);
begin
   if Value<15 then
   Value:=15;
   if Value>400 then
   Value:=400;
    inherited ItemHeight:= Value;
end;

function TamListBoxNoScroll.ItemIndexCaptionGet: string;
begin
  if self.ItemIndex>=0 then
   Result:=Self.Items[ItemIndex]
   else
   Result:='';
end;

procedure TamListBoxNoScroll.ItemIndexCaptionSet(const Value: string);
begin
  if self.ItemIndex>=0 then
   Self.Items[ItemIndex]  := Value;
end;


function TamListBoxNoScroll.ItemIndexTextIdGet: TAmTextId;
begin
    Result.SetValue(ItemIndexCaption);
end;
function TamListBoxNoScroll.ItemIndexTextSdGet: TAmTextSd;
begin
   Result.SetValue(ItemIndexCaption);
end;

function TamListBoxNoScroll.ItemTextIdGet(Index: integer): TAmTextId;
begin
   Result.SetValue(Items[Index]);
end;

function TamListBoxNoScroll.ItemTextSdGet(Index: integer): TAmTextSd;
begin
  Result.SetValue(Items[Index]);
end;

{
function TamListBoxNoScroll.ListObjectGet: TList;
begin
  // if Assigned(ListItems) then
 // Result:=ListItems.ListSf
  // else
   Result:=nil;
end;  }

procedure TamListBoxNoScroll.DrawItem(Index: Integer; Rect: TRect;State: TOwnerDrawState);
var ItemObject:TAmLbItem;
    Obj:TObject;
begin
     Canvas.Brush.Color :=self.Color;
     Canvas.Font:=self.Font;

     Obj:=Items.Objects[Index];
     if Assigned(Obj) and (Obj is TAmLbItem)  then
     begin
      ItemObject:= TAmLbItem(Obj);
      ItemObject.RectItem:=   Rect;
      ItemObject.IndexSet(Index);
     end
      else
      ItemObject:=nil;


     DrawItem_Background(Index,Rect,State,ItemObject);
     DrawItem_CorrectRect(Index,Rect,ItemObject);






    DrawItemElements(Index,Rect,ItemObject);
    If OdFocused In State Then
    DrawFocusRect(Canvas.Handle, Rect);
    DrawItemAfter(Index,Rect,State);

end;
procedure TamListBoxNoScroll.DrawItem_Background(Index: Integer; Rect: TRect;State: TOwnerDrawState;ItemObject:TAmLbItem);
begin
     If (odSelected In State) Then
     Canvas.Brush.Color := FColorItemSelect
     else if (Index=ItemIndexMouseMove) then
     Canvas.Brush.Color :=FColorItemMouseMovi;
     Canvas.FillRect(Rect);
end;
procedure  TamListBoxNoScroll.DrawItemAfter(Index: Integer; Rect: TRect;State: TOwnerDrawState);
begin

end;
procedure TamListBoxNoScroll.DrawItemElements(Index: Integer; Rect: TRect;ItemObject:TAmLbItem);
begin
    DrawItemElements_Caption(Index,Rect,ItemObject);
end;
procedure TamListBoxNoScroll.DrawItemElements_Caption(Index: Integer; Rect: TRect;  ItemObject: TAmLbItem);
begin
     self.Canvas.Brush.Style := bsClear;
     Rect.Left:= Rect.Left + AmScaleV(FTextItemCorrectX);
     if Assigned(ItemObject) then
     ItemObject.RectCaption:= Rect;
     DrawText(Canvas.Handle, PChar(Items[Index]),Length(Items[Index]),Rect,
     DrawTextBiDiModeFlags(DT_SINGLELINE Or DT_VCENTER Or DT_NOPREFIX or DT_END_ELLIPSIS));
end;





{ TAmCustomListBoxHelper }

function TAmCustomListBoxHelper.ItemsListBoxGet: TStrings;
begin
  Result:= Items;
end;

procedure TAmCustomListBoxHelper.ItemsListBoxSet(const Value: TStrings);
begin
    with self do
    begin
       if Assigned(FItems) then
       FreeAndNil(FItems);
      FItems := Value;
    end;
end;

function TAmCustomListBoxHelper.SaveItemsGet: TStrings;
begin
    with self do
    begin
      Result := FSaveItems;
    end;

end;

{ TListBoxStrings }
constructor TAmStringsLB.Create();
begin
   inherited Create();
   ListBox:=nil;
end;
destructor TAmStringsLB.Destroy;
begin
  inherited;
end;
function TAmStringsLB.ControlOwnerGet: TWinControl;
begin
 Result:= ListBox;
end;


function TAmStringsLB.GetCount: Integer;
begin
  Result := SendMessage(ListBox.Handle, LB_GETCOUNT, 0, 0);
end;

function TAmStringsLB.Get(Index: Integer): string;
var
  Len: Integer;
begin
  if ListBox.Style in [lbVirtual, lbVirtualOwnerDraw] then
    Result := ListBox.DoGetData(Index)
  else
  begin
    Len := SendMessage(ListBox.Handle, LB_GETTEXTLEN, Index, 0);
    if Len = LB_ERR then Error(SAmListBoxIndexError, Index);

{$IF DEFINED(CLR)}
    if Len <> 0 then
      SendGetTextMessage(ListBox.Handle, LB_GETTEXT, Index, Result, Len, False)
    else
      Result := '';
{$ELSE}
    SetLength(Result, Len);
    if Len <> 0 then
    begin
      Len := SendMessage(ListBox.Handle, LB_GETTEXT, Index, LPARAM(PChar(Result)));
      SetLength(Result, Len);  // LB_GETTEXTLEN isn't guaranteed to be accurate
    end;
{$ENDIF}
  end;
end;




function TAmStringsLB.IndexOf(const S: string): Integer;
begin

  if ListBox.Style in [lbVirtual, lbVirtualOwnerDraw] then
    Result := ListBox.DoFindData(S)
  else
    Result := SendTextMessage(ListBox.Handle, LB_FINDSTRINGEXACT, WPARAM(-1), S);
end;

procedure TAmStringsLB.EvPut(Index: Integer; const S: string);
var
  I: Integer;
  TempData: TListBoxItemData;
begin

    if (Index < 0) or (Index > Count - 1) then
      Error(SAmListBoxIndexError, Index);
    I := ListBox.ItemIndex;
    TempData := ListBox.InternalGetItemData(Index);
    // Set the Item to 0 in case it is an object that gets freed during Delete
  {$IF DEFINED(CLR)}
    ListBox.InternalSetItemData(Index, nil);
  {$ELSE}
    ListBox.InternalSetItemData(Index, 0);
  {$ENDIF}
    inherited EvPut(Index,S);
    ListBox.InternalSetItemData(Index, TempData);
    ListBox.ItemIndex := I;

end;


(*
procedure TAmListBoxStrings.EvPutObject(Index: Integer; AObject: TObject);
begin
   List[Index]:=IInterface(AObject as TInterfacedObject);
   exit;

  if not (ListBox.Style in [lbVirtual, lbVirtualOwnerDraw]) then
  begin

  exit;

   // Calling Insert (LB_INSERTSTRING) with an index of -1 adds the
   // string to the end of the list. Mimic that behaviour for InsertObject
   // since an index of -1 with LB_SETITEMDATA means something completely
   // different (it sets the "data" for ALL items in the list).
   if Index = -1 then
     Index := Count - 1;
{$IF DEFINED(CLR)}
    ListBox.SetItemData(Index, AObject);
{$ELSE}
    ListBox.SetItemData(Index, TListBoxItemData(AObject));
{$ENDIF}
  end;
end;

function TAmListBoxStrings.GetObject(Index: Integer): TObject;
begin
  Result:= TObject(List[Index]);
  exit;
  if ListBox.Style in [lbVirtual, lbVirtualOwnerDraw] then
    Result := ListBox.DoGetDataObject(Index)
  else
  begin
{$IF DEFINED(CLR)}
    if (Index < 0) or (Index >= Count) then
      Error(SListIndexError, Index);
    Result := TObject(ListBox.GetItemData(Index));
{$ELSE}
    Result := TObject(ListBox.GetItemData(Index));
    if TListBoxItemData(Result) = LB_ERR then Error(SAmListBoxIndexError, Index);
{$ENDIF}
  end;
end;
*)
function TAmStringsLB.EvAdd(const S: string): Integer;
begin

  Result := -1;
  if ListBox.Style in [lbVirtual, lbVirtualOwnerDraw] then Exit;
{$IF DEFINED(CLR)}
  if not Assigned(S) then
    Result := SendTextMessage(ListBox.Handle, LB_ADDSTRING, 0, '')
  else
{$ENDIF}
    Result := SendTextMessage(ListBox.Handle, LB_ADDSTRING, 0, S);
  if Result < 0 then raise EOutOfResources.Create(SAmListBoxIndexError);
  inherited EvAdd(S);
end;

procedure TAmStringsLB.EvInsert(Index: Integer; const S: string);
var
  LResult: Integer;
begin

  if ListBox.Style in [lbVirtual, lbVirtualOwnerDraw] then exit;
{$IF DEFINED(CLR)}
  if not Assigned(S) then
    LResult := SendTextMessage(ListBox.Handle, LB_INSERTSTRING, Index, '')
  else
{$ENDIF}
    LResult := SendTextMessage(ListBox.Handle, LB_INSERTSTRING, Index, S);
  if LResult < 0 then
    raise EOutOfResources.Create(SAmListBoxIndexError);
  inherited ;
end;


procedure TAmStringsLB.EvDelete(Index: Integer);
begin
   ListBox.DeleteString(Index);
   inherited EvDelete(Index);
end;


procedure TAmStringsLB.EvExchange(Index1, Index2: Integer);
var
  TempData: TListBoxItemData;
  TempString: string;
begin
  if ListBox.Style in [lbVirtual, lbVirtualOwnerDraw] then exit;
  BeginUpdate;
  try
    TempString := Strings[Index1];
    TempData := ListBox.InternalGetItemData(Index1);
    Strings[Index1] := Strings[Index2];
    ListBox.InternalSetItemData(Index1, ListBox.InternalGetItemData(Index2));
    Strings[Index2] := TempString;
    ListBox.InternalSetItemData(Index2, TempData);
    if ListBox.ItemIndex = Index1 then
      ListBox.ItemIndex := Index2
    else if ListBox.ItemIndex = Index2 then
      ListBox.ItemIndex := Index1;
     inherited ;
  finally
    EndUpdate;
  end;
end;

procedure TAmStringsLB.EvClear;
begin

  ListBox.ResetContent;
   inherited EvClear;
end;

{
procedure TAmStringsLB.EvSetUpdateState(Updating: Boolean);
begin
  SendMessage(ListBox.Handle, WM_SETREDRAW, Ord(not Updating), 0);
  if not Updating then ListBox.Refresh;
end;
}

procedure TAmStringsLB.EvMove(CurIndex, NewIndex: Integer);
var
  TempData: TListBoxItemData;
  TempString: string;
  TempDataObj:TObject;
begin
  if ListBox.Style in [lbVirtual, lbVirtualOwnerDraw] then exit;
  BeginUpdate;
  ListBox.FMoving := True;
  try
    if CurIndex <> NewIndex then
    begin
      TempString := Get(CurIndex);
      TempData := ListBox.InternalGetItemData(CurIndex);
      TempDataObj:= self.EvGetObject(CurIndex);
{$IF DEFINED(CLR)}
      ListBox.InternalSetItemData(CurIndex, nil);
{$ELSE}
      ListBox.InternalSetItemData(CurIndex, 0);
{$ENDIF}
      EvDelete(CurIndex);
      EvInsertObject(NewIndex, TempString,TempDataObj);
      ListBox.InternalSetItemData(NewIndex, TempData);
     //  inherited ;
    end;
  finally
    ListBox.FMoving := False;
    EndUpdate;
  end;
end;



{ TAmListBox }

constructor TAmListBox.Create(AOwner: TComponent);
begin
  inherited;
    FVScrollLock:=0;
    FVScrollLockPos:=0;
    FScrollVNotVisible:=false;
    FVScroll:= TAmScrollBar.Create(self);
    FVScroll.SetSubComponent(true);
    FVScroll.FocusParentControl:=self;
    FVScroll.BringToFront;
    FVScroll.Kind:= sbVertical;
    FVScroll.Align:=alNone;
    FVScroll.OnChangePos:= VScrollChangePosition;
    FVScroll.OnResize:=self.ScrollVResize;
    FVScroll.OnChangeVisible:= ScrollChangeVisible;
   // FVScroll.AThumbColor:= $00858585;
   // FVScroll.AreaColor:= $00EBEBEB;
   // FVScroll.AreaColorScrolled:= $008A8A8A;




end;

procedure TAmListBox.CreateWnd;
begin
  inherited;
  UpadateScrollV;
end;
procedure TAmListBox.VScrollChangePosition(Sender: TObject; OldPosition,NewPosition: Int64);
begin
   if FVScrollLock>0 then exit;
   inc(FVScrollLock);
  try
      if Items.Count>0 then
      begin
       if (OldPosition> NewPosition)  or ( (OldPosition in [0,1]) and (NewPosition in [0,1])) then
       begin
         if NewPosition<ItemHeight then
         self.TopIndex:= 0
         else
         self.TopIndex:= NewPosition div self.ItemHeight;
       end
       else
         self.TopIndex:= (NewPosition div self.ItemHeight)+1
      end;
  finally
    dec(FVScrollLock);
  end;
end;

destructor TAmListBox.Destroy;
begin
  inherited;
end;

procedure TAmListBox.DrawItemAfter(Index: Integer; Rect: TRect;  State: TOwnerDrawState);
begin
  inherited;
 // if  ScrollV.Visible then
  // ScrollV.Repaint;
end;

procedure TAmListBox.DrawItem_CorrectRect(Index: Integer; var Rect: TRect;ItemObject:TAmLbItem);
begin
   if (csDesigning in self.ComponentState) or   self.ScrollV.Visible   then
      Rect.Right:= Rect.Right -  ScrollV.Width;
end;

procedure TAmListBox.ItemsChangePost(WasCmd:Cardinal);
begin
   UpadateScrollV;
   inherited ItemsChangePost(WasCmd);
end;
procedure TAmListBox.ItemsEvent(Sender: TStrings; Prm: PAmEventStringsPrm);
begin
  inherited ItemsEvent(Sender,Prm);
  case Prm.Enum of

          sevClear,
          sevDelete,
          sevInsert,
          sevInsertObject,
          sevAssign,
          sevAdd,
          sevAddObject,
          sevAddString,
          sevSetTextStr,
          sevSetText,
          sevWinChangeControlItems :
          begin
               UpadateScrollV;
          end;
  end;

end;


procedure TAmListBox.Resize;
begin
  inherited;
   UpadateScrollV;
end;

procedure TAmListBox.ScrollVNotVisibleSet(const Value: boolean);
begin
  FScrollVNotVisible := Value;
  UpadateScrollV;

end;

procedure TAmListBox.ScrollVResize(Sender: TObject);
begin
    UpadateScrollV;
end;


procedure TAmListBox.SetName(const NewName: TComponentName);
begin
  inherited;
    FVScroll.Name:='ScrollV';
end;

procedure TAmListBox.SetParent(W: TWinControl);
begin
  inherited;
  if Parent=nil then
  begin
    FVScroll.Parent:=nil;
    exit;
  end;
  FVScroll.Parent:=Parent;
  UpadateScrollV;
end;
procedure TAmListBox.WMWindowParentChanged(var Message: Winapi.Messages.TMessage);// message WM_CHANGEUISTATE;
var p:Cardinal;
begin
 inherited;
 if (self.Parent<>nil) and self.HandleAllocated then
 begin
   p:=GetParent(self.Handle);
   if p <> GetParent(TLocWinControl(FVScroll).Handle) then
   Winapi.Windows.SetParent(TLocWinControl(FVScroll).Handle,p);
 end;

end;
procedure TAmListBox.SetZOrder(TopMost: Boolean);
begin
   if TopMost then
   begin
      inherited;
      FVScroll.SetZPos(true);
   end
   else
   begin
      FVScroll.SetZPos(false);
      inherited;
   end;

end;

procedure TAmListBox.UpadateScrollVPos;
begin
   if FVScrollLockPos>0 then exit;
   inc(FVScrollLockPos);
  try
    if (FVScroll.Parent=nil) or (Parent =nil) then
    begin
      exit;
    end;
    if self.Width + FVScroll.Width <= Parent.ClientWidth then
    begin
      //  FVScroll.SetBounds(self.Left + self.Width,self.Top,FVScroll.Width,self.Height);
      //  FVScroll.PositionZ:= self.PositionZ +1 ;
       FVScroll.SetBounds(self.Left + self.Width - FVScroll.Width,self.Top,FVScroll.Width,self.Height);
    end
    else
    begin
        FVScroll.SetBounds(self.Left + self.Width - FVScroll.Width,self.Top,FVScroll.Width,self.Height);
      //  self.SendToBack
       // FVScroll.BringToFront;
    end;

         
  finally
     dec(FVScrollLockPos);
  end;



     //alNone, alTop, alBottom, alLeft, alRight, alClient, alCustom



end;
procedure TAmListBox.ScrollChangeVisible(Sender: TObject);
//var c,s:boolean;
begin
    // Sender:= Sender;
     //c:=ScrollV.Visible;
     //s:=ScrollV.Showing;
end;
procedure TAmListBox.UpadateScrollV;
var Range:Integer;
begin
    UpadateScrollVPos;
    if Parent =nil then exit;

    if {(self.Columns>0) or} FScrollVNotVisible or  not Visible then
    begin
     // ScrollV.Visible:=true;
      if ScrollV.Visible then
      begin
      ScrollV.Position:=0;
      ScrollV.Max:=1;
      ScrollV.Visible:=false;
      self.Repaint;
      end;
      exit;
    end;

    Range:=  items.Count * self.ItemHeight;
    if Range>self.ClientHeight then
    begin
       if not  ScrollV.Visible then
       begin
       ScrollV.Visible:=true;
       self.Repaint;
       end;
       ScrollV.Max:=  Range;
       ScrollV.PageSize:=  ClientHeight;

       if FVScrollLock=0 then
       begin
           inc(FVScrollLock);
          try
              ScrollV.Position:=self.TopIndex * self.ItemHeight;
          finally
            dec(FVScrollLock);
          end;
       end;


    end
    else if ScrollV.Visible then
    begin
      ScrollV.Position:=0;
      ScrollV.Max:=1;
      ScrollV.Visible:=false;
      self.Repaint;
    end;
end;

procedure TAmListBox.VScrollSet(const Value: TAmScrollBar);
begin
  if FVScroll=Value then exit;
  FVScroll.Assign(Value);
  UpadateScrollV;
end;

procedure TAmListBox.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  inherited;
  UpadateScrollV;
end;


procedure TAmListBox.CMVisibleChanged(var Message:  Winapi.Messages.TMessage);
begin
   inherited;
   UpadateScrollV;
end;
procedure TAmListBox.CMEnabledChanged(var Message:  Winapi.Messages.TMessage);
begin
    inherited;
     ScrollV.Enabled:=Enabled;
end;

procedure TAmListBox.Wnd_LB_SETTOPINDEX(var Msg:  Winapi.Messages.TMessage);
begin
     inherited;
     UpadateScrollV;
end;


{ TAmListBoxItem }

constructor TAmLbItem.Create(AStringsOwner:TAmStrings);
begin
  FListBox:=nil;
  inherited Create (AStringsOwner);
  RectButtonClose:= Rect(0,0,0,0);
  FButtonCloseVisible:=false;
end;

destructor TAmLbItem.Destroy;
begin
 // if Assigned(FImageBackground) then
 // FreeAndNil(FImageBackground);
  FListBox:=nil;
  inherited;
end;

procedure TAmLbItem.ButtonCloseVisibleSet(const Value: boolean);
begin
  if FButtonCloseVisible= Value then exit;
  FButtonCloseVisible := Value;
  if Assigned(ListBox) then
  ListBox.InvalidDateRectIndex(Index);
end;

function TAmLbItem.ControlOwnerGet: TWinControl;
begin
  Result:= FListBox;
end;

procedure TAmLbItem.ControlOwnerSet(const Value: TWinControl);
begin
   if (Value= nil) or  (Value is TAmListBoxObjects) then
   FListBox:=TAmListBoxObjects(Value)
   else raise Exception.Create('Error TAmListBoxItem.ControlOwnerSet invalid Value');
end;

procedure TAmLbItem.Assign(ASource:TPersistent);
begin
   inherited;
   if ASource is  TAmLbItem then
   FButtonCloseVisible:= TAmLbItem(ASource).FButtonCloseVisible;
   if Assigned(FListBox) then
   FListBox.InvalidDateRectIndex(Index);
end;


{ TAmListBoxObject }

procedure TAmListBoxObjects.ButtonCloseChanged(Sender: TObject);
begin
// if ButtonClose.Visible then
 self.Repaint;
end;

function TAmListBoxObjects.ButtonCloseVisibleGet: boolean;
begin
    Result:= ButtonClose.Visible;
end;

procedure TAmListBoxObjects.ButtonCloseVisibleSet(const Value: boolean);
begin
    ButtonClose.Visible:= Value;
end;

procedure TAmListBoxObjects.Clear;
begin
  inherited;

end;

constructor TAmListBoxObjects.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
   FButtonClose:=TAmButtonClose.Create(self);
   Include(TLocComponent(FButtonClose).FComponentStyle, csSubComponent);
   FButtonClose.Visible:=false;
   FButtonClose.OnChangeSettingClose:=  ButtonCloseChanged;

   ItemsListBoxReplace:= TAmStringsLB.Create();
   TAmStringsLB(Items).ListBox := Self;
   TAmStringsLB(Items).OnEvent:= ItemsEvent;
   TAmStringsLB(Items).ObjectItemClass:=GetClassListBoxItem;
   TAmStringsLB(Items).ObjectItemCanAutoCreate:=true;
   TAmStringsLB(Items).ObjectItemCanCheck:=true;
   TAmStringsLB(Items).ObjectItemNeedEventGetClass:=false;
   //TAmStringsLB(Items).TestNotify;
   self.ParentDoubleBuffered:=false;
   self.DoubleBuffered:=true;
end;

destructor TAmListBoxObjects.Destroy;
begin

   FreeAndNil(FButtonClose);
  inherited;
end;

procedure TAmListBoxObjects.MouseUp(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
var I:integer;
Item:TAmLbItem;
begin
    inherited;
    if self.ButtonClose.Visible then
    begin
      I:=self.ItemIndex;
      if I>=0 then
      begin
        Item:=self.ObjectItemIndex[I];
        if Item.ButtonCloseVisible and not Item.RectButtonClose.IsEmpty then
        if Item.RectButtonClose.Contains(Point(X, Y)) then
        DoClickClose(I);

      end;

    end;
end;
procedure TAmListBoxObjects.DoClickClose(Index: integer);
var can:boolean;
begin
   if Parent <> nil  then
   begin
     Can:=true;
     if Assigned(FOnClickClose) then
     FOnClickClose(self,Index,Can);
      if Can then
      Items.Delete(Index);
   end;

end;

procedure TAmListBoxObjects.DrawItemElements(Index: Integer; Rect: TRect;ItemObject:TAmLbItem);
var P:PRect;
begin
    if self.ButtonClose.Visible and Assigned(ItemObject) and  ItemObject.ButtonCloseVisible  then
    begin
         P:=@ItemObject.RectButtonClose;
         P.Left:= Rect.Left + Rect.Width  - ButtonClose.ButSize - 5;
         P.Top:=  Rect.Top + (Rect.Height div 2 - ButtonClose.ButSize div 2);
         P.Width:= ButtonClose.ButSize;
         P.Height:= ButtonClose.ButSize;
         DrawItemElements_ButtonClose(Index,P^,ItemObject);
         Rect.Right:=  P.Left - 5;
    end
    else if Assigned(ItemObject) then
     ItemObject.RectButtonClose:= System.Classes.rect(0,0,0,0);

    DrawItemElements_Caption(Index,Rect,ItemObject);
end;
procedure TAmListBoxObjects.DrawItemElements_ButtonClose(Index: Integer;Rect: TRect;ItemObject:TAmLbItem);
begin
    if self.ButtonClose.Visible and Assigned(ItemObject) and  ItemObject.ButtonCloseVisible  then
    begin
       self.Canvas.Brush.Style := bsClear;
       {
       if (self.ItemIndexMouseMove = Index) and Rect.Contains(self.MousePointMove) then
       self.Canvas.Brush.Color:= ButtonClose.ColorActive
       else
        self.Canvas.Brush.Color:= ButtonClose.ColorDeActive;
        }
       self.Canvas.Brush.Color:= ButtonClose.ColorDeActive;
       Canvas.FillRect(Rect);
       AmPaintСross(Canvas,Rect,ButtonClose.LineColor,ButtonClose.LineWidth);
    end;
end;


class function TAmListBoxObjects.GetClassListBoxItem: TAmLbItemClass;
begin
   Result:= TAmLbItem;
end;

function TAmListBoxObjects.ItemClassGet: TAmLbItemClass;
var C:TAmStringsObjectItemClass;
begin 
 Result:=nil;
 C:= ItemsList.ObjectItemClass;
 if (C<>nil) and C.InheritsFrom(TAmLbItem) then
 Result:=  TAmLbItemClass(C); 
 if Result = nil then
      Result:= GetClassListBoxItem;
end;

procedure TAmListBoxObjects.ItemClassSet(const Value: TAmLbItemClass);
begin
   ItemsList.ObjectItemClass:=Value;
end;

function TAmListBoxObjects.ItemsEmulGet: IAmListColection;
begin
    if Items is TAmStringsObject then
    begin
     { showmessage('yes');
      showmessage(TAmStringsObject(Items).InterfaceEmul.Count.ToString);
      showmessage('yes2');
      }
      Result:=  TAmStringsObject(Items).InterfaceEmul;
    end
    else Result:=nil;
end;

procedure TAmListBoxObjects.ItemsEvent(Sender: TStrings;
  Prm: PAmEventStringsPrm);
begin
    inherited ItemsEvent(Sender,Prm);
end;



function TAmListBoxObjects.ListItemsGet: TAmStringsObject;
begin
    if Assigned(Items) and (Items is TAmStringsObject) then
    Result :=  TAmStringsObject(Items)
    else Result:=nil;
end;


function TAmListBoxObjects.ObjectItemIndexGet(Index: Integer): TAmLbItem;
var O:TObject;
begin
   O:= Items.Objects[Index];
   if Assigned(O) and (O is TAmLbItem) then
   Result:= TAmLbItem(O)
   else Result:=nil;
end;

procedure TAmListBoxObjects.ObjectItemIndexSet(Index: Integer;
  const Value: TAmLbItem);
begin
    Items.Objects[Index]:=  Value;
end;
function TAmListBoxObjects.ObjectItemAdd(Index: PInteger): TAmLbItem;
begin
    Result:= ObjectItemAddCustom(Index);
end;

function TAmListBoxObjects.ObjectItemAddCustom(Index:PInteger=nil): TAmLbItem;
var I:integer;
begin
  Result:= ItemClassGet.Create(ListItems);
  I:=Items.AddObject('',Result);
  if Assigned(Index) then
  Index^:= I;
end;
function TAmListBoxObjects.ObjectItemInsert(Index: integer): TAmLbItem;
begin
    Result:= ObjectItemInsertCustom(Index);
end;

function TAmListBoxObjects.ObjectItemInsertCustom(Index: integer): TAmLbItem;
begin
    Result:= ItemClassGet.Create(ListItems);
    Items.InsertObject(Index,'',Result);
end;


procedure TAmListBoxObjects.SetName(const NewName: TComponentName);
begin
  inherited;
   FButtonClose.Name:= 'ButtonClose';
end;

function TAmListBoxObjects.ObjectItemCountGet: integer;
begin
    Result:= Items.Count;
end;




{
function TAmListBoxItem.ImageBackgroundGet: TGraphic;
begin
    Result:= FImageBackground;
end;  }
      {
procedure TAmListBoxItem.ImageBackgroundSet(const Value: TGraphic);
begin
  if not Assigned(FImageBackground) then
  begin
     FImageBackground := TBitmap.Create();
     FImageBackground.PixelFormat := pf24bit;
     FImageBackground.Transparent:=true;
  end;
  FImageBackground.Assign(Value);
  if Assigned(ListBox) then
  ListBox.InvalidDateRectIndex(self.Index);
end;  }

{ TAmListBoxCheckItem }
constructor TAmLbItemCB.Create(AStringsOwner:TAmStrings);
begin
   inherited Create(AStringsOwner);
   RectCheckBox:=Rect(0,0,0,0);
   FChecked:=false;
   FCheckedVisible:=true;
end;

destructor TAmLbItemCB.Destroy;
begin
  inherited;
end;

procedure TAmLbItemCB.CheckedSet(const Value: boolean);
begin
  if FChecked=Value then
  exit;
  FChecked := Value;
  if Assigned(ListBox) then
  ListBox.InvalidDateRectIndex(self.Index);
end;

procedure TAmLbItemCB.CheckedVisibleSet(const Value: boolean);
begin
  if FCheckedVisible=Value then
  exit;
  FCheckedVisible := Value;
  if Assigned(ListBox) then
  ListBox.InvalidDateRectIndex(self.Index);
end;

procedure TAmLbItemCB.Assign(ASource:TPersistent);
begin
  inherited ;
  if ASource is TAmLbItemCB  then
  begin
         FChecked:=TAmLbItemCB(ASource).FChecked;
         FCheckedVisible:= TAmLbItemCB(ASource).FCheckedVisible;
         if Assigned(FListBox) then
         FListBox.InvalidDateRectIndex(Index);
  end;
end;

{ TAmListBoxCheck }




procedure TAmListBoxCheck.CheckAllSet(Value: boolean);
var
  I: Integer;
begin
  Items.BeginUpdate;
  try
   for I := 0 to self.Items.Count-1 do
   self.Checked[i]:= Value;
  finally
     Items.EndUpdate;
  end;
end;

procedure TAmListBoxCheck.CheckedPlaceIndexSet(const Value: integer);
begin
  FCheckedPlaceIndex := Value;
  self.Repaint;
end;

function TAmListBoxCheck.CheckedGet(index: integer): boolean;
var I:TAmLbItemCB;
begin
     I:= self.ObjectItemIndex[index];
     if Assigned(I) then
     Result:= I.Checked
     else Result:=false;
     
end;
procedure TAmListBoxCheck.CheckedSet(index: integer; const Value: boolean);
var I:TAmLbItemCB;
begin
     I:= self.ObjectItemIndex[index];
     if Assigned(I) then
     I.Checked := Value;
end;

function TAmListBoxCheck.CheckedVisibleGet(index: integer): boolean;
var I:TAmLbItemCB;
begin
     I:= self.ObjectItemIndex[index];
     if Assigned(I) then
     Result:= I.CheckedVisible
     else Result:=false;

end;

procedure TAmListBoxCheck.CheckedVisibleSet(index: integer; const Value: boolean);
var I:TAmLbItemCB;
begin
     I:= self.ObjectItemIndex[index];
     if Assigned(I) then
     I.CheckedVisible := Value;
end;

constructor TAmListBoxCheck.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCheckedPlaceIndex:=0;
  FCheckedOpt:=TAmCheckBoxOpt.Create(nil);
  FCheckedOpt.OnChangedRef:=  CheckedOptOnChanged;
end;
destructor TAmListBoxCheck.Destroy;
begin
   FreeAndNil(FCheckedOpt);
  inherited;
end;

procedure TAmListBoxCheck.CreateWnd;
begin
  inherited;
   if Assigned(FCheckedOpt) and (Parent<>nil) and FCheckedOpt.RectSizeAuto then
   FCheckedOpt.RectSize:= ItemHeight - (ItemHeight div 3) ;
end;

procedure TAmListBoxCheck.CheckedOptOnChanged(Sender:TObject;PVar:Pointer);
var i:integer;
begin
  if (csLoading in self.ComponentState) or (Parent = nil)  then exit;
  if (Sender = FCheckedOpt) then
  begin
    if PVar = @TLocAmCheckBoxOpt(FCheckedOpt).FVisible then
    begin
        if  not TLocAmCheckBoxOpt(FCheckedOpt).FVisible then
        for I := 0 to self.ObjectItemCount-1 do
        if Assigned(self.ObjectItemIndex[i]) then
        self.ObjectItemIndex[i].RectCheckBox:=Rect(0,0,0,0);
    end
    else if  PVar = @TLocAmCheckBoxOpt(FCheckedOpt).FRectSizeAuto then
    begin
        FCheckedOpt.RectSize:= self.ItemHeight  - ( ItemHeight div 3);
    end;
  end;
   self.Repaint;
end;

procedure TAmListBoxCheck.CheckedOptSet(const Value: TAmCheckBoxOpt);
begin
  FCheckedOpt.Assign(Value);
end;

procedure TAmListBoxCheck.DoChangeClickChecked(Item:TAmLbItemCB; X, Y: Integer);
begin
  if Assigned(FOnClickChecked) then
  FOnClickChecked(self,Item);
end;

procedure TAmListBoxCheck.DoChangeClickSelect( X, Y: Integer);
var I:TAmLbItemCB;
    J:integer;
begin
   J:=  ItemIndex;
   if J>=0 then
   begin
     I:= ObjectItemIndex[J];
     if Assigned(I) and I.RectCheckBox.Contains(Point(X, Y)) then
     begin
      I.Checked:= not I.Checked;
      DoChangeClickChecked(I,X, Y);
     end;

   end;
  inherited;

end;

procedure TAmListBoxCheck.DrawItemElements(Index: Integer; Rect: TRect; ItemObject: TAmLbItem);
var RectChek:TRect;
begin
   if FCheckedOpt.Visible  and CheckedVisible[Index] then
   begin
    RectChek.Left:= AmScaleV(FCheckedOpt.RectOffset.Left);
    RectChek.Top:=  Rect.Top+((self.ItemHeight div 2) - (AmScaleV(FCheckedOpt.RectSize) div 2) +  AmScaleV(FCheckedOpt.RectOffset.Top))  ;
    RectChek.Width:= AmScaleV(FCheckedOpt.RectSize);
    RectChek.Height:= RectChek.Width;

    if ItemObject is TAmLbItemCB then
    DrawItemElements_Checked(Index,RectChek,TAmLbItemCB(ItemObject))
    else
    DrawItemElements_Checked(Index,RectChek,nil);

    Rect.Left:= RectChek.Left + RectChek.Width;
   end;
   inherited DrawItemElements(Index,Rect,ItemObject);

end;
procedure TAmListBoxCheck.DrawItemElements_Checked(Index: Integer;Rect: TRect;ItemObject:TAmLbItemCB);
var R:Trect;
begin
   if FCheckedOpt.Visible and Assigned(ItemObject) and ItemObject.CheckedVisible then
   begin
    R:= FCheckedOpt.Paint(Canvas,Rect,ItemIndexMouseMove = Index,Checked[Index]);
    if Assigned(ItemObject) then
    ItemObject.RectCheckBox:=  R;
     {
    if FCheckedOptPrmPaint.Canvas = nil then
    FCheckedOptPrmPaint.Canvas:= Canvas;
    if FCheckedOptPrmPaint.Opt = nil then
    FCheckedOptPrmPaint.Opt:= FCheckedOpt;

    FCheckedOptPrmPaint.aRect:= Rect;
    FCheckedOptPrmPaint.FChecked:=              Checked[Index];
    FCheckedOptPrmPaint.FIsMouseEnter:=         ItemIndexMouseMove = Index;

    Prm.FColorBoxChecked:=      FARectangleColorChecked;
    Prm.FColorBox:=             FARectangleColor;
    Prm.FColorRectangle:=       FARectangleBolderColor;
    Prm.FColorRectangleChecked:=FARectangleBolderColorChecked;
    Prm.FWidthRectangle:=       self.FARectangleWidth;
    Prm.FPenBolder:=            self.FARectanglePen;
    Prm.FPenChecked:=           self.FCheckedPen;
    Prm.FColorChecked:=         self.FCheckedColor;
    Prm.FColorCheckedMouseActiv:= self.FCheckedColor;
    AmPaintCheckBox(@FCheckedOptPrmPaint);      }

   end;
end;

class function TAmListBoxCheck.GetClassListBoxItem: TAmLbItemClass;
begin
    Result:= TAmLbItemCB;
end;
procedure TAmListBoxCheck.ItemsEvent(Sender: TStrings; Prm: PAmEventStringsPrm);
begin
  inherited;
  // showmessage(GetEnumName(TypeInfo(TAmEventStringsEnum), ord(Prm.Enum)));
end;

function TAmListBoxCheck.ObjectItemIndexGet(Index: Integer): TAmLbItemCB;
var O:TObject;
begin
   O:= Items.Objects[Index];
   if Assigned(O) and (O is TAmLbItemCB) then
   Result:= TAmLbItemCB(O)
   else Result:=nil;
end;
procedure TAmListBoxCheck.ObjectItemIndexSet(Index: Integer; const Value: TAmLbItemCB);
begin
   Items.Objects[Index]:= Value;
end;

{ TAmListBoxIcoItem }




constructor TAmLbItemICO.Create(AStringsOwner:TAmStrings);
begin
   FIco:=nil;
   inherited Create(AStringsOwner);
   FIco:= TAmLbIcoBig.Create(nil);
   FIco.Assign( (FListBox as TAmListBoxIco).IcoBig );
   FIco.FListBox :=self.FListBox as TAmListBoxIco;
   RectIco:=rect(0,0,0,0);
   RectIcoMini:=rect(0,0,0,0);
end;

destructor TAmLbItemICO.Destroy;
begin
   FreeAndNil(FIco);
  inherited;
end;

procedure TAmLbItemICO.Assign(ASource:TPersistent);
begin
  inherited ;
  if ASource is TAmLbItemICO  then
  begin
         FIcoMiniVisible:=   TAmLbItemICO(ASource).FIcoMiniVisible;
         FIco.Assign(TAmLbItemICO(ASource).FIco);
         if Assigned(FListBox) then
         FListBox.InvalidDateRectIndex(Index);
  end;
end;

procedure TAmLbItemICO.IcoMiniVisibleSet(const Value: boolean);
begin
  if FIcoMiniVisible <> Value then
  begin
     FIcoMiniVisible:=Value;
     if Assigned(ListBox) then
     ListBox.InvalidDateRectIndex(self.Index);
  end;
end;

procedure TAmLbItemICO.IcoSet(const Value: TAmLbIcoBig);
begin
  FIco.Assign(Value);
end;

procedure TAmLbItemICO.ItemUpdate;
begin
  inherited;
  FIco.Update;
  if Assigned(self.ListBox) then
  ListBox.Repaint;
end;

function TAmLbItemICO.storedIco: Boolean;
begin
   if Assigned(ListBox) and (ListBox is TAmListBoxIco) then
       Result:= not (TAmListBoxIco(ListBox).IcoImageCollectionDefault
                     and  Assigned(TAmListBoxIco(ListBox).IcoImageCollection))
   else Result:=true;
end;


{ TAmListBoxIco }

constructor TAmListBoxIco.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

 FIcoImageCollection:=nil;
 FIcoImageCollectionDefault:=false;
 FIcoImageCollectionIsListenMannager:=false;
 FIcoImageCollectionUpdateLock:=0;

 FIcoMini:=TAmLbIcoMini.Create(nil);
 FIcoMini.SizeProcent:=30;
 FIcoMini.ControlObject:=self;
 FIcoMini.FListBox :=self;
 FIcoMini.OnChangedRef:= IcoMiniChange;

 FIcoBig:=TAmLbIcoBigHide.Create(nil);
 FIcoBig.SizeProcent:=80;
 FIcoBig.ControlObject:=self;
 FIcoBig.FListBox :=self;
 FIcoBig.OnChangedRef:= IcoBigChange;
end;

destructor TAmListBoxIco.Destroy;
begin
  IcoImageCollectionIsListenMannager:=false;
  if Assigned(FIcoMini) then
  FreeAndNil(FIcoMini);
  if Assigned(FIcoBig) then
  FreeAndNil(FIcoBig);
  FIcoImageCollection:=nil;
  inherited;
end;



procedure TAmListBoxIco.DoChangeClickSelect(X, Y: Integer);
var I:TAmLbItemICO;
    J:integer;
begin
   J:=  ItemIndex;
   if J>=0 then
   begin
     I:= ObjectItemIndex[J];
     
     if Assigned(I) and I.RectIcoMini.Contains(Point(X, Y)) then      
      DoClickIcoMini(I,X, Y)
     else if Assigned(I) and I.RectIco.Contains(Point(X, Y)) then      
      DoClickIcoBig(I,X, Y)
   end;
  inherited;

end;
procedure TAmListBoxIco.DoClickIcoMini(Item:TAmLbItemICO; X, Y: Integer);
begin
   if Assigned(FOnClickIcoMini) then
   FOnClickIcoMini(self,Item);
end;
procedure TAmListBoxIco.DoClickIcoBig(Item:TAmLbItemICO; X, Y: Integer);
begin
   if Assigned(FOnClickIcoBig) then
   FOnClickIcoBig(self,Item);
end;

procedure TAmListBoxIco.DrawItemElements(Index: Integer; Rect: TRect; ItemObject: TAmLbItem);
var Item: TAmLbItemICO;
 P,PS:PRect;
   procedure LocPaintIcons;
//   var BF: TBlendFunction;
   //  B:TBitmap;
//   var C:TRect;
   begin
       if Assigned(Item.Ico) and Assigned(Item.Ico.Use)  and Item.Ico.Visible then
       begin
            P:= @Item.RectIco;
           { if  (Rect.Height - Item.Ico.Use.Height >0)
            and (Rect.Width - Item.Ico.Use.Width  >0) then
            begin
                P.Left:= Rect.left+AmScaleV(5);
                P.Top:=  Rect.Top+abs((Rect.Height- Item.Ico.Use.Height) div 2);
            end
            else
            begin
                P.Left:= AmScaleV(5);
                if Rect.Height - Item.Ico.Use.Height > 0 then
                P.Top:=  Rect.Top + AmScaleV(5)
                else
                P.Top:=  Rect.Top;
            end;
            P.Width:=   min(Item.Ico.Use.Width,Rect.Width);
            P.Height:=  min(Item.Ico.Use.Height,Rect.Height);
            }

           P^:= Item.Ico.Paint(Canvas,Rect,0);
           Rect.left:=  P.Left + P.Width;
            {
            else
            begin
              if Item.Ico.Picture.Graphic is TBitMap then
              begin

               //TBitMap(Item.Ico.Picture.Graphic).AlphaFormat:=  afDefined;
              // TBitMap(Item.Ico.Picture.Graphic).PixelFormat:=  pf24bit;
              // TBitMap(Item.Ico.Picture.Graphic).Transparent:=true;
              end;
              Canvas.Brush.Color := 0;
             Canvas.DrawHighQuality(P^,Item.Ico.Use,Item.Ico.Opacity,true);
            end;
             }

       end
       else
       begin
          Item.RectIco:= System.Classes.rect(0,0,0,0);

       end;


       if Assigned(FIcoMini) and FIcoMini.Visible and Assigned(FIcoMini.Use)  and  Item.IcoMiniVisible then
       begin
         if not Item.RectIco.IsEmpty then
         PS:= @Item.RectIco
         else
         PS:= @Rect;

         P:=@Item.RectIcoMini;
         P.Left:=    PS.left;
         P.Top:=     Rect.Top;
         P.Width:=   FIcoMini.Use.Width;
         P.Height:=  FIcoMini.Use.Height;
         FIcoMini.Paint(Canvas,P^,0);
       //  FIcoMini.paint(Canvas,P^.Left,P^.Top,true);
         //Canvas.Brush.Style:=bsclear;
        // Canvas.Draw(P^.Left,P^.Top,FIcoMini.Use,FIcoMini.Opacity);
       end
       else Item.RectIcoMini:= System.Classes.rect(0,0,0,0);
   end;
   procedure LocPaintCheckBox;
   begin
       if CheckedOpt.Visible  and CheckedVisible[Index] then
       begin
        P:=  @Item.RectCheckBox;
        P.Left:= Rect.left + AmScaleV(CheckedOpt.RectOffset.Left);
        P.Top:=  Rect.Top+((self.ItemHeight div 2) - (AmScaleV(CheckedOpt.RectSize) div 2) +  AmScaleV(CheckedOpt.RectOffset.Top))  ;
        P.Width:= AmScaleV(CheckedOpt.RectSize);
        P.Height:= P.Width;
        DrawItemElements_Checked(Index,P^,Item);
        Rect.Left:= P.Left + P.Width;
       end
       else Item.RectCheckBox:= System.Classes.rect(0,0,0,0);
   end;
begin
   if not  Assigned(ItemObject) or  not (ItemObject is TAmLbItemICO) then exit;
   Item:= TAmLbItemICO(ItemObject);



    if FCheckedPlaceIndex>0 then
    begin
      LocPaintIcons;
      LocPaintCheckBox;
    end
    else
    begin
      LocPaintCheckBox;
      LocPaintIcons;
    end;



    if self.ButtonClose.Visible and Assigned(ItemObject) and  ItemObject.ButtonCloseVisible  then
    begin
         P:=@ItemObject.RectButtonClose;
         P.Left:= Rect.Left + Rect.Width  - ButtonClose.ButSize - 5;
         P.Top:=  Rect.Top + (Rect.Height div 2 - ButtonClose.ButSize div 2);
         P.Width:= ButtonClose.ButSize;
         P.Height:= ButtonClose.ButSize;
         DrawItemElements_ButtonClose(Index,P^,ItemObject);
         Rect.Right:=  P.Left - 5;
    end
    else if Assigned(ItemObject) then
     ItemObject.RectButtonClose:= System.Classes.rect(0,0,0,0);

   DrawItemElements_Caption(Index,Rect,Item);
end;

class function TAmListBoxIco.GetClassListBoxItem: TAmLbItemClass;
begin
   Result:= TAmLbItemICO;
end;

procedure TAmListBoxIco.CreateWnd;
begin
  inherited;
  IcoImageCollectionUpdate;
  IcoIndexImageUpdateSize;
end;

procedure TAmListBoxIco.IcoImageCollectionListenMannagerChange(const Sender: TObject; const M: System.Messaging.TMessage);
begin
   if Assigned(FIcoImageCollection) and  Assigned(M) and  (M is TImageCollectionChangedMessage)
   and (TImageCollectionChangedMessage(M).Collection   = FIcoImageCollection) then
   IcoImageCollectionUpdate;
end;
procedure TAmListBoxIco.IcoImageCollectionDefaultSet(const Value: boolean);
begin
  if FIcoImageCollectionDefault = Value  then exit;
  FIcoImageCollectionDefault := Value;
  IcoImageCollectionUpdate;
end;

procedure TAmListBoxIco.IcoImageCollectionIsListenMannagerSet(const Value: boolean);
begin
  if FIcoImageCollectionIsListenMannager = Value then
  exit;
  FIcoImageCollectionIsListenMannager := Value;
  if not FIcoImageCollectionIsListenMannager then
   TMessageManager.DefaultManager.Unsubscribe(TImageCollectionChangedMessage,IcoImageCollectionListenMannagerChange)
  else
     TMessageManager.DefaultManager.SubscribeToMessage(TImageCollectionChangedMessage,IcoImageCollectionListenMannagerChange);
end;


procedure TAmListBoxIco.IcoImageCollectionSet( Value: TImageCollection);
begin
   if Value = FIcoImageCollection then  exit;
   FIcoImageCollection:=  Value;
   IcoImageCollectionUpdate;
end;

procedure TAmListBoxIco.IcoImageCollectionUpdate;
var I:integer;
    M:Integer;
begin

    //прослушка изменений
   if not FIcoImageCollectionDefault  then
   begin
     IcoImageCollectionIsListenMannager:=false;
     exit;
   end;


 //  if FIcoIndexDesingUpdateLock>0 then exit;
   inc(FIcoImageCollectionUpdateLock);
   try
      if  (csLoading in ComponentState) or (csDesigning in ComponentState)  or FIcoImageCollectionDefault  then
      begin
            if Assigned(FIcoImageCollection) then
            IcoImageCollectionIsListenMannager:= FIcoImageCollectionDefault or (csDesigning in ComponentState)
            else IcoImageCollectionIsListenMannager:=false;
      end
      else
      begin
        IcoImageCollectionIsListenMannager:=false;
        exit;
      end;


      if  WindowHandle = 0 then exit();

      if  not Assigned(FIcoImageCollection) then
      begin
        if not ( (csDesigning in ComponentState)  or FIcoImageCollectionDefault ) then  exit;
        IcoIndexImageClear;
        exit;
      end;

      M:= Min(FIcoImageCollection.Count,self.ObjectItemCount);
      self.Items.BeginUpdate;
      try
        i:=0;
        while I<M do
        begin
           self.IcoIndexImage[i].Picture.Assign(FIcoImageCollection.GetSourceImage(i,0,0));
           inc(I);
        end;
        M:=I;
        for I := M to self.ObjectItemCount-1 do
         IcoIndexImage[i].Picture:=nil;
      finally
         self.Items.EndUpdate;
      end;

   finally
       dec(FIcoImageCollectionUpdateLock);
   end;
end;

procedure TAmListBoxIco.IcoMiniSet(const Value: TAmLbIcoMini);
begin
   FIcoMini.Assign(Value);
end;
procedure TAmListBoxIco.IcoBigSet(const Value: TAmLbIcoBigHide);
begin
   FIcoBig.Assign(Value);
end;
procedure TAmListBoxIco.IcoMiniChange(Sender:TObject;PVar:Pointer);
begin
end;
procedure TAmListBoxIco.IcoBigChange(Sender:TObject;PVar:Pointer);
begin

end;

function TAmListBoxIco.IcoIndexImageGet(Index: Integer): TAmLbIcoBig;
var I:TAmLbItemICO;
begin
   I:= ObjectItemIndex[Index];
   if Assigned(I) then
    Result:= I.Ico
   else
   Result:=nil;
end;
procedure TAmListBoxIco.IcoIndexImageUpdateSize;
var i:integer;
begin
  if WindowHandle = 0 then exit;
   FIcoMini.Update;
   Items.BeginUpdate;
   try
    for I := 0 to Items.Count-1 do
     self.ObjectItemIndex[i].Ico.Update;
   finally
    Items.EndUpdate;
   end;
end;

procedure TAmListBoxIco.IcoIndexImageClear;
var i:integer;
begin
   if WindowHandle = 0 then exit;
   Items.BeginUpdate;
   try
    for I := 0 to Items.Count-1 do
    IcoIndexImageGet(i).Picture:=nil;
   finally
    Items.EndUpdate;
   end;
end;

procedure TAmListBoxIco.ItemsEvent(Sender: TStrings; Prm: PAmEventStringsPrm);
begin
  inherited;

   if Prm.Enum in [sevClear, sevDelete, sevExchange, sevInsert, sevMove,
   sevPutObj, sevAdd, sevAddObject, sevAssign, sevAddString,
   sevInsertObject, sevSetTextStr, sevSetText,sevWinChangeControlItems]  then
   begin
       if  (not  (csLoading in ComponentState)) and
       ( (csDesigning in ComponentState)  or FIcoImageCollectionDefault ) then
       IcoImageCollectionUpdate;
   end;
         { sevGetClassItem,
          sevStateUpdateBefore,
          sevStateUpdate,
          sevClearBefore,
          sevClear,
          sevDelete,
          sevDeleteBefore,
          sevExchangeBefore,
          sevExchange,
          sevInsertBefore,
          sevInsert,
          sevMoveBefore,
          sevMove,
          sevPutBefore,
          sevPut,
          sevPutObjBefore,
          sevPutObj,
          sevAddBefore,
          sevAdd,
          sevAddObjectBefore,
          sevAddObject,
          sevAssignBefore,
          sevAssign,
          sevAddStringBefore,
          sevAddString,
          sevInsertObjectBefore,
          sevInsertObject

    sevSetTextStrBefore,
              sevSetTextStr,
              sevSetTextBefore,
              sevSetText    :( SetText:PChar;);
           }
end;

function TAmListBoxIco.ObjectItemAdd(Index: PInteger): TAmLbItemICO;
begin
  Result:= inherited  ObjectItemAdd(Index) as  TAmLbItemICO ;
end;

function TAmListBoxIco.ObjectItemInsert(Index: integer): TAmLbItemICO;
begin
  Result:= inherited  ObjectItemInsert(Index) as  TAmLbItemICO ;
end;

function TAmListBoxIco.ObjectItemIndexGet(Index:Integer): TAmLbItemICO;
var O:TObject;
begin
   O:= Items.Objects[Index];
   if Assigned(O) and (O is TAmLbItemICO) then
   Result:= TAmLbItemICO(O)
   else Result:=nil;
end;

procedure TAmListBoxIco.ObjectItemIndexSet(Index:Integer;const Value: TAmLbItemICO);
begin
  Items.Objects[Index]:=  Value;
end;


{ TAmLbGraphicBuffer }
constructor TAmLbPictureItem.Create(AOptOwner:TAmVclOpt);
begin
   inherited Create(AOptOwner);
   FListBox:=nil;
   FSizeFix:=0;
   FSizeProcent:=80;
   Offset.Left:= 10;
   Offset.Top:=0;
   FTransparentRect:=true;
   FUpDelay:=false;
   FStretch:=false;
   FBolderColor:= $00FFFF80;
   FBolderSize:= 0;
   FBolderOffset:= 0;
end;
destructor TAmLbPictureItem.Destroy;
begin
   FListBox:=nil;
  inherited;
end;
procedure TAmLbPictureItem.ChangedUse;
begin
  inherited;
  if Assigned(FListBox) then
  FListBox.Repaint;
end;
function TAmLbPictureItem.storedOffset:boolean;
begin
  Result:= not ((Offset.Left = 10) and (Offset.Top=0));
end;


{ TAmLbGraphicBufferMini }

procedure TAmLbIcoMini.DoGetSizeUse(var ASiz: TSize);
var i:integer;
begin
   if not Assigned(FListBox) then exit;

   i:= min(FListBox.ItemHeight,FListBox.Width);
   i:= round(SizeProcent * max(i,1)/100);
   if Picture.Width > Picture.Height then
   begin
     ASiz.Width:= max( i,min(Picture.Width,i));
     ASiz.Height:=0;
   end
   else ASiz:= TSize.Create(0,i);

end;

{ TAmLbGraphicBufferBig }

procedure TAmLbIcoBig.DoGetSizeUse(var ASiz: TSize);
var i:integer;
begin
   if not Assigned(FListBox) then exit;
   i:= min(FListBox.ItemHeight,FListBox.Width);
   i:= round(SizeProcent * max(i,1) /100);

   if Picture.Width > Picture.Height then
   begin
     ASiz.Width:= min(FListBox.ItemHeight - (FListBox.ItemHeight div 5),i);
     ASiz.Height:=0;
     if not  Stretch then
     ASiz.Width:= min(Picture.Width,ASiz.Width);

   end
   else
   begin
     ASiz:= TSize.Create(0,min(FListBox.ItemHeight - (FListBox.ItemHeight div 5),i));
     if not  Stretch then
     ASiz.Height:= min(Picture.Height,ASiz.Height);
   end;




end;
{ TAmLbGraphicBufferBigHide }
constructor TAmLbIcoBigHide.Create(AOptOwner: TAmVclOpt);
begin
  inherited Create(AOptOwner);
 IsHiderObject:=true;
 self.CanAssignPicture:=false;
end;
function TAmLbIcoBigHide.ChangedNoneAfter():boolean;
begin
  Result:=false;
end;
procedure TAmLbIcoBigHide.Changed(Sender:TAmVclOpt;PVar: Pointer);
begin
  inherited Changed(Sender,PVar);
  if self.FListBox = nil then exit;
  if (self.ChangeLockCount>0)
  or (FListBox.Items.Count<=0) then exit;
  if csLoading in FListBox.ComponentState  then exit;
  if csReading in FListBox.ComponentState  then exit;
  if csWriting in FListBox.ComponentState  then exit;
  if csDestroying in FListBox.ComponentState  then exit;
  if csUpdating in FListBox.ComponentState  then exit;
  FListBox.Items.BeginUpdate;
  try
   AssignListRun(Sender,PVar, TAmLbIcoListEnumerator.Create(FListBox));
  finally
     FListBox.Items.EndUpdate;
  end;
end;

procedure TAmLbIcoBigHide.ChangedUse;
begin
end;
procedure TAmLbIcoBigHide.DoGetSizeUse(var ASiz: TSize);
begin
end;

{ TAmLbIcoListEnumerator }

constructor TAmLbIcoListEnumerator.Create(AListBox: TAmListBoxIco);
begin
    inherited Create;
    FListBox:= AListBox;
end;

function TAmLbIcoListEnumerator.Get(Index: integer): TPersistent;
begin
   Result:=FListBox.ObjectItemIndex[Index].Ico;
end;

function TAmLbIcoListEnumerator.Has(Index: integer): boolean;
begin
     Result:=Index<FListBox.ObjectItemCount;
end;


{ TAmListBoxUsers }


constructor TAmListBoxUsers.Create(AOwner: TComponent);
begin
  inherited;

  FUserNameFont:=TFont.Create;
  FUserInfoFont:=TFont.Create;
  FUserNameOffset:=TAmPointVclOpt.Create(nil);
  FUserNameOffset.Left:=5;

  FUserInfoOffset:=TAmPointVclOpt.Create(nil);
  FUserInfoOffset.Left:=5;
  FUserNameFont.OnChange:= UFontChange;
  FUserInfoFont.OnChange:= UFontChange;
  FUserNameOffset.OnChangedRef:= UOffsetChange;
  FUserInfoOffset.OnChangedRef:= UOffsetChange;

  ItemHeight:=100;
  IcoMini.SizeProcent:=20;
  IcoBig.SizeProcent:=80;
end;

destructor TAmListBoxUsers.Destroy;
begin
   FreeAndNil(FUserNameFont);
   FreeAndNil(FUserInfoFont);
   FreeAndNil(FUserNameOffset);
   FreeAndNil(FUserInfoOffset);
  inherited;
end;

procedure TAmListBoxUsers.DoChangeClickSelect(X, Y: Integer);
var I:TAmLbItemUser;
    J:integer;
begin
   J:=  ItemIndex;
   if J>=0 then
   begin
     I:= ObjectItemIndex[J];
     if Assigned(I) and I.RectUserName.Contains(Point(X, Y)) then
      DoClickNameUser(I,X, Y)
     else if Assigned(I) and I.RectUserInfo.Contains(Point(X, Y)) then
      DoClickInfoUser(I,X, Y)
   end;
  inherited DoChangeClickSelect(X, Y);

end;
procedure TAmListBoxUsers.DoClickNameUser(Item:TAmLbItemUser;X, Y:integer);
begin
   if Assigned(FOnClickNameUser) then
   FOnClickNameUser(self,Item);
end;
procedure TAmListBoxUsers.DoClickInfoUser(Item:TAmLbItemUser;X, Y:integer);
begin
   if Assigned(FOnClickInfoUser) then
   FOnClickInfoUser(self,Item);
end;

procedure TAmListBoxUsers.ChangeScale(M, D: Integer; isDpiChange: Boolean);
var p:TAmPointVclOptLoc;
  procedure LocD;
  begin
    p.FLeft:= AmScale.ChangeScaleValue(p.FLeft,M, D);
    p.FTop:= AmScale.ChangeScaleValue(p.FTop,M, D);
  end;
begin
  inherited;
  p:=  TAmPointVclOptLoc(FUserInfoOffset);
  LocD;
  p:=  TAmPointVclOptLoc(FUserNameOffset);
  LocD;
end;


procedure TAmListBoxUsers.DrawItemElements(Index: Integer; Rect: TRect;
  ItemObject: TAmLbItem);
begin
  inherited DrawItemElements(Index,Rect,ItemObject);
end;

procedure TAmListBoxUsers.DrawItemElements_Caption(Index: Integer; Rect: TRect; ItemObject: TAmLbItem);
var Item : TAmLbItemUser;
R1,R2:TRect;
j1,j2:integer;
  procedure LocDrawText(__Text:string;__Rect:TRect);
  begin
       DrawText(Canvas.Handle, PChar(__Text),Length(__Text),__Rect,
       DrawTextBiDiModeFlags(DT_SINGLELINE Or DT_VCENTER Or DT_NOPREFIX or DT_END_ELLIPSIS));
  end;
begin
      if not Assigned(ItemObject) or  not  (ItemObject is TAmLbItemUser) then
      begin
        inherited DrawItemElements_Caption(Index,Rect,ItemObject);
        exit;
      end;
      Item:=  TAmLbItemUser(ItemObject);

     R1:= Rect;
     Item.RectCaption:= TRect.Empty;
     self.Canvas.Brush.Style := bsClear;
     Canvas.Font:= FUserNameFont;
     Canvas.Font.Height:= amScaleF(Canvas.Font.Size);
     j1:= Canvas.TextHeight('Xy')+1;
     Canvas.Font:= FUserInfoFont;
     Canvas.Font.Height:= amScaleF(Canvas.Font.Size);
     j2:= Canvas.TextHeight('Xy')+1;

     if j1 + j2 +4 + amScaleV(FUserNameOffset.Top) + amScaleV(FUserInfoOffset.Top) > Rect.Height then
     begin
       Item.RectUserName:= Rect;
       Item.RectUserName.Width:=  Rect.Width;
       Item.RectUserInfo:=TRect.Empty;
       Canvas.Font:= FUserNameFont;
       Canvas.Font.Height:= amScaleF(Canvas.Font.Size);

       Item.RectUserName.Left:= Item.RectUserName.Left + amScaleV(FUserNameOffset.Left);
       Item.RectUserName.Top:= Item.RectUserName.Top + amScaleV(FUserNameOffset.Top);
       LocDrawText(Item.FUserName,Item.RectUserName);
       Item.RectUserName.Width:=  Rect.Width div 4;
     end
     else
     begin

         R1.Top:= Rect.Top +  amScaleV(FUserNameOffset.Top)  +( Rect.Height div 2  - ( (j1 + j2 +4) div 2  ));
         R1.Left:= Rect.Left + amScaleV(FUserNameOffset.Left);
         R1.Height:= j1;
         R1.Width:= Rect.Width;


         Item.RectUserName:= R1;
         Canvas.Font:= FUserNameFont;
         Canvas.Font.Height:= amScaleF(Canvas.Font.Size);
         LocDrawText(Item.FUserName,Item.RectUserName);
         Item.RectUserName.Width:= Rect.Width div 4;

         R2.Top:= amScaleV(FUserInfoOffset.Top) +  R1.Bottom;
         R2.Left:= Rect.Left + amScaleV(FUserInfoOffset.Left);
         R2.Height:= j2;
         R2.Width:= Rect.Width;

         Item.RectUserInfo:= R2;
         Canvas.Font:= FUserInfoFont;
         Canvas.Font.Height:= amScaleF(Canvas.Font.Size);
         LocDrawText(Item.FUserInfo,Item.RectUserInfo);
         Item.RectUserInfo.Width:= Rect.Width div 4;

     end;
end;

procedure TAmListBoxUsers.DrawItem_Background(Index: Integer; Rect: TRect;
  State: TOwnerDrawState;ItemObject:TAmLbItem);
  var Item:TAmLbItemUser;
begin
     if not Assigned(ItemObject) or  not  (ItemObject is TAmLbItemUser) then
     begin
        inherited DrawItem_Background(Index,Rect,State,ItemObject);
        exit;
     end;
     Item:=  ItemObject as TAmLbItemUser;
     if Item.UserColor <> clblack then
     begin
        Canvas.Brush.Color := Item.UserColor;
       If (odSelected In State) Then
       Canvas.Brush.Color := AmGraphicCanvasHelp.ColorBlend(FColorItemSelect,Item.UserColor,220)
       else if (Index=ItemIndexMouseMove) then
       Canvas.Brush.Color := AmGraphicCanvasHelp.ColorBlend(FColorItemMouseMovi,Item.UserColor,220);
     end
     else
     begin
       If (odSelected In State) Then
       Canvas.Brush.Color := FColorItemSelect
       else if (Index=ItemIndexMouseMove) then
       Canvas.Brush.Color :=FColorItemMouseMovi;
     end;
     Canvas.FillRect(Rect);

end;

class function TAmListBoxUsers.GetClassListBoxItem: TAmLbItemClass;
begin
  Result:= TAmLbItemUser;
end;

procedure TAmListBoxUsers.ItemsEvent(Sender: TStrings; Prm: PAmEventStringsPrm);
begin
  inherited;
end;

function TAmListBoxUsers.ObjectItemAdd(Index: PInteger): TAmLbItemUser;
begin
    Result:= inherited ObjectItemAdd(Index) as  TAmLbItemUser;
end;

function TAmListBoxUsers.ObjectItemIndexGet(Index: Integer): TAmLbItemUser;
var O:TObject;
begin
   O:= Items.Objects[Index];
   if Assigned(O) and (O is TAmLbItemUser) then
   Result:= TAmLbItemUser(O)
   else Result:=nil;
end;

function TAmListBoxUsers.ObjectItemInsert(Index: integer): TAmLbItemUser;
begin
   Result:= inherited ObjectItemInsert(Index) as  TAmLbItemUser;
end;


procedure TAmListBoxUsers.UFontChange(Sender: TObject);
begin
 if csLoading in self.ComponentState  then exit;
 self.Repaint;
end;

procedure TAmListBoxUsers.UOffsetChange(Sender:TObject;PVar:Pointer);
begin
  if csLoading in self.ComponentState  then exit;
  self.Repaint;
end;

function TAmListBoxUsers.UserAddTestDesignGet: boolean;
begin
    Result:=false;
end;

procedure TAmListBoxUsers.UserAddTestDesignSet(const Value: boolean);
var Item:TAmLbItemUser;
const Arr:Array [0..4] of string  = ('Костя Карпин','Мария Апина','Евгений Латутин','Александр Варенков','Светлана Брокина');
const Arr2:Array [0..4] of string  = ('+555-55-55','+111-11-11','+222-22-22','+333-33-33','+444-44-44');
 var B:TBitMap;
begin
 // if not (csDesigning in self.ComponentState)  then exit;
  if csLoading in self.ComponentState  then exit;
  if csReading in self.ComponentState  then exit;
  if csWriting in self.ComponentState  then exit;
  if csDestroying in self.ComponentState  then exit;


  self.Items.BeginUpdate;
  try
   B:=TBitMap.Create;
   try
       B.SetSize(math.RandomRange(100,300),math.RandomRange(100,300));
       B.SetSize(200,200);
       B.Canvas.Brush.Color:=random(200000);
       B.Canvas.FillRect(B.Canvas.ClipRect);
       Item:=ObjectItemAdd;
       Item.UserName:=Arr[math.RandomRange(0,length(Arr))];
       Item.UserInfo:=Arr2[math.RandomRange(0,length(Arr2))];
       Item.Ico.Picture.Assign(B);
       Item.CheckedVisible:=true;//boolean(math.RandomRange(0,2));
       Item.Checked:=boolean(math.RandomRange(0,2));
       Item.ButtonCloseVisible:=    boolean(math.RandomRange(0,2));
       Item.UserColor:=  AmGraphicCanvasHelp.ColorBlend(clwhite, random(200000),200);
   finally
     B.Free;
   end;
  finally
     Items.EndUpdate;
  end;
end;

procedure TAmListBoxUsers.UserInfoFontSet(const Value: TFont);
begin
  FUserInfoFont := Value;
end;

procedure TAmListBoxUsers.UserInfoOffsetSet(const Value: TAmPointVclOpt);
begin
  FUserInfoOffset := Value;
end;

procedure TAmListBoxUsers.UserNameFontSet(const Value: TFont);
begin
  FUserNameFont := Value;
end;

procedure TAmListBoxUsers.UserNameOffsetSet(const Value: TAmPointVclOpt);
begin
  FUserNameOffset := Value;
end;

{ TAmLbItemUser }

constructor TAmLbItemUser.Create(AStringsOwner: TAmStrings);
begin
  inherited;
  RectUserName:=TRect.Empty;
  RectUserInfo:=TRect.Empty;
  FObjectFree :=nil;
  FObjectBusy :=nil;
  FUserColor:=clblack;
  FUserInfo:='';
  FUserName:='';
end;

destructor TAmLbItemUser.Destroy;
begin
   FObjectBusy :=nil;
   if Assigned(FObjectFree) then
   FreeAndNil(FObjectFree);
  inherited;
end;

procedure TAmLbItemUser.UserColorSet(const Value: TColor);
begin
  FUserColor := Value;
   if Assigned(ListBox) then
   ListBox.InvalidDateRectIndex(self.Index);
end;

procedure TAmLbItemUser.UserInfoSet(const Value: string);
begin
  FUserInfo := Value;
   if Assigned(ListBox) then
   ListBox.InvalidDateRectIndex(self.Index);
end;

procedure TAmLbItemUser.UserNameSet(const Value: string);
begin
  FUserName := Value;
   if Assigned(ListBox) then
   ListBox.InvalidDateRectIndex(self.Index);
end;



{ TAmLbItemMyFile }

procedure TAmLbItemMyFile.Changed(IndexVar: integer);
begin
  inherited;
  if (IndexVar = 3) or (IndexVar = integer(@FFileName)) and Assigned(self.ListBox) then
  ListBox.Repaint;
end;

constructor TAmLbItemMyFile.Create(AStringsOwner: TAmStrings);
begin
  inherited;
        RectFileName:=TRect.Empty;
        RectNameRu:=TRect.Empty;
end;

{ TAmListBoxMyFiles }

constructor TAmListBoxMyFiles.Create(AOwner: TComponent);
begin
  inherited;
   FmyNameRuFont:=TFont.Create;
   FmyNameRuFont.Color:=clwhite;
   FmyNameRuFont.Size:=10;
   FmyNameRuFont.OnChange:= myFontChange;
           
   FmyFileNameFont:=TFont.Create;
   FmyFileNameFont.Color:=clsilver;
   FmyFileNameFont.Size:=7;
   FmyFileNameFont.OnChange:= myFontChange;
   

   FmyNameRuOffset:=TAmPointVclOpt.Create(nil);
   FmyNameRuOffset.Left:=5; 
   FmyNameRuOffset.OnChangedRef:= myOffsetChange;  
     
   FmyFileNameOffset:=TAmPointVclOpt.Create(nil); 
   FmyFileNameOffset.Left:=5;
   FmyFileNameOffset.Top:=3;
   FmyFileNameOffset.OnChangedRef:= myOffsetChange;

   ItemHeight:=60;
   IcoMini.SizeProcent:=20;
   IcoBig.SizeProcent:=80;
end;

destructor TAmListBoxMyFiles.Destroy;
begin
  FreeAndNil(FmyFileNameFont);
  FreeAndNil(FmyNameRuFont);
  FreeAndNil(FmyFileNameOffset);
  FreeAndNil(FmyNameRuOffset);
  inherited;
end;

procedure TAmListBoxMyFiles.DoChangeClickSelect(X, Y: Integer);
var I:TAmLbItemMyFile;
    J:integer;
begin
   J:=  ItemIndex;
   if J>=0 then
   begin
     I:= ObjectItemIndex[J];
     if Assigned(I) and I.RectFileName.Contains(Point(X, Y)) then
     DoClickFileName(I,X, Y)
     else if Assigned(I) and I.RectNameRu.Contains(Point(X, Y)) then
     DoClickNameRu(I,X, Y)       
   end;
  inherited;
end;
procedure TAmListBoxMyFiles.DoClickFileName(Item:TAmLbItemMyFile;X, Y:integer);
begin
 if Assigned(FOnClickFileName) then
  FOnClickFileName(self,Item);
end;
procedure TAmListBoxMyFiles.DoClickNameRu(Item:TAmLbItemMyFile;X, Y:integer);
begin
 if Assigned(FOnClickNameRu) then
  FOnClickNameRu(self,Item);
end;

procedure TAmListBoxMyFiles.DrawItemElements_Caption(Index: Integer;
  Rect: TRect; ItemObject: TAmLbItem);
var Item : TAmLbItemMyFile;
R1,R2:TRect;
j1,j2:integer;
  procedure LocDrawText(__Text:string;__Rect:TRect);
  begin
       DrawText(Canvas.Handle, PChar(__Text),Length(__Text),__Rect,
       DrawTextBiDiModeFlags(DT_SINGLELINE Or DT_VCENTER Or DT_NOPREFIX or DT_END_ELLIPSIS));
  end;

  function LocRd2(l:integer;Text:string):integer;
  begin
     Result:= l+ max(Canvas.TextWidth(Text)+2,30);
     Result:= max(l+15, min(Result,Rect.Right - (Rect.Right div 4)));
  end;  
begin
      if not Assigned(ItemObject) or  not  (ItemObject is TAmLbItemMyFile) then
      begin
        inherited DrawItemElements_Caption(Index,Rect,ItemObject);
        exit;
      end;
      Item:=  TAmLbItemMyFile(ItemObject);

     R1:= Rect;
     Item.RectCaption:= TRect.Empty;
     self.Canvas.Brush.Style := bsClear;
     Canvas.Font:= FmyNameRuFont;
     Canvas.Font.Height:= amScaleF(Canvas.Font.Size);
     j1:= Canvas.TextHeight('Xy')+1;
     Canvas.Font:= FmyFileNameFont;
     Canvas.Font.Height:= amScaleF(Canvas.Font.Size);
     j2:= Canvas.TextHeight('Xy')+1;

     if j1 + j2 +4 + amScaleV(FmyNameRuOffset.Top) + amScaleV(FmyFileNameOffset.Top) > Rect.Height then
     begin
       Item.RectNameRu:= Rect;
       Item.RectFileName:=TRect.Empty;
       Canvas.Font:= FmyNameRuFont;
       Canvas.Font.Height:= amScaleF(Canvas.Font.Size);
       Item.RectNameRu.Left:= Item.RectNameRu.Left + amScaleV(FmyNameRuOffset.Left);
       Item.RectNameRu.Top:= Item.RectNameRu.Top + amScaleV(FmyNameRuOffset.Top);
       Item.RectNameRu.Right:=  LocRd2(Item.RectNameRu.Left,Item.NameRu);
       LocDrawText(Item.NameRu,Item.RectNameRu);
     end
     else
     begin

         R1.Top:= Rect.Top +  amScaleV(FmyNameRuOffset.Top)  +( Rect.Height div 2  - ( (j1 + j2 +4) div 2  ));
         R1.Left:= Rect.Left + amScaleV(FmyNameRuOffset.Left);
         R1.Height:= j1;
         R1.Width:= Rect.Width;

         Item.RectNameRu:= R1;           
         Canvas.Font:= FmyNameRuFont;
         Canvas.Font.Height:= amScaleF(Canvas.Font.Size);
         Item.RectNameRu.Right:= LocRd2(Item.RectNameRu.Left,Item.NameRu);
         LocDrawText(Item.NameRu,Item.RectNameRu);

         R2.Top:= amScaleV(FmyFileNameOffset.Top) +  R1.Bottom;
         R2.Left:= Rect.Left + amScaleV(FmyFileNameOffset.Left);
         R2.Height:= j2;
         R2.Width:= Rect.Width;

         Item.RectFileName:= R2;
         Canvas.Font:= FmyFileNameFont;
         Canvas.Font.Height:= amScaleF(Canvas.Font.Size);
         Item.RectFileName.Right:= LocRd2(Item.RectFileName.Left,Item.FileName);    
         LocDrawText(Item.FileName,Item.RectFileName);

     end;

end;

class function TAmListBoxMyFiles.GetClassListBoxItem: TAmLbItemClass;
begin
    Result:= TAmLbItemMyFile;
end;

procedure TAmListBoxMyFiles.myFileNameFontSet(const Value: TFont);
begin
  FmyFileNameFont.Assign(Value);
end;

procedure TAmListBoxMyFiles.myFileNameOffsetSet(const Value: TAmPointVclOpt);
begin
  FmyFileNameOffset.Assign(Value);
end;

procedure TAmListBoxMyFiles.myNameRuFontSet(const Value: TFont);
begin
  FmyNameRuFont.Assign(Value);
end;

procedure TAmListBoxMyFiles.myNameRuOffsetSet(const Value: TAmPointVclOpt);
begin
  FmyNameRuOffset.Assign(Value);
end;

procedure TAmListBoxMyFiles.myFontChange(S:TObject);
begin
 if csLoading in self.ComponentState  then exit;
 self.Repaint;
end;
procedure TAmListBoxMyFiles.myOffsetChange(Sender:TObject;PVar:Pointer);
begin
 if csLoading in self.ComponentState  then exit;
 self.Repaint;
end;

function TAmListBoxMyFiles.ObjectItemAdd(Index: PInteger): TAmLbItemMyFile;
begin
   Result:= inherited ObjectItemAdd(Index)   as TAmLbItemMyFile;
end;

function TAmListBoxMyFiles.ObjectItemIndexGets(Index: Integer): TAmLbItemMyFile;
var O:TObject;
begin
   O:= inherited ObjectItemIndex[Index];
   if Assigned(O) and ( O is TAmLbItemMyFile)  then
    Result:=  TAmLbItemMyFile(O)
    else
    Result:=nil; 
end;

function TAmListBoxMyFiles.ObjectItemInsert(Index: integer): TAmLbItemMyFile;
begin
    Result:= inherited ObjectItemInsert(Index)   as TAmLbItemMyFile;
end;



end.
