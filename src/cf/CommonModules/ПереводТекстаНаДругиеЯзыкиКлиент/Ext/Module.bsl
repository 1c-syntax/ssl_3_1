﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

Процедура ПерейтиКНастройкам(Владелец, ОбработчикЗавершения, ЭтоКонтекстныйВызов = Ложь) Экспорт
	
	Параметры = Новый Структура;
	Параметры.Вставить("ЭтоКонтекстныйВызов", ЭтоКонтекстныйВызов);
	
	ОткрытьФорму("ОбщаяФорма.НастройкаПереводаТекста", Параметры, Владелец, , , , ОбработчикЗавершения);
	
КонецПроцедуры

Процедура ПроверитьНастройки(Форма, ОбработчикЗавершения) Экспорт
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПриЗавершенииНастройки", ЭтотОбъект, ОбработчикЗавершения);

	Если ПереводТекстаНаДругиеЯзыкиВызовСервера.ТребуетсяНастройка() Тогда
		ПерейтиКНастройкам(Форма, ОписаниеОповещения, Истина);
		Возврат;
	КонецЕсли;
	
	ПриЗавершенииНастройки(Истина, ОбработчикЗавершения);
	
КонецПроцедуры

Процедура ПеревестиТекстыТабличногоДокумента(ТабличныйДокумент, ЯзыкПеревода, ИсходныйЯзык, Форма, ОбработчикЗавершения) Экспорт
	
	Если Не ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.Печать") Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ТабличныйДокумент", ТабличныйДокумент);
	ДополнительныеПараметры.Вставить("ЯзыкПеревода", ЯзыкПеревода);
	ДополнительныеПараметры.Вставить("ИсходныйЯзык", ИсходныйЯзык);
	ДополнительныеПараметры.Вставить("ОбработчикЗавершения", ОбработчикЗавершения);
	
	ОписаниеОповещения = Новый ОписаниеОповещения("ПриЗавершенииПроверкиНастроек", ЭтотОбъект, ДополнительныеПараметры);
	ПроверитьНастройки(Форма, ОписаниеОповещения);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПриЗавершенииНастройки(Результат, ОбработчикЗавершения) Экспорт
	
	НастройкаВыполнена = ЗначениеЗаполнено(Результат);
	ВыполнитьОбработкуОповещения(ОбработчикЗавершения, НастройкаВыполнена);
	
КонецПроцедуры

Процедура ПриЗавершенииПроверкиНастроек(НастройкаВыполнена, ДополнительныеПараметры) Экспорт
	
	Если Не НастройкаВыполнена Тогда
		Возврат;
	КонецЕсли;
	
	ТабличныйДокумент = ДополнительныеПараметры.ТабличныйДокумент;
	ЯзыкПеревода = ДополнительныеПараметры.ЯзыкПеревода;
	ИсходныйЯзык = ДополнительныеПараметры.ИсходныйЯзык;
	ОбработчикЗавершения = ДополнительныеПараметры.ОбработчикЗавершения;
	
	ПереводТекстаНаДругиеЯзыкиВызовСервера.ПеревестиТекстыТабличногоДокумента(ТабличныйДокумент, ЯзыкПеревода, ИсходныйЯзык);
	ВыполнитьОбработкуОповещения(ОбработчикЗавершения, ТабличныйДокумент);
	
КонецПроцедуры

#КонецОбласти
