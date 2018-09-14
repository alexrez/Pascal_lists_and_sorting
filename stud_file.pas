program Final2File;
{номер студентческого 09}
{---в группе более трети студентов из городов Владимир, Иваново, Калуга, Москва, Рязань, Смоленск, Тверь---}
{--- Студенты, модальные по набору параметров: фамилия, имя, год рождения---}

const emptyString = '                        ';
type BirthRecord = record
        day, month, year:integer
    end;
    usingStr = string[24]; {учиьывая, что слова по условию задачи могут достигать 12 символов в длинну кириллицей, выделяем 24-литерную строку, из-за большего объема кириллических символов при кодировке}
    {---данные на каждого студента---}
    PersonalData = record
        Surname, Name, Otch:usingStr;
        Gender:(M, F);
        Birth:BirthRecord;
        City:usingStr;
        Group:301..329;
        Grade:array[1..3] of 3..5
    end;
    PtrStudent = ^Student;
    Student = record
        next:PtrStudent;
        data:PersonalData
    end;
    usingFile = text;
    Matrix= array[301..329,1..2] of real;
    PtrModa = ^Moda;
    Moda = record
        next:PtrModa;
        tag, value:usingStr;
        ModaCount:integer;
    end;

var StudentsList, shortList:PtrStudent;
    OneStudent:PersonalData;
    inputFile:usingFile;
    MasOfAllGroups, tagAMassiv:Matrix;
    groupNumber,i,countGrTagA:integer;
    n:real;
    ModaList,ShortModaList:PtrModa;

{---процедура чтения из файла слов и записи их в 24-литерные строки (с пробелами справа)---}
procedure readWord(var inpFile:usingFile; var newStr:usingStr);
var tempStr:usingStr;
    letter:char;
    i:integer;
begin
    tempStr:=emptyString;
    read(inpFile,letter);
    while letter=' ' do read(inpFile,letter); {если слова разделены более, чем одним пробелом}
    i:=1;
    while letter <> ' ' do begin
        tempStr[i]:=letter;
        inc(i);
        read(inpFile,letter)
    end;
    newStr:=tempStr
end;

{---процедура чтения целых чисел---}
procedure readNumber(var currentStr:usingStr; var newNumb:integer);
var tempStr:usingStr;
    i,j:integer;
begin
    i:=pos('.',currentStr);
    if i<>0 then j:=i
    else j:=pos(' ',currentStr);
    tempStr:=copy(currentStr,1,j-1);
    val(tempStr,newNumb);
    delete(currentStr,1,j)
end;

{---процедура формирования записи по студенту---}
procedure readStudent(var inpFile:usingFile; var currentStudent:PersonalData);
var tempGender, tempBirth:usingStr;
begin
    with currentStudent do begin
        readWord(inpFile, Surname);
        readWord(inpFile, Name);
        readWord(inpFile, Otch);
        readWord(inpFile, tempGender);
        if tempGender='М' then Gender:=M
        else Gender:=F;
        readWord(inpFile,tempBirth);
        with Birth do begin
            readNumber(tempBirth, day);
            readNumber(tempBirth, month);
            readNumber(tempBirth, year)
    end;
        readWord(inpFile, City);
        readln(inpFile, Group, Grade[1],Grade[2],Grade[3])
    end
end;

{---добавление в список студентов---}
procedure AddToList(var List:PtrStudent; currentStudent:PersonalData);
begin
    if list=nil then begin
        new(list);
        list^.data:=currentStudent;
        list^.next:=nil
    end
    else AddToList(list^.next, currentStudent)
end;

{---поиск по условию А---}
procedure searchTagA(List:PtrStudent; var Mas, tagAMas: Matrix; var countGrTagA:integer);
var CurrentPtr:PtrStudent;
    tagA:boolean;
    studCity,VLADIMIR,IVANOVO,KALUGA,MOSCOW,RYAZAN,SMOLENSK,TVER :usingStr;
    studentsInGroup, tagACount, i :integer;
begin
    tagACount:=1;
    studentsInGroup:=2;
    CurrentPtr:=List;
    VLADIMIR:=emptyString; insert('ВЛАДИМИР',VLADIMIR,1);
    IVANOVO:=emptyString; insert('ИВАНОВО',IVANOVO,1);
    KALUGA:=emptyString; insert('КАЛУГА',KALUGA,1);
    MOSCOW:=emptyString; insert('МОСКВА',MOSCOW,1);
    RYAZAN:=emptyString; insert('РЯЗАНЬ',RYAZAN,1);
    SMOLENSK:=emptyString; insert('СМОЛЕНСК',SMOLENSK,1);
    TVER:=emptyString; insert('ТВЕРЬ',TVER,1);
    repeat
        studCity:=CurrentPtr^.data.city;
        Mas[CurrentPtr^.data.group, studentsInGroup]:=Mas[CurrentPtr^.data.group, studentsInGroup] + 1;
        tagA:=(VLADIMIR=studCity) or (IVANOVO=studCity) or (KALUGA=studCity) or (MOSCOW=studCity) or (RYAZAN=studCity) or (SMOLENSK=studCity) or (TVER=studCity);
        if tagA then
        Mas[CurrentPtr^.data.group, tagACount]:=Mas[CurrentPtr^.data.group, tagACount] + 1;
    CurrentPtr:=CurrentPtr^.next;
    until CurrentPtr = nil;

    i:=0;
    for groupNumber:=301 to 329 do
        if Mas[groupNumber,studentsInGroup]<>0 then
            if Mas[groupNumber,tagACount]/Mas[groupNumber,studentsInGroup] > (1/3) then begin
                inc(i);
                tagAMas[i,1]:=groupNumber;
                tagAMas[i,2]:=Mas[groupNumber,studentsInGroup]
            end;
        countGrTagA:=i
end;

{---удаление из списка---}
procedure OutOfList(var List:PtrStudent; var tagAMas: Matrix; countGrTagA:integer);
var i:integer;
    predPos, curPos, tempList:PtrStudent;
    flag:boolean;
begin
    curPos:=List;
    predPos:=curPos;
    while curPos<>nil do begin
        flag:=false;
        for i:=1 to countGrTagA do
            if curPos^.data.Group=tagAMas[i,1] then
                flag:=true;
        if flag then begin
            predPos:=curPos;
            curPos:=curPos^.next
        end
        else begin
            if list=curPos then list:=curPos^.next
            else predPos^.next:=curPos^.next;
            tempList:=curPos^.next;
            dispose(curPos);
            curPos:=tempList
        end
    end
end;

{---поиск по условию B---}
procedure ModaTagB(List:PtrStudent; var ModaList:PtrModa);
var tempList:PtrStudent;
    tempModaList:PtrModa;
    st:usingStr;
    {---добавление в список параметров---}
    procedure AddToModaList(var TModaList:PtrModa; modaType, value: usingStr);
    var tagB:boolean;
        tempModaList, NewtempModaList, PredModaPos:PtrModa;
    begin
        new(NewTempModaList);
        NewtempModaList^.next:=nil;
        NewtempModaList^.tag:=modaType;
        NewtempModaList^.value:=value;
        NewtempModaList^.ModaCount:=1;
        if TModaList=nil then
            TModaList:=NewtempModaList
        else begin
            tempModaList:=TModaList;
            tagB:=false;
            while (tempModaList<>nil) and (not tagB) do begin
                if (tempModaList^.tag=NewtempModaList^.tag) and (tempModaList^.value=NewtempModaList^.value) then begin
                    inc(tempModaList^.ModaCount);
                    tagB:=true
                end;
                PredModaPos:=tempModaList;
                tempModaList:=tempModaList^.next;
            end;
            if (not tagB) then begin
                PredModaPos^.next:=NewTempModaList
            end
        end
    end;
begin
    tempList:=List;
    tempModaList:=ModaList;
    while tempList <> nil do begin
        AddToModaList(tempModaList,'Surname', tempList^.data.Surname);
        AddToModaList(tempModaList,'Name', tempList^.data.Name);
        str(tempList^.data.Birth.year,st);
        AddToModaList(tempModaList,'Year', st);
        tempList:=tempList^.next
    end;
    ModaList:=TempModaList
end;

{---расчет модальных значений по параметрам---}
procedure MaxModa(var ModaList:PtrModa);
var MaxCountSurname, MaxCountName, MaxCountYear: integer;
    tempModaList, PredModaPos,curModaList:PtrModa;
begin
    MaxCountSurname:=0;
    MaxCountName:=0;
    MaxCountYear:= 0;
    tempModaList:=ModaList;
    while tempModaList<>nil do begin
        if (tempModaList^.tag='Surname') and (tempModaList^.ModaCount > MaxCountSurname) then
            MaxCountSurname:=tempModaList^.ModaCount;
        if (tempModaList^.tag='Name') and (tempModaList^.ModaCount > MaxCountName) then
            MaxCountName:=tempModaList^.ModaCount;
        if (tempModaList^.tag='Year') and (tempModaList^.ModaCount > MaxCountYear) then
            MaxCountYear:=tempModaList^.ModaCount;
        tempModaList:= tempModaList^.next
    end;
    tempModaList:= ModaList;
    PredModaPos:= tempModaList;
    while tempModaList<>nil do begin
        if (tempModaList^.tag='Surname') and (tempModaList^.ModaCount < MaxCountSurname) or (tempModaList^.tag='Name') and (tempModaList^.ModaCount < MaxCountName) or (tempModaList^.tag='Year') and (tempModaList^.ModaCount < MaxCountYear) then begin
            if tempModaList=ModaList then begin
                ModaList:=tempModaList^.next;
            end
            else PredModaPos^.next:=tempModaList^.next;
            curModaList:= tempModaList^.next;
            dispose(tempModaList);
            tempModaList:=curModaList;
        end
        else begin
            PredModaPos:=tempModaList;
            tempModaList:=tempModaList^.next
        end
    end
end;


{---отбор студентов по модальным параметрам---}
procedure ModaStudents(var List:PtrStudent; ModaList:PtrModa);
var MaxStudModa, TempStudModa: integer;
    tempList, PredListPos, curList: PtrStudent;
    {---расчет модальных значений по студентам---}
    function getStudModa(ModaList:PtrModa; currentStudent:PersonalData):integer;
    var count: integer;
        st:usingStr;
        tempModaList:PtrModa;
    begin
    count:=0;
        tempModaList:= ModaList;
        while tempModaList<> nil do begin
            if (tempModaList^.tag='Surname') and (tempModaList^.value=currentStudent.Surname) then inc(count);
            if (tempModaList^.tag='Name') and (tempModaList^.value=currentStudent.Name) then inc(count);
            str(currentStudent.Birth.year, st);
            if (tempModaList^.tag='Year') and (tempModaList^.value=st) then inc(count);
            tempModaList:=tempModaList^.next
        end;
        getStudModa:=count
    end;
begin
    MaxStudModa:=0;
    tempList:=List;
    PredListPos:=tempList;
    while tempList<>nil do begin
        TempStudModa:=0;
        TempStudModa:=getStudModa(ModaList,tempList^.data);
        if MaxStudModa <= TempStudModa then begin
            MaxStudModa:=TempStudModa;
            PredListPos:=tempList;
            tempList:=tempList^.next
        end
        else begin
            if tempList=List then begin
                List:=tempList^.next;
            end
            else PredListPos^.next:=tempList^.next;
            curList:= tempList^.next;
            dispose(tempList);
            tempList:=curList
        end
    end;
    tempList:=List;
    PredListPos:=tempList;
    while tempList<>nil do begin
        TempStudModa:=0;
        TempStudModa:=getStudModa(ModaList,tempList^.data);
        if MaxStudModa = TempStudModa then begin
            PredListPos:=tempList;
            tempList:=tempList^.next
        end
        else begin
            if tempList=List then begin
                List:=tempList^.next;
            end
            else PredListPos^.next:=tempList^.next;
            curList:= tempList^.next;
            dispose(tempList);
            tempList:=curList
        end
    end
end;

{---упорядочить список---}
procedure OrderList(var List:PtrStudent);
var curList, predList, OrdList, newTempList:PtrStudent;
flag:boolean;
begin
    ordList:=List;
    if ordList<>nil then begin
        new(newTempList);
        newTempList^.data:=ordList^.data;
        newTempList^.next:=nil;
        List:=newTempList;

        while ordList<>nil do begin
            new(newTempList);
            newTempList^.data:=ordList^.data;
            newTempList^.next:=nil;
            curList:=List;
            predList:=curList;
            flag:=false;
            while curList<>nil do begin
                if (newTempList^.data.Surname< curList^.data.Surname) and (not flag) and (newTempList^.next=nil) then begin
                    flag:=true;
                    if curList=List then begin
                        newTempList^.next:=List;
                        List:=newTempList
                    end
                    else begin
                        newTempList^.next:=curList;
                        predList^.next:=newTempList
                    end;
                end;
                predList:=curList;
                curList:=curList^.next
            end;
            if not flag then begin
                predList^.next:=newTempList;
                newTempList^.next:=nil;
            end;
            ordList:=ordList^.next
        end
    end
end;

{---вывод на печать---}
procedure printList(List:PtrStudent);
begin
    if List<>nil then begin
        delete(List^.data.Surname,(pos(' ',List^.data.Surname)+1),(24-pos(' ',List^.data.Surname)));
        delete(List^.data.Name,(pos(' ',List^.data.Name)+1),(24-pos(' ',List^.data.Name)));
        delete(List^.data.Otch,(pos(' ',List^.data.Otch)),(24-pos(' ',List^.data.Otch)));
        Write('ФИО: ');
        write(concat(List^.data.Surname,List^.data.Name,List^.data.Otch));
        write('(№ группы: ',List^.data.Group,'); Год рождения: ',List^.data.Birth.year);
        delete(List^.data.City,pos(' ',List^.data.City),(24-pos(' ',List^.data.City)));
        writeln('; Город: ',List^.data.City);
        printList(List^.next)
    end
end;

{---вывод на печать модального списка---}
procedure printModaList(List:PtrModa);
var tempList:PtrModa;
begin
    tempList:=List;
    Writeln('Встречаемость заданных параметров (раз):');
    writeln('------------------------------------------------');
    writeln('Фамилия');
    writeln('------------------------------------------------');
    While tempList<>nil do begin
        if tempList^.tag='Surname' then begin
            writeln(tempList^.ModaCount,' - ',tempList^.value)
        end;
        templist:=tempList^.next
    end;
    writeln('------------------------------------------------');
    tempList:=List;
    writeln('Имя');
    writeln('------------------------------------------------');
    While tempList<>nil do begin
        if tempList^.tag='Name' then begin
            writeln(tempList^.ModaCount,' - ',tempList^.value);
        end;
        templist:=tempList^.next
    end;
    writeln('------------------------------------------------');
    tempList:=List;
    writeln('Год рождения');
    writeln('------------------------------------------------');
    While tempList<>nil do begin
        if tempList^.tag='Year' then begin
    writeln(tempList^.ModaCount,' - ',tempList^.value);
        end;
        templist:=tempList^.next
    end;
    writeln('------------------------------------------------');
end;

{---тело программы---}
begin
    assign(inputFile,'students_3rd_year_rus.txt');

    {---Чтение информации из файла и построение списка---}
    reset(inputFile);
    StudentsList:=nil;
    repeat
        readStudent(inputFile, oneStudent);
        addToList(StudentsList, oneStudent)
    until eof(inputFile);
    close(inputFile);

    {---инициализация массива по числу груп для учета вхождения заданных пареметров---}
    for groupNumber:=301 to 329 do
        for i:=1 to 2 do
            MasOfAllGroups[groupNumber,i]:=0;
    {---инициализация массива для учета подходящих групп---}
    for groupNumber:=301 to 329 do
        for i:=1 to 2 do
            tagAMassiv[groupNumber,i]:=0;

    {---Просмотр списка и определение нужных сведений по каждой группе---}
    searchTagA(StudentsList, MasOfAllGroups, tagAMassiv, countGrTagA);

    {---Промежуточная печать---}
    Writeln('Файл содержит сведения по следующим группам:');
    Writeln('№ группы |':16,'Всего студентов в группе |':58,'Число студентов из указанных городов|');
    writeln('--------------------------------------------------------------------------------');
    for groupNumber:=301 to 329 do begin
        if MasOfAllGroups[groupNumber,2]<>0 then begin
            write(groupNumber:9,'|');
            for i:=2 downto 1 do
                write(MasOfAllGroups[groupNumber,i]:36:0,'|');
            writeln
        end
    end;
    writeln('--------------------------------------------------------------------------------');
    writeln('Отобранные группы: ');
    n:=0;
    for i:=1 to countGrTagA do begin
        write(tagAMassiv[i,1]:6:0);
        n:=n+tagAMassiv[i,2]
    end;
    writeln;
    writeln('Общее число студентов в отобранных группах: ',n:0:0);

    {---Просмотр списка и удаление из него сведений о студентах из других групп---}
    shortList:=StudentsList;
    OutOfList(shortList, tagAMassiv, countGrTagA);

    {---Определение наиболее часто встречающихся---}
    ModaList:=nil;
    ModaTagB(shortList, ModaList);

    {---Промежуточная печать---}
    printModaList(ModaList);
    writeln(' ');

    {---Определение максимума значений модальных параметров---}
    ShortModaList:=ModaList;
    MaxModa(ShortModaList);
    writeln('Наиболее часто встречающиеся параметры');
    printModaList(ShortModaList);
    writeln(' ');

    {---Выбор студентов с наибольшим числом модальных параметров---}
    ModaStudents(shortList, ShortModaList);

    {---Печать окончательного результата (упорядочив по ФИО)---}
    OrderList(shortList);
    Writeln('Сведения о студентах, удовлетворяющих заданным параметрам: ');
    writeln('--------------------------------------------------------------------------------');
    printList(shortList);

end.
