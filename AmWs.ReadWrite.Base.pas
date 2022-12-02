

         ////////////////////////////////////////////////////////////////
         /////                         BASE CLASS                   /////
         ///////////////////////////////////////////////////////////////
         {
          пустые условно классы с виртуальными методами оправки приема и событиями
          в детях будет вся доп логика работы


         }

         ////////////////////////////////////////////////////////////////
         /////                      STANDART1 CLASS                 /////
         ///////////////////////////////////////////////////////////////
         {
           STANDART1 унаследован от BASE
           способы оправка примемы самые прострые сначало оправляем размер данных
           затем сами данные
           при получение сначало читаем размер потом данные
           так же обратите внимание что по умолчанию размер данных т.е число как набор байт инверсируется
           можно отключить если ваш сервак не шарит за такое



         }

         ////////////////////////////////////////////////////////////////
         /////                      WEBSOKECT CLASS                 /////
         ///////////////////////////////////////////////////////////////
         {
           WEBSOKECT унаследован от BASE
           способы оправка примема согласно протоколу вебсокета
         }

         // можно дальше унаследоватся что бы свои кастомные протоколы написать
         //если вы управляете и клиентом и сервером

unit AmWs.ReadWrite.Base;

interface

uses Winapi.Windows, Winapi.Messages,Classes, System.SysUtils, IdSSLOpenSSL, IdTCPClient, IdGlobal, IdCoderMIME,
     IdHash, IdHashSHA, math, System.threading, DateUtils, System.SyncObjs, IdURI,IdIOHandler,IdGlobalProtocols,
     AmUserType,IdSocks,idStack,idHTTP,IdSSL,
     IdHTTPHeaderInfo,IdHeaderList,IdIOHandlerStack,AmList,AmHandleObject,
     IdComponent,
     IdStackConsts,Idwinsock2,
     System.Diagnostics,
     IdIOHandlerSocket,
     AmSystemBase,AmSystemObject;

    type
         ////////////////////////////////////////////////////////////////
         /////                         BASE CLASS                   /////
         ///////////////////////////////////////////////////////////////
      {
              схема отправки приема сообщ. для понимания событий
              [                  одно MSG                         ]
              [  frm      |    frm        |     frm   |   frm     ]
              [ blc 'blc  'blc'blc'blc'blc'     blc   'blc'blc'blc]
              frm = фрейм
              blc = блок (часть фрейма)

              blc.size  <= frm.size а frm.size<= MSG.size

              но на низком уровне свегда дело идет с блоками



        одно сообщение передаваймое по сети  состоит из фреймов (маленькие кусочки скажем 4096 байт)
        в вебсокете фреймом может быть и одно большое сообщение 2 гига
        тогда в этом модуле 2 гига разобьется на маленькие кусочки которые будут называтся блоками
        эт инфа нужна для понимания событий EventMsg EventFrm EventBlc

        интернет не надежный он может их увеличить или уменщить как повезет юзеру с интернетом
        однако последовательность нарущатся не должа

        если отпрвляем (привет как дела?)
        не надо в середину вставлять картинку или бог знает что или пинги
        а потерей пакетов (чего не может быть) займется родитель TCP

        в веб сокете фреймы кодируются а если есть sll то там еше кодируются
        на другой стороне sll декодируется затем веб сокет  декодирует фрейм
        т.е другая сторона делает читку а первая запись отсюда названия класов read write

        самое простое понятия как узнать сколько байт нужно получить
        1. сначало отравим число это наш размер
        2. потом сами данные

        в протоколе вебсокета немного сложнее
        в частности из за того что при даже единичном пропуске 1 байта
        из рандомного набора байт тоже получится рандомное число

        так же знайте что скорость  передачи увеличивается если не использовать sll
        помогает если большие файлы суете в сеть через websoket
        побочка. данные полностью открыты и их даже баба зина поймет особенно текст
        можно свой шифр придумать и перед отправкой шифровать

        если ниче не понятно из выше закройте этот модуль и пользуйтесь
        готовыми решениями из модулей высшего порядка.


        чистаем фреймы из  TAmIoBase  = TIdIOHandlerStack,
        а ребенок класса может быть любой что бы Sll было эт TIdSSLIOHandlerSocketOpenSSL
        класс читки сообщений содержит переменную  класса читки фреймов

        в базовом классе TAmIoReadMsg_Baze   можно отследить логику вызова методов
        и после унаследоваться что бы сделать условный протокол WebSoket или свой какой то
        так же можно унаследоваться от WebSoket что над ним сделать свой протокол
        пример с WebSoket есть так что можно разобратся при желании

      }

      // ..........................................................................
       //классы которые в этом модуле
       TAmIoBase         = class(TIdIOHandlerSocket);  // самый низкий предок IOHandler
       TAmIoMsg_Base  = class;          // базовый класс чтения записи который использует параметры TAmIoMsgParam
       TAmIoMsg_Class = class of TAmIoMsg_Base;

       TAmIoMsgParam = class; // от этого класса унаследуются параметры процессов выполнения чтения и записи
       TAmIoMsgParam_Class = class of TAmIoMsgParam;

       TAmIoMsgParamRead_Base  = class; // базовые параметры для чтения
       TAmIoMsgParamWrite_Base  = class; // базовые параметры для записи

       TAmIoMsgParamRead_Class  = class of TAmIoMsgParamRead_Base;
       TAmIoMsgParamWrite_Class  = class of TAmIoMsgParamWrite_Base;

       TAmIoThreadWrite =class; // поток для write (можно поставить сообщения в очередь чтобы вызывающий поток не стопорился в ожидании предыдущих отправок)
      // ..........................................................................






      // ..........................................................................
        TAmIoMsgParamReadEvent_Base = procedure (S:TObject;Param:TAmIoMsgParamRead_Base ) of object;
        TAmIoMsgParamWriteEvent_Base = procedure (S:TObject;Param:TAmIoMsgParamWrite_Base ) of object;


      // ..........................................................................




       // от этого класса унаследуются параметры read write  base ws std1 и другие
       TAmIoMsgParam =class
          type
            TStatistics= record
             private
              Stopwatch:TStopwatch;
              procedure Init;
             public
              IsNeed:boolean;  // если нужна статискика то true в событии процесса выполения можно будет получать данные
              Procent:integer;
              Speed:real;
              FromEnd:integer;
              FromBegin:integer;
              Updata:boolean;
              function SpeedToString :string;
              function FromEndToString :string;
              function FromBeginToString :string;

            end;
         private
            CS:TAmCs; // секция для блокировки класса с другого потока в событих нет смысла ипользовать
            FIsValid,
            FIsProcess,
            FIsWasProcess,
            FIsAbort:boolean;

            procedure StatisticsStart;
            procedure StatisticsProcess(IgnorSleep:boolean);
            procedure StatisticsEnd;

            function  GetIsValid:boolean;
            procedure SetIsValid(v:boolean);
            function  GetIsProcess:boolean;
            procedure SetIsProcess(v:boolean);
            function  GetIsWasProcess:boolean;
            procedure SetIsWasProcess(v:boolean);
            function  GetIsAbort:boolean;
            procedure SetIsAbort(v:boolean);
         public
          xIsDestoy:integer; //удален ли объект если нет то xIsDestoy = Word.MaxValue обычно не используется то при сомнениях можно проверить
          xStatistics:TStatistics; // как быстро идет процесс статистика

          msgSize:int64;      // размер всего сообщения websoket всегда 0  там размер фрейма будет
          //  msgCountFrm:int64;  // количество фреймов     websoket 0
          msgCountBytesExp:int64;  // количество байт которое получено  или отправлено в этом сообщении

          frmSize:int64;     // размер фрейма
          frmCountBytesExp :int64; // количество байт которое получено  или отправлено в этом фрейме
          frmNum:int64;      // номер фрейма
          frmIsLast:boolean;  // это последний фрейм


          // произвольное поле для обозначения статуса буду обозначать в какой процедуре код сейчас для каждого унаследованного класса будут свои значения   поможет с откладной при зависании
         // xStatusProc:integer;


          xData:Pointer; // произвольное поле   к компоненту как то привязать для получения сколько скачалось или отмены
          xComponent:Pointer;// произвольное поле
          xIndiv:Integer;   // произвольное поле

          //..............................................
          // зашещенные переменные для обращения с разных потоков

          //валидны ли даннные которые  во всем  текущем классе если нет то обрыв
          //соединения будет в событии можно самому поставить так же в модулях выставляется
          property  xIsValid:boolean read GetIsValid write SetIsValid;

          // отправляются ли сейчас данные
          property  xIsProcess:boolean read GetIsProcess write SetIsProcess;

          // была ли попытка отправки данных
          property xIsWasProcess:boolean read GetIsWasProcess write SetIsWasProcess;

          //xIsAbort если true прекратить чтение закрыть соединение
                    // эт костыль обрыва операции  в модулях всегда false только
                    //в событиях можно поставить в true или др способами через list или pointer объекта
                    // особенность xIsAbort
                    // если  xIsAbort =true изменился в процессе выполнения = разоврать соединение
                    // если в очереди ток стоит то это сообщение не отправить а другие будут отправлять
                    // целостность системы не нарушится
                    // можно просто close выполнить когда захотел да и все
                    // просто если на половине прервать то сервер же не знает он ожидает
                    //получить  1м а получил 0.5 буде ждать или 2е сообщение начнем отправлять
                    //а сервер будет считать его окончанием первого сообщ. эт фиерический пиздец
                    {
                     делал я как то чат... основной канал
                     который пинговался что юзер онлайн отправлял маленькие сообщения
                     как только дело доходило до фото видео или длиннызх переписок
                     то выполнял на тот же сервак новый коненкт а основной так же продолжал работать не нагружаясь
                     как только фото было получено то обрыв как обычный http() GET POST
                     сохр фото на диск юзера что бы повторно не скачивал в некст раз да и все.
                    }
          property  xIsAbort:boolean read GetIsAbort write SetIsAbort;
          //..............................................

          procedure Lock;   virtual;
          function  TryLock:Boolean;   virtual;
          procedure UnLock; virtual;
          procedure Init; virtual; //при создании класса
          procedure Clear;virtual;//очистка всех полей
          procedure Clear_Msg;virtual;//очистка полей относящихся к msg
          procedure Clear_Frm;virtual;//очистка полей относящихся к frm (фрейм)

          class function ClassWrite: TAmIoMsgParamWrite_Class; virtual;
          class function ClassRead: TAmIoMsgParamRead_Class;   virtual;
          function IsClassWrite:boolean;
          constructor Create;virtual;
          destructor Destroy;override;
       end;


       // ........................................................................
        // базовые параметры для чтения
       TAmIoMsgParamRead_Base = class (TAmIoMsgParam)
        private

        public
          msg_Stream:TStream; //сюда записываются данные при чтении сокета
          // по поводу удаления стримов посморите логику Clear_Msg
          // по поводу установки стримов в событии до чтения можно установить куда писать или по ходу поменять в процессе есть событие или после читки фрейма
          //если в before msg установили то в after msg удалили и  msg_Stream в nil привратили
          // иначе не надо удалять ниче
          //стоит ли обрабатывать полученное сообщение зависит от переменных if  xIsValid and not  xIsAbort then обрабатывать
          procedure Clear_Msg;override;
          class function ClassWrite: TAmIoMsgParamWrite_Class; override;
          class function ClassRead: TAmIoMsgParamRead_Class; override;
          function ParamToString(var P:string):integer;
       end;
       // базовые параметры для записи
       TAmIoMsgParamWrite_Base = class (TAmIoMsgParam)
        private
          FWriteID:int64;
          FIsThread:boolean;
          FIsSendCallBack:boolean;
          FResultWrite:integer;
          function ExpCallBack:boolean;
          function GetResultWrite:integer;
        protected
          const

           msg_whop_stream=1;
           msg_whop_file=2;
           msg_whop_string=3;
           msg_whop_head=4; // только заголовки отправляются без тела
          var
           msg_whop:word;// при проверке параметров устанавливается сама или [1,2,3,4] стрим файл строка
        public
          property ResultWrite:integer read GetResultWrite; //>0 удачно отправлено в сокет а отправит ли он хз с малелькими сообщениями точно не ясно а с большими если интернет пропадет то во write исключение будет
          {
                 0 //значение по умолчанию нет ответа значит какие то параметры не содействуют отправке
                -3; //не указано что нужно отправить
                 1  //все было отправлено в сокет
                -2; //или отмена была или не валид параметры или др проблемы сети
                -1; //внутренняя ошибка кода сбой в отправке exception

          }


          property WriteID:int64 read FWriteID;  // id в листе потока очереди на отправку ставиться само
          property IsThread:boolean read FIsThread; // отравляется ли в отдельном потоке
          var
          UseCallBack:boolean;// использовать переменную  HandleCallBack и не удалять текуший объект после write

          // если использовать UseCallBack true вы долны гарантировать что получите сообщение через postmessage которое установите
          // в HandleCallBack и там где его получить удалите и очистите этот объект сам объект передастся в lparam как число
          // будет выполнятся только если write выполнялось в отдельном потоке для write
          HandleCallBack:TMsg; // параметры для отравки PostMessage при окончании записи текушего сообщения
          msg_W2:boolean; // отправлять ли msg_StreamHead msg_Stream как 2 разных сообщения
          msg_StreamHead:TStream; //заголовок сообщения  можно nil это поле задел а будущее вдруг я захочу поверх текущего протокола накнуть свой или 10 своих  протоколов
           //сами данные на выбор что то одно  приоритет проверки как написано

          msg_Stream:TStream;
          msg_File:string; //путь к файлу если файл (файл можно и в стрим сразу впихнуть просто не понятно сколько в очереди уже сообщений ждут отправку а файл будет отрыт т.е недоступен все это время а если путь к файлу указать то стрим откроется только когда очередь придет)
          msg_Str:string; // строка
          msg_Head:boolean; // без тела только заголовок
          // по поводу удаления стримов посморите логику Clear_Msg если утраивает то ок если нет то ловите событие просле выпонения и там удаляйте стрим а сюда nil
          procedure Clear_Msg;override;
          procedure Clear;override;
          procedure Init;override;
          class function ClassWrite: TAmIoMsgParamWrite_Class; override;
          class function ClassRead: TAmIoMsgParamRead_Class; override;

       end;
         {
           если возникает диссонанс как же так во write 2 стрима а в read 1
           то  TAmIoMsgParamWrite_Base побоку на 2 стрима
           он их отравит 1 за другим по очереди и это будет одно сообщение
           которое запишится в TAmIoMsgParamRead_Base.msg_Stream
           но можно словить событие bsDoAfterReadFrm узнать сколько байт получено уже
           и выдернуть свое стандартизированное коливо байт

           а после в параметрах указать тот стрим куда писать реальные данные
          не забыв записать остаток байт с предыдущего шага

          если же хотим что бы msg_StreamHead и msg_Stream  были 2мя разными сообщениями
          то msg_W2 установить в true тогда

          скажем на клиенте write иполнится 1 раз а на серваке 2 раза
          сначало придет msg_StreamHead
          вы обработаете событии после чтения и установите условную переменную что
          сервер готов получать сами данные
          а затем придет  msg_Stream

          даж если сервак после получения   msg_StreamHead отправит что то обратно
          набор байт для чтения на серваке не нарушится так как TCP передает или все или ничего

         }

       // ........................................................................

       // базовый класс чтения записи
       {
          read и  write считайте двумя разныеми классами
          для каждого есть своя критическая секция
          в которых код может в кс выполятся оч долго
          но есть CsFun в которой код должен быстро выполнятся иначе блок будет  значение переменных каких то просто получить

          если read  то может одновремено и write
          но 2  read или 2 write одновременно не может быть

          используются имено кс а не мьютексы или эвенты


       }

       TAmIoMsg_Base = class
         private
           FIO: TIdIOHandler;
           FIsServerSide:boolean;
           FOnLog:TProcDefaultError;

           {read}
           //..............................................
           FParamRead:TAmIoMsgParamRead_Base;
           FSaveReadTimeOutMs:integer;
           CsRead:TAmCs;
           ReadStreamDef:TMemoryStream;
           FOnBeforeReadMsg :TAmIoMsgParamReadEvent_Base;
           FOnAfterReadMsg :TAmIoMsgParamReadEvent_Base;
           FOnProcessReadMsg :TAmIoMsgParamReadEvent_Base;

           FOnBeforeReadFrm :TAmIoMsgParamReadEvent_Base;
           FOnAfterReadFrm :TAmIoMsgParamReadEvent_Base;

           FOnBeforeReadBlc :TAmIoMsgParamReadEvent_Base;
           FOnAfterReadBlc :TAmIoMsgParamReadEvent_Base;

           FOnPing:TProcDefaultObjStrInt; // в этом классе пинг понга нет
           FOnPong:TProcDefaultObjStrInt;

           procedure bsParamReadSet(aParam:TAmIoMsgParamRead_Base);



           //..............................................

            {write}
           //..............................................
           var
           ThreadWrite:TAmIoThreadWrite;
           CsWrite:TAmCs;
           CsWritePre:TAmCs;
           F_IsExpCanWriteEx:boolean;

           FOnBeforeWriteMsg :TAmIoMsgParamWriteEvent_Base;
           FOnAfterWriteMsg :TAmIoMsgParamWriteEvent_Base;
           FOnProcessWriteMsg :TAmIoMsgParamWriteEvent_Base;

           FOnBeforeWriteFrm :TAmIoMsgParamWriteEvent_Base;
           FOnAfterWriteFrm :TAmIoMsgParamWriteEvent_Base;
           {fun}
           //..............................................
           CsFun:TAmCs;
           FCountWritedForRead:integer;//для подсчета запусков на отправку в ноль выствляется когда ReadBytes уходит в долгое ожидания а после выхода с ожидания проверяется что бы не закрыть случайно соеденение
           //.............................................

           FOnCanWrite:TNotifyEvent;// готов к записи
           FOnCanWriteEx:TNotifyEvent;// готов к записи когда прислано первое контрольное сообщени может быть ping
           FOnCanRead:TNotifyEvent; // готов к чтению


           function GetIsExpCanWriteEx :boolean;
           procedure SetIsExpCanWriteEx(V:boolean);

           procedure CountWritedForReadInc;
           procedure CountWritedForReadNull;
           function CountWritedForReadGet:integer;
         protected
            const
             const_buffer_size:integer = 16*1024;
             const_read_timeout:integer= 200;
           var
            PongCountRead:int64;
            PingCountRead:int64;
            PongCountWrite:int64;
            PingCountWrite:int64;
            PingLastWriteTime:TDateTime;
            PongLastWriteTime:TDateTime;
            PingLastReadTime:TDateTime;
            PongLastReadTime:TDateTime;

          // что бы свои пареметры предать можно Cardinal:=Lparam(MyClassParam)
          // MyClassParam:= TAmIoReadMsgParam_Base(Cardinal);
          // нельзя передавать классы не TAmIoReadMsgParam_Base
            {read}
            //..............................................

           procedure bsReadBegin(SecTimeOut,ARate:integer;IsNeedHeartBeat:boolean);virtual;
           procedure bsReadEnd();virtual;

           procedure bsDoBeforeReadMsg(Param:TAmIoMsgParamRead_Base);virtual;
           procedure bsDoAfterReadMsg(Param:TAmIoMsgParamRead_Base);virtual;
           procedure bsDoProcessReadMsg(Param:TAmIoMsgParamRead_Base);virtual;

           procedure bsDoBeforeReadFrm(Param:TAmIoMsgParamRead_Base);virtual;
           procedure bsDoAfterReadFrm(Param:TAmIoMsgParamRead_Base);virtual;

           procedure bsDoBeforeReadBlc(Param:TAmIoMsgParamRead_Base);virtual;
           procedure bsDoAfterReadBlc(Param:TAmIoMsgParamRead_Base);virtual;

           // вызывается на сервере если при старте указано что эт нужно раз в 1 сек если другого нечего делать
           // в детях можно пинг понг прописать
           procedure bsReadHeartBeat(var IsCounterTimeOutToZero:boolean);virtual;

           // когда длинный тайм аут нужен можно это использовать
           function bsReadLongTimeOut(TimeOutMs:integer):boolean;

           //один фрейм не может быть больше integer.maxvalue
           function bsReadFrameGetSize:integer;virtual;
           function bsReadFrameDecoder(var ABuffer:TidBytes;var Count:Integer):boolean;virtual;

           function bsReadReable(TimeOut:integer):boolean;virtual;
           procedure bsReadBytes(var ABuffer:TidBytes; const ACountBytes:integer);virtual;
           function bsReadByte():byte;virtual;
           function bsReadBytesTry(var ABuffer:TidBytes; const ACountBytes:integer):boolean;virtual;
           function bsReadFrameLogic():boolean;virtual; //result последний ли это фрейм

           function bsReadStream():boolean;virtual; // result удачно ли прочитали
           function bsReadStreamTry():boolean;virtual; // result удачно ли прочитали
           function bsReadSizeStream():int64;virtual; // result вернуть рамер стрима если такая локика и сам размер записан перед самими данныеми в вебсокете такого нет



           //..............................................


            {write}
           //..............................................
           var
           LinkWriteParam:TAmIoMsgParamWrite_Base;



           procedure bsDoBeforeWriteMsg(Param:TAmIoMsgParamWrite_Base);virtual;
           procedure bsDoAfterWriteMsg(Param:TAmIoMsgParamWrite_Base);virtual;
           procedure bsDoProcessWriteMsg(Param:TAmIoMsgParamWrite_Base);virtual;

           procedure bsDoBeforeWriteFrm(Param:TAmIoMsgParamWrite_Base);virtual;
           procedure bsDoAfterWriteFrm(Param:TAmIoMsgParamWrite_Base);virtual;

            // часть байтов т.е 1 фрейм кодируем если нужно и отправляем в сокет канал
            procedure bsWriteFrameDirect(var  Buf: TIdBytes; const Count:integer);virtual;
            procedure bsWriteFrameCoder(var Buf:TIdBytes;const Count:integer);virtual;
            procedure bsWriteFrameLogic(var ABuffer:TIdBytes;const Count:integer);virtual;

            procedure bsWriteSizeStream(AValue:Int64;Param:TAmIoMsgParamWrite_Base);virtual;
            procedure bsWritePartStream(DataHead,DataMain:TStream;Param:TAmIoMsgParamWrite_Base);
            procedure bsWriteOpenStream(Param:TAmIoMsgParamWrite_Base);virtual;
            procedure bsWriteOpenFile(FileName:String;Param:TAmIoMsgParamWrite_Base);
            procedure bsWriteOpenStr(Source:String;Param:TAmIoMsgParamWrite_Base);
            procedure bsWriteOpenHead(Param:TAmIoMsgParamWrite_Base);

           //эта процедура может выполнятся в отдельном потоке смотрите  TAmIoThreadWrite or bsWriteParamThread
           // и она не виртуальная
           procedure bsWriteParamStart(Param:TAmIoMsgParamWrite_Base);
            //..............................................


            procedure Log(S:string;exception:Exception=nil);Virtual;
            procedure LogThread(Sender:TObject;const S:string;exception:Exception=nil);

           //.........................
            property  IsExpCanWriteEx :boolean read GetIsExpCanWriteEx write SetIsExpCanWriteEx;
            procedure  CanRead;virtual;
            procedure  CanWrite;virtual;
            procedure  CanWriteEx;virtual;
            procedure  DoCanWriteEx;virtual;

            procedure bsPingRead(msg:string;cmd:int64);virtual;
            procedure bsPongRead(msg:string;cmd:int64);virtual;

            function bsPingWrite(msg:string;cmd:int64):int64;virtual;
            function bsPongWrite(msg:string;cmd:int64):int64;virtual;


         public





           {read}
           //..............................................

           procedure LockRead;  // код может в кс выполятся оч долго
           procedure UnLockRead;

           //в детях можно перекрыть  что бы свое написать но ссылку на новосозданного ребенка сюда лучше поместить
           property  bsReadParam:TAmIoMsgParamRead_Base read  FParamRead write bsParamReadSet;

          // начать принимать новое сообщение или ожидать поспупления новых
          // если result код результата чтения пока не прописал если не 0 то все ок
           function bsReadNextMessage():integer;virtual;
           function bsReadCanNextMessage(TimeOut:integer):boolean;virtual;




           // запустить в потоке чтения эт главная входнаая процедура
           procedure bsReadProcessMain(SecTimeOut:integer;  //макс время  ожидания поспупления новых данных если за эт время новых данных нет то обрыв
                                         IsNeedHeartBeat:boolean );virtual; //нужно ли серцебиение скажем раз в секунду или же блокировать сразу на весь SecTimeOut



           //то же что и bsReadProcessMain +выбрана сторона где запускать
           procedure bsReadProcessServer();virtual;
           procedure bsReadProcessClient();virtual;




           property OnBeforeReadMsg :TAmIoMsgParamReadEvent_Base read FOnBeforeReadMsg write FOnBeforeReadMsg;
           property OnAfterReadMsg :TAmIoMsgParamReadEvent_Base read FOnAfterReadMsg write FOnAfterReadMsg;
           property OnProcessReadMsg :TAmIoMsgParamReadEvent_Base read FOnProcessReadMsg write FOnProcessReadMsg;

           property OnBeforeReadFrm :TAmIoMsgParamReadEvent_Base read FOnBeforeReadFrm write FOnBeforeReadFrm;
           property OnAfterReadFrm :TAmIoMsgParamReadEvent_Base read FOnAfterReadFrm write FOnAfterReadFrm;

           property OnBeforeReadBlc :TAmIoMsgParamReadEvent_Base read FOnBeforeReadBlc write FOnBeforeReadBlc;
           property OnAfterReadBlc :TAmIoMsgParamReadEvent_Base read FOnAfterReadBlc write FOnAfterReadBlc;

            //..............................................





           {write}
           //..............................................
            //сюда подается сами данные напримр строка или файл
            // bsWriteParam делит на части стрим и отравляет в bsWriteFrame байты
            // эсли передаем не параметры а стрим то параметры содадутся на автомате

           procedure LockWrite;    // код может в кс может выполятся оч долго
           procedure UnLockWrite;

           procedure LockWritePre;    //
           procedure UnLockWritePre;

           // перед отправкой проверка параметров в потомке может быть перекрыта
           function bsWriteCheckParam(Param:TAmIoMsgParamWrite_Base):boolean;virtual;
           // bsWrite... отправка через отдельный поток если IsThread = true иначе в том же потоке где и вызвана

           //Result id параметрова в очереди на отправку если IsThread = true иначе  или <=0  код  ощибки
           // хороший  Result должен быть >0
           // bsWriteParamThread основаная для отправки
           function bsWriteParam(Param:TAmIoMsgParamWrite_Base;IsThread :boolean = true):int64;

           // просто пример для отправки как создаются параметры на этом уровне
           function bsWriteSimple(Stream:TStream;FileName,SourceString:String; IsThread :boolean = true):int64;

            function bsPingWriteCustom(msg:String;cmd:Int64):Int64;
            function bsPongWriteCustom(msg:String;cmd:Int64):Int64;

           function  bsWriteListIndexOf(AId:int64):TAmIoMsgParamWrite_Base;
           procedure bsWriteListAbortAll();
           function  bsWriteListLock:TAmList<TAmIoMsgParamWrite_Base>;
           procedure bsWriteListUnlock;

           property OnBeforeWriteMsg :TAmIoMsgParamWriteEvent_Base read FOnBeforeWriteMsg write FOnBeforeWriteMsg;
           property OnAfterWriteMsg :TAmIoMsgParamWriteEvent_Base read FOnAfterWriteMsg write FOnAfterWriteMsg;
           property OnProcessWriteMsg :TAmIoMsgParamWriteEvent_Base read FOnProcessWriteMsg write FOnProcessWriteMsg;

           property OnBeforeWriteFrm :TAmIoMsgParamWriteEvent_Base read FOnBeforeWriteFrm write FOnBeforeWriteFrm;
           property OnAfterWriteFrm :TAmIoMsgParamWriteEvent_Base read FOnAfterWriteFrm write FOnAfterWriteFrm;
           //..............................................
           {custom event read}
           property OnPingMsg :TProcDefaultObjStrInt read FOnPing write FOnPing;
           property OnPongMsg :TProcDefaultObjStrInt read FOnPong write FOnPong;
           //..............................................
           //как определять готовность к записи в сокет
           // CanWriteWhenFirstPingPong = true сервер гарантирует что первое сообщение от сервера будет ping
           // тогда событие OnCanWriteEx сработает после получение первого ping от сервера
          // OnCanWriteEx на сервере сработает после получение первого pong
           // и можно будет начать писать в сокет
           // OnCanRead OnCanWrite выполнять одновременно до начала читки



           property IsCanWriteEx :boolean read GetIsExpCanWriteEx;
           //готов к записи когда прислано первое контрольное сообщение может быть ping
           // контрольное не контрольное определяется в потомках
           // и CanWriteEx вызывается в потомках
           property OnCanWriteEx :TNotifyEvent read FOnCanWriteEx write FOnCanWriteEx;
           //готов к записи
           property OnCanWrite :TNotifyEvent read FOnCanWrite write FOnCanWrite;
           // готов к чтению
           property OnCanRead :TNotifyEvent read FOnCanRead write FOnCanRead;

            //вынесены в отдельное поле т.к эти события вызываются не с текущего класса а только с потомков
            // вначале нужно определить понимает ли друг друга сервер и клиент
            // вызвать события и после этого например можно отправлять чето

            // пример с Std1
            // CanRead вызывается сама в bsReadBegin   а  в Std1 во bsReadBegin отправится ping клиенту
            // для сервера CanWrite  вызовется когда придет первый ответ pong от клиента
            // для клиента CanWrite  вызовется когда придет первый ping от сервера
           //..............................................

           {help}
           //..............................................
           //удобные методы помошь в отправке можно дописать свои
           procedure hpWriteInt64(Value:int64;Convert:boolean=true);
           function  hpReadInt64(Convert:boolean=true):int64;

           {fun}
          //..............................................

           procedure LockFun;  // код должен в кс выполятся быстро иначе блокировка будет потоков
           procedure UnLockFun;


           function IsWriteWork:boolean;virtual;
           function IsWriteFree:boolean;virtual;

           function Connected:boolean;virtual;
           function Connected2:boolean;virtual;
           procedure CheckForDisconnect(); virtual;
           procedure Close;virtual;
           property IO: TIdIOHandler read FIO;
           property IsServerSide: boolean read FIsServerSide write FIsServerSide;

           // должна возвращать связанный класс ReadWriteParam c этим классом ReadWrite
           class function ClassParamRead: TAmIoMsgParamRead_Class; virtual;
           class function ClassParamWrite: TAmIoMsgParamWrite_Class; virtual;

          //..............................................
           property OnLog: TProcDefaultError read FOnLog write FOnLog;
           constructor Create(aIO:TIdIOHandler);virtual;
           destructor Destroy ;override;
       end;


       // поток для write в асинхронном режиме
       TAmIoThreadWrite = class (TamHandleThread)
         type
           TProcEvent = procedure (Param:TAmIoMsgParamWrite_Base) of object;
         const
           CONST_PROC_EVENT = wm_user+100;
           CONST_NOTIFY_EVENT = wm_user+101;
         strict private
          FProcEvent: TProcEvent;
          FList:TAmList<TAmIoMsgParamWrite_Base>;
          FCS:TAmCS;
          CounterId:int64;
          procedure xProcEvent(var Msg:TMessage); message CONST_PROC_EVENT;
          procedure xNotifyEvent(var Msg:TMessage); message CONST_NOTIFY_EVENT;
         public
          property CsList :TAmCS read FCS;
          property ListParam :TAmList<TAmIoMsgParamWrite_Base> read FList;
          function ParamFree(Param:TAmIoMsgParamWrite_Base):int64;
          procedure ParamAbort(Param:TAmIoMsgParamWrite_Base);
          function ParamFreeAll():int64;
          function ParamAbortAll():int64;
          function ParamIndexOf(AId:Int64):TAmIoMsgParamWrite_Base;
          function ParamGetCountListIsValid():integer;
          function ParamWrite(Param:TAmIoMsgParamWrite_Base):int64; //result id параметра  WriteID
          constructor Create(AEventProc:TProcEvent);
          destructor  Destroy; override;
       end;

         ////////////////////////////////////////////////////////////////
         /////                      STANDART1 CLASS                 /////
         ///////////////////////////////////////////////////////////////
         {
           STANDART1 унаследован от BASE
           способы оправка примемы самые прострые сначало оправляем размер данных
           затем сами данные
         }

         ////////////////////////////////////////////////////////////////
         /////                      WEBSOKECT CLASS                 /////
         ///////////////////////////////////////////////////////////////
         {
           WEBSOKECT унаследован от BASE
           способы оправка примема согласно протоколу вебсокета
         }




implementation







               {TAmIoMsg_Base базовый класс чтения записи}
constructor TAmIoMsg_Base.Create(aIO:TIdIOHandler);
begin
    if (ClassParamRead = nil) or (ClassParamWrite = nil) then
    raise Exception.Create('Error TAmIoMsg_Base.Create Class Read or Write=Nil');

    if not ClassParamRead.InheritsFrom(TAmIoMsgParamRead_Base)
    or (ClassParamRead = TAmIoMsgParamRead_Base) then
    raise Exception.Create('Error TAmIoMsg_Base.Create Class Read Invalid Класс '+ClassParamRead.ClassName+
    ' не может полноценно выполнять все операции. Сделайте наследник!');


    if not ClassParamWrite.InheritsFrom(TAmIoMsgParamWrite_Base)
    or (ClassParamWrite = TAmIoMsgParamWrite_Base) then
    raise Exception.Create('Error TAmIoMsg_Base.Create Class Write Invalid! Класс '+ClassParamWrite.ClassName+
    ' не может полноценно выполнять все операции. Сделайте наследник!' );

    if not Assigned(aIO) then
    raise Exception.Create('Error TAmIoMsg_Base.Create Class IO=Nil');

    inherited  Create;
    PongCountRead:=0;
    PingCountRead:=0;
    PongCountWrite:=0;
    PingCountWrite:=0;

    PingLastWriteTime:=0;
    PongLastWriteTime:=0;
    PingLastReadTime:=0;
    PongLastReadTime:=0;
    F_IsExpCanWriteEx:=false;



    FIsServerSide:=false;
    CsRead:=  TAmCs.create;
    CsWrite:=TAmCs.create;
    CsWritePre:=TAmCs.create;
    CsFun:= TAmCs.create;
    FIO:= aIO;
    CountWritedForReadNull;
    ReadStreamDef:=TMemoryStream.Create;
    FParamRead:=ClassParamRead.Create;


    ThreadWrite:=  TAmIoThreadWrite.Create(bsWriteParamStart);
    ThreadWrite.OnLog:= LogThread;
    ThreadWrite.Start;
end;
destructor TAmIoMsg_Base.Destroy ;
begin

   Close;


   if Assigned(ThreadWrite) then
   FreeAndNil(ThreadWrite);



   if Assigned(FParamRead) then
   FreeAndNil(FParamRead);

   if Assigned(ReadStreamDef) then
   FreeAndNil(ReadStreamDef);

   if Assigned(CsRead) then
   FreeAndNil(CsRead);
   if Assigned(CsWrite) then
   FreeAndNil(CsWrite);
   if Assigned(CsWritePre) then
   FreeAndNil(CsWritePre);

   if Assigned(CsFun) then
   FreeAndNil(CsFun);




    inherited;

end;
class function TAmIoMsg_Base.ClassParamRead: TAmIoMsgParamRead_Class;
begin
   Result:=  TAmIoMsgParamRead_Base;
end;
class function TAmIoMsg_Base.ClassParamWrite: TAmIoMsgParamWrite_Class;
begin
  Result:=  TAmIoMsgParamWrite_Base;
end;
procedure TAmIoMsg_Base.Log(S:string;exception:Exception=nil);
begin
  if Assigned(OnLog) then
  OnLog(self,S,exception);

end;
procedure TAmIoMsg_Base.LogThread(Sender:TObject;const S:string;exception:Exception=nil);
begin
   Log(S,exception);
end;
procedure TAmIoMsg_Base.LockFun;
begin
   CsFun.Enter;
end;
procedure TAmIoMsg_Base.UnLockFun;
begin
  CsFun.Leave;
end;
function TAmIoMsg_Base.IsWriteFree:boolean;
var RCS:boolean;
begin
    // свободен ли write поток

    LockFun;
    Result:=true;
    try
       try

         RCS:=  CsWrite.TryEnter;
         try
            Result:= RCS;
            if Result then
            begin
             // тогда проверим колво параметров в очереди потока

             //если чето есть значит работает write и сейчас Cs займется   им
             Result:=self.ThreadWrite.ParamGetCountListIsValid<=0;
             if Result then
             Result:= not Assigned(LinkWriteParam); //еще один критерий что поток write работает
            end;

         finally
           if  RCS then CsWrite.Leave;
         end;

       except
          log('IsWriteFree Error');
       end;
    finally
      UnLockFun;
    end;

end;
function TAmIoMsg_Base.IsWriteWork:boolean;
begin
    Result:= not IsWriteFree;
   // log('IsWorkWrite '+Result.ToString());

end;
function TAmIoMsg_Base.Connected:boolean;
begin
   // Result:=false;
    Result:=Connected2
  {
   else
   begin
     try
        LockFun;
        try
           try
             if Assigned(IO) then
             Result:=IO.Connected;
           except
             on e: exception do
             begin
               log('Error TAmIoMsg_Base.Connected2 '+e.Message,e);
             end;
           end;
        finally
          UnLockFun;
        end;


     except
       on e: exception do
       begin
         log('Error TAmIoMsg_Base.Connected1 '+e.Message,e);
       end;
     end;
   end;
     }
end;
function TAmIoMsg_Base.Connected2:boolean;

 function Loc_inherited_Connect:boolean;
  begin
    //CheckForDisconnect(False);
    Result :=
     (
       (
         // Set when closed properly. Reflects actual socket state.
         (not IO.ClosedGracefully)
         // Created on Open. Prior to Open ClosedGracefully is still false.
         and (IO.InputBuffer <> nil)
       )
       // Buffer must be empty. Even if closed, we are "connected" if we still have
       // data
       or (not IO.InputBufferIsEmpty)
     )
     and IO.Opened;
  end;


 function Loc_Binding:boolean;
 begin
  Result :=
  ( TAmIoBase(IO).BindingAllocated and Loc_inherited_Connect )  or ( not TAmIoBase(IO).InputBufferIsEmpty );
 end;
begin
    Result:=false;
     try
        LockFun;
        try
           try
             if Assigned(IO) then
             Result:= Loc_Binding;
           except
             on e: exception do
             begin
               log('Error TAmIoMsg_Base.Connected2_2 '+e.Message,e);
             end;
           end;
        finally
          UnLockFun;
        end;


     except
       on e: exception do
       begin
         log('Error TAmIoMsg_Base.Connected2_1 '+e.Message,e);
       end;
     end;
end;
procedure TAmIoMsg_Base.CheckForDisconnect();
begin
    LockFun;
    try
       if Assigned(IO) then
       IO.CheckForDisconnect(true,true);
    finally
      UnLockFun;
    end;
end;
procedure TAmIoMsg_Base.Close;
begin
   // в детях можно написать что бы сообщение отправлялось при закрытии в веб сокете буду писать
    LockFun;
    try
       IsExpCanWriteEx:=false;
       if Assigned(ThreadWrite) then
       ThreadWrite.ParamAbortAll;

       if Assigned(IO) then
       begin
       IO.CloseGracefully;
       IO.Close;
       IO.InputBuffer.Clear;
       end;

    finally
      UnLockFun;
    end;

end;
procedure TAmIoMsg_Base.CountWritedForReadNull;
begin
    LockFun;
    try
       FCountWritedForRead:=0;
    finally
      UnLockFun;
    end;
end;
procedure TAmIoMsg_Base.CountWritedForReadInc;
begin
    LockFun;
    try
       inc(FCountWritedForRead);
       if FCountWritedForRead>1000000 then
       FCountWritedForRead:=  1000000;

    finally
      UnLockFun;
    end;
end;

function TAmIoMsg_Base.CountWritedForReadGet:integer;
begin
    LockFun;
    try
       Result:= FCountWritedForRead;
       if FCountWritedForRead<>0 then
       FCountWritedForRead:=0;
    finally
      UnLockFun;
    end;
end;
           {help}
procedure TAmIoMsg_Base.hpWriteInt64(Value:int64;Convert:boolean=true);
var ABuffer:TIdBytes;
begin


    // переворот байтов для сети интернет
    if Convert then
    Value := Int64(GStack.HostToNetwork(UInt64(Value)));

    // число в байты
    ABuffer:= TIdBytes( AmBytes(Int64(Value)) );

    // отправка байтов
    self.bsWriteFrameDirect(ABuffer,Length(ABuffer));


     // альтернативно тож самое но без контрольно

    //IO.Write(Int64(AValue));

end;
function  TAmIoMsg_Base.hpReadInt64(Convert:boolean=true):int64;
var ABuffer:TIdBytes;
begin
    {
    IO.Readbytes(ABuffer,sizeof(Result),true);

    Result:=AmInt64(TBytes(ABuffer));
    }

    // читаем байты для числа
    self.bsReadBytes(ABuffer,sizeof(Result));

    // переводим байты в число
    Result:=AmInt64(TBytes(ABuffer));

    // переворот байтов с сети интернет в исходное int64
    if  Convert then
    Result := Int64(GStack.NetworkToHost(UInt64(Result)));

    // альтернативно тож самое но без контрольно

    // Result:=IO.ReadInt64();

end;

                        {read base}
procedure TAmIoMsg_Base.bsParamReadSet(aParam:TAmIoMsgParamRead_Base);
begin
    if Assigned(FParamRead) then
    FreeAndNil(FParamRead);
    FParamRead:= aParam;

end;
function TAmIoMsg_Base.bsReadFrameGetSize:integer;
begin
   Result:=-1; //не используется
end;
function TAmIoMsg_Base.bsReadFrameDecoder(var ABuffer:TidBytes;var Count:Integer):boolean;
begin
   // используйте эту функцию что бы раскодировать фрейм
   Result:=true;
   // при ходит буффер [1,2,3,4,5]  Count = 5
  // на выходе может быть
  //  буффер [2,5,3,4,3,3,6,9]  Count = 8
  // главное что бы размер соответствовал буферу который нужно добавить в выходной TStream
end;


function  TAmIoMsg_Base.bsReadLongTimeOut(TimeOutMs:integer):boolean;
begin
    //длинный период ожидания поспупления новых данных

    //используется в readbytes и readprocessmain

    // если true значит чето есть что можно читать но надо еше у этом убедится как в readbytes

    // false ощибку вызвать что время ожидания истекло т.е за TimeOutMs ничего не пришло  то Close

    if (TimeOutMs<=0) or (TimeOutMs>500*1000) then
    TimeOutMs:= const_read_timeout*1000;

    Result:= IsWriteWork;  // проверка что write работает или нет зачем нужно в  readbytes писал
    if  Result then exit;

    CountWritedForReadNull;
    Result:= TAmIoBase(IO).ReadFromSource(false,TimeOutMs,false)>0;
    if  Result then exit;

    Result:= IsWriteWork;
   { if  Result then exit;  Result:= CountWritedForReadGet>0; в bsReadProcessMain объяснил зачем эт не нужно }
end;

procedure TAmIoMsg_Base.bsReadHeartBeat(var IsCounterTimeOutToZero:boolean);
begin
  if IsServerSide and (now > incsecond(PingLastWriteTime,124)) then
  begin
    if self.PongCountRead>0 then
    begin
      bsPingWrite(AmGeneratStr.Pass(3),0);
    end
    else IsCounterTimeOutToZero:=false;
  end
  else if not IsServerSide  then
  begin
      if not self.PingCountRead<=0 then
      IsCounterTimeOutToZero:=false;
  end;
end;
function TAmIoMsg_Base.bsPingWrite(msg:string;cmd:int64):int64;
begin
    // отправить Ping базовый класс не знает что именно отправлять только потомок
   Result:=0;
   inc(PingCountWrite);
   self.PingLastWriteTime:=now;
end;
function TAmIoMsg_Base.bsPongWrite(msg:string;cmd:int64):int64;
begin
   // отправить Pong базовый класс не знает что именно отправлять только потомок
   Result:=0;
   inc(PongCountWrite);
   self.PongLastWriteTime:=now;
end;
procedure TAmIoMsg_Base.bsPingRead(msg:string;cmd:int64);
begin
   // определить что прищел пинг и вызвать bsPingRead может только потомок
    inc(PingCountRead);
   PingLastReadTime:= now;
   bsPongWrite(msg,cmd);

   if not IsServerSide and (PingCountRead=1) then
   DoCanWriteEx;

   if Assigned(FOnPing) then
   FOnPing(self,msg,cmd);
end;
procedure TAmIoMsg_Base.bsPongRead(msg:string;cmd:int64);
begin
   // определить что прищел понг и вызвать bsPongRead может только потомок
    inc(PongCountRead);
    PongLastReadTime:= now;
    if  IsServerSide and (PongCountRead=1) then DoCanWriteEx;
    if  not IsServerSide and (PongCountRead=1) then DoCanWriteEx;

    if Assigned(FOnPong) then
    FOnPong(self,msg,cmd);
end;
procedure TAmIoMsg_Base.bsReadBegin(SecTimeOut,ARate:integer;IsNeedHeartBeat:boolean);
begin
  if IsServerSide then bsPingWrite(AmGeneratStr.Pass(3),0);
  if not IsServerSide then bsPingWrite(AmGeneratStr.Pass(3),0);
  CanRead;
  CanWrite;
end;
procedure TAmIoMsg_Base.bsReadEnd();
begin
end;
procedure  TAmIoMsg_Base.CanRead;
begin
  if Assigned(FOnCanRead) then
  FOnCanRead(self);
end;
procedure  TAmIoMsg_Base.CanWrite;
begin
  if Assigned(FOnCanWrite) then
  FOnCanWrite(self);
end;
procedure  TAmIoMsg_Base.DoCanWriteEx;
begin
  if not IsExpCanWriteEx then
  begin
    try
       CanWriteEx;
    finally
        IsExpCanWriteEx:=true;
    end;
  end;
end;
function TAmIoMsg_Base.GetIsExpCanWriteEx :boolean;
begin
    self.LockFun;
    try
        Result:= F_IsExpCanWriteEx;
    finally
      self.UnLockFun;
    end;
end;
procedure TAmIoMsg_Base.SetIsExpCanWriteEx(V:boolean);
begin
    self.LockFun;
    try
        F_IsExpCanWriteEx:= V;
    finally
      self.UnLockFun;
    end;
end;
procedure  TAmIoMsg_Base.CanWriteEx;
begin
  if Assigned(FOnCanWriteEx) then
  FOnCanWriteEx(self);
end;

procedure TAmIoMsg_Base.bsReadProcessMain(SecTimeOut:integer;
                                         IsNeedHeartBeat:boolean);

var Counter:integer;
    R:boolean;
    ARate:integer;
begin
  try
    IO.InputBuffer.Clear;
    PongCountRead:=0;
    PingCountRead:=0;
    PongCountWrite:=0;
    PingCountWrite:=0;
    IsExpCanWriteEx:=false;


    ARate:= 1000*5;//частота серцебиения если  IsNeedHeartBeat true


    if SecTimeOut<0 then SecTimeOut:= self.const_read_timeout;
    if SecTimeOut<5 then SecTimeOut:=5;
    if SecTimeOut>500 then SecTimeOut:=500;

    SecTimeOut:= SecTimeOut*1000;
    FSaveReadTimeOutMs:= SecTimeOut;
    SecTimeOut:= SecTimeOut div ARate;



   // Io.UseNagle := False;  //no 200ms delay!

    Counter:=0;
     try
        CountWritedForReadNull;

        bsReadBegin(SecTimeOut,ARate,IsNeedHeartBeat);
        try
          while Connected do
          begin
             //if not Connected then break;
             R:= bsReadCanNextMessage(ARate);
             if R then
             begin
               R:= bsReadNextMessage = 0;
               if  R then break
               else if Counter<>0 then Counter:=0;
             end
             else
             begin
                    if IsNeedHeartBeat then
                    begin



                        //если поток отправки работает и что то отправляет

                        //а это может быть продолжительняя операция то не нужно разайденять соединение

                        // если же поток работает но соединения по факту уже нет то write прекратить свою работу ощибкой

                        // и вся очередь на отправку остановится тогда можно будет коду зайти дальше в ожидание 150sec

                        // но так как write сделал close то сразу и сдесь будет ошибка и код завершится не дожидаясь 150 сек по тригеру winsock2 select

                        // проверка что сейчас  ничего не отправляется

                        R:= IsWriteWork;// остается актуальным т.к отправка может быть долгой и дольше чем время ожидания read

                        // проверка что  в последнее время ничего не отправлялось

                        // R1:=  (CountWritedForReadGet>0);
                       {
                        это лишнее я могу отправлять мальнькие сообщения но

                        ответ должен также быстро придти и выполнится read иначе read  или уже работает т.е юзер сюда отправляет длинное сообщение или он отправляет в никуда и read здесь ждет то ждем таймер и close

                        проблема была найдена при прослушке трафика через fiddler с проксями

                        на непонятных фидлеру протоколах соединений остается открытым. сервер отправляет пинги а фидлер не знает что отправить отбратно
                       }

                        bsReadHeartBeat(R); // в детях можно написать свой пинг понг что бы поддерживать соединение
                        log('ReadHeartBeat '+Counter.ToString);

                        if R {or R1} then
                        begin
                          //чето отправляется  или отравлялось недавно  - ( отравлялось недавно не актуально только что сейчас отправляется)

                          if Counter<>0 then
                          Counter:=0;
                          continue;
                        end;



                        inc(Counter);
                        if Counter>SecTimeOut then
                        break;   //за последнее 150 sec не было ни одного нового байта   разрыв связи

                    end
                    else
                    begin
                         R:=bsReadLongTimeOut(FSaveReadTimeOutMs);
                         if  not R then
                         begin
                           log('ErrorReadTimeOut');
                           break;
                         end;
                    end;
             end;




          end;
        finally
           bsReadEnd;
        end;

     except
      on e:exception do
      begin
        bsReadParam.xIsValid:=false;
        log('Error TAmIoMsg_Base.bsReadProcessServer '+e.Message,e);
      end;
     end;
  finally
    Close;
   // log('bsReadProcessMain Finish');
  end;

end;

function TAmIoMsg_Base.bsReadReable(TimeOut:integer):boolean;
begin
   Result:=TAmIoBase(IO).InputBuffer.Size>0 ;
   if Result then exit()
   else
   Result:=Io.Readable(TimeOut);
  // CheckForDisconnect;

end;
function TAmIoMsg_Base.bsReadByte():byte;
var ABuffer:TidBytes;
begin
    bsReadBytes(ABuffer,1);
    Result:= ABuffer[0];
end;
procedure TAmIoMsg_Base.bsReadBytes(var ABuffer:TidBytes; const ACountBytes:integer);
var R:boolean;

  procedure Loc_Sleep(ms:integer);
  begin
    if ms>0 then
    TThread.Sleep(ms);
  end;
  function  Loc_CanExtract:boolean;
  begin
     // хватает ли байт в буфере что бы заполнмть ABuffer ACountBytes
     Result:= TAmIoBase(IO).InputBuffer.Size>=ACountBytes;
     if not Result then
     Loc_Sleep(0);

  end;
begin
             // здесь идет получение новыых данных

             if ACountBytes<=0 then
             raise Exception.Create('ErrorCountBytes<=0');
             while not Loc_CanExtract do
             begin
               // 500 ms  быстрая проверка есть ли новые данные без ошибки тайм аута

               R:= TAmIoBase(IO).ReadFromSource(false,500,false)>0;
               if R then  continue
               else
               begin
                 // время ожидания 500ms  выщло и новых данных нет то ждем 150 сек  вдруг интернет у юзера плохой

                 CheckForDisconnect;

                 // если поток отправяет что то в сокет то не входить в  одидание bsReadLongTimeOut

                 // вот ситуация данные еще не пришли а вот мы отправляем что то. а у юзера интернет плохой

                 //он чето принимает раз отправка идет а вот сам он сюда отправить не может

                 // если write выдаст ощибку то соединение закроется и здесь тригер сработает  на выход


               //  R:= TAmIoBase(IO).ReadFromSource(false,ATimeOutRead2,false)>0;
                 R:=bsReadLongTimeOut(FSaveReadTimeOutMs);
                 if R then continue
                 else  raise Exception.Create('ErrorReadTimeOut');

                 // время ожидания 150 сек вышло обрываем соединение мы же данные ждем а их нет

                 // сообщение не получено полностью причиана или не верный код определения размера фрейма

                 // или сообщения или данные где-то застряли по пути например из-за потери интернета )

               end;
             end;

             // сюда мы придем если в InputBuffer достаточно байт что бы заполнить желаймое количество ACountBytes
             IO.InputBuffer.ExtractToBytes(ABuffer, ACountBytes, false);
end;
function TAmIoMsg_Base.bsReadBytesTry(var ABuffer:TidBytes; const ACountBytes:integer):boolean;
begin
          Result:=true;
          try
           bsReadBytes(ABuffer,ACountBytes);
          except
           on e :exception do
           begin
            log('Error TAmIoMsg_Base.bsReadFrameLogic.bsReadBytesTry '+e.Message,e);
            bsReadParam.xIsValid:=false;
            Result:=false;
           end;
          end;
end;

function TAmIoMsg_Base.bsReadFrameLogic():boolean;
var ABuffer:TidBytes;
var ACount64Ost:int64;
var ACountWrite,ASize:integer;
begin
     Result:=false;
     bsReadParam.Clear_Frm;
     bsReadParam.frmSize:= bsReadFrameGetSize;


    // размер сообщения получен и  в bsReadSizeStream  и в bsReadFrameGetSize
    // фрейм это внутренняя структуризация msg
    // поэтому и  bsReadSizeStream <>=0  допустимо
    // так и  bsReadFrameGetSize <>=0  допустимо
    // но одновременно и то и то не может быть <0
    // если вернуть <0 код считает что то или иное не используется

    if (bsReadParam.frmSize<0)
    and (bsReadParam.msgSize<0) then
    raise Exception.Create('Error TAmIoMsg_Base.bsReadFrameLogic Invalid Size Msg and Frame ');

     bsReadParam.frmNum:= bsReadParam.frmNum+1;
     bsReadParam.frmNum:= bsReadParam.frmNum+1;

     // в событии можно поменять стрим куда сохраниять полученное
     // это альтернатива bsDoBeforeReadMsg
     // web soket использует фреймы а другие нет
     bsDoBeforeReadFrm(bsReadParam);
     try

         if bsReadParam.frmSize<0 then
         begin
             //когда дело имеем с  bsReadParam.msgSize >=0
             // msgSize узнается еше до вызова текушей процедуры в потомках эт же базовый класс логики
             ACount64Ost:=  int64(bsReadParam.msgSize - bsReadParam.msgCountBytesExp);
         end
         else
         begin
           //когда дело имеем с  фремами >=0  например вебсокет
           ACount64Ost:= bsReadParam.frmSize;
         end;

         if ACount64Ost<0 then
         raise Exception.Create('Error TAmIoMsg_Base.bsReadFrameLogic Invalid Size Msg and Frame2 ');

         repeat
            // даже если  ACount64Ost = 0 то один раз пройти код

             // Asize может быть только integer но ни как не Int64 т.к   const_buffer_size < Integer.maxValue
             ASize:= integer(    min(Int64(const_buffer_size),ACount64Ost)  );

            bsDoBeforeReadBlc(bsReadParam);
            try

                 if (bsReadParam.frmSize > 0) or (bsReadParam.msgSize>0) then
                 begin
                   // можно читать с буффера только если тело не пустое
                   // и не в процессе оно стало пустое а до чтения
                   if  not bsReadBytesTry(ABuffer,ASize)then exit;
                   if  not bsReadParam.xIsValid then exit;
                 end;


                 // в этой proc буффер может быть изменен перед записью в bsReadParam.msg_Stream
                 bsReadFrameDecoder(ABuffer,ASize);


                 ACountWrite:=bsReadParam.msg_Stream.Write(TBytes(ABuffer),ASize);
                 if ACountWrite<>ASize then
                 begin
                 bsReadParam.xIsValid:=false;
                 raise Exception.Create('Error TAmIoMsg_Base.bsReadFrameLogic.Stream.Write ACountWrite<>ASize');
                 end;

                // bsReadParam.msg_Stream.position:= bsReadParam.msg_Stream.Size;

                // некcт 2 строки значения могут быть разными т.к фрейм эт часть msg
                 bsReadParam.msgCountBytesExp:= bsReadParam.msgCountBytesExp + ASize ;
                 bsReadParam.frmCountBytesExp:= bsReadParam.frmCountBytesExp + ASize ;

                 if bsReadParam.frmSize<0 then
                 begin
                    ACount64Ost:= bsReadParam.msgSize - bsReadParam.msgCountBytesExp;

                    if ACount64Ost=0 then
                    bsReadParam.frmIsLast:=true;

                 end
                 else
                 begin
                    ACount64Ost:=ACount64Ost - ASize;

                  //  if (ACount64Ost= 0) and  not bsReadParam.frmIsLast then
                   // raise Exception.Create('Error TAmIoMsg_Base.bsReadFrameMain not frmIsLast должен установится в потомке');


                    //bsReadParam.frmIsLast:=true;
                    // должен установится в потомке
                    // т.к  может быть такое сообщение  [Frame,Frame,Frame,LastFrame]
                    // если bsReadParam.frmIsLast:=true не установить то код впадет в бесконечный цикл получения новых фреймов
                    // и будет считать что это все одно и тоже сообщение протсто новый его фрейм
                    // отсюда следует что если та сторона не верно выстовляет и вообще забыла поставить LastFrame=true
                     // то тут будет бесконечный цикл получения новых фреймов и запись их в одно сообщение
                 end;

                 if ACount64Ost<0 then
                 raise Exception.Create('Error TAmIoMsg_Base.bsReadFrameMain нарушение '+
                 'порядка байтов получено больше чем отправлено');

                 Result:=  bsReadParam.frmIsLast;
                 bsReadParam.StatisticsProcess(false);
                 bsDoProcessReadMsg(bsReadParam);

                 if bsReadParam.xIsAbort
                 or not bsReadParam.xIsValid then  break;

            finally
              bsDoAfterReadBlc(bsReadParam);
            end;


         until ACount64Ost<=0 ;


     finally
       bsDoAfterReadFrm(bsReadParam);
     end;
   //  Log('LogRead:'+bsReadParam.msg_Stream.Size.ToString);
end;
function TAmIoMsg_Base.bsReadStream():boolean;
begin
     Result:=false; //удачино ли прочитали
     if not Assigned(bsReadParam.msg_Stream) then exit;
     bsReadParam.frmIsLast:=false;
     while not bsReadParam.frmIsLast do
     begin


       //.....................................
       bsReadParam.frmIsLast:=bsReadFrameLogic();
       //.....................................

      if bsReadParam.xIsAbort
      or not bsReadParam.xIsValid then
      begin
        log('прервана чтение Close');
        Close;
        exit();
      end;

     end;
     Result:=  bsReadParam.frmIsLast;
end;
function TAmIoMsg_Base.bsReadStreamTry():boolean;
begin

    try
      Result:= bsReadStream;
    except
     on e:Exception do
     begin
      Result:=false;
      log('Error TAmIoMsg_Base.bsReadStreamTry ',e);
     end;
    end;
end;
function TAmIoMsg_Base.bsReadSizeStream():int64;
begin
   Result:=-1; //-1 не используется
end;
procedure TAmIoMsg_Base.bsReadProcessServer();
begin
    bsReadProcessMain(const_read_timeout,true);
end;
procedure TAmIoMsg_Base.bsReadProcessClient();
begin
   bsReadProcessMain(const_read_timeout,false);
end;
function TAmIoMsg_Base.bsReadCanNextMessage(TimeOut:integer):boolean;
begin
  Result:= self.bsReadReable(TimeOut);
end;
function TAmIoMsg_Base.bsReadNextMessage():integer;
var ASize:int64;

begin
  Result:=0;
   self.LockRead;
  try
     try

        bsReadParam.Clear_Msg;
        ReadStreamDef.Clear;

        ASize:= bsReadSizeStream;
        if ASize > 4000000000 then
        begin
          raise Exception.Create('Error TAmIoMsg_Base.bsReadNextMessage Size Message > 4 гигов');
        end;



        bsReadParam.msgSize:= ASize;
        bsReadParam.xIsValid:=true;
        bsReadParam.StatisticsStart;
        bsReadParam.StatisticsProcess(true);

        bsDoBeforeReadMsg(bsReadParam);

        // после события проверим msg_Stream и если его нет то установим по умолчанию буффер
        if Not Assigned(bsReadParam.msg_Stream) then
        bsReadParam.msg_Stream:= ReadStreamDef;



        try
           //.....................................
           bsReadParam.xIsValid:= bsReadStreamTry;
           Result:= bsReadParam.xIsValid.ToInteger;
           //.....................................
          // TEST;
        finally
          bsReadParam.StatisticsProcess(true);
          try
            bsDoAfterReadMsg(bsReadParam);
          finally
              bsReadParam.StatisticsEnd;


              // после события bsDoAfterReadMsg
              // проверим msg_Stream если он есть и это не буффер поумолчанию по удалим этот стрим
              // т.е я если не хочу что бы мой стрим удалился должен
              // msg_Stream в событии привратить в nil
              if Assigned(bsReadParam.msg_Stream)
              and (bsReadParam.msg_Stream<>ReadStreamDef) then
              bsReadParam.msg_Stream.Free;


              bsReadParam.msg_Stream:=nil;
              bsReadParam.Clear_Msg;
              ReadStreamDef.Clear;
          end;
        end;

     except
      on e:exception do
      begin
        bsReadParam.xIsValid:=false;
        log('Error TAmIoMsg_Base.bsReadNextMessage '+e.Message,e);
      end;
     end;


  finally
    self.UnLockRead;
  end;






end;
procedure TAmIoMsg_Base.bsDoBeforeReadMsg(Param:TAmIoMsgParamRead_Base);
begin
    if Assigned(FOnBeforeReadMsg) then
    FOnBeforeReadMsg(Self,Param);
end;
procedure TAmIoMsg_Base.bsDoAfterReadMsg(Param:TAmIoMsgParamRead_Base);
begin
    if Assigned(FOnAfterReadMsg) then
    FOnAfterReadMsg(Self,Param);
end;
procedure TAmIoMsg_Base.bsDoProcessReadMsg(Param:TAmIoMsgParamRead_Base);
begin
    if Assigned(FOnProcessReadMsg) then
    FOnProcessReadMsg(Self,Param);
end;

procedure TAmIoMsg_Base.bsDoBeforeReadFrm(Param:TAmIoMsgParamRead_Base);
begin
    if Assigned(FOnBeforeReadFrm) then
    FOnBeforeReadFrm(Self,Param);
end;
procedure TAmIoMsg_Base.bsDoAfterReadFrm(Param:TAmIoMsgParamRead_Base);
begin
    if Assigned(FOnAfterReadFrm) then
    FOnAfterReadFrm(Self,Param);
end;
procedure TAmIoMsg_Base.bsDoBeforeReadBlc(Param:TAmIoMsgParamRead_Base);
begin
    if Assigned(FOnBeforeReadBlc) then
    FOnBeforeReadBlc(Self,Param);
end;
procedure TAmIoMsg_Base.bsDoAfterReadBlc(Param:TAmIoMsgParamRead_Base);
begin
    if Assigned(FOnAfterReadBlc) then
    FOnAfterReadBlc(Self,Param);
end;
procedure TAmIoMsg_Base.LockRead;
begin
    CsRead.Enter;
end;
procedure TAmIoMsg_Base.UnLockRead;
begin
   CsRead.Leave;
end;


                      {write base}


procedure TAmIoMsg_Base.bsWriteFrameDirect(var  Buf: TIdBytes; const Count:integer);
var


  LSize: Integer;
  LByteCount: Integer;
  LLastError: Integer;

begin
  // Check if disconnected
  // exit;
 self.LockWrite;
 try
   try

      CheckForDisconnect;

      LSize := Count;
     // LPos := 0;

      while LSize > 0 do
      begin
         try
          LByteCount := TAmIoBase(IO).WriteDataToTarget(Buf,0, LSize);
         except
           on e: exception do
           begin
             LinkWriteParam.xIsValid:=false;
             log('Error TAmIoMsg_Base.WriteDataToTarget '+e.Message,e);
             break;
           end;

         end;
        if LByteCount < 0 then
        begin
          LLastError := TAmIoBase(IO).CheckForError(LByteCount);
          if LLastError <> Id_WSAETIMEDOUT then begin
            TAmIoBase(IO).FClosedGracefully := True;
            Close;
          end;
          TAmIoBase(IO).RaiseError(LLastError);
        end;


        // can be called more. Maybe a prop of the connection, MaxSendSize?

        if LByteCount = 0 then begin
          TAmIoBase(IO).FClosedGracefully := True;
        end;
        // Check if other side disconnected
        CheckForDisconnect;
        //IO.DoWork(wmWrite, LByteCount);

       // Inc(LPos, LByteCount);
        Dec(LSize, LByteCount);
      end;
      if Assigned(LinkWriteParam) then
      LinkWriteParam.xIsValid:=true;
   except
     on e: exception do
     begin
       log('Error TAmIoMsg_Base.bsWriteFrameDirect '+e.Message,e);
       if Assigned(LinkWriteParam) then
       LinkWriteParam.xIsValid:=false;
     end;

   end;
 finally
   self.UnLockWrite;
 end;
end;
procedure TAmIoMsg_Base.bsWriteFrameCoder(var Buf:TIdBytes;const Count:integer);
begin
           //здесь можно закодиторать фрейм и отправить  в bsWriteFrameDirect
          bsWriteFrameDirect(Buf,Count);
end;
procedure TAmIoMsg_Base.bsWriteFrameLogic(var  ABuffer:TIdBytes;const Count:integer);
var ABuf:TIdBytes;
begin

    LinkWriteParam.Clear_Frm;
    LinkWriteParam.frmSize:= Count;
    LinkWriteParam.frmNum:=LinkWriteParam.frmNum+1;
    LinkWriteParam.frmIsLast:= LinkWriteParam.msgSize = LinkWriteParam.msgCountBytesExp + Count;


    SetLength(ABuf,Count);
    if Count>0 then
    Move(ABuffer[0], ABuf[0], Count);



    bsDoBeforeWriteFrm(LinkWriteParam);
    try

                   try
                    bsWriteFrameCoder(ABuf,Count);


                   except
                     on e: exception do
                     begin
                       log('Error TAmIoMsg_Base.bsWriteFrameCoder '+e.Message,e);
                       LinkWriteParam.xIsValid:=false;
                     end;

                   end;

                   if LinkWriteParam.xIsValid then
                   LinkWriteParam.FrmCountBytesExp := LinkWriteParam.FrmCountBytesExp + Count;
    finally
      bsDoAfterWriteFrm(LinkWriteParam);
    end;



end;
procedure TAmIoMsg_Base.bsWriteSizeStream(AValue:Int64;Param:TAmIoMsgParamWrite_Base);
begin
end;


procedure TAmIoMsg_Base.bsWritePartStream(DataHead,DataMain:TStream;Param:TAmIoMsgParamWrite_Base);
var
  LBuffer: TIdBytes;
  LStream:TStream;
  LStreamSize:int64;
//  LStreamPos: TIdStreamSize;
  LBufSize: Integer;

  // LBufferingStarted: Boolean;
begin
   try
         if not Assigned(DataMain) then
         raise Exception.Create('Error TAmIoMsg_Base.bsWritePartStream DataMain=nil');

         LockWrite;
         try
            LinkWriteParam:= Param;
            CountWritedForReadInc;


            if Assigned(DataHead) then
            begin
              DataHead.Position:=0;
              DataMain.Position:=0;
              Param.msgSize:= DataHead.Size + DataMain.Size;
              LStream:= DataHead;

            end
            else
            begin
              Param.msgSize:= DataMain.Size;
              DataMain.Position:=0;
              LStream:= DataMain;
            end;

            Param.msgCountBytesExp:=0;
            LStreamSize:= Param.msgSize;





            Param.StatisticsStart;
            Param.StatisticsProcess(true);
            bsDoBeforeWriteMsg(Param);
            try
              Param.xIsValid:=false;
              bsWriteSizeStream(LStreamSize,Param);

              LBufSize:=  Integer( Min(Int64(const_buffer_size),LStreamSize) );


              SetLength(LBuffer,LBufSize);
              repeat
                     //  xIsValid := false   и в bsWriteFrameDirect xIsValid:= true
                     Param.xIsValid:=false;
                     LBufSize:=  Integer( Min(Int64(const_buffer_size),LStreamSize) );
                    // Do not use ReadBuffer. Some source streams are real time and will not
                    // return as much data as we request. Kind of like recv()
                    // NOTE: We use .Size - size must be supported even if real time

                    if LBufSize>0 then
                    LBufSize := LStream.Read(TBytes(LBuffer), LBufSize);


                    if LBufSize <= 0 then begin
                      if LStream = DataHead then
                      begin
                         LStream:= DataMain;
                         continue;
                      end
                      else if (Param.msg_whop <> Param.msg_whop_head) then
                      raise Exception.Create('Error TAmIoMsg_Base.bsWritePartStream LBufSize=0');
                    end;

                    try
                      bsWriteFrameLogic(LBuffer,LBufSize);
                    except
                     on e: exception do
                     begin
                       Param.xIsValid:=false;
                       log('Error TAmIoMsg_Base.bsWriteFrameLogic '+e.Message,e);
                     end;

                    end;

                    if Param.xIsValid then
                    begin
                      Param.msgCountBytesExp := Param.msgCountBytesExp + LBufSize;
                      Param.StatisticsProcess(false);
                      bsDoProcessWriteMsg(Param);
                    end;


                    if Param.xIsAbort
                    or not Param.xIsValid then
                    begin
                     log('прервана отправка Close');
                     Close;
                     break;
                    end;


                   Dec(LStreamSize, LBufSize);

              until LStreamSize <= 0;

            finally
              //IO.EndWork(wmWrite);
              Param.StatisticsProcess(true);
              bsDoAfterWriteMsg(Param);
              Param.StatisticsEnd;
            //  LBuffer := nil;
            end;
         finally
           LinkWriteParam:= nil;
           UnLockWrite;
         end;



   except
     on e: exception do
     begin

       log('Error TAmIoMsg_Base.bsWritePartStream '+e.Message,e);
       Param.xIsValid:=false;
     end;

   end;
end;

procedure TAmIoMsg_Base.bsWriteOpenStream(Param:TAmIoMsgParamWrite_Base);
var R:boolean;
   function Loc_IsBadParam :boolean;
   begin
           Result:= not Assigned(Param) or  not  Assigned(Param.msg_Stream);
           if Result then exit;

           Result:= not (Param.msg_whop in
           [Param.msg_whop_stream ,Param.msg_whop_file ,
           Param.msg_whop_string,Param.msg_whop_head ]);

           if Result then exit;

           Result:= (Param.msg_Stream.Size=0) and (Param.msg_whop<>Param.msg_whop_head);

           if Result then exit;


   end;
begin
   try
      LockWrite;
      try

           R:= Loc_IsBadParam;
           Param.xIsValid:= not R;
           if not Param.xIsValid
           or  Param.xIsAbort then exit;




           if Assigned(Param.msg_StreamHead)
           and (Param.msg_StreamHead.Size>0) then
           begin

             if Param.msg_W2 then
             begin
               bsWritePartStream(nil,Param.msg_StreamHead,Param);
               bsWritePartStream(nil,Param.msg_Stream,Param);
             end
             else
               bsWritePartStream(Param.msg_StreamHead,Param.msg_Stream,Param);
           end
           else
              bsWritePartStream(nil,Param.msg_Stream,Param);

      finally
         UnLockWrite;
      end;
   except
     on e: exception do
     begin
       log('Error TAmIoMsg_Base.bsWriteOpenStream '+e.Message,e);
       Param.xIsValid:=false;
     end;

   end;
end;
procedure TAmIoMsg_Base.bsWriteOpenFile(FileName:String;Param:TAmIoMsgParamWrite_Base);
var Strm:TFileStream;
begin
   try
      LockWrite;
      try
        if  not AmFileIsFreeRead(FileName) then
        begin
          Param.xIsValid :=false;
          exit;
        end;
        Strm:=  TFileStream.Create(FileName,fmOpenRead);
        try
            Param.msg_Stream:= Strm;
            bsWriteOpenStream(Param);
        finally
          Param.msg_Stream:=nil;
          Strm.free;
        end;
      finally
         UnLockWrite;
      end;
   except
     on e: exception do
     begin
       Param.xIsValid:=false;
       log('Error TAmIoMsg_Base.bsWriteOpenFile '+e.Message,e);
     end;

   end;
end;
procedure TAmIoMsg_Base.bsWriteOpenStr(Source:String;Param:TAmIoMsgParamWrite_Base);
var ms:TMemoryStream;
begin
   try
      LockWrite;
      try
          if  length(Source)=0 then
          begin
            Param.xIsValid :=false;
            exit;
          end;



          ms:=TMemoryStream.Create;
          try
             Param.msg_Stream:= ms;
             AmStream.StrToSteam(Param.msg_Stream,Source);
             bsWriteOpenStream(Param);
          finally
             ms.Free;
             Param.msg_Stream:=nil;
          end;
      finally
         UnLockWrite;
      end;
   except
     on e: exception do
     begin
       Param.xIsValid:=false;
       log('Error TAmIoMsg_Base.bsWriteOpenStr '+e.Message,e);
     end;

   end;
end;
procedure TAmIoMsg_Base.bsWriteOpenHead(Param:TAmIoMsgParamWrite_Base);
var ms:TMemoryStream;
begin
   try
      LockWrite;
      try
          ms:=TMemoryStream.Create;
          try
             Param.msg_Stream:= ms;
             bsWriteOpenStream(Param);
          finally
             ms.Free;
             Param.msg_Stream:=nil;
          end;
      finally
         UnLockWrite;
      end;
   except
     on e: exception do
     begin
       Param.xIsValid:=false;
       log('Error TAmIoMsg_Base.bsWriteOpenHead '+e.Message,e);
     end;

   end;

end;
procedure TAmIoMsg_Base.bsWriteParamStart(Param:TAmIoMsgParamWrite_Base);
var Result:integer;
 procedure Loc_In;
 begin
   Param.CS.Enter;
   try
      Param.FResultWrite:=0;
      Param.xIsProcess:=true;
   finally
      Param.CS.Leave;
   end;
 end;
 procedure Loc_Out;
 begin
   Param.CS.Enter;
   try
      Param.FResultWrite:=Result;
      Param.xIsProcess:=false;
      Param.xIsWasProcess:=true;
   finally
      Param.CS.Leave;
   end;
 end;
begin

  LockWrite;
  try
    Result:=0;
    Loc_In;
    try

         try
           if not Param.xIsValid or Param.xIsAbort then
           begin
               Result:=-2; //или отмена была или не валид параметры или др проблемы сети
               exit;
           end;

           try
              case Param.msg_whop of


                  Param.msg_whop_stream    : bsWriteOpenStream(Param);
                  Param.msg_whop_file      : bsWriteOpenFile(Param.msg_File,Param);
                  Param.msg_whop_string    : bsWriteOpenStr(Param.msg_Str,Param);
                  Param.msg_whop_head      : bsWriteOpenHead(Param);
                  else Result:=-3; //не указано что нужно отправить
              end;

           except
             on e: exception do
             begin
               Result:=-1; //внутренняя ошибка кода сбой в отправке
               log('Error TAmIoMsg_Base.bsWriteParamStart2 '+e.Message,e);
             end;

           end;

          if Param.FResultWrite=0 then
          begin
               if Param.xIsValid and  not  Param.xIsAbort and Param.frmIsLast then
                     Result:= 1  //все было отправлено в сокет
               else  Result:=-2; //или отмена была или не валид параметры или др проблемы сети
          end;

         except
           on e: exception do
           begin
             Result:=-1; //внутренняя ошибка кода сбой в отправке
             log('Error TAmIoMsg_Base.bsWriteParamStart '+e.Message,e);
           end;

         end;

    finally
       Loc_Out;
    end;



  finally
     UnLockWrite;
  end;
end;
function TAmIoMsg_Base.bsWriteCheckParam(Param:TAmIoMsgParamWrite_Base):boolean;
 var r1,r2,r3,r4:boolean;
 function loc_strm:boolean;
 begin
   Result:= Assigned(Param.msg_Stream) and (Param.msg_Stream.Size>0);


 end;
 function loc_file:boolean;
 begin
    Result:= Param.msg_File<>'';
 end;
 function loc_str:boolean;
 begin
     Result:= Param.msg_Str<>'';
 end;
begin
  // виртуальная функция потомки могут перекрыть эту проверку
   Result:=false;
   if not Assigned(Param) then  exit;

   r1:=loc_strm;
   r2:=loc_file;
   r3:=loc_str;
   r4:= Param.msg_Head;

   if r1 then        Param.msg_Whop:=Param.msg_whop_stream
   else if r2 then   Param.msg_Whop:=Param.msg_whop_file
   else if r3 then   Param.msg_Whop:=Param.msg_whop_string
   else if r4 then   Param.msg_Whop:=Param.msg_whop_head;


   Result:=  r1 or r2 or  r3 or r4;
end;
function TAmIoMsg_Base.bsWriteParam(Param:TAmIoMsgParamWrite_Base;IsThread :boolean = true):int64;
begin

 Result:=0;
 LockWritePre;
 try
   if not bsWriteCheckParam(Param) then  exit;

   if IsThread then
   Result:=ThreadWrite.ParamWrite(Param)
   else
   begin
     bsWriteParamStart(Param);
     Result:= Param.ResultWrite;
   end;
 finally
   UnLockWritePre;
 end;

end;
function TAmIoMsg_Base.bsWriteSimple(Stream:TStream;FileName,SourceString:String; IsThread :boolean = true):int64;
var Param:TAmIoMsgParamWrite_Base;
begin
   Result:=0;
   LockWritePre;
   try
     // создание класса параметров которые соответсвуют типу потомка TAmIoMsg_Base
     // если бы в websockete находились то было бы просто
     // TAmIoMsgParamWrite_WebSocket.Create
     Param:= ClassParamWrite.Create;
     try

         if Assigned(Stream) and (Stream.Size>0) then
         begin
           Param.msg_Stream:= Stream;
           Param.msgSize:=  Stream.Size;
         end
         else if FileName<>'' then
          Param.msg_File:=  FileName
         else if SourceString<>'' then
           Param.msg_Str:=  SourceString
         else exit;

         // пустое msg через bsWriteSimple нельзя отправить только через bsWriteParam установив Param.msg_Head=true
         // но потомки могут если у них это предусморенно в своих каких то функциях

         Param.xIsValid:=true;
         Result:=bsWriteParam(Param,IsThread);
     finally


         // т.к здесь параметры создали то и здесь их удалить нужно
         // если в поток отправяли то не нужно удалять т.к поток сам их удалит когда закончит
         // но если Result = 0 значит дело до потока не дошло и нужнно здесь удалить
         if not IsThread
         or (Result = 0) then
         begin
           Param.msg_Stream:= nil;
           Param.Free;
         end;
     end;
   finally
     UnLockWritePre;
   end;
end;
function TAmIoMsg_Base.bsPingWriteCustom(msg:String;cmd:Int64):Int64;
begin
   LockWritePre;
   try
      Result:= bsPingWrite(msg,cmd);
   finally
    UnLockWritePre;
   end;
end;
function TAmIoMsg_Base.bsPongWriteCustom(msg:String;cmd:Int64):Int64;
begin
   LockWritePre;
   try
      Result:= bsPongWrite(msg,cmd);
   finally
    UnLockWritePre;
   end;
end;
function  TAmIoMsg_Base.bsWriteListIndexOf(AId:int64):TAmIoMsgParamWrite_Base;
begin
   Result:= nil;
   if not Assigned(ThreadWrite) or (AId<=0) then exit;
   Result:=ThreadWrite.ParamIndexOf(AId);
end;
procedure TAmIoMsg_Base.bsWriteListAbortAll();
begin
   if not Assigned(ThreadWrite) then exit;
   ThreadWrite.ParamAbortAll;
end;
function  TAmIoMsg_Base.bsWriteListLock:TAmList<TAmIoMsgParamWrite_Base>;
begin
   Result:= nil;
   if not Assigned(ThreadWrite) then exit;
   ThreadWrite.CsList.Enter;
   Result:= ThreadWrite.ListParam;
end;
procedure TAmIoMsg_Base.bsWriteListUnlock;
begin
   if not Assigned(ThreadWrite) then exit;
   ThreadWrite.CsList.Leave;
end;

procedure TAmIoMsg_Base.bsDoBeforeWriteMsg(Param:TAmIoMsgParamWrite_Base);
begin

    if Assigned(FOnBeforeWriteMsg) then
    FOnBeforeWriteMsg(Self,Param);
end;
procedure TAmIoMsg_Base.bsDoAfterWriteMsg(Param:TAmIoMsgParamWrite_Base);
begin
    if Assigned(FOnAfterWriteMsg) then
    FOnAfterWriteMsg(Self,Param);
end;
procedure TAmIoMsg_Base.bsDoProcessWriteMsg(Param:TAmIoMsgParamWrite_Base);
begin
    if Assigned(FOnProcessWriteMsg) then
    FOnProcessWriteMsg(Self,Param);
end;

procedure TAmIoMsg_Base.bsDoBeforeWriteFrm(Param:TAmIoMsgParamWrite_Base);
begin
    if Assigned(FOnBeforeWriteFrm) then
    FOnBeforeWriteFrm(Self,Param);
end;
procedure TAmIoMsg_Base.bsDoAfterWriteFrm(Param:TAmIoMsgParamWrite_Base);
begin
    if Assigned(FOnAfterWriteFrm) then
    FOnAfterWriteFrm(Self,Param);
end;
procedure TAmIoMsg_Base.LockWrite;
begin
  CsWrite.Enter;
end;
procedure TAmIoMsg_Base.UnLockWrite;
begin
  CsWrite.Leave;
end;
procedure TAmIoMsg_Base.LockWritePre;    //
begin
   CsWritePre.Enter;
end;
procedure TAmIoMsg_Base.UnLockWritePre;
begin
   CsWritePre.Leave;
end;

                 {TAmIoThreadWrite  поток для write в асинхронном режиме}
constructor TAmIoThreadWrite.Create(AEventProc:TProcEvent);
begin
    if not  Assigned(AEventProc) then
    raise Exception.Create('Error TAmIoThreadWrite.Create AEventProc=nil');

    inherited  Create(INFINITE);
    FProcEvent:= AEventProc;
    FList:=TAmList<TAmIoMsgParamWrite_Base>.create;
    FCS:= TAmCs.Create;
    CounterId:=0;
end;
destructor  TAmIoThreadWrite.Destroy;
begin
   ParamAbortAll;

   if self.Suspended then self.Resume;
   self.Terminate;
   self.WaitFor;

   ParamFreeAll;
   FProcEvent:=nil;
   inherited Destroy;
   FreeAndNil(FList);
   FreeAndNil(FCS);
end;
function TAmIoThreadWrite.ParamWrite(Param:TAmIoMsgParamWrite_Base):int64;
var r:boolean;
begin
    Result:=0;
    r:= self.PostMessageThread(CONST_NOTIFY_EVENT,0,0);
    if not r then  exit;

    CsList.Enter;
    try

        inc(CounterId);
        ListParam.Add(Param);
        Result:= CounterId;
        Param.FWriteID:=Result;
        Param.FIsThread:=true;
    finally
     CsList.Leave;
    end;

    r:= self.PostMessageThread(CONST_PROC_EVENT,0,LPARAM(Param));
    if not r then
    begin
        CsList.Enter;
        try
        dec(CounterId);
        finally CsList.Leave; end;
        ParamFree(Param);
        Result:=-1;
    end

end;
procedure TAmIoThreadWrite.ParamAbort(Param:TAmIoMsgParamWrite_Base);
begin
   Param.xIsAbort:=true;
end;
function TAmIoThreadWrite.ParamFree(Param:TAmIoMsgParamWrite_Base):int64;
begin
    Result:=0;
    if not Assigned(Param) or (Param.xIsDestoy<>Word.MaxValue)  then  exit;

    CsList.Enter;
    try
        Result:=ListParam.Remove(Param);

        if  not Param.ExpCallBack then
        FreeAndNil(Param);

    finally
     CsList.Leave;
    end;
end;
function TAmIoThreadWrite.ParamFreeAll():int64;
var i:integer;
begin
    CsList.Enter;
    try
        Result:=  ListParam.Count;
        for I := 0 to ListParam.Count-1 do
        begin
          ListParam[i].xIsAbort:=true;
          ListParam[i].xIsValid:=false;
          if  not ListParam[i].ExpCallBack then
          ListParam[i].Free;
        end;
        ListParam.Clear;
    finally
     CsList.Leave;
    end;
end;
function TAmIoThreadWrite.ParamGetCountListIsValid():integer;
var i:integer;
begin
    Result:= 0;
    CsList.Enter;
    try
        for I := 0 to ListParam.Count-1 do
        begin
          if not ListParam[i].xIsAbort and  ListParam[i].xIsValid then
          inc(Result);
        end;
    finally
     CsList.Leave;
    end;
end;
function TAmIoThreadWrite.ParamAbortAll():int64;
var i:integer;
begin
    CsList.Enter;
    try
        Result:=  ListParam.Count;
        for I := 0 to ListParam.Count-1 do
        begin
          ListParam[i].xIsAbort:=true;
          ListParam[i].xIsValid:=false;
        end;
    finally
     CsList.Leave;
    end;
end;
function TAmIoThreadWrite.ParamIndexOf(AId:Int64):TAmIoMsgParamWrite_Base;
var i:integer;
begin
    Result:=nil;
    CsList.Enter;
    try

        for I := 0 to ListParam.Count-1 do
        begin
          if ListParam[i].WriteID= AId then
          begin
           Result:= ListParam[i];
           break;
          end;
        end;
    finally
     CsList.Leave;
    end;

end;
procedure TAmIoThreadWrite.xProcEvent(var Msg:TMessage); //message CONST_PROC_EVENT;
var param:TAmIoMsgParamWrite_Base;
begin

   if (Msg.LParam>0) then
   begin
       try
         param:= TAmIoMsgParamWrite_Base(Msg.LParam);
         param.FResultWrite:=0;
         try
           if Assigned(FProcEvent)  then
           FProcEvent(param);
         finally
           ParamFree(param);
         end;
       except
         on e:Exception do
         Log('ErrorCode.AmWs.ReadWrite.TAmIoThreadWrite.xProcEvent '+e.Message,e);

       end;
   end
   else Log('Error.AmWs.ReadWrite.TAmIoThreadWrite.xProcEvent Msg.LParam=0');
end;
procedure TAmIoThreadWrite.xNotifyEvent(var Msg:TMessage); //message CONST_NOTIFY_EVENT;
begin
end;










                   {TAmIoMsgParamRead_Base}
procedure TAmIoMsgParamRead_Base.Clear_Msg;
begin
    inherited Clear_Msg;
    if Assigned(msg_Stream) then
    msg_Stream.Free;

    msg_Stream:=nil;
end;
class function TAmIoMsgParamRead_Base.ClassWrite: TAmIoMsgParamWrite_Class;
begin
   Result:= TAmIoMsgParamWrite_Base;
end;
class function TAmIoMsgParamRead_Base.ClassRead: TAmIoMsgParamRead_Class;
begin
  Result:= TAmIoMsgParamRead_Base;
end;

function TAmIoMsgParamRead_Base.ParamToString(var P:string):integer;
begin
    P:='';
    Result:= 0;
    if xIsValid and  not xIsAbort then
    begin
        if Assigned(msg_Stream)
        and (msg_Stream.size>0)
        then
        begin
           if AmStream.SteamToStr(msg_Stream,P) then //200Mb
           Result:= 1
           else Result:= -1;
        end
        else Result:= -2;
    end;


end;


                   {TAmIoMsgParamWrite_Base}
procedure TAmIoMsgParamWrite_Base.Clear_Msg;
begin
    inherited Clear_Msg;
    msg_W2:=false;
    msg_Whop:=0;

    msg_File:='';
    msg_Str:='';
    msg_Head:=false;

    if Assigned(msg_StreamHead) then
    msg_StreamHead.Free;

    if Assigned(msg_Stream) then
    msg_Stream.Free;

    msg_StreamHead:=nil;
    msg_Stream:=nil;
end;
procedure TAmIoMsgParamWrite_Base.Clear;
begin
    inherited Clear;
    FResultWrite:=0;
    FWriteID:=0;
    FIsThread:=false;
    UseCallBack:=false;
    HandleCallBack.hwnd:=0;
    HandleCallBack.message:=0;
    HandleCallBack.wParam:=0;
    HandleCallBack.lParam:=0;
end;

procedure TAmIoMsgParamWrite_Base.Init;
begin
    inherited Init;
    FIsSendCallBack:=false;
end;
function TAmIoMsgParamWrite_Base.ExpCallBack:boolean;
begin
        Result:=false;
        if  UseCallBack and not FIsSendCallBack then
        begin
          if (HandleCallBack.hwnd>0)
          and (HandleCallBack.message>0) then
          Result:= postmessage(HandleCallBack.hwnd,
                            HandleCallBack.message,
                            HandleCallBack.wParam,
                            lparam(self));

          FIsSendCallBack:=true;

        end

end;
class function TAmIoMsgParamWrite_Base.ClassWrite: TAmIoMsgParamWrite_Class;
begin
    Result:=  TAmIoMsgParamWrite_Base;
end;
class function TAmIoMsgParamWrite_Base.ClassRead: TAmIoMsgParamRead_Class;
begin
   Result:=  TAmIoMsgParamRead_Base;
end;
function TAmIoMsgParamWrite_Base.GetResultWrite:integer;
begin
   Lock;
   try
      Result:=FResultWrite;
   finally
     UnLock
   end;
end;



                   {TAmIoMsgParam}
constructor TAmIoMsgParam.Create;
begin
    inherited Create;
    xIsDestoy:= word.MaxValue;
    CS:=TAmCs.Create;
    Init;
end;
destructor TAmIoMsgParam.Destroy;
begin
   xIsDestoy:= word.MaxValue-1;
   Clear;
   xIsDestoy:= word.MaxValue-2;
   inherited;
   FreeAndNil(CS);

end;

procedure TAmIoMsgParam.Clear_Msg;
begin

          msgSize:=0;
          msgCountBytesExp:=0;
          frmNum:=0;
          Clear_Frm;
end;
procedure TAmIoMsgParam.Clear_Frm;
begin
          frmSize:=0;
          frmIsLast:=false;
          frmCountBytesExp:=0;
end;
procedure TAmIoMsgParam.Clear;
begin
          xIsValid:=false;
          xIsAbort:=false;
          xIsProcess:=false;
          xIsWasProcess:=false;
          //xStatusProc:=0;
          xData:=nil;
          xComponent:=nil;
          xIndiv:=0;
          Clear_Msg;
          Clear_Frm;
end;
procedure TAmIoMsgParam.Init;
begin


    xStatistics.Init;
    xIsValid:=false;
    xIsAbort:=false;
    //xStatusProc:=0;
    xData:=nil;
    xComponent:=nil;
    xIndiv:=0;
    Clear_Msg;
    Clear_Frm;
end;
procedure TAmIoMsgParam.Lock;
begin
  CS.Enter;
end;
function  TAmIoMsgParam.TryLock:Boolean;
begin
  Result:=CS.TryEnter;
end;
procedure TAmIoMsgParam.UnLock;
begin
  CS.Leave;
end;
class function TAmIoMsgParam.ClassWrite: TAmIoMsgParamWrite_Class;
begin
   Result:= nil;
end;
class function TAmIoMsgParam.ClassRead: TAmIoMsgParamRead_Class;
begin
   Result:= nil;
end;
function TAmIoMsgParam.IsClassWrite:boolean;
var O:TObject;
begin
     O:=Self;
     if O is TAmIoMsgParamWrite_Base then  Result:= true
     else if O is TAmIoMsgParamRead_Base then Result:=false
     else raise Exception.Create('Error TAmIoMsgParam.IsClassWrite Class Invalid');
end;

function  TAmIoMsgParam.GetIsValid:boolean;
begin
    Lock;
    try
    Result:= FIsValid;
    finally
    UnLock;
    end;
end;
procedure TAmIoMsgParam.SetIsValid(v:boolean);
begin
   Lock;
   try
   FIsValid:= v;
   finally
   UnLock;
   end;
end;
function  TAmIoMsgParam.GetIsProcess:boolean;
begin
    Lock;
    try
    Result:= FIsProcess;
    finally
    UnLock;
    end;
end;
procedure TAmIoMsgParam.SetIsProcess(v:boolean);
begin
   Lock;
   try
   FIsProcess:= v;
   finally
   UnLock;
   end;
end;
function  TAmIoMsgParam.GetIsWasProcess:boolean;
begin
    Lock;
    try
    Result:= FIsWasProcess;
    finally
    UnLock;
    end;
end;
procedure TAmIoMsgParam.SetIsWasProcess(v:boolean);
begin
    Lock;
    try
    FIsWasProcess:= v;
    finally
    UnLock;
    end;
end;
function  TAmIoMsgParam.GetIsAbort:boolean;
begin
    Lock;
    try
    Result:= FIsAbort;
    finally
    UnLock;
    end;
end;
procedure TAmIoMsgParam.SetIsAbort(v:boolean);
begin
   Lock;
   try
   FIsAbort:= v;
   finally
   UnLock;
   end;
end;
procedure TAmIoMsgParam.StatisticsStart;
begin
      if xStatistics.IsNeed then
      begin
          xStatistics.Stopwatch:=TStopwatch.StartNew;
          xStatistics.Procent:=0;
          xStatistics.Speed:=0;
          xStatistics.FromEnd:=0;
          xStatistics.FromBegin:=0;
          xStatistics.Updata:=false;
          xStatistics.Stopwatch.Start;
      end;
end;
procedure TAmIoMsgParam.StatisticsEnd;
begin

     if xStatistics.IsNeed then
     begin
          xStatistics.Stopwatch.Stop;
          xStatistics.Procent:=0;
          xStatistics.Speed:=0;
          xStatistics.FromEnd:=0;
          xStatistics.FromBegin:=0;
          xStatistics.Updata:=false;
     end;
end;
procedure TAmIoMsgParam.StatisticsProcess(IgnorSleep:boolean);
  var AMs,APos,APosMax:int64;
   //s:string;
   function LocRoundInt(R:real):Integer;
   begin
     if R>Result.MaxValue then  Result:=  Result.MaxValue
     else if R<Result.MinValue then Result:=  Result.MinValue
     else Result:= round(R);
   end;
   function LocRoundReal(R:real):real;
   begin
     if R>Integer.MaxValue then  Result:=  Integer.MaxValue
     else if R<Integer.MinValue then Result:=  Integer.MinValue
     else Result:= Math.RoundTo( R , -3 );
   end;
   function GetSpeed(): real;
   var R:real;
   begin
     try
      R:=( (APos/1024) / (AMs /1000)  *8  ) / 1000;
      Result:= LocRoundReal(R);
     except
       on e :exception do
       begin
        //s:=e.message;
       Result:= 0;
       end;
     end;
   end;
   function GetTimeEnd(): integer;
   var R:real;
   begin
     try
      R:= (  (APosMax / APos)  * AMs) - AMs ;
      Result:= LocRoundInt(R);
     except
       on e :exception do
       begin
        //s:=e.message;
       Result:= 0;
       end;
     end;
   end;
begin
  if xStatistics.IsNeed then
  begin
    AMs:= xStatistics.Stopwatch.ElapsedMilliseconds;
    if IgnorSleep or (xStatistics.FromBegin < (AMs div 1000)) or  (xStatistics.FromBegin=0) then
    begin
      if AMs=0 then AMs:=1;
      APosMax:=max(msgSize,frmSize);
      APos:= msgCountBytesExp;
      if APosMax<=0 then APosMax:=1;
      if APos<=0 then APos:=1;

      xStatistics.Procent:=  LocRoundInt(APos *100 / APosMax);
      xStatistics.Speed:= GetSpeed;
      xStatistics.FromEnd:=GetTimeEnd  div 1000;
      xStatistics.FromBegin:= max(AMs div 1000,1);
      xStatistics.Updata:=true;
    end
    else xStatistics.Updata:=false;
  end;
end;

procedure TAmIoMsgParam.TStatistics.Init;
begin
    IsNeed:=false;
    Procent:=0;
    Speed:=0;
    FromEnd:=0;
    FromBegin:=0;
    Updata:=false;
end;
function TAmIoMsgParam.TStatistics.SpeedToString :string;
begin
   Result:= FormatFloat('0.0000',Speed)+' Мбит/сек.';
end;
function TAmIoMsgParam.TStatistics.FromEndToString :string;
begin
  if FromEnd>4000 then
   Result:='Время до завершения  : Примерно '+((FromEnd div 3600)+1).Tostring+' ч.'
  else if  FromEnd>120 then
   Result:='Время до завершения  : Примерно '+((FromEnd div 60)+1).Tostring+' мин.'
  else
   Result:='Время до завершения  : '+FromEnd.Tostring+' сек.';
end;
function TAmIoMsgParam.TStatistics.FromBeginToString :string;
begin
  if FromBegin>4000 then
   Result:='Время от начала  : Примерно '+(FromEnd div 3600).Tostring+' ч.'
  else if  FromEnd>120 then
   Result:='Время от начала  : Примерно '+(FromEnd div 60).Tostring+' мин.'
  else
   Result:='Время от начала  : '+FromEnd.Tostring+' сек.';
end;


end.
