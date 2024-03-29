Целта на задачата е да напишете два класа/модула, правещи промени в текст и валидиращи различни типове данни.

Правилата, описващи различните типове данни, ще намерите в края на условието.

## PrivacyFilter

Идеята на този клас е да извършва просто филтриране на "лични" данни. В случая, ще дефинираме лични данни като email адреси и телефонни номера. Класът трбява да предоставя следния интерфейс:

	filter = PrivacyFilter.new(text)
	filter.filtered # => returns the filtered text

Тоест, да може да се конструира с един аргумент — текстът за филтриране и да връща обект, имащ метод `filtered`. Този метод трябва да връща филтрирания текст. Във филтрирания текст, всяко срещане на валиден email или телефонен номер се филтрира според правилата, указани по-долу.

Обектът трябва да поддържа и три опционални флага, които по подразбиране са "изключени":

	PrivacyFilter#preserve_phone_country_code
	PrivacyFilter#preserve_email_hostname
	PrivacyFilter#partially_preserve_email_username

Правила за филтиране:

- Всеки валиден email адрес се замества с `[EMAIL]`
- Всеки валиден телефон се замества с `[PHONE]`
- Когато е вдигнат флагът `preserve_phone_country_code`, валидните телефонни номера, записани в интернационален формат, се филтрират само частично, като им се запазва кодът на държавата. Връща се код на държавата, последван от интервал, последван от `[FILTERED]`. Например:

		filter = PrivacyFilter.new 'Phone: +35925551212'
		filter.preserve_phone_country_code = true
		filter.filtered # => 'Phone: +359 [FILTERED]'

- Ако номерът не е в интернационален формат, се филтрира целия и флагът `preserve_phone_country_code` трябва да се игнорира
- Когато флагът `preserve_email_hostname` е истина, се запазва hostname-частта от валидните email адреси, например:

		filter = PrivacyFilter.new 'someone@example.com'
		filter.preserve_email_hostname = true
		filter.filtered # => '[FILTERED]@example.com'
- При вдигнат флаг `partially_preserve_email_username`, се подразбира вдигнат флаг `preserve_email_hostname` и се филтрира само част от потребителското име в даден валиден мейл, като първите три символа се запазват. Например:

		filter = PrivacyFilter.new 'someone@example.com'
		filter.partially_preserve_email_username = true
		filter.filtered # => 'som[FILTERED]@example.com'

- Ако в горния случай, дължината на потребителското име в email е под 6 символа, то се обфускира цялото потребителско име
- Първо се заместват валидните email адреси и след това, на този вече филтриран резултат, се прилагат следващите правила, за заместване на телефонни номера

В края на условието сме описали какво считаме за валиден телефонен номер или email.

## Validations

Този клас или модул трябва да предоставя няколко "класови" метода, които да ни позволят да извършваме проста валидация на текстови данни. Всички методи са тип предикат и трябва да връщат задължително или `true`, или `false`.

Интерфейс:

	Validations.email?(value)       # => true or false
	Validations.phone?(value)       # => true or false
	Validations.hostname?(value)    # => true or false
	Validations.ip_address?(value)  # => true or false
	Validations.number?(value)      # => true or false
	Validations.integer?(value)     # => true or false
	Validations.date?(value)        # => true or false
	Validations.time?(value)        # => true or false
	Validations.date_time?(value)   # => true or false

Имената на методите са очевидни. Какво разбираме под валиден формат на дадения тип данни, може да разберете в следващата секция.

## Описание на форматите

Тук ще опишем какво ще разбираме в тази задача под "валиден Х". С цел опростяване на задачата, "валиден Х" не винаги ще покрива съотетната дефиниция от реалността.

Където не е указано изрично, се подразбира само букви и цифри от ASCII таблицата с кодове под 127, т.е. без unicode букви и цифри.

### Email адрес

Валиден email адрес ще наричаме всяка последователност от символи, която:

- започва с малка, главна буква или цифра
- опционално могат да следват до 200 други букви, цифри, долни черти, плюсове, точки или тирета
- символ `@`
- име на хост, т.е. валиден hostname (вж. по-долу)

### Hostname

Всеки hostname е съставен от 0 или повече поддомейна и един домейн, разделени със символа `.`. Всеки домейн има име и TLD, също разделени с `.`. Всеки поддомейн има само име.

- Валидно име на домейн или поддомейн:
	- започва с цифра, малка или главна буква
	- следват до 62 цифри, малки или големи букви или тире
	- последният символ не може да е тире
	- общата дължина трябва да е между 1 и 63 символа
- Валидно TLD:
	- две или три букви, малки или главни
	- опционално, символ `.` и още две малки или главни букви

Примерен hostname:

	foo.bar.baz

### Телефонен номер

Телефонният номер е последователност от цифри с опционални разделители. Може да бъде в интернационален запис или в локален запис. Да приемем, че всеки номер е съставен от префикс и същинска чст.

- Префикс:
	- в локален формат, започва с `0`, която не е предшествана от друга цифра, буква или символ `+`; след тази начална `0` не може да следва друга `0`
	- в интернационален формат, започва с `00` (след граница на дума) или `+` и следват една до три цифри международен код, без разделители в тях; международният код не може да започва с `0`
- Същинска част:
	- от 6 до 11 цифри
	- опционално, между всяка цифра може да има максимум до два разделителя от следните: интервал, `-`, `(` и `)`
	- същинската част не може да завършва на разделител, но може да започва с разделител(и)

Примери за телефонни номера:

	08812121212        # В локален формат
	+359 88 121-212-12 # В интернационален формат, с разделители

### IP адрес

Под IP адрес ще разбираме IPv4 адрес, т.е. последователност от четири байта, записани в десетичен формат и разделени с точки. Всеки байт може да има стойност от 0 до 255. Например:

	1.2.3.4
	127.0.0.1

### Число

Числата могат да бъдат цели или дробни

- могат да започват опционално с `-`
- може да следва или само една `0`, или пък цифра от 1 до 9, последвана от неограничен брой други цифри от 0 до 9
- може да има опционално десетичен разделител `.`, последван от поне една цифра

Примери:

	42
	0.00015
	-1000000

### Цяло число (integer)

За целите числа важат същите правила както и при числата, с тази разлика, че при тях не може да има десетичен разделител.

### Дата

Под дата ще разбираме следната последователност от символи:

- четири цифри, от 0 до 9 за година
- разделител `-`
- две цифри от 0 до 9 за месец; числото, съответстващо на месеца, трябва да е между 1 и 12
- разделител `-`
- две цифри от 0 до 9 за ден; числото, съответстващо на деня, трябва да е между 1 и 31

Пример:

	2012-11-19
	2013-01-01

### Час

Под час ще разбираме следната последователност от символи:

- две цифри за час
- разделител `:`
- две цифри за минута
- разделител `:`
- две цифри за секунда

Часът трябва да е между 0 и 23, минутата и секундата между 0 и 59, включително. Пример:

	12:00:01

### Дата и час

Под "дата и час" ще разбираме горните два формата, събрани заедно с разделител или интервал, или главна латинска буква `T`. Например:

	2012-11-19 19:15:00
