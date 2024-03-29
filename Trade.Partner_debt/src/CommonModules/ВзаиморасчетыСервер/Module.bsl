
&После("НайтиВыбранныеПоляРекурсивно")
Процедура PartnerDebt_НайтиВыбранныеПоляРекурсивно(КоллекцияЭлементов, МассивЭлементов) 
	Индекс = МассивЭлементов.Найти("Лимит");
	Если НЕ Индекс = Неопределено Тогда
		МассивЭлементов.Удалить(Индекс);
	КонецЕсли;
	
	Для Каждого ТекЭл Из МассивЭлементов Цикл
		Если Строка(ТекЭл.Поле) = "Лимит" Тогда
			МассивЭлементов.Удалить(МассивЭлементов.Найти(ТекЭл));
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры
