
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
	
	Долг = 0;
	
	ДанныеПоСостоянию = СуммаДолгаПартнера(ДокументСсылка.Партнер, ДокументСсылка.Организация, ДокументСсылка.Дата);
	Долг = ДанныеПоСостоянию.СуммаОплат - ДанныеПоСостоянию.СуммаЗадолженности;
	
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
Функция ЛимитДолгаПартнера(Партнер, Дата) Экспорт
	
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
	Запрос.УстановитьПараметр("Дата", Дата);
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

// За основу функции взята Отчеты.ЗадолжностьКлиентов.Модульобхекта.ТекстЗапроса()
// И переделана, берутся все ключи партнера, и по ним собирается долг.
// 
// Параметры:
//  Партнер - СправочникСсылка.Партнеры - Партнер
//  Организация - СправочникСсылка.Организации - Организация
//  Дата - Дата - Дата
// 
// Возвращаемое значение:
//  ДолгКлиента - Число - Долг в рублях
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
		
		СуммаДолгаВРублях = РаботаСКурсамиВалют.ПересчитатьВВалюту(Выборка.ДолгКлиента, Выборка.Валюта,
			ВалютаРубл, Дата);
		
		ДолгКлиента = ДолгКлиента + СуммаДолгаВРублях;
		
	КонецЦикла;

	Возврат ДолгКлиента;

КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИфункции

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

