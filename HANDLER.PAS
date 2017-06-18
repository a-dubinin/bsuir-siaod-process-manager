{Программа, моделирующая работу обработчика задач (процессов)
на основе очереди с приоритетом.
Разработчик - Дубинин А. В. (http://dubinin.net)}
program HANDLER;

{Подключение модуля Crt}
uses crt;

{Объявление констант}
const
    {Приращение времени процессу, который не завершился за выделенное время}
    TIME_INC = 100;

{Объявление типов}
type
    {Тип TermType - запись, описывающая процесс}
    ProcessType = record
        time: longint; {Время выполнения}
        pid: integer;  {ID процесса}
        pname: string  {Название процесса}
    end;

    {ItemAddr - указатель на элемент очереди}
    ItemAddr = ^Item;

    {Тип Item - запись, описывающая элемент очереди}
    Item = record
        process: ProcessType; {Данные текущего процесса}
        next: ItemAddr {Указатель на следующий элемент очереди}
    end;

    {Тип Queue - запись, описывающая очередь}
    Queue = record
        {front - заглавный элемент очереди,
        rear - последний элемент очереди}
        front, rear: ItemAddr
    end;

    {Тип QueueInfo - запись, описывающая основные сведения об очереди}
    QueueInfo = record
        {queueLenght - количество процессов в очереди,
        minFreePID - освободившийся PID с минимальных значением,
        maxPID - максимальное значение ID процесса в очереди}
        queueLenght, minFreePID, maxPID: integer
    end;

{Процедура перевода строки}
procedure br;
    begin
        writeln;
    end;

{Процедура вывода на всю ширину окна горизонтальной полосы}
procedure hr;
    var
        i: integer;
    begin
        for i := 1 to 79 do write('-');
        br;
    end;

{Процедура вывода посередине окна заголовка.
title - параметр-константа типа string}
procedure renderTitle(const title: string);
    var
        position: integer;
    begin
        clrscr;
        position := 79;
        if length(title) < 79 then
            position := (79 + length(title)) div 2;
        br;
        writeln(title:position);
        br;
        hr;
    end;

procedure renderKillProcessTitle;
    begin
        renderTitle('Удаление процесса из очереди');
    end;

procedure renderChangePriorityTitle;
    begin
        renderTitle('Изменение приоритета процесса');
    end;

{Процедура вывода на экран головной строки списка процессов}
procedure renderProcessListHeader;
    begin
        writeln('PID | ':9, 'Process Name', '| ':38, 'Time');
        hr;
    end;

{Процедура вывода на экран одной строки списка процессов.
process - параметр-константа типа ProcessType}
procedure renderProcessListRow(const process: ProcessType);
    begin
        with process do
            begin
                write(pid:6, ' | ');
                write(pname, ' | ':(50-length(pname)));
                write(time);
            end;
    end;

{Процедура вывода сообщения об ошибке.
pid - параметр-константа типа integer}
procedure errorNotExistsPID(const pid: integer);
    begin
        br;
        writeln('Ошибка: процесса PID ', pid, ' не существует');
    end;

{Процедура ввода значения целочисленного типа integer.
i - параметр-переменная типа integer}
procedure readIntValue(var i: integer);
    var
        x, code: integer;
        str: string;
    begin
        x := whereX;
        readln(str);
        val(str, i, code);
        if (code <> 0) or (i <= 0) then
            begin
                gotoXY(x, whereY - 1);
                clreol;
                readIntValue(i);
            end;
    end;

{Процедура ввода значения целочисленного типа longint.
i - параметр-переменная типа longint}
procedure readLongintValue(var i: longint);
    var
        x, code: integer;
        str: string;
    begin
        x := whereX;
        readln(str);
        val(str, i, code);
        if (code <> 0) or (i <= 0) then
            begin
                gotoXY(x, whereY - 1);
                clreol;
                readLongintValue(i);
            end;
    end;

{Процедура, реализующая возврат к списку операций}
procedure returnToMainMenu;
    begin
        br;
        write(' ESC - возврат к списку операций');
        repeat until readkey = #27;
    end;

{Процедура инициализации очереди и ее начальных сведений.
waiting - параметр-переменная типа Queue,
info - параметр-переменная типа QueueInfo}
procedure initQueue(var waiting: Queue; var info: QueueInfo);
    begin
        new(waiting.front);
        waiting.front^.next := nil;
        waiting.rear := waiting.front;

        {Инициализация начальных значений сведений об очереди}
        with info do
            begin
                queueLenght := 0;
                minFreePID := 0;
                maxPID := 0;
            end;
    end;

{Процедура вывода на экран очереди процессов.
waiting - параметр-переменная ссылочного типа Queue}
procedure displayProcessQueue(var waiting: Queue);
    var
        current: ItemAddr;
    begin
        renderProcessListHeader;
        current := waiting.front^.next;
        while current <> nil do
            begin
                renderProcessListRow(current^.process);
                current := current^.next;
                br;
            end;
        hr;
    end;

{Процедура добавления элемента в очередь.
waiting - параметр-переменная ссылочного типа Queue,
process - параметр-константа типа ProcessType}
procedure addItem(var waiting: Queue; const process: ProcessType);
    begin
        new(waiting.rear^.next);
        waiting.rear := waiting.rear^.next;
        waiting.rear^.process := process;
        waiting.rear^.next := nil;
    end;

{Процедура добавление нового процесса в очередь.
waiting - параметр-переменная ссылочного типа Queue,
info - параметр-переменная типа QueueInfo}
procedure insertProcess(var waiting: Queue; var info: QueueInfo);
    var
        newProcess: ProcessType;
        newPID: integer;
    begin
        renderTitle('Добавление процесса в очередь');

        {Изменение основных сведений об очереди и генерация PID,
        с последующим присвоением его вновь добавляемому процессу}
        if info.minFreePID = 0 then
            begin
                inc(info.maxPID);
                newPID := info.maxPID;
            end
        else
            begin
                newPID := info.minFreePID;
                info.minFreePID := 0;
            end;
        inc(info.queueLenght);

        {Ввод данных нового процесса}
        with newProcess do
            begin
                pid := newPID;
                write(' Название процесса: ');
                readln(pname);
                write(' Время выполнения: ');
                readLongintValue(time);
            end;

        {Добавление нового процесса в очередь}
        addItem(waiting, newProcess);

        hr;
        writeln('Процесс "', newProcess.pname, '" (PID ', newPID, ') добавлен в очередь');
    end;

{Функция изменения приоритета процесса. Возвращает:
true - при успешном изменении приоритета,
false - в случае ошибки.
waiting - параметр-переменная ссылочного типа Queue,
info - параметр-константа типа QueueInfo}
function changeProcessPriority(var waiting: Queue; const info: QueueInfo): boolean;
    var
        current: ItemAddr;
        pid: integer;
        newTime: longint;
        isChanged, notExists: boolean;
    begin
        renderChangePriorityTitle;
        displayProcessQueue(waiting);
        current := waiting.front;
        write('Изменяемый PID: ');
        readIntValue(pid);
        isChanged := false;

        {Проверка на вхождение введенного PID
        в диапазон находящися в очереди PIDs}
        if (pid > 0) and (pid <= info.maxPID) then
            begin
                notExists := false;

                {Поиск в очереди процесса с указанным PID}
                repeat
                    current := current^.next;
                    if current^.process.pid = pid then
                        isChanged := true;
                    if current = nil then
                        notExists := true;
                until (isChanged = true) or (notExists = true);

                if isChanged = true then
                    {Изменение времени выполнения у указанного процесса}
                    begin
                        br;
                        hr;
                        write(' Новое значения времени выполнения (текущее = ',current^.process.time, '): ');
                        readLongintValue(newTime);
                        current^.process.time := newTime;
                        renderChangePriorityTitle;
                        displayProcessQueue(waiting);
                        writeln('У процесса PID ', pid, ' изменен приоритет');
                    end
                else
                    errorNotExistsPID(pid);
            end
        else
            errorNotExistsPID(pid);
        changeProcessPriority := isChanged;
    end;

{Процедура удаление элемента из очереди.
(Например, в результате взятия на выполнение процесса из очереди обработчиком
или удаления процесса из очереди внешними вызовами).
waiting - параметр-переменная ссылочного типа Queue,
prev - параметр-переменная типа ItemAddr (элемент, предшествующий удаляемому)}
procedure deleteItem(var waiting: Queue; var prev: ItemAddr);
    var
        deleted: ItemAddr;
    begin
        deleted := prev^.next;
        prev^.next := deleted^.next;
        if deleted = waiting.rear then
            waiting.rear := prev;
        dispose(deleted);
    end;

{Процедура изменения сведений об очереди
в результате удаления процесса из очереди.
info - параметр-переменная типа QueueInfo,
pid - параметр-константа типа integer}
procedure changeQueueInfo(var info: QueueInfo; const pid: integer);
    begin
        dec(info.queueLenght);
        if pid = info.maxPID then
            dec(info.maxPID)
        else if (info.minFreePID = 0) or (info.minFreePID > pid) then
            info.minFreePID := pid;
    end;

{Процедура удаления процесса из очереди.
waiting - параметр-переменная ссылочного типа Queue,
info - параметр-переменная типа QueueInfo}
procedure killProcess(var waiting: Queue; var info: QueueInfo);
    var
        current: ItemAddr;
        pid: integer;
        isRemoved, notExists: boolean;
    begin
        renderKillProcessTitle;
        displayProcessQueue(waiting);
        current := waiting.front;
        write('Удаляемый PID: ');
        readIntValue(pid);

        {Проверка на вхождение введенного PID
        в диапазон находящися в очереди PIDs}
        if (pid > 0) and (pid <= info.maxPID) then
            begin
                isRemoved := false;
                notExists := false;

                {Поиск в очереди процесса с указанным PID}
                repeat
                    if current^.next^.process.pid = pid then
                        isRemoved := true
                    else if current^.next <> nil then
                        current := current^.next
                    else
                        notExists := true;
                until (isRemoved = true) or (notExists = true);

                if isRemoved = true then
                    {Удаление указанного процесса из очереди}
                    begin
                        deleteItem(waiting, current);
                        changeQueueInfo(info, pid);
                        renderKillProcessTitle;
                        displayProcessQueue(waiting);
                        writeln('Процесс PID ', pid, ' удален из очереди');
                    end
                else
                    errorNotExistsPID(pid);
            end
        else
            errorNotExistsPID(pid);
    end;

{Процедура сортировки очереди по приоритету процессов
(чем меньше время выполнения, тем приоритет выше).
waiting - параметр-переменная ссылочного типа Queue}
procedure sortByPriority(var waiting: Queue);
    var
        current: ItemAddr;
        elem: ProcessType;
        isSorted: boolean;
    begin
        repeat
            isSorted := true;
            current := waiting.front^.next;
            while current^.next <> nil do
                begin
                    if current^.process.time > current^.next^.process.time then
                        begin
                            elem := current^.process;
                            current^.process := current^.next^.process;
                            current^.next^.process := elem;
                            isSorted := false;
                        end;
                    current := current^.next;
                end;
        until isSorted = true;
    end;

{Функция выбора из очереди процесса с самым высоким приоритетом
(самым меньшим временем выполнения) и его обработка.
Возвращает true - при успешном завершении процесса
за выделенное время, иначе возвращает false.
waiting - параметр-переменная ссылочного типа Queue,
info - параметр-переменная типа QueueInfo}
function selectProcess(var waiting: Queue; var info: QueueInfo): boolean;
    var
        runningProcess: ProcessType;
        key: char;
        y: integer;
        isEndedProcess: boolean;
    begin
        renderTitle('На обработку взят процесс');

        {Взятие на обработку первого процесса из очереди}
        runningProcess := waiting.front^.next^.process;

        {Удаление из очереди взятого на обработку процесса}
        deleteItem(waiting, waiting.front);

        {Вывод информации об обрабатываемом процессе}
        with runningProcess do
            begin
                writeln(' PID ', pid);
                writeln(' Название процесса: ', pname);
                writeln(' Время выполнения: ', time);
            end;
        hr;

        {Определение состояния процесса по окончанию выделенного времени}
        write('Процесс закончился за выделенное время? (y/n)');
        y := whereY;
        repeat
            key := readkey;
        until (key = 'y') or (key = 'n');

        if key = 'y' then
            {Изменение общих сведений об очереди в случае
            успешного завершения процесса}
            begin
                changeQueueInfo(info, runningProcess.pid);
                gotoXY(1, y);
                clreol;
                isEndedProcess := true;
            end
        else if key = 'n' then
            {Возврат процесса в очередь с новым приоритетом в случае
            неуспешного его завершения}
            begin
                runningProcess.time := runningProcess.time + TIME_INC;
                addItem(waiting, runningProcess);
                gotoXY(1, y);
                clreol;
                writeln('Процесс возвращен в очередь с новым приоритетом');
                isEndedProcess := false;
            end;
        selectProcess := isEndedProcess;
    end;

{Процедура отображения списка операций.
queueLenght - параметр-константа типа integer}
procedure displayMainMenu(const queueLenght: integer);
    begin
        clrscr;
        br;
        renderTitle('Обработчик процессов');
        writeln('Выбор операции:');
        br;

        if queueLenght > 0 then
            begin
                writeln(' 0   - показать очередь процессов');
                writeln(' 1   - добавить процесс в очередь');
                writeln(' 2   - изменить приоритет процесса');
                writeln(' 3   - удалить процесс из очереди');
                writeln(' 4   - взять процесс на выполнение')
            end
        else
            {Для пустой очереди можно только добавить новый процесс}
            writeln(' 1   - добавить процесс в очередь');
        br;
        writeln(' ESC - завершение работы');
        br;
        hr;
        write('(для выбора операции нажмите соответствующую клавишу) ');
    end;

{Процедура исполнения программы}
procedure runApplication;
    var
        waiting: Queue; {очередь процессов}
        info: QueueInfo; {основные сведения об очереди}
        keyAction, keyExit: char;
        {isQueueSorted - признак отсортированности очереди,
        exitFlag - флаг завершения работы программы}
        isQueueSorted, exitFlag: boolean;
    begin

        {Инициализация очереди процессов}
        initQueue(waiting, info);

        exitFlag := false;
        repeat
            displayMainMenu(info.queueLenght);

            {Установим признак отсортированности в значение true
            для пустой или содержащей один элемент очереди}
            if info.queueLenght < 2 then
                isQueueSorted := true;

            keyAction := readkey;
            if info.queueLenght > 0 then
                case keyAction of

                    {вывод на экран очереди процессов}
                    '0': begin
                             renderTitle('Очередь процессов');
                             displayProcessQueue(waiting);
                             returnToMainMenu;
                         end;

                    {добавление нового процесса в очередь}
                    '1': begin
                             insertProcess(waiting, info);
                             isQueueSorted := false;
                             returnToMainMenu;
                         end;

                    {изменение приоритета процесса в очереди}
                    '2': begin
                             {Если у процесса изменился приоритет и очередь
                             была отсортирована, то меняется признак
                             отсортированности на значение false}
                             if (changeProcessPriority(waiting, info) = true) and
                                (isQueueSorted = true) then
                                 isQueueSorted := false;
                             returnToMainMenu;
                         end;

                    {удаление процесса из очереди}
                    '3': begin
                             killProcess(waiting, info);
                             returnToMainMenu;
                         end;

                    {взятие процесса на выполнение}
                    '4': begin
                             {Сортировка неотсортированной очереди}
                             if isQueueSorted = false then
                                 sortByPriority(waiting);
                             isQueueSorted := selectProcess(waiting, info);
                             returnToMainMenu;
                         end;
                end
            else
                case keyAction of
                    {добавление нового процесса в очередь}
                    '1': begin
                             insertProcess(waiting, info);
                             returnToMainMenu;
                         end;
                end;

            {завершение работы с подтверждением}
            if keyAction = chr(27) then
                begin
                    renderTitle(''Завершить работу программы?');
                    br;
                    write(' ENTER - подтвердить завершение работы');
                    keyExit := readkey;
                    if keyExit = chr(13) then
                        exitFlag := true;
                end;
        until exitFlag = true;
    end;

begin
    runApplication;
end.
