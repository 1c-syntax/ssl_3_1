﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Устанавливает состояние оригинала для выделенных документов. Вызывается через подсистему "Подключаемые команды".
//
//	Параметры:
//  МассивСсылок - ОпределяемыйТип.ОбъектСУчетомОригиналовПервичныхДокументов - ссылка на документ.
//  Параметры -см. ПодключаемыеКоманды.ПараметрыВыполненияКоманды.
//
Процедура Подключаемый_УстановитьСостояниеОригинала(МассивСсылок, Параметры) Экспорт
	
	Если ТипЗнч(Параметры.Источник) = Тип("ТаблицаФормы") Тогда 
		УстановитьСостояниеОригиналаФормаСписка(Параметры, Параметры.Источник);
	Иначе
		Ссылка = МассивСсылок[0];
		УстановитьСостояниеОригиналаФормаДокумента(Ссылка, Параметры);
	КонецЕсли;
	
КонецПроцедуры

// Устанавливает состояние оригинала для выделенных документов. Вызывается без подключения подсистемы "Подключаемые команды".
//
//	Параметры:
//  ИмяКоманды - Строка- имя выполняемой команды формы.
//  Форма - ФормаКлиентскогоПриложения - форма списка или документа.
//  Список - ТаблицаФормы - список формы, в котором будет происходить изменение состояния. Если состояние устанавливается
//  						из формы документа, то Неопределено.
//
Процедура УстановитьСостояниеОригинала(ИмяКоманды, Форма, Список = Неопределено) Экспорт
	
	Параметры = ПодключаемыеКомандыКлиент.ПараметрыВыполненияКоманды();
	
	Параметры.ОписаниеКоманды = Новый Структура("Идентификатор", ИмяКоманды);
	
	Если ИмяКоманды = "УстановкаСостоянияОригиналПолучен" Тогда
		СостояниеОригинала = ПредопределенноеЗначение("Справочник.СостоянияОригиналовПервичныхДокументов.ОригиналПолучен");
		ДополнительныеПараметры = Новый Структура("СсылкаНаСостояние", СостояниеОригинала);
		Параметры.ОписаниеКоманды.Вставить("ДополнительныеПараметры", ДополнительныеПараметры);
	ИначеЕсли Не ИмяКоманды = "НастройкаСостояний" И Не ИмяКоманды = "УточнитьПоПечатнымФормам" Тогда
		СостояниеОригинала = УчетОригиналовПервичныхДокументовВызовСервера.СостояниеОригиналаПервичногоДокументаПоИмениКоманды(ИмяКоманды);
		ДополнительныеПараметры = Новый Структура("СсылкаНаСостояние", СостояниеОригинала);
		Параметры.ОписаниеКоманды.Вставить("ДополнительныеПараметры", ДополнительныеПараметры);
	КонецЕсли;

	Если Список = Неопределено Тогда
		УстановитьСостояниеОригиналаФормаДокумента(Форма.Объект.Ссылка, Параметры);
		Возврат;
	КонецЕсли;
	
	УстановитьСостояниеОригиналаФормаСписка(Параметры, Список);
	
КонецПроцедуры

// Открывает на форме списка или документа выпадающие меню выбора состояния оригинала.
//
//	Параметры:
//  Форма - ФормаКлиентскогоПриложения - основной реквизит формы.
//  Источник - ТаблицаФормы - список или декорация формы, у которого будет открыт выпадающий список.
//                            Если не задан, то элемент с именем "ДекорацияСостояниеОригинала".
//
Процедура ОткрытьМенюВыбораСостояния(Знач Форма, Знач Источник = Неопределено) Экспорт 
	
	Если ТипЗнч(Источник) = Неопределено Тогда
		Источник = Форма.Элементы.Найти("ДекорацияСостояниеОригинала");
	КонецЕсли;
	
	Если ТипЗнч(Источник) = Тип("ТаблицаФормы") Тогда
		ДанныеЗаписи = Источник.ТекущиеДанные;
		Документ = ДанныеЗаписи.Ссылка;
		НеобходимоУточнитьПоПечатнымФормам = ДанныеЗаписи.ОбщееСостояние 
			Или Не ЗначениеЗаполнено(ДанныеЗаписи.СостояниеОригиналаПервичногоДокумента);
		ЭлементФормыИсточник = Форма.Элементы.СостояниеОригиналаПервичногоДокумента;
	Иначе
		ДанныеЗаписи = Новый Структура("Ссылка", Форма.Объект.Ссылка);
		Документ = Форма.Объект.Ссылка;
		НеобходимоУточнитьПоПечатнымФормам = Истина;
		ЭлементФормыИсточник = Источник;
	КонецЕсли;
	
	Если Документ.Пустая() Тогда
		ПоказатьПредупреждение(,НСтр("ru = 'Для установки состояния оригинала предварительно проведите документ.'"));
		Возврат;
	КонецЕсли;

	Результат = ПодключаемыеКомандыКлиент.СведенияОПроведенииДокументов(
		ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Документ));
	Если Результат.НепроведенныеДокументы.Количество() = 1 Тогда
		ТекстСообщения = ?(Результат.ЕстьПравоПроведения, 
			НСтр("ru = 'Для установки состояния оригинала предварительно проведите документ.'"),
			НСтр("ru = 'Невозможно установить состояние оригинала, т.к. нет прав на проведение документа.'"));
		ПоказатьПредупреждение(, ТекстСообщения);
		Возврат;
	КонецЕсли;
	
	ПараметрыРаботыКлиента = СтандартныеПодсистемыКлиент.ПараметрыРаботыКлиента();
	ОткрытьФорму = Не ПараметрыРаботыКлиента.УчетОригиналовПервичныхДокументов.ОткрыватьВыпадающиеМенюПоГиперссылке; 
	Если ОткрытьФорму Тогда
		ОткрытьФормуИзмененияСостоянийПечатныхФорм(Документ);
		Возврат;
	КонецЕсли;

	УточнитьПоПечатнымФормам = Форма.СписокВыбораСостоянийОригинала.НайтиПоЗначению("УточнитьПоПечатнымФормам");
	Если НеобходимоУточнитьПоПечатнымФормам Тогда
		Если УточнитьПоПечатнымФормам = Неопределено Тогда
			Форма.СписокВыбораСостоянийОригинала.Добавить("УточнитьПоПечатнымФормам",
				НСтр("ru = 'Уточнить по печатным формам...'"),,
				БиблиотекаКартинок.УточнитьСостояниеОригиналаПервичногоДокументаПоПечатнымФормам);
		КонецЕсли;
	ИначеЕсли УточнитьПоПечатнымФормам <> Неопределено Тогда
		Форма.СписокВыбораСостоянийОригинала.Удалить(УточнитьПоПечатнымФормам);
	КонецЕсли;

	ОписаниеОповещения = Новый ОписаниеОповещения("ОткрытьМенюВыбораСостоянияЗавершение", ЭтотОбъект, ДанныеЗаписи);
	Форма.ПоказатьВыборИзМеню(ОписаниеОповещения, Форма.СписокВыбораСостоянийОригинала, ЭлементФормыИсточник);

КонецПроцедуры

// Обработчик оповещения событий подсистемы "Учет оригиналов первичных документов" для формы документа.
//
//	Параметры:
//  ИмяСобытия - Строка - имя произошедшего события.
//  Форма - ФормаКлиентскогоПриложения - форма документа. 
//   Источник - ОпределяемыйТип.ОбъектСУчетомОригиналовПервичныхДокументов - ссылка на документ, источник события.
//            - Массив из ОпределяемыйТип.ОбъектСУчетомОригиналовПервичныхДокументов:
//         * Ссылка - ОпределяемыйТип.ОбъектСУчетомОригиналовПервичныхДокументов - ссылка на документ, источник события.
//
Процедура ОбработчикОповещенияФормаДокумента(ИмяСобытия, Форма, Источник = Неопределено) Экспорт
		
	Если ИмяСобытия = "Запись_РегистрСведенийСостоянияОригиналовПервичныхДокументов" 
		И ((ТипЗнч(Источник) = Тип("Массив") И Источник.Найти(Форма.Объект.Ссылка) <> Неопределено)
		Или Источник = Неопределено Или Источник = Форма.Объект.Ссылка) Тогда 
		ОбновитьТекущееСостоянияОригиналаНаФормеДокумента(Форма);
	ИначеЕсли ИмяСобытия = "Запись_СостоянияОригиналовПервичныхДокументов" Тогда	
		ПодменюСостояниеОригинала = Форма.Элементы.Найти("ПодменюУстановитьНастроитьСостояниеОригинала");
		Если ПодменюСостояниеОригинала <> Неопределено Тогда
			Форма.ОтключитьОбработчикОжидания("Подключаемый_ОбновитьКомандыСостоянияОригинала");
			Форма.ПодключитьОбработчикОжидания("Подключаемый_ОбновитьКомандыСостоянияОригинала", 0.2, Истина);
			НастроитьКнопкиНаФормеДокумента(Форма);
		КонецЕсли;
		СтруктураПоиска = Новый Структура;
 		СтруктураПоиска.Вставить("СписокВыбораСостоянийОригинала", Неопределено);
 		ЗаполнитьЗначенияСвойств(СтруктураПоиска, Форма);
 		Если СтруктураПоиска.СписокВыбораСостоянийОригинала <> Неопределено Тогда
			УчетОригиналовПервичныхДокументовВызовСервера.ЗаполнитьСписокВыбораСостоянийОригинала(Форма.СписокВыбораСостоянийОригинала); 
		КонецЕсли;
		Форма.ОбновитьОтображениеДанных();	
	КонецЕсли;
		
КонецПроцедуры

// Обработчик оповещения событий подсистемы "Учет оригиналов первичных документов" для формы списка.
//
//	Параметры:
//  ИмяСобытия - Строка - имя произошедшего события.
//  Форма - ФормаКлиентскогоПриложения - форма списка документов.
//  Список - ТаблицаФормы - основной список формы.
//  Источник - ОпределяемыйТип.ОбъектСУчетомОригиналовПервичныхДокументов - ссылка на документ, источник события.
//           - Массив из ОпределяемыйТип.ОбъектСУчетомОригиналовПервичныхДокументов:
//         * Ссылка - ОпределяемыйТип.ОбъектСУчетомОригиналовПервичныхДокументов - ссылка на документ, источник события.
//
Процедура ОбработчикОповещенияФормаСписка(ИмяСобытия, Форма, Список, Источник = Неопределено) Экспорт 
	
	Если ИмяСобытия = "Запись_СостоянияОригиналовПервичныхДокументов" Тогда
		СтруктураПоиска = Новый Структура;
 		СтруктураПоиска.Вставить("СписокВыбораСостоянийОригинала", Неопределено);
 		ЗаполнитьЗначенияСвойств(СтруктураПоиска, Форма);
 		Если СтруктураПоиска.СписокВыбораСостоянийОригинала<> Неопределено Тогда
			Форма.ОтключитьОбработчикОжидания("Подключаемый_ОбновитьКомандыСостоянияОригинала");
			Форма.ПодключитьОбработчикОжидания("Подключаемый_ОбновитьКомандыСостоянияОригинала", 0.2, Истина);
			УчетОригиналовПервичныхДокументовВызовСервера.ЗаполнитьСписокВыбораСостоянийОригинала(Форма.СписокВыбораСостоянийОригинала);
			Форма.ОбновитьОтображениеДанных();
		Иначе
			Возврат;
		КонецЕсли;
	ИначеЕсли ИмяСобытия = "Запись_РегистрСведенийСостоянияОригиналовПервичныхДокументов" Тогда
		Список.Обновить();
	КонецЕсли;

КонецПроцедуры

// Обработчик события "Выбор" списка.
//
//	Параметры:
//  ИмяПоля - Строка - наименование выбранного поля.
//  Форма - ФормаКлиентскогоПриложения - форма списка документов.
//  Список - ТаблицаФормы - основной список формы.
//  СтандартнаяОбработка - Булево - Истина, если в форме используется стандартная обработка события "Выбор"
//
Процедура СписокВыбор(ИмяПоля, Форма, Список, СтандартнаяОбработка) Экспорт 
	
	Если ИмяПоля = "СостояниеОригиналаПервичногоДокумента" Или ИмяПоля = "СостояниеОригиналПолучен" Тогда
		СтандартнаяОбработка = Ложь;
		Если УчетОригиналовПервичныхДокументовВызовСервера.ЭтоОбъектУчета(Список.ТекущиеДанные.Ссылка) Тогда
			Если ИмяПоля = "СостояниеОригиналаПервичногоДокумента" Тогда
				ОткрытьМенюВыбораСостояния(Форма, Список);
			ИначеЕсли ИмяПоля = "СостояниеОригиналПолучен" Тогда
				УстановитьСостояниеОригинала("УстановкаСостоянияОригиналПолучен", Форма, Список);
			КонецЕсли;
		Иначе
			ПоказатьПредупреждение(, НСтр("ru = 'Для данного документа учет оригиналов не ведется.'"));
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

// Процедура обрабатывает действия по учету оригиналов после сканирования штрихкода документа.
//
//	Параметры:
//  Штрихкод - Строка - отсканированный штрихкод документа.
//  ИмяСобытия - Строка - имя события формы.
//
Процедура ОбработатьШтрихкод(Штрихкод, ИмяСобытия) Экспорт
	
	Если ИмяСобытия = "ScanData" Тогда
		Состояние(НСтр("ru = 'Выполняется установка состояния оригинала по штрихкоду...'"));
		УчетОригиналовПервичныхДокументовВызовСервера.ОбработатьШтрихкод(Штрихкод[0]);
	КонецЕсли;
	
КонецПроцедуры

// Процедура показывает пользователю оповещение об изменении состояний оригинала документа.
//
//	Параметры:
//  КоличествоОбработанных - Число - количество успешно обработанных документов.
//  Документ - ОпределяемыйТип.ОбъектСУчетомОригиналовПервичныхДокументов - ссылка на документ для обработки нажатия 
//			   на оповещение пользователя в случае единичной установки состояния. Необязательный параметр.
//  СостояниеОригинала - СправочникСсылка.СостоянияОригиналовПервичныхДокументов - ссылка на устанавливаемое состояние.
//
Процедура ОповеститьПользователяОбУстановкеСостояний(КоличествоОбработанных, Документ = Неопределено, СостояниеОригинала = Неопределено) Экспорт

	Если КоличествоОбработанных > 1 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru='Состояние оригинала ""%1"" установлено для всех выделенных в списке документов.'"), Строка(СостояниеОригинала));
		
		ТекстЗаголовка = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru='""%1"" установлено'"), Строка(СостояниеОригинала));

		ПоказатьОповещениеПользователя(ТекстЗаголовка,, ТекстСообщения, БиблиотекаКартинок.ДиалогИнформация, СтатусОповещенияПользователя.Информация);
	Иначе
		ОписаниеОповещения = Новый ОписаниеОповещения("ОбработатьНажатиеНаОповещение", ЭтотОбъект, Документ);
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru='""%1"" установлено:'"), Строка(СостояниеОригинала));
		ПоказатьОповещениеПользователя(ТекстСообщения, ОписаниеОповещения, Документ, БиблиотекаКартинок.ДиалогИнформация,
			СтатусОповещенияПользователя.Информация);
	КонецЕсли;

КонецПроцедуры

// Открывает форму списка справочника "СостоянияОригиналовПервичныхДокументов".
Процедура ОткрытьФормуНастройкиСостояний() Экспорт
	
	ОткрытьФорму("Справочник.СостоянияОригиналовПервичныхДокументов.ФормаСписка");

КонецПроцедуры

// Вызывается для записи состояний оригиналов печатных форм в регистр, после печати формы.
//
//	Параметры:
//  ОбъектыПечати - СписокЗначений - список ссылок на объекты печати.
//  СписокПечати - СписокЗначений - список с именами макетов и представлениями печатных форм.
//  Записано - Булево - признак того, что состояние документа записано в регистр.
//
Процедура ЗаписатьСостоянияОригиналовПослеПечати(ОбъектыПечати, СписокПечати, Записано = Ложь) Экспорт

	УчетОригиналовПервичныхДокументовВызовСервера.ЗаписатьСостоянияОригиналовПослеПечатиФорм(ОбъектыПечати, СписокПечати, Записано);
	Если СписокПечати.Количество() = 0 Или Записано = Ложь Тогда
		Возврат;
	КонецЕсли;

	Оповестить("Запись_РегистрСведенийСостоянияОригиналовПервичныхДокументов",, ОбъектыПечати.ВыгрузитьЗначения());
	
	Если ОбъектыПечати.Количество() > 1 Тогда
		ОповеститьПользователяОбУстановкеСостояний(ОбъектыПечати.Количество(),,ПредопределенноеЗначение("Справочник.СостоянияОригиналовПервичныхДокументов.ФормаНапечатана"));
	ИначеЕсли ОбъектыПечати.Количество() = 1 Тогда
		ОповеститьПользователяОбУстановкеСостояний(1,ОбъектыПечати[0].Значение,ПредопределенноеЗначение("Справочник.СостоянияОригиналовПервичныхДокументов.ФормаНапечатана"));
	КонецЕсли;
	
КонецПроцедуры

// Открывает форму уточнения состояний печатных форм документа.
//
//	Параметры:
//  ДокументСсылка - ОпределяемыйТип.ОбъектСУчетомОригиналовПервичныхДокументов - ссылка на документ,для которого 
//  				 необходимо получить ключ записи общего состояния.
//
Процедура ОткрытьФормуИзмененияСостоянийПечатныхФорм(ДокументСсылка) Экспорт

	КлючЗаписиРегистра = УчетОригиналовПервичныхДокументовВызовСервера.КлючЗаписиОбщегоСостояния(ДокументСсылка);
	
	ПередаваемыеПараметры = Новый Структура;
	Если КлючЗаписиРегистра = Неопределено Тогда
		ПередаваемыеПараметры.Вставить("ДокументСсылка", ДокументСсылка);
	Иначе
		ПередаваемыеПараметры.Вставить("Ключ", КлючЗаписиРегистра);
	КонецЕсли;
	ОткрытьФорму("РегистрСведений.СостоянияОригиналовПервичныхДокументов.Форма.ИзменениеСостоянийОригиналовПервичныхДокументов",
		ПередаваемыеПараметры);

КонецПроцедуры

// Вызывается при открытии журнала оригиналов первичных документов в случае использования подключаемого оборудования.
// Позволяет определить собственный процесс подключения подключаемого оборудования к журналу.
//	
//	Параметры:
//  Форма - ФормаКлиентскогоПриложения - форма списка документа.
//
Процедура ПриПодключенииСканераШтрихкода(Форма) Экспорт
	
	ИнтеграцияПодсистемБСПКлиент.ПриПодключенииСканераШтрихкодаКЖурналуУчетаОригиналов(Форма);
	УчетОригиналовПервичныхДокументовКлиентПереопределяемый.ПриПодключенииСканераШтрихкода(Форма);

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура УстановитьСостояниеОригиналаФормаСписка(Параметры, Список)	
	
	МассивСтрок = Новый Массив; // см. УчетОригиналовПервичныхДокументовВызовСервера.УстановитьНовоеСостояниеОригинала.ОбъектыЗаписи
	Для Каждого СтрокаСписка Из Список.ВыделенныеСтроки Цикл
		ДанныеСтроки = Список.ДанныеСтроки(СтрокаСписка);
		МассивСтрок.Добавить(ДанныеСтроки);
	КонецЦикла;

	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("МассивСтрок", МассивСтрок);
	ДополнительныеПараметры.Вставить("МножественноеИзменение", Истина);
	
	Если Параметры.ОписаниеКоманды.Идентификатор = "НастройкаСостояний" Тогда
		ОткрытьФормуНастройкиСостояний();
		Возврат;
	КонецЕсли;
	
	СостояниеОригинала = Параметры.ОписаниеКоманды.ДополнительныеПараметры.СсылкаНаСостояние;

	ДополнительныеПараметры.Вставить("СостояниеОригинала", СостояниеОригинала);
	
	Если МассивСтрок.Количество() > 1 Тогда
		ТекстВопроса = НСтр("ru = 'У выделенных в списке документов будет установлено состояние оригинала ""%ИмяСостояния%"". Продолжить?'");
		ТекстВопроса = СтрЗаменить(ТекстВопроса, "%ИмяСостояния%", Строка(СостояниеОригинала));

		Кнопки = Новый СписокЗначений;
		Кнопки.Добавить(КодВозвратаДиалога.Да,НСтр("ru = 'Установить'"));
		Кнопки.Добавить(КодВозвратаДиалога.Нет,НСтр("ru = 'Не устанавливать'"));
		ПоказатьВопрос(Новый ОписаниеОповещения("УстановитьСостояниеОригиналаЗавершение", ЭтотОбъект, ДополнительныеПараметры), ТекстВопроса, Кнопки); 
		
	ИначеЕсли УчетОригиналовПервичныхДокументовВызовСервера.ЭтоОбъектУчета(МассивСтрок[0].Ссылка) Тогда 
		УстановитьСостояниеОригиналаЗавершение(КодВозвратаДиалога.Да, ДополнительныеПараметры);
	Иначе
		ПоказатьПредупреждение(, НСтр("ru = 'Для данного документа учет оригиналов не ведется.'"));
	КонецЕсли;
	
КонецПроцедуры

Процедура УстановитьСостояниеОригиналаФормаДокумента(Ссылка, Параметры)
			
	Если Параметры.ОписаниеКоманды.Идентификатор = "НастройкаСостояний" Тогда
		ОткрытьФормуНастройкиСостояний();
	ИначеЕсли Параметры.ОписаниеКоманды.Идентификатор = "УточнитьПоПечатнымФормам" Тогда
		ОткрытьФормуИзмененияСостоянийПечатныхФорм(Ссылка);
	Иначе
		СостояниеОригинала = Параметры.ОписаниеКоманды.ДополнительныеПараметры.СсылкаНаСостояние;
		ДополнительныеПараметры = Новый Структура;
		ДополнительныеПараметры.Вставить("СостояниеОригинала", СостояниеОригинала); 
		ДополнительныеПараметры.Вставить("Ссылка", Ссылка);
		ДополнительныеПараметры.Вставить("МножественноеИзменение", Ложь);
		УстановитьСостояниеОригиналаЗавершение(КодВозвратаДиалога.Да, ДополнительныеПараметры);
	КонецЕсли;
	
КонецПроцедуры

// Формирует надпись для вывода информации о текущем состоянии на форму документа.
//
//	Параметры:
//  Форма - ФормаКлиентскогоПриложения - форма документа.
//
Процедура ОбновитьТекущееСостоянияОригиналаНаФормеДокумента(Форма)
	
	НастроитьКнопкиНаФормеДокумента(Форма);

	ДекорацияСостояниеОригинала = Форма.Элементы.Найти("ДекорацияСостояниеОригинала");
	Если ДекорацияСостояниеОригинала = Неопределено Тогда
		Возврат;
	КонецЕсли;
		 
	Если ЗначениеЗаполнено(Форма.Объект.Ссылка) Тогда
		ТекущиеСостояниеОригинала = УчетОригиналовПервичныхДокументовВызовСервера.СведенияОСостоянииОригиналаПоСсылке(Форма.Объект.Ссылка);
		Если ТекущиеСостояниеОригинала.Количество() = 0 Тогда
			ТекущиеСостояниеОригинала=НСтр("ru='<Состояние оригинала неизвестно>'");
			ДекорацияСостояниеОригинала.ЦветТекста = WebЦвета.Серебряный;
		Иначе
			ТекущиеСостояниеОригинала = ТекущиеСостояниеОригинала.СостояниеОригиналаПервичногоДокумента;
			ДекорацияСостояниеОригинала.ЦветТекста = Новый Цвет;
		КонецЕсли;
	Иначе
		ДекорацияСостояниеОригинала.ЦветТекста = WebЦвета.Серебряный;
	КонецЕсли;

	ДекорацияСостояниеОригинала.Заголовок = ТекущиеСостояниеОригинала;
	
КонецПроцедуры

Процедура НастроитьКнопкиНаФормеДокумента(Форма)
	
	ПодменюСостояниеОригинала = Форма.Элементы.Найти("ПодменюУстановитьНастроитьСостояниеОригинала");
	Если ПодменюСостояниеОригинала = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ПодменюСостояниеОригинала.Отображение = ОтображениеКнопки.Картинка;
	ПодменюСостояниеОригинала.Картинка = БиблиотекаКартинок.СостояниеОригиналаПервичногоДокументаОригиналНеПолучен;
		
	Если ЗначениеЗаполнено(Форма.Объект.Ссылка) Тогда
		Сведения = УчетОригиналовПервичныхДокументовВызовСервера.СведенияОСостоянииОригиналаПоСсылке(Форма.Объект.Ссылка);
		Если Не Сведения.Количество() = 0 Тогда 
			ТекущиеСостояниеОригинала = Сведения.СостояниеОригиналаПервичногоДокумента;
			Картинка = ?(ТекущиеСостояниеОригинала = ПредопределенноеЗначение("Справочник.СостоянияОригиналовПервичныхДокументов.ОригиналПолучен"),
			БиблиотекаКартинок.СостояниеОригиналаПервичногоДокументаОригиналПолучен,
			БиблиотекаКартинок.СостояниеОригиналаПервичногоДокументаОригиналНеПолучен);
			ПодменюСостояниеОригинала.Отображение = ОтображениеКнопки.КартинкаИТекст;
			ПодменюСостояниеОригинала.Заголовок = ТекущиеСостояниеОригинала;
			ПодменюСостояниеОригинала.Картинка = Картинка;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

// Обработчик оповещения, вызванного после завершения работы процедуры УстановитьСостояниеОригинала(...).
Процедура УстановитьСостояниеОригиналаЗавершение(Ответ, ДополнительныеПараметры) Экспорт

	Если Ответ <> КодВозвратаДиалога.Да Тогда
		Возврат;
	КонецЕсли;
	
	СостояниеОригинала = ДополнительныеПараметры.СостояниеОригинала;
	
	МассивСсылок = Новый Массив;
	Если ДополнительныеПараметры.МножественноеИзменение Тогда
		ОбъектыЗаписи = ДополнительныеПараметры.МассивСтрок;
		Для Каждого Объект Из ОбъектыЗаписи Цикл
			МассивСсылок.Добавить(Объект.Ссылка);
		КонецЦикла;
	Иначе
 		ОбъектыЗаписи = ДополнительныеПараметры.Ссылка;
		МассивСсылок.Добавить(ДополнительныеПараметры.Ссылка);
	КонецЕсли;
	
	Изменено = УчетОригиналовПервичныхДокументовВызовСервера.УстановитьНовоеСостояниеОригинала(ОбъектыЗаписи, СостояниеОригинала);
	Если Изменено = "НеПроведено" Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Для установки состояния оригиналов предварительно проведите выделенные документы.'"));
		Возврат;
	ИначеЕсли Изменено = "НеИзменено" Тогда
		Возврат;
	КонецЕсли;

	Если Не ТипЗнч(ОбъектыЗаписи) = Тип("Массив") Тогда
		ОповеститьПользователяОбУстановкеСостояний(1, ОбъектыЗаписи, СостояниеОригинала); 
	ИначеЕсли ОбъектыЗаписи.Количество() = 1 Тогда 
		ОповеститьПользователяОбУстановкеСостояний(1, ОбъектыЗаписи[0].Ссылка, СостояниеОригинала);
	Иначе
		ОповеститьПользователяОбУстановкеСостояний(ОбъектыЗаписи.Количество(), , СостояниеОригинала);
	КонецЕсли;
	
	Оповестить("Запись_РегистрСведенийСостоянияОригиналовПервичныхДокументов",, МассивСсылок);

КонецПроцедуры

// Обработчик оповещения, вызванного после завершения работы процедуры ОткрытьМенюВыбораСостояния(...).
//	
//	Параметры:
//  ВыбранноеСостояниеИзСписка - Строка - выбранное пользователем состояние оригинала.
//  ДополнительныеПараметры - Структура - сведения необходимые для установки состояния оригинала:
//                            * Ссылка - ДокументСсылка - ссылка на документ для установки состояния оригинала.
//       	                - Массив из ДокументСсылка:
//                            * Ссылка - ДокументСсылка - ссылка на документ для установки состояния оригинала.
//
Процедура ОткрытьМенюВыбораСостоянияЗавершение(ВыбранноеСостояниеИзСписка, ДополнительныеПараметры) Экспорт

	Если ВыбранноеСостояниеИзСписка = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Ссылка = ДополнительныеПараметры.Ссылка;
	Если ТипЗнч(ДополнительныеПараметры) = Тип("ДанныеФормыСтруктура") Тогда 
		ДанныеЗаписи = Новый Массив;
		ДанныеЗаписи.Добавить(ДополнительныеПараметры);  
	Иначе
		ДанныеЗаписи = ДополнительныеПараметры.Ссылка;
	КонецЕсли;
			
	Если ВыбранноеСостояниеИзСписка.Значение = "УточнитьПоПечатнымФормам" Тогда
		ОткрытьФормуИзмененияСостоянийПечатныхФорм(Ссылка);
		Возврат;
	КонецЕсли;
	
	Изменено = УчетОригиналовПервичныхДокументовВызовСервера.УстановитьНовоеСостояниеОригинала(ДанныеЗаписи, 
		ВыбранноеСостояниеИзСписка.Значение);
	Если Изменено = "Изменено" Тогда
		ОповеститьПользователяОбУстановкеСостояний(1, Ссылка, ВыбранноеСостояниеИзСписка.Значение);
		Оповестить("Запись_РегистрСведенийСостоянияОригиналовПервичныхДокументов",, Ссылка);
	ИначеЕсли Изменено = "НеПроведено" Тогда
		ПоказатьПредупреждение(, НСтр("ru = 'Для установки состояния оригиналов предварительно проведите выделенные документы.'"));
	КонецЕсли;

КонецПроцедуры

// Обработчик оповещения, вызванного после завершения работы процедуры ОповеститьПользователяОбУстановкеСостояний(...).
Процедура ОбработатьНажатиеНаОповещение(ДополнительныеПараметры) Экспорт

	ПоказатьЗначение(,ДополнительныеПараметры);

КонецПроцедуры

#КонецОбласти
