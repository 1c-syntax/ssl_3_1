﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

// Процедура обновляет данные регистра по результату изменения прав ролей,
// сохраненному при обновлении регистра сведений ПраваРолей.
//
Процедура ОбновитьДанныеРегистраПоИзменениямКонфигурации() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПоследниеИзменения = СтандартныеПодсистемыСервер.ИзмененияПараметраРаботыПрограммы(
		"СтандартныеПодсистемы.УправлениеДоступом.ОбъектыМетаданныхПравРолей");
	
	Если ПоследниеИзменения = Неопределено Тогда
		ОбновитьДанныеРегистра();
	Иначе
		ОбъектыМетаданных = Новый Массив;
		Для каждого ЧастьИзменений Из ПоследниеИзменения Цикл
			Если ТипЗнч(ЧастьИзменений) = Тип("ФиксированныйМассив") Тогда
				Для каждого ОбъектМетаданных Из ЧастьИзменений Цикл
					Если ОбъектыМетаданных.Найти(ОбъектМетаданных) = Неопределено Тогда
						ОбъектыМетаданных.Добавить(ОбъектМетаданных);
					КонецЕсли;
				КонецЦикла;
			Иначе
				ОбъектыМетаданных = Неопределено;
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		ОбновитьДанныеРегистра(, ОбъектыМетаданных);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Процедура обновляет данные регистра при изменении состава ролей профилей и
// изменении профилей у групп доступа.
//
// Параметры:
//  ГруппыДоступа - СправочникСсылка.ГруппыДоступа.
//                - Массив - значения указанного выше типа.
//                - Неопределено - без отбора.
//
//  Таблицы       - СправочникСсылка.ИдентификаторыОбъектовМетаданных
//                - СправочникСсылка.ИдентификаторыОбъектовРасширений
//                - Массив - значения указанных выше типов.
//
//  ЕстьИзменения - Булево - (возвращаемое значение) - если производилась запись,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьДанныеРегистра(ГруппыДоступа = Неопределено,
                                 Таблицы       = Неопределено,
                                 ЕстьИзменения = Неопределено) Экспорт
	
	Если ТипЗнч(Таблицы) = Тип("Массив") Или ТипЗнч(Таблицы) = Тип("ФиксированныйМассив") Тогда
		КоличествоЗаписей = Таблицы.Количество();
		Если КоличествоЗаписей = 0 Тогда
			Возврат;
		ИначеЕсли КоличествоЗаписей > 500 Тогда
			Таблицы = Неопределено;
		КонецЕсли;
	КонецЕсли;
	
	РегистрыСведений.ПраваРолей.ПроверитьДанныеРегистра();
	
	УстановитьПривилегированныйРежим(Истина);
	
	ЗапросПустыхЗаписей = Новый Запрос;
	ЗапросПустыхЗаписей.Текст =
	"ВЫБРАТЬ
	|	ТаблицыГруппДоступа.Таблица КАК Таблица
	|ИЗ
	|	РегистрСведений.ТаблицыГруппДоступа КАК ТаблицыГруппДоступа
	|ГДЕ
	|	ТаблицыГруппДоступа.Таблица В (
	|		ЗНАЧЕНИЕ(Справочник.ИдентификаторыОбъектовМетаданных.ПустаяСсылка),
	|		ЗНАЧЕНИЕ(Справочник.ИдентификаторыОбъектовРасширений.ПустаяСсылка),
	|		НЕОПРЕДЕЛЕНО)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ ПЕРВЫЕ 1
	|	ИСТИНА КАК ЗначениеИстина
	|ИЗ
	|	РегистрСведений.ТаблицыГруппДоступа КАК ТаблицыГруппДоступа
	|ГДЕ
	|	ТаблицыГруппДоступа.ГруппаДоступа = ЗНАЧЕНИЕ(Справочник.ГруппыДоступа.ПустаяСсылка)";
	
	ТекстЗапросовВременныхТаблиц =
	"ВЫБРАТЬ
	|	ПраваРолейРасширений.ОбъектМетаданных КАК ОбъектМетаданных,
	|	ПраваРолейРасширений.Роль КАК Роль,
	|	ПраваРолейРасширений.ПравоИзменение КАК ПравоИзменение,
	|	ПраваРолейРасширений.ПравоДобавление КАК ПравоДобавление,
	|	ПраваРолейРасширений.ПравоЧтениеБезОграничения КАК ПравоЧтениеБезОграничения,
	|	ПраваРолейРасширений.ПравоИзменениеБезОграничения КАК ПравоИзменениеБезОграничения,
	|	ПраваРолейРасширений.ПравоДобавлениеБезОграничения КАК ПравоДобавлениеБезОграничения,
	|	ПраваРолейРасширений.ВидИзмененияСтроки КАК ВидИзмененияСтроки
	|ПОМЕСТИТЬ ПраваРолейРасширений
	|ИЗ
	|	&ПраваРолейРасширений КАК ПраваРолейРасширений
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ПраваРолейРасширений.ОбъектМетаданных КАК ОбъектМетаданных,
	|	ПраваРолейРасширений.Роль КАК Роль,
	|	ПраваРолейРасширений.ПравоИзменение КАК ПравоИзменение,
	|	ПраваРолейРасширений.ПравоДобавление КАК ПравоДобавление,
	|	ПраваРолейРасширений.ПравоЧтениеБезОграничения КАК ПравоЧтениеБезОграничения,
	|	ПраваРолейРасширений.ПравоИзменениеБезОграничения КАК ПравоИзменениеБезОграничения,
	|	ПраваРолейРасширений.ПравоДобавлениеБезОграничения КАК ПравоДобавлениеБезОграничения
	|ПОМЕСТИТЬ ПраваРолей
	|ИЗ
	|	ПраваРолейРасширений КАК ПраваРолейРасширений
	|ГДЕ
	|	ПраваРолейРасширений.ВидИзмененияСтроки = 1
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ПраваРолей.ОбъектМетаданных,
	|	ПраваРолей.Роль,
	|	ПраваРолей.ПравоИзменение,
	|	ПраваРолей.ПравоДобавление,
	|	ПраваРолей.ПравоЧтениеБезОграничения,
	|	ПраваРолей.ПравоИзменениеБезОграничения,
	|	ПраваРолей.ПравоДобавлениеБезОграничения
	|ИЗ
	|	РегистрСведений.ПраваРолей КАК ПраваРолей
	|		ЛЕВОЕ СОЕДИНЕНИЕ ПраваРолейРасширений КАК ПраваРолейРасширений
	|		ПО ПраваРолей.ОбъектМетаданных = ПраваРолейРасширений.ОбъектМетаданных
	|			И ПраваРолей.Роль = ПраваРолейРасширений.Роль
	|ГДЕ
	|	ПраваРолейРасширений.ОбъектМетаданных ЕСТЬ NULL
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ГруппыДоступа.Ссылка КАК Ссылка,
	|	ГруппыДоступа.Профиль КАК Профиль
	|ПОМЕСТИТЬ ГруппыДоступа
	|ИЗ
	|	Справочник.ГруппыДоступа КАК ГруппыДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПрофилиГруппДоступа КАК ПрофилиГруппДоступа
	|		ПО ГруппыДоступа.Профиль = ПрофилиГруппДоступа.Ссылка
	|			И (НЕ ГруппыДоступа.ПометкаУдаления)
	|			И (НЕ ПрофилиГруппДоступа.ПометкаУдаления)
	|			И (&УсловиеОтбораГруппДоступа1)
	|			И (ИСТИНА В
	|				(ВЫБРАТЬ ПЕРВЫЕ 1
	|					ИСТИНА КАК ЗначениеИстина
	|				ИЗ
	|					Справочник.ГруппыДоступа.Пользователи КАК УчастникиГруппДоступа
	|				ГДЕ
	|					УчастникиГруппДоступа.Ссылка = ГруппыДоступа.Ссылка))
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ГруппыДоступа.Профиль
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ГруппыДоступа.Профиль КАК Ссылка
	|ПОМЕСТИТЬ Профили
	|ИЗ
	|	ГруппыДоступа КАК ГруппыДоступа
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ГруппыДоступа.Профиль
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	РолиПрофилей.Ссылка КАК Профиль,
	|	ПраваРолей.ОбъектМетаданных КАК Таблица,
	|	ПраваРолей.ОбъектМетаданных.ЗначениеПустойСсылки КАК ТипТаблицы,
	|	МАКСИМУМ(ПраваРолей.ПравоИзменение) КАК ПравоИзменение,
	|	МАКСИМУМ(ПраваРолей.ПравоИзменение)
	|		И МАКСИМУМ(ПраваРолей.ПравоДобавление) КАК ПравоДобавление,
	|	МАКСИМУМ(ПраваРолей.ПравоЧтениеБезОграничения) КАК ПравоЧтениеБезОграничения,
	|	МАКСИМУМ(ПраваРолей.ПравоИзменениеБезОграничения) КАК ПравоИзменениеБезОграничения,
	|	МАКСИМУМ(ПраваРолей.ПравоИзменениеБезОграничения)
	|		И МАКСИМУМ(ПраваРолей.ПравоДобавлениеБезОграничения) КАК ПравоДобавлениеБезОграничения
	|ПОМЕСТИТЬ ТаблицыПрофилей
	|ИЗ
	|	Справочник.ПрофилиГруппДоступа.Роли КАК РолиПрофилей
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Профили КАК Профили
	|		ПО (Профили.Ссылка = РолиПрофилей.Ссылка)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ПраваРолей КАК ПраваРолей
	|		ПО (&УсловиеОтбораТаблиц1)
	|			И (ПраваРолей.Роль = РолиПрофилей.Роль)
	|			И (НЕ ПраваРолей.Роль.ПометкаУдаления)
	|			И (НЕ ПраваРолей.ОбъектМетаданных.ПометкаУдаления)
	|
	|СГРУППИРОВАТЬ ПО
	|	РолиПрофилей.Ссылка,
	|	ПраваРолей.ОбъектМетаданных,
	|	ПраваРолей.ОбъектМетаданных.ЗначениеПустойСсылки
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ПраваРолей.ОбъектМетаданных
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ТаблицыПрофилей.Таблица КАК Таблица,
	|	ГруппыДоступа.Ссылка КАК ГруппаДоступа,
	|	ТаблицыПрофилей.ПравоИзменение КАК ПравоИзменение,
	|	ТаблицыПрофилей.ПравоДобавление КАК ПравоДобавление,
	|	ТаблицыПрофилей.ПравоЧтениеБезОграничения КАК ПравоЧтениеБезОграничения,
	|	ТаблицыПрофилей.ПравоИзменениеБезОграничения КАК ПравоИзменениеБезОграничения,
	|	ТаблицыПрофилей.ПравоДобавлениеБезОграничения КАК ПравоДобавлениеБезОграничения,
	|	ТаблицыПрофилей.ТипТаблицы КАК ТипТаблицы
	|ПОМЕСТИТЬ НовыеДанные
	|ИЗ
	|	ТаблицыПрофилей КАК ТаблицыПрофилей
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ГруппыДоступа КАК ГруппыДоступа
	|		ПО (ГруппыДоступа.Профиль = ТаблицыПрофилей.Профиль)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ТаблицыПрофилей.Таблица,
	|	ГруппыДоступа.Ссылка";
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	НовыеДанные.Таблица,
	|	НовыеДанные.ГруппаДоступа,
	|	НовыеДанные.ПравоИзменение,
	|	НовыеДанные.ПравоДобавление,
	|	НовыеДанные.ПравоЧтениеБезОграничения,
	|	НовыеДанные.ПравоИзменениеБезОграничения,
	|	НовыеДанные.ПравоДобавлениеБезОграничения,
	|	НовыеДанные.ТипТаблицы,
	|	&ПодстановкаПоляВидИзмененияСтроки
	|ИЗ
	|	НовыеДанные КАК НовыеДанные";
	
	// Подготовка выбираемых полей с необязательным отбором.
	Поля = Новый Массив; 
	Поля.Добавить(Новый Структура("Таблица",       "&УсловиеОтбораТаблиц2"));
	Поля.Добавить(Новый Структура("ГруппаДоступа", "&УсловиеОтбораГруппДоступа2"));
	Поля.Добавить(Новый Структура("ПравоИзменение"));
	Поля.Добавить(Новый Структура("ПравоДобавление"));
	Поля.Добавить(Новый Структура("ПравоЧтениеБезОграничения"));
	Поля.Добавить(Новый Структура("ПравоИзменениеБезОграничения"));
	Поля.Добавить(Новый Структура("ПравоДобавлениеБезОграничения"));
	Поля.Добавить(Новый Структура("ТипТаблицы"));
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ПраваРолейРасширений", УправлениеДоступомСлужебный.ПраваРолейРасширений());
	Запрос.Текст = УправлениеДоступомСлужебный.ТекстЗапросаВыбораИзменений(
		ТекстЗапроса, Поля, "РегистрСведений.ТаблицыГруппДоступа", ТекстЗапросовВременныхТаблиц);
	
	УправлениеДоступомСлужебный.УстановитьУсловиеОтбораВЗапросе(Запрос, Таблицы, "Таблицы",
		"&УсловиеОтбораТаблиц1:ПраваРолей.ОбъектМетаданных
		|&УсловиеОтбораТаблиц2:СтарыеДанные.Таблица");
	
	УправлениеДоступомСлужебный.УстановитьУсловиеОтбораВЗапросе(Запрос, ГруппыДоступа, "ГруппыДоступа",
		"&УсловиеОтбораГруппДоступа1:ГруппыДоступа.Ссылка
		|&УсловиеОтбораГруппДоступа2:СтарыеДанные.ГруппаДоступа");
		
	Блокировка = Новый БлокировкаДанных;
	Если ГруппыДоступа = Неопределено Тогда
		Блокировка.Добавить("РегистрСведений.ТаблицыГруппДоступа");
	Иначе
		ЗначенияБлокировки = ?(ТипЗнч(ГруппыДоступа) = Тип("Массив"), ГруппыДоступа,
			ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ГруппыДоступа));
		Для Каждого ЗначениеБлокировки Из ЗначенияБлокировки Цикл
			ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.ТаблицыГруппДоступа");
			ЭлементБлокировки.УстановитьЗначение("ГруппаДоступа", ЗначениеБлокировки);
		КонецЦикла;
	КонецЕсли;
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		Результаты = ЗапросПустыхЗаписей.ВыполнитьПакет();
		Если Не Результаты[0].Пустой() Тогда
			Выборка = Результаты[0].Выбрать();
			Пока Выборка.Следующий() Цикл
				НаборЗаписей = СоздатьНаборЗаписей();
				НаборЗаписей.Отбор.Таблица.Установить(Выборка.Таблица);
				ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(НаборЗаписей);
			КонецЦикла;
			ЕстьИзменения = Истина;
		КонецЕсли;
		Если Не Результаты[1].Пустой() Тогда
			НаборЗаписей = СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.ГруппаДоступа.Установить(Справочники.ГруппыДоступа.ПустаяСсылка());
			ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(НаборЗаписей);
			ЕстьИзменения = Истина;
		КонецЕсли;
		
		Если ГруппыДоступа <> Неопределено
		   И Таблицы        = Неопределено Тогда
			
			ИзмеренияОтбора = "ГруппаДоступа";
		Иначе
			ИзмеренияОтбора = Неопределено;
		КонецЕсли;
		
		Данные = Новый Структура;
		Данные.Вставить("МенеджерРегистра",      РегистрыСведений.ТаблицыГруппДоступа);
		Данные.Вставить("ИзмененияСоставаСтрок", Запрос.Выполнить().Выгрузить());
		Данные.Вставить("ИзмеренияОтбора",       ИзмеренияОтбора);
		
		ЕстьТекущиеИзменения = Ложь;
		УправлениеДоступомСлужебный.ОбновитьРегистрСведений(Данные, ЕстьТекущиеИзменения);
		Если ЕстьТекущиеИзменения Тогда
			ЕстьИзменения = Истина;
			СоставИзменений = Данные.ИзмененияСоставаСтрок.Скопировать(, "Таблица");
			СоставИзменений.Свернуть("Таблица");
			ИзменениеТаблиц = СоставИзменений.ВыгрузитьКолонку("Таблица");
			РегистрыСведений.ИспользуемыеВидыДоступаПоТаблицам.ОбновитьДанныеРегистра(ИзменениеТаблиц);
		КонецЕсли;
		
		Если ЕстьТекущиеИзменения
		   И УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
			
			// Планирование обновления доступа.
			УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступаПриИзмененииТаблицГруппДоступа(СоставИзменений);
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли
