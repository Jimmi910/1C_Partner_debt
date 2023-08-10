
#Область ПрограммныйИнтерфейс

// Лимит долга партнера превышен.
// 
// Параметры:
//  ДокументСсылка - ДокументОбъект.РеализацияТоваровУслуг - РТУ
// 
// Возвращаемое значение:
//  Булево - Лимит долга партнера превышен
Функция ЛимитДолгаПартнераПревышен(ДокументСсылка) Экспорт
	
	ЛимитПривышен = Ложь;
	
	Лимит = ЛимитДолгаПартнера(ДокументСсылка.Партнер, ДокументСсылка.Дата);
	Если Лимит = 0 Тогда
		Возврат ЛимитПривышен;
	КонецЕсли;
	
	Долг = ДолгПартнераПоДокументу(ДокументСсылка);
	
	Если Долг > Лимит Тогда
		
		ЛимитПривышен = Истина;
		
		Текст = "Текущий сумарный долг по всем Контрагентм Партнера '" + Строка(ДокументСсылка.Партнер)
			+ "' составляет: " + Строка(Долг) + Символы.ПС + "Максимальный установленый лимит на "
			+ Строка(ДокументСсылка.Дата) + " составляет " + Строка(Лимит);
		
		ОбщегоНазначения.СообщитьПользователю(Текст);
		
	КонецЕсли;
	
	Возврат ЛимитПривышен;
	
КонецФункции

Процедура УстановитьНовыйЛимитДолга(Лимит, Партнер) Экспорт
	
	Набор = РегистрыСведений.PartnerDebt_РучныеЛимитыДолгаПартнера.СоздатьНаборЗаписей();
	Набор.Отбор.Партнер.Установить(Партнер);
	Набор.Прочитать();
	
	Запись = Набор.Добавить();
	Запись.Период = ТекущаяДатаСеанса();
	Запись.Партнер = Партнер;
	Запись.Сумма = Лимит;
	
	Набор.Записать();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Долг партнера по документу.
// 
// Параметры:
//  ДокументСсылка - ДокументОбъект.РеализацияТоваровУслуг - РТУ
// 
// Возвращаемое значение:
//  Число - Долг партнера по документу
Функция ДолгПартнераПоДокументу(ДокументСсылка) Экспорт
	
	Долг = СуммаДолгаПартнера(ДокументСсылка.Партнер, ДокументСсылка.Организация, ДокументСсылка.Дата);
	
	Возврат Долг;
	
КонецФункции

// Лимит долга партнера.
// 
// Параметры:
//  Партнер - СправочникСсылка.Партнеры - Партнер
//  Дата - Дата - Дата на которую нужно получить лимит
// 
// Возвращаемое значение:
//  Число - Лимит долга партнера
Функция ЛимитДолгаПартнера(Партнер, Дата = Неопределено) Экспорт
	
	Если Дата = Неопределено Тогда
		Дата = ТекущаяДатаСеанса();
	КонецЕсли;
	
	ТипЛимита = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Партнер, "PartnerDebt_ТипУстановкиЛимитаДолга");
	
	Если ТипЛимита = Перечисления.PartnerDebt_ТипУстановкиЛимитаДолга.Ручной Тогда
		Лимит = РучнаяСуммаЛимитаПартнера(Партнер, Дата);
	Иначе
		Лимит = МаксимальнаяСуммаЛимитаПоДоговорамПартнера(Партнер, Дата);
	КонецЕсли;
	
	Возврат Лимит;
	
КонецФункции

// За основу функции взята Отчеты.ЗадолжностьКлиентов.Модульобхекта.ТекстЗапроса()
// И переделана, берутся все ключи партнера, и по ним собирается долг.
// 
// Параметры:
//  Партнер - СправочникСсылка.Партнеры - Партнер
//  Организация - СправочникСсылка.Организации - Организация
//  Дата - Дата - Дата
// 
// Возвращаемое значение:
//  Число - Долг в рублях
Функция СуммаДолгаПартнера(Партнер, Организация, Дата) Экспорт

	ДолгКлиента = 0;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Организация", Организация);
	Запрос.УстановитьПараметр("Партнер", Партнер);
	Запрос.УстановитьПараметр("Дата", Дата);

	Запрос.Текст = ТекстЗапроса2();
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	ВалютаРубл = Константы.ВалютаРегламентированногоУчета.Получить();
	
	Пока Выборка.Следующий() Цикл
		
		ДолгВВалюте = Выборка.ДолгКлиента;
		
		СуммаДолгаВРублях = РаботаСКурсамиВалют.ПересчитатьВВалюту(ДолгВВалюте, Выборка.Валюта,
			ВалютаРубл, Дата);
		
		ДолгКлиента = ДолгКлиента + СуммаДолгаВРублях;
		
	КонецЦикла;

	Возврат ДолгКлиента;

КонецФункции

// Имя элемента надписи долга.
// 
// Возвращаемое значение:
//  Строка - Имя элемента надписи долга
Функция ИмяЭлементаНадписиДолга() Экспорт
	Возврат "PartnerDebt_ТекущийЛимитДолга";
КонецФункции

// Наименование валюты управленческого учета.
// 
// Возвращаемое значение:
//  Строка - Наименование валюты управленческого учета
Функция НаименованиеВалютыУправленческогоУчета() Экспорт
	Возврат ЗначениеНастроекПовтИсп.БазоваяВалютаПоУмолчанию().Наименование;
КонецФункции

// Ручной тип установки лимита.
// 
// Возвращаемое значение:
//  ПеречислениеСсылка.PartnerDebt_ТипУстановкиЛимитаДолга - Ручной тип установки лимита
Функция РучнойТипУстановкиЛимита() Экспорт
	Возврат  Перечисления.PartnerDebt_ТипУстановкиЛимитаДолга.Ручной;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИфункции

// Ручная сумма лимита партнера.
// 
// Параметры:
//  Партнер - СправочникСсылка.Партнеры - Партнер
//  Дата - Дата - Дата
// 
// Возвращаемое значение:
//  Число - Ручная сумма лимита партнера
Функция РучнаяСуммаЛимитаПартнера(Партнер, Дата)
	
	Лимит = 0;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	PartnerDebt_РучныеЛимитыДолгаПартнераСрезПоследних.Сумма КАК Лимит
		|ИЗ
		|	РегистрСведений.PartnerDebt_РучныеЛимитыДолгаПартнера.СрезПоследних(&Дата, Партнер = &Партнер) КАК
		|		PartnerDebt_РучныеЛимитыДолгаПартнераСрезПоследних";
	
	Запрос.УстановитьПараметр("Партнер", Партнер);
	Запрос.УстановитьПараметр("Дата", Дата);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Лимит = Выборка.Лимит;
	КонецЦикла;
	
	Возврат Лимит;
	
КонецФункции

// Максимальная сумма лимита по договорам партнера.
// 
// Параметры:
//  Партнер - СправочникСсылка.Партнеры - Партнер
//  Дата - Дата - Дата
// 
// Возвращаемое значение:
//  Число - Максимальная сумма лимита по договорам партнера
Функция МаксимальнаяСуммаЛимитаПоДоговорамПартнера(Партнер, Дата)
	
	Лимит = 0;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ДоговорыКонтрагентов.ДопустимаяСуммаЗадолженности КАК Лимит,
		|	ДоговорыКонтрагентов.ВалютаВзаиморасчетов КАК ВалютаВзаиморасчетов
		|ИЗ
		|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
		|ГДЕ
		|	ДоговорыКонтрагентов.Партнер = &Партнер
		|	И ДоговорыКонтрагентов.ПометкаУдаления = Ложь
		|	И ДоговорыКонтрагентов.Статус = &Статус";
	
	Запрос.УстановитьПараметр("Партнер", Партнер);
	Запрос.УстановитьПараметр("Статус", Перечисления.СтатусыДоговоровКонтрагентов.Действует);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	ВалютаРубл = Константы.ВалютаРегламентированногоУчета.Получить();
	
	Пока Выборка.Следующий() Цикл
		
		СуммаДолгаВРублях = РаботаСКурсамиВалют.ПересчитатьВВалюту(Выборка.Лимит, Выборка.ВалютаВзаиморасчетов,
			ВалютаРубл, Дата);
		
		// НУжно взять максимальную сумму из всех, сумма должна быть в рублях		
		Лимит = Макс(Лимит, СуммаДолгаВРублях);
		
	КонецЦикла;
	
	Возврат Лимит;
	
КонецФункции

Функция ТекстЗапроса()
	
	ТекстЗапроса = "ВЫБРАТЬ РАЗРЕШЕННЫЕ
               |	КлючиАналитикиУчетаПоПартнерам.Ссылка КАК КлючиАналитики
               |ПОМЕСТИТЬ ВтКлючиАналитики
               |ИЗ
               |	Справочник.КлючиАналитикиУчетаПоПартнерам КАК КлючиАналитикиУчетаПоПартнерам
               |ГДЕ
               |	КлючиАналитикиУчетаПоПартнерам.Партнер = &Партнер
               |	И КлючиАналитикиУчетаПоПартнерам.Организация = &Организация
               |
               |ИНДЕКСИРОВАТЬ ПО
               |	КлючиАналитики
               |;
               |
               |////////////////////////////////////////////////////////////////////////////////
               |ВЫБРАТЬ РАЗРЕШЕННЫЕ
               |	Расчеты.Организация КАК Организация,
               |	Расчеты.Партнер КАК Партнер,
               |	Расчеты.Валюта КАК Валюта,
               |	СУММА(Расчеты.НашДолг) КАК НашДолг,
               |	СУММА(Расчеты.ДолгКлиента) КАК ДолгКлиента
               |ПОМЕСТИТЬ ВтРасчеты
               |ИЗ
               |	(ВЫБРАТЬ
               |		&Организация КАК Организация,
               |		&Партнер КАК Партнер,
               |		РасчетыПоСрокам.Валюта КАК Валюта,
               |		РасчетыПоСрокам.ПредоплатаОстаток КАК НашДолг,
               |		РасчетыПоСрокам.ДолгОстаток КАК ДолгКлиента
               |	ИЗ
               |		РегистрНакопления.РасчетыСКлиентамиПоСрокам.Остатки(
               |				&Дата,
               |				АналитикаУчетаПоПартнерам В
               |					(ВЫБРАТЬ
               |						ВтКлючиАналитики.КлючиАналитики
               |					ИЗ
               |						ВтКлючиАналитики КАК ВтКлючиАналитики)) КАК РасчетыПоСрокам) КАК Расчеты
               |
               |СГРУППИРОВАТЬ ПО
               |	Расчеты.Организация,
               |	Расчеты.Партнер,
               |	Расчеты.Валюта
               |;
               |
               |////////////////////////////////////////////////////////////////////////////////
               |ВЫБРАТЬ РАЗРЕШЕННЫЕ
               |	Расчеты.Организация КАК Организация,
               |	Расчеты.Партнер КАК Партнер,
               |	Расчеты.Валюта КАК Валюта,
               |	Расчеты.ДолгКлиента КАК ДолгКлиента
               |ИЗ
               |	ВтРасчеты КАК Расчеты";
	
	Возврат ТекстЗапроса;
КонецФункции

Функция ТекстЗапроса2()
	
	ТекстЗапроса = "ВЫБРАТЬ
	|	РасчетыСКлиентамиОстатки.СуммаОстаток + РасчетыСКлиентамиОстатки.ОтгружаетсяОстаток КАК ДолгКлиента,
	|	РасчетыСКлиентамиОстатки.Валюта КАК Валюта
	|ИЗ
	|	РегистрНакопления.РасчетыСКлиентами.Остатки(&Дата
	|		,
	|		АналитикаУчетаПоПартнерам В (
	|			ВЫБРАТЬ
	|				АналитикаПоПартнерам.КлючАналитики КАК КлючАналитики
	|			ИЗ
	|				РегистрСведений.АналитикаУчетаПоПартнерам КАК АналитикаПоПартнерам
	|			ГДЕ
	|				АналитикаПоПартнерам.Партнер = &Партнер
    |				И АналитикаПоПартнерам.Организация = &Организация
	|			)
	|	) КАК РасчетыСКлиентамиОстатки
	|";
	
	Возврат ТекстЗапроса;
	
КонецФункции

#КонецОбласти

