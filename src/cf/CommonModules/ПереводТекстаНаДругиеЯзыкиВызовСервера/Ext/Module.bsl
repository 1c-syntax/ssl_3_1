﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Функция ТребуетсяНастройка() Экспорт
	
	Возврат ПереводТекстаНаДругиеЯзыки.ТребуетсяНастройка();
	
КонецФункции

Процедура ПеревестиТекстыТабличногоДокумента(ТабличныйДокумент, ЯзыкПеревода, ИсходныйЯзык) Экспорт
	
	ПереводТекстаНаДругиеЯзыки.ПеревестиТекстыТабличногоДокумента(ТабличныйДокумент, ЯзыкПеревода, ИсходныйЯзык);
	
КонецПроцедуры

#КонецОбласти