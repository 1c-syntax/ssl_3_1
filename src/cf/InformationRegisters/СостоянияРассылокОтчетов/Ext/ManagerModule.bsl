﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Для внутреннего использования.
// 
Процедура ЗафиксироватьЗапускРассылки(Рассылка) Экспорт
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных();
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.СостоянияРассылокОтчетов");
		ЭлементБлокировки.УстановитьЗначение("Рассылка", Рассылка);
		Блокировка.Заблокировать();
		
		МенеджерЗаписи = СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Рассылка = Рассылка;
		МенеджерЗаписи.Прочитать();
		
		МенеджерЗаписи.Рассылка = Рассылка;
		МенеджерЗаписи.ПоследнийЗапускНачало = ТекущаяДатаСеанса();
		// На случай если ЗафиксироватьРезультатВыполненияРассылки не будет вызван из-за необработанного исключения.
		МенеджерЗаписи.ПоследнийЗапускЗавершение = МенеджерЗаписи.ПоследнийЗапускНачало + 30 * 60; 
		МенеджерЗаписи.НомерСеанса = НомерСеансаИнформационнойБазы();
		МенеджерЗаписи.Выполнена = Ложь;
		МенеджерЗаписи.СОшибками = Истина;
		
		МенеджерЗаписи.Записать(Истина);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
КонецПроцедуры

// Для внутреннего использования.
// 
Процедура ЗафиксироватьРезультатВыполненияРассылки(Рассылка, РезультатВыполнения) Экспорт
	УстановитьПривилегированныйРежим(Истина);
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных();
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.СостоянияРассылокОтчетов");
		ЭлементБлокировки.УстановитьЗначение("Рассылка", Рассылка);
		Блокировка.Заблокировать();
		
		МенеджерЗаписи = СоздатьМенеджерЗаписи();
		МенеджерЗаписи.Рассылка = Рассылка;
		МенеджерЗаписи.Прочитать();
		
		МенеджерЗаписи.Рассылка = Рассылка;
		МенеджерЗаписи.СОшибками = РезультатВыполнения.БылиОшибки Или РезультатВыполнения.БылиПредупреждения;
		МенеджерЗаписи.Выполнена = РезультатВыполнения.ВыполненаВПапку
			Или РезультатВыполнения.ВыполненаВСетевойКаталог
			Или РезультатВыполнения.ВыполненаНаFTP
			Или РезультатВыполнения.ВыполненаПоЭлектроннойПочте
			Или Не МенеджерЗаписи.СОшибками;
		Если МенеджерЗаписи.Выполнена Тогда
			МенеджерЗаписи.УспешныйЗапуск = МенеджерЗаписи.ПоследнийЗапускНачало;
		КонецЕсли;
		МенеджерЗаписи.ПоследнийЗапускЗавершение = ТекущаяДатаСеанса();
		
		МенеджерЗаписи.Записать(Истина);
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
КонецПроцедуры

#КонецОбласти

#КонецЕсли
