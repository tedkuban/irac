Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера		- АгентКластера	- ссылка на родительский объект агента кластера
//   Кластер			- Кластер		- ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//											- Ложь - данные будут получены если истекло время актуальности
//													или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт
	
	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	// TODO: Добавить просмотр лицензий
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("process");
	ПараметрыЗапуска.Добавить("list");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	МассивРезультатов = Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды());

	МассивПроцессов = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивПроцессов.Добавить(Новый РабочийПроцесс(Кластер_Агент, Кластер_Владелец, ТекОписание["process"]));
	КонецЦикла;

	Элементы.Заполнить(МассивПроцессов);

	Элементы.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает список рабочих процессов
//   
// Параметры:
//   Отбор					 	- Структура	- Структура отбора процессов (<поле>:<значение>)
//   ОбновитьПринудительно 		- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Массив - список рабочих процессов 1С
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь) Экспорт

	РабочиеПроцессы = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Возврат РабочиеПроцессы;

КонецФункции // Список()

// Функция возвращает список рабочих процессов кластера 1С
//   
// Параметры:
//   ПоляИерархии 			- Строка		- Поля для построения иерархии списка процессов, разделенные ","
//   ОбновитьПринудительно 	- Булево		- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - список рабочих процессов кластера 1С
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь) Экспорт

	РабочиеПроцессы = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно); 
	
	Возврат РабочиеПроцессы;

КонецФункции // ИерархическийСписок()

// Функция возвращает описание рабочего процесса кластера 1С
//   
// Параметры:
//   Процесс			 	- Строка	- Номер процесса в виде <адрес сервера>:<номер процесса ОС (pid))>
//   ОбновитьПринудительно 	- Булево	- Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - описание рабочего процесса кластера 1С
//
Функция Получить(Знач Процесс, Знач ОбновитьПринудительно = Ложь) Экспорт

	Процесс = СтрРазделить(Процесс, ":");

	Если Процесс.Количество() = 1 Тогда
		Процесс.Вставить(0, Кластер_Владелец.Получить("host"));
	КонецЕсли;

	Отбор = Новый Структура("host, pid", Процесс[0], Процесс[1]);

	РабочиеПроцессы = Элементы.Список(Отбор, ОбновитьПринудительно);

	Если РабочиеПроцессы.Количество() = 0 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Возврат РабочиеПроцессы[0];

КонецФункции // Получить()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча 		- Строка	- имя поля, значение которого будет использовано
//									  в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//	Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПолучитьСтруктуруПараметровОбъекта(ИмяПоляКлюча = "ИмяПараметра") Экспорт
	
	СтруктураПараметров = Новый Соответствие();

    Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"Ид"							, "process"					, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"АдресСервера"					, "host"					, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПортСервера"					, "port"					, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ИдПроцессаОС"					, "pid"						, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"Активен"						, "is-enable"				, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"Выполняется"					, "running"					, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ВремяЗапуска"					, "started-at"				, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"Использование"					, "use"						, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ДоступнаяПроизводительность"	, "available-perfomance"	, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"Емкость"						, "capacity"				, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"КоличествоСоединений"			, "connections"				, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ЗанятьПамяти"					, "memory-size"				, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ВремяПревышенияЗанятойПамяти"	, " memory-excess-time"		, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ОбъемВыборки"					, "selection-size"			, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ЗатраченоКлиентом"				, "avg-back-call-time"		, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ЗатраченоВсего"				, "avg-call-time"			, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ЗатраченоСУБД"					, "avg-db-call-time"		, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ЗатраченоМенеджеромБлокировок"	, "avg-lock-call-time"		, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ЗатраченоСервером"				, "avg-server-call-time"	, , "-");
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"КлиентскихПотоков"				, "avg-threads"				, , "-");

	Возврат СтруктураПараметров;

КонецФункции // ПолучитьСтруктуруПараметровОбъекта()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
