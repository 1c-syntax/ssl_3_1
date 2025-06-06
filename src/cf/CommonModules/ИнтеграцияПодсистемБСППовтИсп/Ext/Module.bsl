﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

Функция ПодпискиБТС() Экспорт
	
	Подписки = ИнтеграцияПодсистемБСП.СобытияБСП();
	Если ОбщегоНазначения.ПодсистемаСуществует("ТехнологияСервиса") Тогда
		МодульИнтеграцияПодсистемБТС = ОбщегоНазначения.ОбщийМодуль("ИнтеграцияПодсистемБТС");
		МодульИнтеграцияПодсистемБТС.ПриОпределенииПодписокНаСобытияБСП(Подписки);
	КонецЕсли;
	
	Возврат Подписки;
	
КонецФункции

Функция ПодпискиБИП() Экспорт
	
	Подписки = ИнтеграцияПодсистемБСП.СобытияБСП();
	Если ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей") Тогда
		МодульИнтеграцияПодсистемБИП = ОбщегоНазначения.ОбщийМодуль("ИнтеграцияПодсистемБИП");
		МодульИнтеграцияПодсистемБИП.ПриОпределенииПодписокНаСобытияБСП(Подписки);
	КонецЕсли;
	
	Возврат Подписки;
	
КонецФункции

Функция ПодпискиБПО() Экспорт
	
	Подписки = ИнтеграцияПодсистемБСП.СобытияБСП();
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("ПоддержкаОборудования") Тогда
		Возврат Подписки;
	КонецЕсли;
	
	Если Метаданные.ОбщиеМодули.Найти("ИнтеграцияПодсистемБПО") = Неопределено Тогда
		Возврат Подписки;
	КонецЕсли;
		
	МодульИнтеграцияПодсистемБПО = ОбщегоНазначения.ОбщийМодуль("ИнтеграцияПодсистемБПО");
	МодульИнтеграцияПодсистемБПО.ПриОпределенииПодписокНаСобытияБСП(Подписки);
	
	Возврат Подписки;
	
КонецФункции

Функция ПодпискиБЭД() Экспорт
	
	Подписки = ИнтеграцияПодсистемБСП.СобытияБСП();
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ЭлектронноеВзаимодействие") Тогда
		
		Если Метаданные.ОбщиеМодули.Найти("ИнтеграцияПодсистемБЭД") = Неопределено Тогда
			Возврат Подписки;
		КонецЕсли;
		
		МодульИнтеграцияПодсистемБЭД = ОбщегоНазначения.ОбщийМодуль("ИнтеграцияПодсистемБЭД");
		МодульИнтеграцияПодсистемБЭД.ПриОпределенииПодписокНаСобытияБСП(Подписки);
		
	КонецЕсли;
	
	Возврат Подписки;
	
КонецФункции

Функция ПодпискиПлюс() Экспорт
	
	Подписки = ИнтеграцияПодсистемБСП.СобытияБСП();
	Если ОбщегоНазначения.ПодсистемаСуществует("ПлюсСервис") Тогда
		МодульИнтеграцияПодсистемПлюс = ОбщегоНазначения.ОбщийМодуль("ИнтеграцияПодсистемПлюс");
		МодульИнтеграцияПодсистемПлюс.ПриОпределенииПодписокНаСобытияБСП(Подписки);
	КонецЕсли;
	
	Возврат Подписки;
	
КонецФункции

#КонецОбласти