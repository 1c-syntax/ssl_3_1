﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ПрочитатьПараметрыПрописи();
	
	Если ОбщегоНазначения.ЭтоМобильныйКлиент() Тогда
		Элементы.ГруппаПримерПрописи.ВыравниваниеЭлементовИЗаголовков = ВариантВыравниванияЭлементовИЗаголовков.ЭлементыПравоЗаголовкиЛево;
		Элементы.СуммаПрописью.ПоложениеЗаголовка = ПоложениеЗаголовкаЭлементаФормы.Верх;
		Элементы.СуммаПрописью.Высота = 2;
		Элементы.СуммаПрописью.МногострочныйРежим = Истина;
		ПоложениеКоманднойПанели = ПоложениеКоманднойПанелиФормы.Авто;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	СуммаЧисло = 123.45;
	УстановитьСуммуПрописью();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПолеВводаПриИзменении(Элемент)
	
	Модифицированность = Истина;
	УстановитьСуммуПрописью();
	ОповеститьВладельца();
	
КонецПроцедуры

&НаКлиенте
Процедура ПолеВводаИзменениеТекстаРедактирования(Элемент, Текст, СтандартнаяОбработка)
	
	Модифицированность = Истина;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	
	ОповеститьВладельца(Истина, Истина);
	
КонецПроцедуры

&НаКлиенте
Процедура Записать(Команда)
	
	ОповеститьВладельца(Истина);
	Модифицированность = ВладелецФормы.Модифицированность;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиентеНаСервереБезКонтекста
Функция ПараметрыПрописи(Форма)
	
	ПараметрыПрописи = Новый Массив;
	ПараметрыПрописи.Добавить(Форма.ЦелаяЧастьЕдинственноеЧисло);
	ПараметрыПрописи.Добавить(Форма.ЦелаяЧастьМножественноеЧисло);
	ПараметрыПрописи.Добавить(Форма.ДробнаяЧастьЕдинственноеЧисло);
	ПараметрыПрописи.Добавить(Форма.ДробнаяЧастьМножественноеЧисло);
	ПараметрыПрописи.Добавить(Форма.ДлинаДробнойЧасти);
	
	Возврат СтрСоединить(ПараметрыПрописи, ", ");
	
КонецФункции

&НаКлиенте
Процедура УстановитьСуммуПрописью()
	
	Если ЗначениеЗаполнено(Параметры.КодЯзыка) Тогда
		СуммаПрописью = ЧислоПрописью(СуммаЧисло, "L=" + Параметры.КодЯзыка + ";ДП=Ложь", ПараметрыПрописи(ЭтотОбъект)); // АПК:1357
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПрочитатьПараметрыПрописи()
	
	ПараметрыПрописи = СтрРазделить(Параметры.ПараметрыПрописи, ",", Истина);
	Если ПараметрыПрописи.Количество() <> 5 Тогда
		Возврат;
	КонецЕсли;
	
	ЦелаяЧастьЕдинственноеЧисло = СокрЛП(ПараметрыПрописи[0]);
	ЦелаяЧастьМножественноеЧисло = СокрЛП(ПараметрыПрописи[1]);
	ДробнаяЧастьЕдинственноеЧисло = СокрЛП(ПараметрыПрописи[2]);
	ДробнаяЧастьМножественноеЧисло = СокрЛП(ПараметрыПрописи[3]);
	ДлинаДробнойЧасти = ОчиститьСтрокуСЧисломОтПостороннихСимволов(ПараметрыПрописи[4]);
	
КонецПроцедуры

&НаСервере
Функция ОчиститьСтрокуСЧисломОтПостороннихСимволов(СтрокаСЧислом)
	
	ПосторонниеСимволы = СтрСоединить(СтрРазделить(СтрокаСЧислом, "0123456789", Ложь), "");
	Возврат СтрСоединить(СтрРазделить(СтрокаСЧислом, ПосторонниеСимволы, Ложь), "");
	
КонецФункции

&НаКлиенте
Процедура ОповеститьВладельца(Записать = Ложь, Закрыть = Ложь)
	
	ПараметрыПрописи = Новый Структура;
	ПараметрыПрописи.Вставить("КодЯзыка", Параметры.КодЯзыка);
	ПараметрыПрописи.Вставить("ПараметрыПрописи", ПараметрыПрописи(ЭтотОбъект));
	ПараметрыПрописи.Вставить("Записать", Записать);
	ПараметрыПрописи.Вставить("Закрыть", Закрыть);
	
	Оповестить("ПараметрыПрописиВалюты", ПараметрыПрописи, ВладелецФормы);
	
КонецПроцедуры

#КонецОбласти

