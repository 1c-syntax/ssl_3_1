﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

Перем СтарыеЗаписи; // Заполняется ПередЗаписью для использования ПриЗаписи.

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗащитаПерсональныхДанных.ИспользоватьУничтожениеПерсональныхДанныхСубъектов() Тогда
		СтарыеЗаписи = ОбщегоНазначения.ЗаписиНабораИзБазыДанных(ЭтотОбъект, Замещение, "Субъект");
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ, Замещение)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ЗащитаПерсональныхДанных.ИспользоватьУничтожениеПерсональныхДанныхСубъектов() Тогда
		Возврат;
	КонецЕсли;
	
	ДатаСобытия = ТекущаяДатаСеанса();
	
	Если Не ОбщегоНазначения.ЭтоУдалениеНабораЗаписей(Замещение) И Количество() > 0 Тогда
		ДатаСобытия = ЭтотОбъект[0].Период;
		Для Каждого Запись Из ЭтотОбъект Цикл
			СтарыеЗаписи.Добавить().Субъект = Запись.Субъект;
		КонецЦикла;
		СтарыеЗаписи.Свернуть("Субъект");
	КонецЕсли;
	СписокСубъектов = СтарыеЗаписи.ВыгрузитьКолонку("Субъект");
	
	ЗащитаПерсональныхДанных.ДобавитьСубъектыДляРасчетаСроковХранения(СписокСубъектов, ДатаСобытия);
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли