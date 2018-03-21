﻿///////////////////////////////////////////////////////////////////////////////////
// УПРАВЛЕНИЕ ЗАПУСКОМ КОМАНД 1С:Предприятия 8
//

#Использовать logos
#Использовать tempfiles
#Использовать asserts
#Использовать strings
#Использовать 1commands
#Использовать v8runner
#Использовать "."

Перем Лог;

//////////////////////////////////////////////////////////////////////////////////
// Программный интерфейс

Процедура ОписаниеСерверов(Серверы)
	
	Сообщить("Всего серверов: " + Серверы.ПолучитьСписок().Количество());
	Для Каждого ТекОписание Из Серверы.ПолучитьСписок() Цикл
		Сервер = ТекОписание.Значение;
		Сообщить(Сервер.Имя() + " (" + Сервер.Сервер() + ":" + Сервер.Порт() + ")");
		Для Каждого ТекАтрибут Из Сервер.Параметры() Цикл
			Сообщить(ТекАтрибут.Ключ + " : " + ТекАтрибут.Значение);
		КонецЦикла;
		Сообщить("");
	КонецЦикла;
				
КонецПроцедуры

Процедура ОписаниеИБ(ИБ)
	
	Сообщить("Всего ИБ: " + ИБ.ПолучитьСписок().Количество());
	Для Каждого ТекОписание Из ИБ.ПолучитьСписок() Цикл
		ТекИБ = ТекОписание.Значение;
		Сообщить(ТекИБ.Имя() + " (" + ?(ТекИБ.ПолноеОписание(), "Полное", "Сокращенное") + " " + ТекИБ.Описание() + ")");
		Для Каждого ТекАтрибут Из ТекИБ.Параметры() Цикл
			Сообщить(ТекАтрибут.Ключ + " : " + ТекАтрибут.Значение);
		КонецЦикла;
		Сообщить("");
	КонецЦикла;
				
КонецПроцедуры

Процедура ВывестиСписокБаз()
	
	СерверРАК = "localhost";
	ПортРАК = 1545;
	ВерсияРАК = "8.3";

	Агент = Новый АгентКластера(СерверРАК, ПортРАК, ВерсияРАК);
	Сообщить(Агент.ОписаниеПодключения());

	Кластеры = Агент.Кластеры();

	МассивРезультатов = Новый Массив();

	Для Каждого ТекЭлемент Из Кластеры.ПолучитьСписок() Цикл

		Сообщить(СтрШаблон("Кластер: %1", ТекЭлемент.Ключ));
		Для Каждого ТекПоле Из ТекЭлемент.Значение.Параметры() Цикл
			Сообщить(СтрШаблон("%1 : %2", ТекПоле.Ключ, ТекПоле.Значение));
		КонецЦикла;

		ОписаниеСерверов(ТекЭлемент.Значение.Серверы());
		ОписаниеИБ(ТекЭлемент.Значение.ИнформационныеБазы());

	КонецЦикла;

КонецПроцедуры // ВывестиСписокБаз()
	
//////////////////////////////////////////////////////////////////////////////////
// Служебные процедуры

//////////////////////////////////////////////////////////////////////////////////////
// Инициализация

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");

ВывестиСписокБаз();