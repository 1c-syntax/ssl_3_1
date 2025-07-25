﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОписаниеПеременных

Перем СтарыеЗначения; // см. СтарыеЗначения

#КонецОбласти

#Область ОбработчикиСобытий

Процедура ПередЗаписью(Отказ)
	
	// АПК:75-выкл проверка ОбменДанными.Загрузка должна быть после записи изменений в журнал.
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
	
	Если ПользователиСлужебныйПовтИсп.РегистрироватьИзмененияПравДоступа()
	 Или Не ОбменДанными.Загрузка Тогда
		
		УправлениеДоступом.УстановитьБлокировкуПередЗаписьюВФайловойИБ(, Истина);
		СтарыеЗначения = СтарыеЗначения();
	КонецЕсли;
	// АПК:75-вкл
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	РегистрыСведений.ПраваРолей.ПроверитьДанныеРегистра();

	Если Не Справочники.ВерсииРасширений.ВсеРасширенияПодключены() Тогда
		Справочники.ПрофилиГруппДоступа.ВосстановитьНесуществующиеВидыИЗначенияДоступа(СтарыеЗначения, ЭтотОбъект);
	КонецЕсли;
	
	// Проверка ролей.
	РолиАдминистратора = Новый Массив;
	РолиАдминистратора.Добавить("Роль.ПолныеПрава");
	РолиАдминистратора.Добавить("Роль.АдминистраторСистемы");
	ИдентификаторыРолей = ОбщегоНазначения.ИдентификаторыОбъектовМетаданных(РолиАдминистратора);
	ОбработанныеРоли = Новый Соответствие;
	ПрофильАдминистратор = УправлениеДоступом.ПрофильАдминистратор();
	Индекс = Роли.Количество();
	Пока Индекс > 0 Цикл
		Индекс = Индекс - 1;
		Роль = Роли[Индекс].Роль;
		Если ОбработанныеРоли.Получить(Роль) <> Неопределено Тогда
			Роли.Удалить(Индекс);
			Продолжить;
		КонецЕсли;
		ОбработанныеРоли.Вставить(Роль, Истина);
		Если Ссылка = ПрофильАдминистратор Тогда
			Продолжить;
		КонецЕсли;
		Если Роль = ИдентификаторыРолей["Роль.ПолныеПрава"]
		 Или Роль = ИдентификаторыРолей["Роль.АдминистраторСистемы"] Тогда
			
			Роли.Удалить(Индекс);
		КонецЕсли;
	КонецЦикла;
	
	Справочники.ПрофилиГруппДоступа.ЗаполнитьСтандартныеРолиРасширений(Роли);
	
	Если Не ДополнительныеСвойства.Свойство("НеОбновлятьРеквизитПоставляемыйПрофильИзменен") Тогда
		НовоеЗначениеПоставляемыйПрофильИзменен =
			Справочники.ПрофилиГруппДоступа.ПоставляемыйПрофильИзменен(ЭтотОбъект);
		
		Если ПоставляемыйПрофильИзменен <> НовоеЗначениеПоставляемыйПрофильИзменен
		   И (Не НовоеЗначениеПоставляемыйПрофильИзменен
			  Или Справочники.ПрофилиГруппДоступа.ПоставляемыеОбластиПрофиляИзменены(ЭтотОбъект, СтарыеЗначения)) Тогда
			
			ПоставляемыйПрофильИзменен = НовоеЗначениеПоставляемыйПрофильИзменен;
		КонецЕсли;
	КонецЕсли;
	
	// Обновление наименования у персональных групп доступа этого профиля (если есть).
	ИнтерфейсУпрощенный = УправлениеДоступомСлужебный.УпрощенныйИнтерфейсНастройкиПравДоступа();
	Если ИнтерфейсУпрощенный Тогда
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Профиль",      Ссылка);
		Запрос.УстановитьПараметр("Наименование", Наименование);
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ГруппыДоступа.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ГруппыДоступа КАК ГруппыДоступа
		|ГДЕ
		|	ГруппыДоступа.Профиль = &Профиль
		|	И ГруппыДоступа.Пользователь <> НЕОПРЕДЕЛЕНО
		|	И ГруппыДоступа.Пользователь <> ЗНАЧЕНИЕ(Справочник.Пользователи.ПустаяСсылка)
		|	И ГруппыДоступа.Пользователь <> ЗНАЧЕНИЕ(Справочник.ВнешниеПользователи.ПустаяСсылка)
		|	И ГруппыДоступа.Наименование <> &Наименование";
		
		НачатьТранзакцию();
		Попытка
			ИзмененныеГруппыДоступа = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка"); // Массив из СправочникСсылка.ПрофилиГруппДоступа
			
			Если ИзмененныеГруппыДоступа.Количество() > 0 Тогда
				Блокировка = Новый БлокировкаДанных;
				Для каждого ГруппаДоступаСсылка Из ИзмененныеГруппыДоступа Цикл
					ЭлементБлокировки = Блокировка.Добавить("Справочник.ГруппыДоступа");
					ЭлементБлокировки.УстановитьЗначение("Ссылка", ГруппаДоступаСсылка);
				КонецЦикла;
				Блокировка.Заблокировать();
				
				Для каждого ГруппаДоступаСсылка Из ИзмененныеГруппыДоступа Цикл
					ПерсональнаяГруппаДоступаОбъект = ГруппаДоступаСсылка.ПолучитьОбъект();
					ПерсональнаяГруппаДоступаОбъект.Наименование = Наименование;
					ОбновлениеИнформационнойБазы.ЗаписатьДанные(ПерсональнаяГруппаДоступаОбъект);
				КонецЦикла;
				ДополнительныеСвойства.Вставить("ПерсональныеГруппыДоступаСОбновленнымНаименованием", ИзмененныеГруппыДоступа);
			КонецЕсли;
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;	
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриЗаписи(Отказ)
	
	// АПК:75-выкл проверка ОбменДанными.Загрузка должна быть после записи изменений в журнал.
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
	
	Если ПользователиСлужебныйПовтИсп.РегистрироватьИзмененияПравДоступа() Тогда
		УстановитьОтключениеБезопасногоРежима(Истина);
		УстановитьПривилегированныйРежим(Истина);
		
		Справочники.ПрофилиГруппДоступа.ЗарегистрироватьИзменениеРолейПрофилей(ЭтотОбъект, СтарыеЗначения);
		Справочники.ГруппыДоступа.ЗарегистрироватьИзменениеУчастниковГруппДоступа(ЭтотОбъект, СтарыеЗначения);
		Справочники.ГруппыДоступа.ЗарегистрироватьИзменениеРазрешенныхЗначений(ЭтотОбъект, СтарыеЗначения);
		
		УстановитьПривилегированныйРежим(Ложь);
		УстановитьОтключениеБезопасногоРежима(Ложь);
	КонецЕсли;
	// АПК:75-вкл
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ПроверитьОднозначностьПоставляемыхДанных();
	
	// При установке пометки удаления нужно установить пометку удаления у групп доступа профиля.
	Если Справочники.ГруппыДоступа.УстановленаПометкаУдаленияПрофиля(ЭтотОбъект, СтарыеЗначения) Тогда
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("Профиль", Ссылка);
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ГруппыДоступа.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.ГруппыДоступа КАК ГруппыДоступа
		|ГДЕ
		|	(НЕ ГруппыДоступа.ПометкаУдаления)
		|	И ГруппыДоступа.Профиль = &Профиль";
		
		НачатьТранзакцию();
		Попытка
			ИзмененныеГруппыДоступа = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
			Если ИзмененныеГруппыДоступа.Количество() > 0 Тогда
				Блокировка = Новый БлокировкаДанных;
				Для каждого ГруппаДоступаСсылка Из ИзмененныеГруппыДоступа Цикл
					ЭлементБлокировки = Блокировка.Добавить("Справочник.ГруппыДоступа");
					ЭлементБлокировки.УстановитьЗначение("Ссылка", ГруппаДоступаСсылка);
					ЗаблокироватьДанныеДляРедактирования(ГруппаДоступаСсылка);
				КонецЦикла;
				Блокировка.Заблокировать();
				
				УстановитьПривилегированныйРежим(Истина);
				Для Каждого ГруппаДоступаСсылка Из ИзмененныеГруппыДоступа Цикл
					ГруппаДоступаОбъект = ГруппаДоступаСсылка.ПолучитьОбъект();
					ГруппаДоступаОбъект.ДополнительныеСвойства.Вставить("УстановкаПометкиУдаленияГруппыДоступаПриУстановкеПометкиУдаленияПрофиля");
					ГруппаДоступаОбъект.ПометкаУдаления = Истина;
					ГруппаДоступаОбъект.Записать();
				КонецЦикла;
				УстановитьПривилегированныйРежим(Ложь);
			КонецЕсли;
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;
	КонецЕсли;
	
	Если ДополнительныеСвойства.Свойство("ОбновитьГруппыДоступаПрофиля") Тогда
		Справочники.ГруппыДоступа.ОбновитьГруппыДоступаПрофиля(Ссылка, Истина);
	КонецЕсли;
	
	ИзмененияСоставаТаблицПриИзмененииРолей = ОбновитьРолиПользователейПриИзмененииРолейПрофиля();
	
	Если ИзмененияСоставаТаблицПриИзмененииРолей.Количество() > 0 Тогда
		ГруппыДоступаПрофиля = Справочники.ГруппыДоступа.ГруппыДоступаПрофиля(Ссылка);
		РегистрыСведений.ТаблицыГруппДоступа.ОбновитьДанныеРегистра(ГруппыДоступаПрофиля,
			ИзмененияСоставаТаблицПриИзмененииРолей);
	КонецЕсли;
	
	Если Справочники.ПрофилиГруппДоступа.ИзменилисьВидыИлиЗначенияДоступаИлиНазначение(СтарыеЗначения, ЭтотОбъект)
	 Или ПометкаУдаления <> СтарыеЗначения.ПометкаУдаления Тогда
		
		Если ГруппыДоступаПрофиля = Неопределено Тогда
			ГруппыДоступаПрофиля = Справочники.ГруппыДоступа.ГруппыДоступаПрофиля(Ссылка);
		КонецЕсли;
		РегистрыСведений.ЗначенияГруппДоступа.ОбновитьДанныеРегистра(ГруппыДоступаПрофиля);
	КонецЕсли;
	
	ОтправитьСообщениеИзмененияПрофиля();
	
КонецПроцедуры

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
	
	Если ДополнительныеСвойства.Свойство("ПроверенныеРеквизитыОбъекта") Тогда
		ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(
			ПроверяемыеРеквизиты, ДополнительныеСвойства.ПроверенныеРеквизитыОбъекта);
	КонецЕсли;
	
	ПроверитьОднозначностьПоставляемыхДанных(Истина, Отказ);
	
КонецПроцедуры

Процедура ПриКопировании(ОбъектКопирования)
	
	Если ЭтоГруппа Тогда
		Возврат;
	КонецЕсли;
	
	ИдентификаторПоставляемыхДанных = Неопределено;
	
	Если Не ОбъектКопирования.ДополнительныеСвойства.Свойство("ПропуститьОчисткуРолей")
	   И ОбъектКопирования.Ссылка = УправлениеДоступом.ПрофильАдминистратор() Тогда
		Роли.Очистить();
	КонецЕсли;
	
КонецПроцедуры

Процедура ПередУдалением(Отказ)

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	ОтправитьСообщениеИзмененияПрофиля(Истина);	

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Вспомогательные процедуры и функции.

Функция ОбновитьРолиПользователейПриИзмененииРолейПрофиля()
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Профиль", ?(ПометкаУдаления,
		Справочники.ПрофилиГруппДоступа.ПустаяСсылка(), Ссылка));
	
	Запрос.УстановитьПараметр("СтарыеРолиПрофиля",
		?(Ссылка = СтарыеЗначения.Ссылка И Не СтарыеЗначения.ПометкаУдаления,
			СтарыеЗначения.Роли.Выгрузить(), Роли.Выгрузить(Новый Массив)));
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СтарыеРолиПрофиля.Роль
	|ПОМЕСТИТЬ СтарыеРолиПрофиля
	|ИЗ
	|	&СтарыеРолиПрофиля КАК СтарыеРолиПрофиля
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Данные.Роль
	|ПОМЕСТИТЬ ИзмененныеРоли
	|ИЗ
	|	(ВЫБРАТЬ
	|		СтарыеРолиПрофиля.Роль КАК Роль,
	|		-1 КАК ВидИзмененияСтроки
	|	ИЗ
	|		СтарыеРолиПрофиля КАК СтарыеРолиПрофиля
	|	
	|	ОБЪЕДИНИТЬ ВСЕ
	|	
	|	ВЫБРАТЬ РАЗЛИЧНЫЕ
	|		НовыеРолиПрофиля.Роль,
	|		1
	|	ИЗ
	|		Справочник.ПрофилиГруппДоступа.Роли КАК НовыеРолиПрофиля
	|	ГДЕ
	|		НовыеРолиПрофиля.Ссылка = &Профиль) КАК Данные
	|
	|СГРУППИРОВАТЬ ПО
	|	Данные.Роль
	|
	|ИМЕЮЩИЕ
	|	СУММА(Данные.ВидИзмененияСтроки) <> 0
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Данные.Роль";
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ПраваРолейРасширений.ОбъектМетаданных КАК ОбъектМетаданных,
	|	ПраваРолейРасширений.Роль КАК Роль,
	|	ПраваРолейРасширений.ПравоДобавление КАК ПравоДобавление,
	|	ПраваРолейРасширений.ПравоИзменение КАК ПравоИзменение,
	|	ПраваРолейРасширений.ПравоЧтениеБезОграничения КАК ПравоЧтениеБезОграничения,
	|	ПраваРолейРасширений.ПравоДобавлениеБезОграничения КАК ПравоДобавлениеБезОграничения,
	|	ПраваРолейРасширений.ПравоИзменениеБезОграничения КАК ПравоИзменениеБезОграничения,
	|	ПраваРолейРасширений.ПравоПросмотр КАК ПравоПросмотр,
	|	ПраваРолейРасширений.ПравоИнтерактивноеДобавление КАК ПравоИнтерактивноеДобавление,
	|	ПраваРолейРасширений.ПравоРедактирование КАК ПравоРедактирование,
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
	|	ПраваРолейРасширений.ПравоДобавление КАК ПравоДобавление,
	|	ПраваРолейРасширений.ПравоИзменение КАК ПравоИзменение,
	|	ПраваРолейРасширений.ПравоЧтениеБезОграничения КАК ПравоЧтениеБезОграничения,
	|	ПраваРолейРасширений.ПравоДобавлениеБезОграничения КАК ПравоДобавлениеБезОграничения,
	|	ПраваРолейРасширений.ПравоИзменениеБезОграничения КАК ПравоИзменениеБезОграничения,
	|	ПраваРолейРасширений.ПравоПросмотр КАК ПравоПросмотр,
	|	ПраваРолейРасширений.ПравоИнтерактивноеДобавление КАК ПравоИнтерактивноеДобавление,
	|	ПраваРолейРасширений.ПравоРедактирование КАК ПравоРедактирование
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
	|	ПраваРолей.ПравоДобавление,
	|	ПраваРолей.ПравоИзменение,
	|	ПраваРолей.ПравоЧтениеБезОграничения,
	|	ПраваРолей.ПравоДобавлениеБезОграничения,
	|	ПраваРолей.ПравоИзменениеБезОграничения,
	|	ПраваРолей.ПравоПросмотр,
	|	ПраваРолей.ПравоИнтерактивноеДобавление,
	|	ПраваРолей.ПравоРедактирование
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
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПраваРолей.ОбъектМетаданных КАК ОбъектМетаданных
	|ИЗ
	|	ПраваРолей КАК ПраваРолей
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ИзмененныеРоли КАК ИзмененныеРоли
	|		ПО ПраваРолей.Роль = ИзмененныеРоли.Роль
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИзмененныеРоли.Роль КАК Роль
	|ИЗ
	|	ИзмененныеРоли КАК ИзмененныеРоли";
	
	Запрос.Текст = Запрос.Текст + "
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|" + ТекстЗапроса;
	
	Запрос.УстановитьПараметр("ПраваРолейРасширений", УправлениеДоступомСлужебный.ПраваРолейРасширений());
	РезультатыЗапросов = Запрос.ВыполнитьПакет();
	
	Если УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально()
	   И Не РезультатыЗапросов[5].Пустой() Тогда
			
			ИзмененныеРоли = РезультатыЗапросов[5].Выгрузить().ВыгрузитьКолонку("Роль");
			УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступаПриИзмененииРолейПрофиля(
				"ОбновитьРолиПользователейПриИзмененииРолейПрофиля", ИзмененныеРоли);
	КонецЕсли;
	
	Если Не ДополнительныеСвойства.Свойство("НеОбновлятьРолиПользователей")
	   И Не РезультатыЗапросов[5].Пустой() Тогда
		
		ПользователиДляОбновленияРолей = Справочники.ГруппыДоступа.ПользователиДляОбновленияРолейПоПрофилю(Ссылка);
		УправлениеДоступом.ОбновитьРолиПользователей(ПользователиДляОбновленияРолей);
	КонецЕсли;
	
	Возврат РезультатыЗапросов[4].Выгрузить().ВыгрузитьКолонку("ОбъектМетаданных");
	
КонецФункции

Процедура ПроверитьОднозначностьПоставляемыхДанных(ПроверкаЗаполнения = Ложь, Отказ = Ложь)
	
	// Проверка однозначности поставляемых данных.
	Если Не ЗначениеЗаполнено(ИдентификаторПоставляемыхДанных) Тогда
		Возврат;
	КонецЕсли;

	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИдентификаторПоставляемыхДанных", ИдентификаторПоставляемыхДанных);
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ПрофилиГруппДоступа.Ссылка КАК Ссылка,
	|	ПрофилиГруппДоступа.Наименование КАК Наименование
	|ИЗ
	|	Справочник.ПрофилиГруппДоступа КАК ПрофилиГруппДоступа
	|ГДЕ
	|	ПрофилиГруппДоступа.ИдентификаторПоставляемыхДанных = &ИдентификаторПоставляемыхДанных";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Количество() > 1 Тогда
		
		КраткоеПредставлениеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Поставляемый профиль ""%1"" уже существует:'"),
			Наименование);
		
		ПодробноеПредставлениеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Идентификатор поставляемых данных ""%1"" уже используется в профиле ""%2"":'"),
			Строка(ИдентификаторПоставляемыхДанных),
			Наименование);
		
		Пока Выборка.Следующий() Цикл
			Если Выборка.Ссылка <> Ссылка Тогда
				
				КраткоеПредставлениеОшибки = КраткоеПредставлениеОшибки
					+ Символы.ПС + """" + Выборка.Наименование + """.";
				
				ПодробноеПредставлениеОшибки = ПодробноеПредставлениеОшибки
					+ Символы.ПС + """" + Выборка.Наименование + """ ("
					+ Строка(Выборка.Ссылка.УникальныйИдентификатор())+ ")."
			КонецЕсли;
		КонецЦикла;
		
		Если ПроверкаЗаполнения Тогда
			ОбщегоНазначения.СообщитьПользователю(КраткоеПредставлениеОшибки,,,, Отказ);
		Иначе
			ЗаписьЖурналаРегистрации(
				НСтр("ru = 'Управление доступом.Нарушение однозначности поставляемого профиля'",
				     ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

// Значения некоторых реквизитов и табличных частей профиля
// до его изменения для использования в обработчике события ПриЗаписи.
// 
// Возвращаемое значение:
//  Структура:
//     * Ссылка - СправочникСсылка.ПрофилиГруппДоступа
//     * Наименование    - Строка
//     * Родитель        - СправочникСсылка.ПрофилиГруппДоступа
//     * ПометкаУдаления - Булево
//     * Роли - РезультатЗапроса
//     * Назначение - РезультатЗапроса
//     * ВидыДоступа - РезультатЗапроса
//     * ЗначенияДоступа - РезультатЗапроса
//
Функция СтарыеЗначения()

	Возврат ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка,
		"Ссылка, Наименование, Родитель, ПометкаУдаления, Роли, Назначение, ВидыДоступа, ЗначенияДоступа");
	
КонецФункции

Процедура ОтправитьСообщениеИзмененияПрофиля(ЭтоУдаление = Ложь)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если УправлениеДоступомСлужебный.ПоддерживаетсяУправлениеДоступомВМоделиСервиса() Тогда
		МодульУправлениеДоступомСлужебныйВМоделиСервиса = ОбщегоНазначения.ОбщийМодуль(
			"УправлениеДоступомСлужебныйВМоделиСервиса");
		МодульУправлениеДоступомСлужебныйВМоделиСервиса.ОтправитьСообщениеИзмененияГруппыДоступа(ЭтотОбъект, ЭтоУдаление);
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Иначе
ВызватьИсключение НСтр("ru = 'Недопустимый вызов объекта на клиенте.'");
#КонецЕсли