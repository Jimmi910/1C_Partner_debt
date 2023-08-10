
#Область ПрограммныйИнтерфейс

// Установить лимит долга.
// 
// Параметры:
//  Форма - ФормаКлиентскогоПриложения - Форма
Процедура УстановитьЛимитДолга(Форма) Экспорт
	
	Если Форма.Объект.Ссылка.Пустая() ИЛИ Форма.Модифицированность Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю("Необходимо записать Партнера!");
		Возврат;
	КонецЕсли;
	
	ОбновлениеНадписи = Новый ОписаниеОповещения("ОбновитьНадписьЛимитаДолга",
		PartnerDebt_ОтбработчикиФормыПартнераКлиент, Форма);
	
	ДополнительныеПараметры = Новый Структура();
	ДополнительныеПараметры.Вставить("Партнер", Форма.Объект.Ссылка);
	ДополнительныеПараметры.Вставить("ОповищениеОбновлениеНадписиДолга", ОбновлениеНадписи);
	
	ПослеВводаЛимита = Новый ОписаниеОповещения("ПослеВводаЛимита",
		PartnerDebt_ОтбработчикиФормыПартнераКлиент, ДополнительныеПараметры);
	
	ПоказатьВводЧисла(ПослеВводаЛимита, 0, "Введите новый лимит", 17, 2);
	
КонецПроцедуры

Процедура ОткрытьФормуСпискаРучныхЛимитовСОтборомПоПартнеру(Партнер) Экспорт
	
	ОтборФормы = Новый Структура;
	ОтборФормы.Вставить("Партнер", Партнер);
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("Отбор", ОтборФормы);
	
	ОткрытьФорму("РегистрСведений.PartnerDebt_РучныеЛимитыДолгаПартнера.ФормаСписка", ПараметрыФормы);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Процедура ОбновитьНадписьЛимитаДолга(Лимит, Форма) Экспорт
	
	Элементы = Форма.Элементы;
	
	ИмяДекорации = PartnerDebt_КонтрольДолгаПартнераВызовСервера.ИмяЭлементаНадписиДолга();
	Валюта = PartnerDebt_КонтрольДолгаПартнераВызовСервера.НаименованиеВалютыУправленческогоУчета();
	
	Если Лимит = Неопределено Тогда
		Лимит = PartnerDebt_КонтрольДолгаПартнераВызовСервера.ЛимитДолгаПартнера(Форма.Объект.Ссылка);
	КонецЕсли;
	
	ЭлементДекорации = Элементы.Найти(ИмяДекорации);
	Если Не ЭлементДекорации = Неопределено Тогда
		ЭлементДекорации.Заголовок = "Лимит долга составляет: " + Строка(Лимит) + " " + Валюта;
	КонецЕсли;
	
КонецПроцедуры

Процедура УстановитьВидимость(Форма) Экспорт
	
	РучнойТип = PartnerDebt_КонтрольДолгаПартнераВызовСервера.РучнойТипУстановкиЛимита();
	
	РучнойЛимит = Форма.Объект.PartnerDebt_ТипУстановкиЛимитаДолга = РучнойТип;
	
	КнопкаУстановкиЛимита = Форма.Элементы.Найти("PartnerDebt_УстановитьЛимитДолга");
	
	Если Не КнопкаУстановкиЛимита = Неопределено Тогда
		КнопкаУстановкиЛимита.Видимость = РучнойЛимит;
		Форма.Элементы["PartnerDebt_ПосмотретьИсториюИзмененийРучногоЛимита"].Видимость = РучнойЛимит;
	КонецЕсли;
	
КонецПроцедуры

Функция ЛимитДолгаПоВыбранномуТипу(Тип, Партнер) Экспорт
	Возврат PartnerDebt_КонтрольДолгаПартнераВызовСервера.ЛимитДолгаПартнера(Партнер, , Тип);
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПослеВводаЛимита(НовыйЛимит, ДополнительныеПараметры) Экспорт
	
	Если НовыйЛимит = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если НовыйЛимит >= 0 Тогда
		PartnerDebt_КонтрольДолгаПартнераВызовСервера.УстановитьНовыйЛимитДолга(НовыйЛимит,
			ДополнительныеПараметры.Партнер);
		ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОповищениеОбновлениеНадписиДолга, НовыйЛимит);
	Иначе
		ОбщегоНазначенияКлиент.СообщитьПользователю("Нельзя установить отрицательное значение лимита!");
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
