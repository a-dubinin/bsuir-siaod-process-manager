{�ணࠬ��, ����������� ࠡ��� ��ࠡ��稪� ����� (����ᮢ)
�� �᭮�� ��।� � �ਮ��⮬.
���ࠡ��稪 - �㡨��� �. �.}
program HANDLER;

{������祭�� ����� Crt}
uses crt;

{������� ����⠭�}
const
    {���饭�� �६��� ������, ����� �� �����訫�� �� �뤥������ �६�}
    TIME_INC = 100;

{������� ⨯��}
type
    {��� TermType - ������, ����뢠��� �����}
    ProcessType = record
        time: longint; {�६� �믮������}
        pid: integer;  {ID �����}
        pname: string  {�������� �����}
    end;

    {ItemAddr - 㪠��⥫� �� ������� ��।�}
    ItemAddr = ^Item;

    {��� Item - ������, ����뢠��� ������� ��।�}
    Item = record
        process: ProcessType; {����� ⥪�饣� �����}
        next: ItemAddr {�����⥫� �� ᫥���騩 ������� ��।�}
    end;

    {��� Queue - ������, ����뢠��� ��।�}
    Queue = record
        {front - �������� ������� ��।�,
        rear - ��᫥���� ������� ��।�}
        front, rear: ItemAddr
    end;

    {��� QueueInfo - ������, ����뢠��� �᭮��� ᢥ����� �� ��।�}
    QueueInfo = record
        {queueLenght - ������⢮ ����ᮢ � ��।�,
        minFreePID - �᢮�����訩�� PID � ���������� ���祭���,
        maxPID - ���ᨬ��쭮� ���祭�� ID ����� � ��।�}
        queueLenght, minFreePID, maxPID: integer
    end;

{��楤�� ��ॢ��� ��ப�}
procedure br;
    begin
        writeln;
    end;

{��楤�� �뢮�� �� ��� �ਭ� ���� ��ਧ��⠫쭮� ������}
procedure hr;
    var
        i: integer;
    begin
        for i := 1 to 79 do write('-');
        br;
    end;

{��楤�� �뢮�� ���।��� ���� ���������.
title - ��ࠬ���-����⠭� ⨯� string}
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
        renderTitle('�������� ����� �� ��।�');
    end;

procedure renderChangePriorityTitle;
    begin
        renderTitle('��������� �ਮ��� �����');
    end;

{��楤�� �뢮�� �� ��࠭ �������� ��ப� ᯨ᪠ ����ᮢ}
procedure renderProcessListHeader;
    begin
        writeln('PID | ':9, 'Process Name', '| ':38, 'Time');
        hr;
    end;

{��楤�� �뢮�� �� ��࠭ ����� ��ப� ᯨ᪠ ����ᮢ.
process - ��ࠬ���-����⠭� ⨯� ProcessType}
procedure renderProcessListRow(const process: ProcessType);
    begin
        with process do
            begin
                write(pid:6, ' | ');
                write(pname, ' | ':(50-length(pname)));
                write(time);
            end;
    end;

{��楤�� �뢮�� ᮮ�饭�� �� �訡��.
pid - ��ࠬ���-����⠭� ⨯� integer}
procedure errorNotExistsPID(const pid: integer);
    begin
        br;
        writeln('�訡��: ����� PID ', pid, ' �� �������');
    end;

{��楤�� ����� ���祭�� 楫��᫥����� ⨯� integer.
i - ��ࠬ���-��६����� ⨯� integer}
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

{��楤�� ����� ���祭�� 楫��᫥����� ⨯� longint.
i - ��ࠬ���-��६����� ⨯� longint}
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

{��楤��, ॠ������� ������ � ᯨ�� ����権}
procedure returnToMainMenu;
    begin
        br;
        write(' ESC - ������ � ᯨ�� ����権');
        repeat until readkey = #27;
    end;

{��楤�� ���樠����樨 ��।� � �� ��砫��� ᢥ�����.
waiting - ��ࠬ���-��६����� ⨯� Queue,
info - ��ࠬ���-��६����� ⨯� QueueInfo}
procedure initQueue(var waiting: Queue; var info: QueueInfo);
    begin
        new(waiting.front);
        waiting.front^.next := nil;
        waiting.rear := waiting.front;

        {���樠������ ��砫��� ���祭�� ᢥ����� �� ��।�}
        with info do
            begin
                queueLenght := 0;
                minFreePID := 0;
                maxPID := 0;
            end;
    end;

{��楤�� �뢮�� �� ��࠭ ��।� ����ᮢ.
waiting - ��ࠬ���-��६����� ��뫮筮�� ⨯� Queue}
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

{��楤�� ���������� ������� � ��।�.
waiting - ��ࠬ���-��६����� ��뫮筮�� ⨯� Queue,
process - ��ࠬ���-����⠭� ⨯� ProcessType}
procedure addItem(var waiting: Queue; const process: ProcessType);
    begin
        new(waiting.rear^.next);
        waiting.rear := waiting.rear^.next;
        waiting.rear^.process := process;
        waiting.rear^.next := nil;
    end;

{��楤�� ���������� ������ ����� � ��।�.
waiting - ��ࠬ���-��६����� ��뫮筮�� ⨯� Queue,
info - ��ࠬ���-��६����� ⨯� QueueInfo}
procedure insertProcess(var waiting: Queue; var info: QueueInfo);
    var
        newProcess: ProcessType;
        newPID: integer;
    begin
        renderTitle('���������� ����� � ��।�');

        {��������� �᭮���� ᢥ����� �� ��।� � ������� PID,
        � ��᫥���騬 ��᢮����� ��� ����� ������塞��� ������}
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

        {���� ������ ������ �����}
        with newProcess do
            begin
                pid := newPID;
                write(' �������� �����: ');
                readln(pname);
                write(' �६� �믮������: ');
                readLongintValue(time);
            end;

        {���������� ������ ����� � ��।�}
        addItem(waiting, newProcess);

        hr;
        writeln('����� "', newProcess.pname, '" (PID ', newPID, ') �������� � ��।�');
    end;

{�㭪�� ��������� �ਮ��� �����. �����頥�:
true - �� �ᯥ譮� ��������� �ਮ���,
false - � ��砥 �訡��.
waiting - ��ࠬ���-��६����� ��뫮筮�� ⨯� Queue,
info - ��ࠬ���-����⠭� ⨯� QueueInfo}
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
        write('�����塞� PID: ');
        readIntValue(pid);
        isChanged := false;

        {�஢�ઠ �� �宦����� ���������� PID
        � �������� ��室���� � ��।� PIDs}
        if (pid > 0) and (pid <= info.maxPID) then
            begin
                notExists := false;

                {���� � ��।� ����� � 㪠����� PID}
                repeat
                    current := current^.next;
                    if current^.process.pid = pid then
                        isChanged := true;
                    if current = nil then
                        notExists := true;
                until (isChanged = true) or (notExists = true);

                if isChanged = true then
                    {��������� �६��� �믮������ � 㪠������� �����}
                    begin
                        br;
                        hr;
                        write(' ����� ���祭�� �६��� �믮������ (⥪�饥 = ',current^.process.time, '): ');
                        readLongintValue(newTime);
                        current^.process.time := newTime;
                        renderChangePriorityTitle;
                        displayProcessQueue(waiting);
                        writeln('� ����� PID ', pid, ' ������� �ਮ���');
                    end
                else
                    errorNotExistsPID(pid);
            end
        else
            errorNotExistsPID(pid);
        changeProcessPriority := isChanged;
    end;

{��楤�� 㤠����� ������� �� ��।�.
(���ਬ��, � १���� ����� �� �믮������ ����� �� ��।� ��ࠡ��稪��
��� 㤠����� ����� �� ��।� ���譨�� �맮����).
waiting - ��ࠬ���-��६����� ��뫮筮�� ⨯� Queue,
prev - ��ࠬ���-��६����� ⨯� ItemAddr (�������, �।�����騩 㤠�塞���)}
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

{��楤�� ��������� ᢥ����� �� ��।�
� १���� 㤠����� ����� �� ��।�.
info - ��ࠬ���-��६����� ⨯� QueueInfo,
pid - ��ࠬ���-����⠭� ⨯� integer}
procedure changeQueueInfo(var info: QueueInfo; const pid: integer);
    begin
        dec(info.queueLenght);
        if pid = info.maxPID then
            dec(info.maxPID)
        else if (info.minFreePID = 0) or (info.minFreePID > pid) then
            info.minFreePID := pid;
    end;

{��楤�� 㤠����� ����� �� ��।�.
waiting - ��ࠬ���-��६����� ��뫮筮�� ⨯� Queue,
info - ��ࠬ���-��६����� ⨯� QueueInfo}
procedure killProcess(var waiting: Queue; var info: QueueInfo);
    var
        current: ItemAddr;
        pid: integer;
        isRemoved, notExists: boolean;
    begin
        renderKillProcessTitle;
        displayProcessQueue(waiting);
        current := waiting.front;
        write('����塞� PID: ');
        readIntValue(pid);

        {�஢�ઠ �� �宦����� ���������� PID
        � �������� ��室���� � ��।� PIDs}
        if (pid > 0) and (pid <= info.maxPID) then
            begin
                isRemoved := false;
                notExists := false;

                {���� � ��।� ����� � 㪠����� PID}
                repeat
                    if current^.next^.process.pid = pid then
                        isRemoved := true
                    else if current^.next <> nil then
                        current := current^.next
                    else
                        notExists := true;
                until (isRemoved = true) or (notExists = true);

                if isRemoved = true then
                    {�������� 㪠������� ����� �� ��।�}
                    begin
                        deleteItem(waiting, current);
                        changeQueueInfo(info, pid);
                        renderKillProcessTitle;
                        displayProcessQueue(waiting);
                        writeln('����� PID ', pid, ' 㤠��� �� ��।�');
                    end
                else
                    errorNotExistsPID(pid);
            end
        else
            errorNotExistsPID(pid);
    end;

{��楤�� ���஢�� ��।� �� �ਮ���� ����ᮢ
(祬 ����� �६� �믮������, ⥬ �ਮ��� ���).
waiting - ��ࠬ���-��६����� ��뫮筮�� ⨯� Queue}
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

{�㭪�� �롮� �� ��।� ����� � ᠬ� ��᮪�� �ਮ��⮬
(ᠬ� ����訬 �६���� �믮������) � ��� ��ࠡ�⪠.
�����頥� true - �� �ᯥ譮� �����襭�� �����
�� �뤥������ �६�, ���� �����頥� false.
waiting - ��ࠬ���-��६����� ��뫮筮�� ⨯� Queue,
info - ��ࠬ���-��६����� ⨯� QueueInfo}
function selectProcess(var waiting: Queue; var info: QueueInfo): boolean;
    var
        runningProcess: ProcessType;
        key: char;
        y: integer;
        isEndedProcess: boolean;
    begin
        renderTitle('�� ��ࠡ��� ���� �����');

        {���⨥ �� ��ࠡ��� ��ࢮ�� ����� �� ��।�}
        runningProcess := waiting.front^.next^.process;

        {�������� �� ��।� ���⮣� �� ��ࠡ��� �����}
        deleteItem(waiting, waiting.front);

        {�뢮� ���ଠ樨 �� ��ࠡ��뢠���� �����}
        with runningProcess do
            begin
                writeln(' PID ', pid);
                writeln(' �������� �����: ', pname);
                writeln(' �६� �믮������: ', time);
            end;
        hr;

        {��।������ ���ﭨ� ����� �� ����砭�� �뤥������� �६���}
        write('����� �����稫�� �� �뤥������ �६�? (y/n)');
        y := whereY;
        repeat
            key := readkey;
        until (key = 'y') or (key = 'n');

        if key = 'y' then
            {��������� ���� ᢥ����� �� ��।� � ��砥
            �ᯥ譮�� �����襭�� �����}
            begin
                changeQueueInfo(info, runningProcess.pid);
                gotoXY(1, y);
                clreol;
                isEndedProcess := true;
            end
        else if key = 'n' then
            {������ ����� � ��।� � ���� �ਮ��⮬ � ��砥
            ���ᯥ譮�� ��� �����襭��}
            begin
                runningProcess.time := runningProcess.time + TIME_INC;
                addItem(waiting, runningProcess);
                gotoXY(1, y);
                clreol;
                writeln('����� �����饭 � ��।� � ���� �ਮ��⮬');
                isEndedProcess := false;
            end;
        selectProcess := isEndedProcess;
    end;

{��楤�� �⮡ࠦ���� ᯨ᪠ ����権.
queueLenght - ��ࠬ���-����⠭� ⨯� integer}
procedure displayMainMenu(const queueLenght: integer);
    begin
        clrscr;
        br;
        renderTitle('��ࠡ��稪 ����ᮢ');
        writeln('�롮� ����樨:');
        br;

        if queueLenght > 0 then
            begin
                writeln(' 0   - �������� ��।� ����ᮢ');
                writeln(' 1   - �������� ����� � ��।�');
                writeln(' 2   - �������� �ਮ��� �����');
                writeln(' 3   - 㤠���� ����� �� ��।�');
                writeln(' 4   - ����� ����� �� �믮������')
            end
        else
            {��� ���⮩ ��।� ����� ⮫쪮 �������� ���� �����}
            writeln(' 1   - �������� ����� � ��।�');
        br;
        writeln(' ESC - �����襭�� ࠡ���');
        br;
        hr;
        write('(��� �롮� ����樨 ������ ᮮ⢥�������� �������) ');
    end;

{��楤�� �ᯮ������ �ணࠬ��}
procedure runApplication;
    var
        waiting: Queue; {��।� ����ᮢ}
        info: QueueInfo; {�᭮��� ᢥ����� �� ��।�}
        keyAction, keyExit: char;
        {isQueueSorted - �ਧ��� �����஢������ ��।�,
        exitFlag - 䫠� �����襭�� ࠡ��� �ணࠬ��}
        isQueueSorted, exitFlag: boolean;
    begin

        {���樠������ ��।� ����ᮢ}
        initQueue(waiting, info);

        exitFlag := false;
        repeat
            displayMainMenu(info.queueLenght);

            {��⠭���� �ਧ��� �����஢������ � ���祭�� true
            ��� ���⮩ ��� ᮤ�ঠ饩 ���� ������� ��।�}
            if info.queueLenght < 2 then
                isQueueSorted := true;

            keyAction := readkey;
            if info.queueLenght > 0 then
                case keyAction of

                    {�뢮� �� ��࠭ ��।� ����ᮢ}
                    '0': begin
                             renderTitle('��।� ����ᮢ');
                             displayProcessQueue(waiting);
                             returnToMainMenu;
                         end;

                    {���������� ������ ����� � ��।�}
                    '1': begin
                             insertProcess(waiting, info);
                             isQueueSorted := false;
                             returnToMainMenu;
                         end;

                    {��������� �ਮ��� ����� � ��।�}
                    '2': begin
                             {�᫨ � ����� ��������� �ਮ��� � ��।�
                             �뫠 �����஢���, � ������� �ਧ���
                             �����஢������ �� ���祭�� false}
                             if (changeProcessPriority(waiting, info) = true) and
                                (isQueueSorted = true) then
                                 isQueueSorted := false;
                             returnToMainMenu;
                         end;

                    {㤠����� ����� �� ��।�}
                    '3': begin
                             killProcess(waiting, info);
                             returnToMainMenu;
                         end;

                    {���⨥ ����� �� �믮������}
                    '4': begin
                             {����஢�� �������஢����� ��।�}
                             if isQueueSorted = false then
                                 sortByPriority(waiting);
                             isQueueSorted := selectProcess(waiting, info);
                             returnToMainMenu;
                         end;
                end
            else
                case keyAction of
                    {���������� ������ ����� � ��।�}
                    '1': begin
                             insertProcess(waiting, info);
                             returnToMainMenu;
                         end;
                end;

            {�����襭�� ࠡ��� � ���⢥ত�����}
            if keyAction = chr(27) then
                begin
                    renderTitle('�������� ࠡ��� �ணࠬ��?');
                    br;
                    write(' ENTER - ���⢥न�� �����襭�� ࠡ���');
                    keyExit := readkey;
                    if keyExit = chr(13) then
                        exitFlag := true;
                end;
        until exitFlag = true;
    end;

begin
    runApplication;
end.