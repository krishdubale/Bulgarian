// Bulgarian alphabet letters
class BulgarianLetter {
  final String cyrillic;
  final String romanization;
  final String pronunciationGuide;
  final String exampleWordBulgarian;
  final String exampleWordEnglish;
  final String exampleWordTransliteration;

  const BulgarianLetter({
    required this.cyrillic,
    required this.romanization,
    required this.pronunciationGuide,
    required this.exampleWordBulgarian,
    required this.exampleWordEnglish,
    required this.exampleWordTransliteration,
  });
}

// Bulgarian vocabulary word
class BulgarianWord {
  final String bulgarian;
  final String transliteration;
  final String english;
  final String category;
  final String? exampleBulgarian;
  final String? exampleEnglish;

  const BulgarianWord({
    required this.bulgarian,
    required this.transliteration,
    required this.english,
    required this.category,
    this.exampleBulgarian,
    this.exampleEnglish,
  });
}

// Grammar topic
class GrammarTopic {
  final String title;
  final String explanation;
  final List<GrammarExample> examples;
  final List<QuizQuestion> quiz;
  final String level;

  const GrammarTopic({
    required this.title,
    required this.explanation,
    required this.examples,
    required this.quiz,
    required this.level,
  });
}

class GrammarExample {
  final String bulgarian;
  final String transliteration;
  final String english;

  const GrammarExample({
    required this.bulgarian,
    required this.transliteration,
    required this.english,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

// Reading text
class ReadingText {
  final String title;
  final String bulgarian;
  final String english;
  final String level;
  final List<QuizQuestion> questions;

  const ReadingText({
    required this.title,
    required this.bulgarian,
    required this.english,
    required this.level,
    required this.questions,
  });
}

// Listening dialogue
class DialogueLine {
  final String speaker;
  final String bulgarian;
  final String transliteration;
  final String english;

  const DialogueLine({
    required this.speaker,
    required this.bulgarian,
    required this.transliteration,
    required this.english,
  });
}

class ListeningDialogue {
  final String title;
  final List<DialogueLine> lines;
  final String level;
  final List<QuizQuestion> questions;

  const ListeningDialogue({
    required this.title,
    required this.lines,
    required this.level,
    required this.questions,
  });
}

// Speaking phrase
class SpeakingPhrase {
  final String bulgarian;
  final String transliteration;
  final String english;
  final String level;
  final String context;

  const SpeakingPhrase({
    required this.bulgarian,
    required this.transliteration,
    required this.english,
    required this.level,
    required this.context,
  });
}

// Writing exercise
class WritingExercise {
  final String type; // 'translate', 'fill_blank', 'sentence_build'
  final String prompt;
  final String answer;
  final String? hint;
  final String level;

  const WritingExercise({
    required this.type,
    required this.prompt,
    required this.answer,
    this.hint,
    required this.level,
  });
}

class BulgarianData {
  BulgarianData._();

  // ─────────────────────────── ALPHABET ───────────────────────────

  static const List<BulgarianLetter> alphabet = [
    BulgarianLetter(
      cyrillic: 'Аа',
      romanization: 'A',
      pronunciationGuide: 'as in "father"',
      exampleWordBulgarian: 'азбука',
      exampleWordEnglish: 'alphabet',
      exampleWordTransliteration: 'azbuka',
    ),
    BulgarianLetter(
      cyrillic: 'Бб',
      romanization: 'B',
      pronunciationGuide: 'as in "book"',
      exampleWordBulgarian: 'баща',
      exampleWordEnglish: 'father',
      exampleWordTransliteration: 'bashta',
    ),
    BulgarianLetter(
      cyrillic: 'Вв',
      romanization: 'V',
      pronunciationGuide: 'as in "voice"',
      exampleWordBulgarian: 'вода',
      exampleWordEnglish: 'water',
      exampleWordTransliteration: 'voda',
    ),
    BulgarianLetter(
      cyrillic: 'Гг',
      romanization: 'G',
      pronunciationGuide: 'as in "go"',
      exampleWordBulgarian: 'град',
      exampleWordEnglish: 'city',
      exampleWordTransliteration: 'grad',
    ),
    BulgarianLetter(
      cyrillic: 'Дд',
      romanization: 'D',
      pronunciationGuide: 'as in "door"',
      exampleWordBulgarian: 'дом',
      exampleWordEnglish: 'home',
      exampleWordTransliteration: 'dom',
    ),
    BulgarianLetter(
      cyrillic: 'Ее',
      romanization: 'E',
      pronunciationGuide: 'as in "bed"',
      exampleWordBulgarian: 'есен',
      exampleWordEnglish: 'autumn',
      exampleWordTransliteration: 'esen',
    ),
    BulgarianLetter(
      cyrillic: 'Жж',
      romanization: 'ZH',
      pronunciationGuide: 'as in "measure"',
      exampleWordBulgarian: 'жена',
      exampleWordEnglish: 'woman',
      exampleWordTransliteration: 'zhena',
    ),
    BulgarianLetter(
      cyrillic: 'Зз',
      romanization: 'Z',
      pronunciationGuide: 'as in "zero"',
      exampleWordBulgarian: 'земя',
      exampleWordEnglish: 'earth',
      exampleWordTransliteration: 'zemya',
    ),
    BulgarianLetter(
      cyrillic: 'Ии',
      romanization: 'I',
      pronunciationGuide: 'as in "feet"',
      exampleWordBulgarian: 'игра',
      exampleWordEnglish: 'game',
      exampleWordTransliteration: 'igra',
    ),
    BulgarianLetter(
      cyrillic: 'Йй',
      romanization: 'Y',
      pronunciationGuide: 'as in "yes"',
      exampleWordBulgarian: 'йога',
      exampleWordEnglish: 'yoga',
      exampleWordTransliteration: 'yoga',
    ),
    BulgarianLetter(
      cyrillic: 'Кк',
      romanization: 'K',
      pronunciationGuide: 'as in "king"',
      exampleWordBulgarian: 'книга',
      exampleWordEnglish: 'book',
      exampleWordTransliteration: 'kniga',
    ),
    BulgarianLetter(
      cyrillic: 'Лл',
      romanization: 'L',
      pronunciationGuide: 'as in "love"',
      exampleWordBulgarian: 'луна',
      exampleWordEnglish: 'moon',
      exampleWordTransliteration: 'luna',
    ),
    BulgarianLetter(
      cyrillic: 'Мм',
      romanization: 'M',
      pronunciationGuide: 'as in "mother"',
      exampleWordBulgarian: 'майка',
      exampleWordEnglish: 'mother',
      exampleWordTransliteration: 'mayka',
    ),
    BulgarianLetter(
      cyrillic: 'Нн',
      romanization: 'N',
      pronunciationGuide: 'as in "now"',
      exampleWordBulgarian: 'небе',
      exampleWordEnglish: 'sky',
      exampleWordTransliteration: 'nebe',
    ),
    BulgarianLetter(
      cyrillic: 'Оо',
      romanization: 'O',
      pronunciationGuide: 'as in "hot"',
      exampleWordBulgarian: 'огън',
      exampleWordEnglish: 'fire',
      exampleWordTransliteration: 'ogyn',
    ),
    BulgarianLetter(
      cyrillic: 'Пп',
      romanization: 'P',
      pronunciationGuide: 'as in "pen"',
      exampleWordBulgarian: 'приятел',
      exampleWordEnglish: 'friend',
      exampleWordTransliteration: 'priyatel',
    ),
    BulgarianLetter(
      cyrillic: 'Рр',
      romanization: 'R',
      pronunciationGuide: 'rolled R (like Spanish)',
      exampleWordBulgarian: 'ръка',
      exampleWordEnglish: 'hand',
      exampleWordTransliteration: 'raka',
    ),
    BulgarianLetter(
      cyrillic: 'Сс',
      romanization: 'S',
      pronunciationGuide: 'as in "sun"',
      exampleWordBulgarian: 'слънце',
      exampleWordEnglish: 'sun',
      exampleWordTransliteration: 'slantse',
    ),
    BulgarianLetter(
      cyrillic: 'Тт',
      romanization: 'T',
      pronunciationGuide: 'as in "top"',
      exampleWordBulgarian: 'тигър',
      exampleWordEnglish: 'tiger',
      exampleWordTransliteration: 'tigar',
    ),
    BulgarianLetter(
      cyrillic: 'Уу',
      romanization: 'U',
      pronunciationGuide: 'as in "book"',
      exampleWordBulgarian: 'улица',
      exampleWordEnglish: 'street',
      exampleWordTransliteration: 'ulitsa',
    ),
    BulgarianLetter(
      cyrillic: 'Фф',
      romanization: 'F',
      pronunciationGuide: 'as in "four"',
      exampleWordBulgarian: 'фотография',
      exampleWordEnglish: 'photograph',
      exampleWordTransliteration: 'fotografiya',
    ),
    BulgarianLetter(
      cyrillic: 'Хх',
      romanization: 'KH',
      pronunciationGuide: 'as in Scottish "loch"',
      exampleWordBulgarian: 'хляб',
      exampleWordEnglish: 'bread',
      exampleWordTransliteration: 'khlyab',
    ),
    BulgarianLetter(
      cyrillic: 'Цц',
      romanization: 'TS',
      pronunciationGuide: 'as in "cats"',
      exampleWordBulgarian: 'цвете',
      exampleWordEnglish: 'flower',
      exampleWordTransliteration: 'tsvete',
    ),
    BulgarianLetter(
      cyrillic: 'Чч',
      romanization: 'CH',
      pronunciationGuide: 'as in "church"',
      exampleWordBulgarian: 'чай',
      exampleWordEnglish: 'tea',
      exampleWordTransliteration: 'chay',
    ),
    BulgarianLetter(
      cyrillic: 'Шш',
      romanization: 'SH',
      pronunciationGuide: 'as in "shoe"',
      exampleWordBulgarian: 'шапка',
      exampleWordEnglish: 'hat',
      exampleWordTransliteration: 'shapka',
    ),
    BulgarianLetter(
      cyrillic: 'Щщ',
      romanization: 'SHT',
      pronunciationGuide: 'SH + T combined',
      exampleWordBulgarian: 'щастие',
      exampleWordEnglish: 'happiness',
      exampleWordTransliteration: 'shtastie',
    ),
    BulgarianLetter(
      cyrillic: 'Ъъ',
      romanization: 'UH',
      pronunciationGuide: 'as in "hurt" (schwa-like)',
      exampleWordBulgarian: 'ъгъл',
      exampleWordEnglish: 'corner/angle',
      exampleWordTransliteration: 'agal',
    ),
    BulgarianLetter(
      cyrillic: 'Ьь',
      romanization: 'Y',
      pronunciationGuide: 'soft sign – softens preceding consonant',
      exampleWordBulgarian: 'шофьор',
      exampleWordEnglish: 'driver',
      exampleWordTransliteration: 'shofyor',
    ),
    BulgarianLetter(
      cyrillic: 'Юю',
      romanization: 'YU',
      pronunciationGuide: 'as in "you"',
      exampleWordBulgarian: 'юли',
      exampleWordEnglish: 'July',
      exampleWordTransliteration: 'yuli',
    ),
    BulgarianLetter(
      cyrillic: 'Яя',
      romanization: 'YA',
      pronunciationGuide: 'as in "yard"',
      exampleWordBulgarian: 'ябълка',
      exampleWordEnglish: 'apple',
      exampleWordTransliteration: 'yabylka',
    ),
  ];

  // ─────────────────────────── VOCABULARY ───────────────────────────

  static const List<BulgarianWord> vocabulary = [
    // Greetings
    BulgarianWord(
      bulgarian: 'Здравей',
      transliteration: 'Zdravey',
      english: 'Hello',
      category: 'Greetings',
      exampleBulgarian: 'Здравей, как си?',
      exampleEnglish: 'Hello, how are you?',
    ),
    BulgarianWord(
      bulgarian: 'Добро утро',
      transliteration: 'Dobro utro',
      english: 'Good morning',
      category: 'Greetings',
      exampleBulgarian: 'Добро утро! Как спа?',
      exampleEnglish: 'Good morning! How did you sleep?',
    ),
    BulgarianWord(
      bulgarian: 'Добър ден',
      transliteration: 'Dobur den',
      english: 'Good afternoon',
      category: 'Greetings',
      exampleBulgarian: 'Добър ден, господине.',
      exampleEnglish: 'Good afternoon, sir.',
    ),
    BulgarianWord(
      bulgarian: 'Добър вечер',
      transliteration: 'Dobur vecher',
      english: 'Good evening',
      category: 'Greetings',
      exampleBulgarian: 'Добър вечер на всички!',
      exampleEnglish: 'Good evening everyone!',
    ),
    BulgarianWord(
      bulgarian: 'Довиждане',
      transliteration: 'Dovizhdane',
      english: 'Goodbye',
      category: 'Greetings',
      exampleBulgarian: 'Довиждане, до утре!',
      exampleEnglish: 'Goodbye, see you tomorrow!',
    ),
    BulgarianWord(
      bulgarian: 'Благодаря',
      transliteration: 'Blagodarya',
      english: 'Thank you',
      category: 'Greetings',
      exampleBulgarian: 'Благодаря ти много!',
      exampleEnglish: 'Thank you very much!',
    ),
    BulgarianWord(
      bulgarian: 'Моля',
      transliteration: 'Molya',
      english: "Please / You're welcome",
      category: 'Greetings',
      exampleBulgarian: 'Моля, помогни ми.',
      exampleEnglish: 'Please, help me.',
    ),
    BulgarianWord(
      bulgarian: 'Съжалявам',
      transliteration: 'Sazhalyavam',
      english: 'I am sorry',
      category: 'Greetings',
      exampleBulgarian: 'Съжалявам, закъснях.',
      exampleEnglish: 'I am sorry, I am late.',
    ),
    BulgarianWord(
      bulgarian: 'Да',
      transliteration: 'Da',
      english: 'Yes',
      category: 'Greetings',
      exampleBulgarian: 'Да, разбирам.',
      exampleEnglish: 'Yes, I understand.',
    ),
    BulgarianWord(
      bulgarian: 'Не',
      transliteration: 'Ne',
      english: 'No',
      category: 'Greetings',
      exampleBulgarian: 'Не, не знам.',
      exampleEnglish: 'No, I do not know.',
    ),
    BulgarianWord(
      bulgarian: 'Как си?',
      transliteration: 'Kak si?',
      english: 'How are you?',
      category: 'Greetings',
      exampleBulgarian: 'Как си днес?',
      exampleEnglish: 'How are you today?',
    ),
    BulgarianWord(
      bulgarian: 'Добре',
      transliteration: 'Dobre',
      english: 'Fine / Good',
      category: 'Greetings',
      exampleBulgarian: 'Добре съм, благодаря.',
      exampleEnglish: 'I am fine, thank you.',
    ),

    // Numbers
    BulgarianWord(
      bulgarian: 'едно',
      transliteration: 'edno',
      english: 'one',
      category: 'Numbers',
      exampleBulgarian: 'едно кафе, моля',
      exampleEnglish: 'one coffee, please',
    ),
    BulgarianWord(
      bulgarian: 'две',
      transliteration: 'dve',
      english: 'two',
      category: 'Numbers',
      exampleBulgarian: 'две чаши вода',
      exampleEnglish: 'two glasses of water',
    ),
    BulgarianWord(
      bulgarian: 'три',
      transliteration: 'tri',
      english: 'three',
      category: 'Numbers',
      exampleBulgarian: 'три деца',
      exampleEnglish: 'three children',
    ),
    BulgarianWord(
      bulgarian: 'четири',
      transliteration: 'chetiri',
      english: 'four',
      category: 'Numbers',
      exampleBulgarian: 'четири сезона',
      exampleEnglish: 'four seasons',
    ),
    BulgarianWord(
      bulgarian: 'пет',
      transliteration: 'pet',
      english: 'five',
      category: 'Numbers',
      exampleBulgarian: 'пет минути',
      exampleEnglish: 'five minutes',
    ),
    BulgarianWord(
      bulgarian: 'шест',
      transliteration: 'shest',
      english: 'six',
      category: 'Numbers',
      exampleBulgarian: 'шест часа',
      exampleEnglish: 'six hours',
    ),
    BulgarianWord(
      bulgarian: 'седем',
      transliteration: 'sedem',
      english: 'seven',
      category: 'Numbers',
      exampleBulgarian: 'седем дни в седмицата',
      exampleEnglish: 'seven days in a week',
    ),
    BulgarianWord(
      bulgarian: 'осем',
      transliteration: 'osem',
      english: 'eight',
      category: 'Numbers',
      exampleBulgarian: 'осем часа сън',
      exampleEnglish: 'eight hours of sleep',
    ),
    BulgarianWord(
      bulgarian: 'девет',
      transliteration: 'devet',
      english: 'nine',
      category: 'Numbers',
      exampleBulgarian: 'девет месеца',
      exampleEnglish: 'nine months',
    ),
    BulgarianWord(
      bulgarian: 'десет',
      transliteration: 'deset',
      english: 'ten',
      category: 'Numbers',
      exampleBulgarian: 'десет лева',
      exampleEnglish: 'ten leva (Bulgarian currency)',
    ),

    // Family
    BulgarianWord(
      bulgarian: 'майка',
      transliteration: 'mayka',
      english: 'mother',
      category: 'Family',
      exampleBulgarian: 'Моята майка е учителка.',
      exampleEnglish: 'My mother is a teacher.',
    ),
    BulgarianWord(
      bulgarian: 'баща',
      transliteration: 'bashta',
      english: 'father',
      category: 'Family',
      exampleBulgarian: 'Баща ми работи в София.',
      exampleEnglish: 'My father works in Sofia.',
    ),
    BulgarianWord(
      bulgarian: 'брат',
      transliteration: 'brat',
      english: 'brother',
      category: 'Family',
      exampleBulgarian: 'Имам един брат.',
      exampleEnglish: 'I have one brother.',
    ),
    BulgarianWord(
      bulgarian: 'сестра',
      transliteration: 'sestra',
      english: 'sister',
      category: 'Family',
      exampleBulgarian: 'Сестра ми е на 15 години.',
      exampleEnglish: 'My sister is 15 years old.',
    ),
    BulgarianWord(
      bulgarian: 'дядо',
      transliteration: 'dyado',
      english: 'grandfather',
      category: 'Family',
      exampleBulgarian: 'Дядо ми разказва истории.',
      exampleEnglish: 'My grandfather tells stories.',
    ),
    BulgarianWord(
      bulgarian: 'баба',
      transliteration: 'baba',
      english: 'grandmother',
      category: 'Family',
      exampleBulgarian: 'Баба ми готви много добре.',
      exampleEnglish: 'My grandmother cooks very well.',
    ),
    BulgarianWord(
      bulgarian: 'дете',
      transliteration: 'dete',
      english: 'child',
      category: 'Family',
      exampleBulgarian: 'Детето играе в парка.',
      exampleEnglish: 'The child plays in the park.',
    ),
    BulgarianWord(
      bulgarian: 'семейство',
      transliteration: 'semeystvo',
      english: 'family',
      category: 'Family',
      exampleBulgarian: 'Семейството е важно.',
      exampleEnglish: 'Family is important.',
    ),
    BulgarianWord(
      bulgarian: 'съпруг',
      transliteration: 'saprug',
      english: 'husband',
      category: 'Family',
      exampleBulgarian: 'Съпругът ми е лекар.',
      exampleEnglish: 'My husband is a doctor.',
    ),
    BulgarianWord(
      bulgarian: 'съпруга',
      transliteration: 'sapruga',
      english: 'wife',
      category: 'Family',
      exampleBulgarian: 'Съпругата му е адвокат.',
      exampleEnglish: 'His wife is a lawyer.',
    ),

    // Food
    BulgarianWord(
      bulgarian: 'хляб',
      transliteration: 'khlyab',
      english: 'bread',
      category: 'Food',
      exampleBulgarian: 'Искам хляб, моля.',
      exampleEnglish: 'I want bread, please.',
    ),
    BulgarianWord(
      bulgarian: 'вода',
      transliteration: 'voda',
      english: 'water',
      category: 'Food',
      exampleBulgarian: 'Чаша вода, моля.',
      exampleEnglish: 'A glass of water, please.',
    ),
    BulgarianWord(
      bulgarian: 'кафе',
      transliteration: 'kafe',
      english: 'coffee',
      category: 'Food',
      exampleBulgarian: 'Обичам кафе с мляко.',
      exampleEnglish: 'I love coffee with milk.',
    ),
    BulgarianWord(
      bulgarian: 'чай',
      transliteration: 'chay',
      english: 'tea',
      category: 'Food',
      exampleBulgarian: 'Чаят е горещ.',
      exampleEnglish: 'The tea is hot.',
    ),
    BulgarianWord(
      bulgarian: 'мляко',
      transliteration: 'mlyako',
      english: 'milk',
      category: 'Food',
      exampleBulgarian: 'Прясно мляко от магазина.',
      exampleEnglish: 'Fresh milk from the store.',
    ),
    BulgarianWord(
      bulgarian: 'яйце',
      transliteration: 'yaytse',
      english: 'egg',
      category: 'Food',
      exampleBulgarian: 'Две яйца за закуска.',
      exampleEnglish: 'Two eggs for breakfast.',
    ),
    BulgarianWord(
      bulgarian: 'сирене',
      transliteration: 'sirene',
      english: 'cheese (white)',
      category: 'Food',
      exampleBulgarian: 'Баницата е със сирене.',
      exampleEnglish: 'The banitsa is with white cheese.',
    ),
    BulgarianWord(
      bulgarian: 'месо',
      transliteration: 'meso',
      english: 'meat',
      category: 'Food',
      exampleBulgarian: 'Не ям месо.',
      exampleEnglish: 'I do not eat meat.',
    ),
    BulgarianWord(
      bulgarian: 'салата',
      transliteration: 'salata',
      english: 'salad',
      category: 'Food',
      exampleBulgarian: 'Шопска салата е вкусна.',
      exampleEnglish: 'Shopska salad is delicious.',
    ),
    BulgarianWord(
      bulgarian: 'ябълка',
      transliteration: 'yabylka',
      english: 'apple',
      category: 'Food',
      exampleBulgarian: 'Тази ябълка е сладка.',
      exampleEnglish: 'This apple is sweet.',
    ),

    // Travel
    BulgarianWord(
      bulgarian: 'влак',
      transliteration: 'vlak',
      english: 'train',
      category: 'Travel',
      exampleBulgarian: 'Влакът пристига в 10.',
      exampleEnglish: 'The train arrives at 10.',
    ),
    BulgarianWord(
      bulgarian: 'автобус',
      transliteration: 'avtobus',
      english: 'bus',
      category: 'Travel',
      exampleBulgarian: 'Автобусът е закъснял.',
      exampleEnglish: 'The bus is late.',
    ),
    BulgarianWord(
      bulgarian: 'летище',
      transliteration: 'letishte',
      english: 'airport',
      category: 'Travel',
      exampleBulgarian: 'Летището е далеч.',
      exampleEnglish: 'The airport is far.',
    ),
    BulgarianWord(
      bulgarian: 'хотел',
      transliteration: 'hotel',
      english: 'hotel',
      category: 'Travel',
      exampleBulgarian: 'Хотелът е на центъра.',
      exampleEnglish: 'The hotel is in the center.',
    ),
    BulgarianWord(
      bulgarian: 'паспорт',
      transliteration: 'pasport',
      english: 'passport',
      category: 'Travel',
      exampleBulgarian: 'Имам ли паспорта си?',
      exampleEnglish: 'Do I have my passport?',
    ),
    BulgarianWord(
      bulgarian: 'карта',
      transliteration: 'karta',
      english: 'map',
      category: 'Travel',
      exampleBulgarian: 'Имаш ли карта на града?',
      exampleEnglish: 'Do you have a map of the city?',
    ),
    BulgarianWord(
      bulgarian: 'билет',
      transliteration: 'bilet',
      english: 'ticket',
      category: 'Travel',
      exampleBulgarian: 'Един билет, моля.',
      exampleEnglish: 'One ticket, please.',
    ),
    BulgarianWord(
      bulgarian: 'гара',
      transliteration: 'gara',
      english: 'train station',
      category: 'Travel',
      exampleBulgarian: 'Гарата е близо.',
      exampleEnglish: 'The train station is nearby.',
    ),

    // Colors
    BulgarianWord(
      bulgarian: 'червен',
      transliteration: 'cherven',
      english: 'red',
      category: 'Colors',
      exampleBulgarian: 'Червената роза е красива.',
      exampleEnglish: 'The red rose is beautiful.',
    ),
    BulgarianWord(
      bulgarian: 'син',
      transliteration: 'sin',
      english: 'blue',
      category: 'Colors',
      exampleBulgarian: 'Небето е синьо.',
      exampleEnglish: 'The sky is blue.',
    ),
    BulgarianWord(
      bulgarian: 'зелен',
      transliteration: 'zelen',
      english: 'green',
      category: 'Colors',
      exampleBulgarian: 'Тревата е зелена.',
      exampleEnglish: 'The grass is green.',
    ),
    BulgarianWord(
      bulgarian: 'жълт',
      transliteration: 'zhalt',
      english: 'yellow',
      category: 'Colors',
      exampleBulgarian: 'Слънцето е жълто.',
      exampleEnglish: 'The sun is yellow.',
    ),
    BulgarianWord(
      bulgarian: 'бял',
      transliteration: 'byal',
      english: 'white',
      category: 'Colors',
      exampleBulgarian: 'Снегът е бял.',
      exampleEnglish: 'The snow is white.',
    ),
    BulgarianWord(
      bulgarian: 'черен',
      transliteration: 'cheren',
      english: 'black',
      category: 'Colors',
      exampleBulgarian: 'Котката е черна.',
      exampleEnglish: 'The cat is black.',
    ),
    BulgarianWord(
      bulgarian: 'оранжев',
      transliteration: 'oranzhev',
      english: 'orange',
      category: 'Colors',
      exampleBulgarian: 'Портокалът е оранжев.',
      exampleEnglish: 'The orange is orange.',
    ),
    BulgarianWord(
      bulgarian: 'лилав',
      transliteration: 'lilav',
      english: 'purple',
      category: 'Colors',
      exampleBulgarian: 'Лилавото цвете е красиво.',
      exampleEnglish: 'The purple flower is beautiful.',
    ),

    // Animals
    BulgarianWord(
      bulgarian: 'куче',
      transliteration: 'kuche',
      english: 'dog',
      category: 'Animals',
      exampleBulgarian: 'Кучето лае.',
      exampleEnglish: 'The dog barks.',
    ),
    BulgarianWord(
      bulgarian: 'котка',
      transliteration: 'kotka',
      english: 'cat',
      category: 'Animals',
      exampleBulgarian: 'Котката спи.',
      exampleEnglish: 'The cat sleeps.',
    ),
    BulgarianWord(
      bulgarian: 'птица',
      transliteration: 'ptitsa',
      english: 'bird',
      category: 'Animals',
      exampleBulgarian: 'Птицата пее.',
      exampleEnglish: 'The bird sings.',
    ),
    BulgarianWord(
      bulgarian: 'риба',
      transliteration: 'riba',
      english: 'fish',
      category: 'Animals',
      exampleBulgarian: 'Рибата плува.',
      exampleEnglish: 'The fish swims.',
    ),
    BulgarianWord(
      bulgarian: 'кон',
      transliteration: 'kon',
      english: 'horse',
      category: 'Animals',
      exampleBulgarian: 'Конят тича бързо.',
      exampleEnglish: 'The horse runs fast.',
    ),
    BulgarianWord(
      bulgarian: 'лъв',
      transliteration: 'luv',
      english: 'lion',
      category: 'Animals',
      exampleBulgarian: 'Лъвът е царят на животните.',
      exampleEnglish: 'The lion is king of the animals.',
    ),
    BulgarianWord(
      bulgarian: 'мечка',
      transliteration: 'mechka',
      english: 'bear',
      category: 'Animals',
      exampleBulgarian: 'Мечката спи през зимата.',
      exampleEnglish: 'The bear sleeps in winter.',
    ),
    BulgarianWord(
      bulgarian: 'вълк',
      transliteration: 'valk',
      english: 'wolf',
      category: 'Animals',
      exampleBulgarian: 'Вълкът вие на луната.',
      exampleEnglish: 'The wolf howls at the moon.',
    ),

    // Body
    BulgarianWord(
      bulgarian: 'глава',
      transliteration: 'glava',
      english: 'head',
      category: 'Body',
      exampleBulgarian: 'Боли ме главата.',
      exampleEnglish: 'My head hurts.',
    ),
    BulgarianWord(
      bulgarian: 'ръка',
      transliteration: 'raka',
      english: 'hand / arm',
      category: 'Body',
      exampleBulgarian: 'Дай ми ръка.',
      exampleEnglish: 'Give me your hand.',
    ),
    BulgarianWord(
      bulgarian: 'крак',
      transliteration: 'krak',
      english: 'leg / foot',
      category: 'Body',
      exampleBulgarian: 'Боли ме кракът.',
      exampleEnglish: 'My leg hurts.',
    ),
    BulgarianWord(
      bulgarian: 'очи',
      transliteration: 'ochi',
      english: 'eyes',
      category: 'Body',
      exampleBulgarian: 'Тя има сини очи.',
      exampleEnglish: 'She has blue eyes.',
    ),
    BulgarianWord(
      bulgarian: 'уши',
      transliteration: 'ushi',
      english: 'ears',
      category: 'Body',
      exampleBulgarian: 'Ушите ме болят.',
      exampleEnglish: 'My ears hurt.',
    ),
    BulgarianWord(
      bulgarian: 'уста',
      transliteration: 'usta',
      english: 'mouth',
      category: 'Body',
      exampleBulgarian: 'Отвори устата.',
      exampleEnglish: 'Open your mouth.',
    ),
    BulgarianWord(
      bulgarian: 'нос',
      transliteration: 'nos',
      english: 'nose',
      category: 'Body',
      exampleBulgarian: 'Носът ми тече.',
      exampleEnglish: 'My nose is running.',
    ),
    BulgarianWord(
      bulgarian: 'сърце',
      transliteration: 'sartse',
      english: 'heart',
      category: 'Body',
      exampleBulgarian: 'Сърцето бие.',
      exampleEnglish: 'The heart beats.',
    ),

    // Time
    BulgarianWord(
      bulgarian: 'ден',
      transliteration: 'den',
      english: 'day',
      category: 'Time',
      exampleBulgarian: 'Денят е дълъг.',
      exampleEnglish: 'The day is long.',
    ),
    BulgarianWord(
      bulgarian: 'нощ',
      transliteration: 'nosht',
      english: 'night',
      category: 'Time',
      exampleBulgarian: 'Нощта е тиха.',
      exampleEnglish: 'The night is quiet.',
    ),
    BulgarianWord(
      bulgarian: 'седмица',
      transliteration: 'sedmitsa',
      english: 'week',
      category: 'Time',
      exampleBulgarian: 'Тази седмица е натоварена.',
      exampleEnglish: 'This week is busy.',
    ),
    BulgarianWord(
      bulgarian: 'месец',
      transliteration: 'mesets',
      english: 'month',
      category: 'Time',
      exampleBulgarian: 'Следващия месец пътувам.',
      exampleEnglish: 'Next month I am traveling.',
    ),
    BulgarianWord(
      bulgarian: 'година',
      transliteration: 'godina',
      english: 'year',
      category: 'Time',
      exampleBulgarian: 'Тази година беше трудна.',
      exampleEnglish: 'This year was difficult.',
    ),
    BulgarianWord(
      bulgarian: 'сега',
      transliteration: 'sega',
      english: 'now',
      category: 'Time',
      exampleBulgarian: 'Ела сега.',
      exampleEnglish: 'Come now.',
    ),
    BulgarianWord(
      bulgarian: 'утре',
      transliteration: 'utre',
      english: 'tomorrow',
      category: 'Time',
      exampleBulgarian: 'Ще се видим утре.',
      exampleEnglish: 'We will see each other tomorrow.',
    ),
    BulgarianWord(
      bulgarian: 'вчера',
      transliteration: 'vchera',
      english: 'yesterday',
      category: 'Time',
      exampleBulgarian: 'Вчера беше хубав ден.',
      exampleEnglish: 'Yesterday was a nice day.',
    ),
  ];

  // ─────────────────────────── GRAMMAR ───────────────────────────

  static const List<GrammarTopic> grammarTopics = [
    GrammarTopic(
      title: 'Basic Sentence Structure',
      explanation:
          'Bulgarian sentences follow Subject-Verb-Object (SVO) order, similar to English. '
          'However, word order is more flexible than in English because nouns are marked for case through context and articles.\n\n'
          'The definite article in Bulgarian is attached to the END of the word (postpositive), not placed before it.',
      examples: [
        GrammarExample(
          bulgarian: 'Аз говоря български.',
          transliteration: 'Az govorya balgarski.',
          english: 'I speak Bulgarian.',
        ),
        GrammarExample(
          bulgarian: 'Тя чете книга.',
          transliteration: 'Tya chete kniga.',
          english: 'She reads a book.',
        ),
        GrammarExample(
          bulgarian: 'Книгата е интересна.',
          transliteration: 'Knigata e interesna.',
          english: 'The book is interesting. (definite article -та attached)',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'How is the definite article positioned in Bulgarian?',
          options: [
            'Before the noun (like English "the")',
            'Attached to the END of the noun',
            'It does not exist in Bulgarian',
            'It is a separate word in the middle',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'What is the basic word order in Bulgarian?',
          options: ['SOV', 'SVO', 'VSO', 'OVS'],
          correctIndex: 1,
        ),
      ],
      level: 'A1',
    ),
    GrammarTopic(
      title: 'Noun Gender',
      explanation:
          'Bulgarian nouns have three grammatical genders: masculine, feminine, and neuter.\n\n'
          '• Masculine nouns typically end in a consonant: стол (chair), град (city)\n'
          '• Feminine nouns typically end in -а or -я: жена (woman), земя (earth)\n'
          '• Neuter nouns typically end in -о or -е: дете (child), слово (word)\n\n'
          'Adjectives must agree in gender, number, and definiteness with the noun they modify.',
      examples: [
        GrammarExample(
          bulgarian: 'голям град (m) · голяма жена (f) · голямо дете (n)',
          transliteration: 'golyam grad · golyama zhena · golyamo dete',
          english: 'big city (m) · big woman (f) · big child (n)',
        ),
        GrammarExample(
          bulgarian: 'нов стол · нова книга · ново куче',
          transliteration: 'nov stol · nova kniga · novo kuche',
          english: 'new chair (m) · new book (f) · new dog (n)',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What gender is "жена" (woman)?',
          options: ['Masculine', 'Feminine', 'Neuter', 'No gender'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question:
              'Which ending is typical for neuter nouns in Bulgarian?',
          options: ['-consonant', '-а / -я', '-о / -е', '-и'],
          correctIndex: 2,
        ),
      ],
      level: 'A1',
    ),
    GrammarTopic(
      title: 'Personal Pronouns',
      explanation:
          'Bulgarian personal pronouns change form based on their function in the sentence.\n\n'
          'Subject pronouns:\n'
          '• аз – I\n'
          '• ти – you (singular)\n'
          '• той – he\n'
          '• тя – she\n'
          '• то – it\n'
          '• ние – we\n'
          '• вие – you (plural/formal)\n'
          '• те – they\n\n'
          'Note: Subject pronouns are often dropped in Bulgarian when the verb form makes the subject clear.',
      examples: [
        GrammarExample(
          bulgarian: 'Аз съм студент.',
          transliteration: 'Az sam student.',
          english: 'I am a student.',
        ),
        GrammarExample(
          bulgarian: 'Той е от България.',
          transliteration: 'Toy e ot Balgariya.',
          english: 'He is from Bulgaria.',
        ),
        GrammarExample(
          bulgarian: 'Ние учим български.',
          transliteration: 'Nie uchim balgarski.',
          english: 'We are learning Bulgarian.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'What does "ние" mean?',
          options: ['I', 'You', 'We', 'They'],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'Which pronoun means "she" in Bulgarian?',
          options: ['то', 'той', 'тя', 'ти'],
          correctIndex: 2,
        ),
      ],
      level: 'A1',
    ),
    GrammarTopic(
      title: 'The Verb "to be" (съм)',
      explanation:
          'The verb "съм" (to be) is one of the most important verbs in Bulgarian.\n\n'
          'Present tense conjugation:\n'
          '• аз съм – I am\n'
          '• ти си – you are\n'
          '• той/тя/то е – he/she/it is\n'
          '• ние сме – we are\n'
          '• вие сте – you are (plural)\n'
          '• те са – they are\n\n'
          'Negative form: add "не" before the verb (не съм, не си, не е...)',
      examples: [
        GrammarExample(
          bulgarian: 'Аз съм добре.',
          transliteration: 'Az sam dobre.',
          english: 'I am fine.',
        ),
        GrammarExample(
          bulgarian: 'Те са приятели.',
          transliteration: 'Te sa priyateli.',
          english: 'They are friends.',
        ),
        GrammarExample(
          bulgarian: 'Не съм уморен.',
          transliteration: 'Ne sam umoren.',
          english: 'I am not tired.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'How do you say "they are" in Bulgarian?',
          options: ['те си', 'те е', 'те са', 'те сте'],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'To make "съм" negative, you add:',
          options: ['не before the verb', 'не after the verb', '-не suffix', 'без before'],
          correctIndex: 0,
        ),
      ],
      level: 'A1',
    ),
    GrammarTopic(
      title: 'Present Tense Verb Conjugation',
      explanation:
          'Bulgarian verbs are conjugated based on person and number. There are three conjugation groups based on the vowel before the ending:\n\n'
          '1st conjugation (-а / -ят): говоря (to speak)\n'
          '2nd conjugation (-а / -ят after e): пея (to sing)\n'
          '3rd conjugation (-а / -ят after и): чета (to read)\n\n'
          'Example – говоря (to speak):\n'
          '• аз говоря – I speak\n'
          '• ти говориш – you speak\n'
          '• той говори – he speaks\n'
          '• ние говорим – we speak\n'
          '• вие говорите – you (pl) speak\n'
          '• те говорят – they speak',
      examples: [
        GrammarExample(
          bulgarian: 'Аз говоря английски.',
          transliteration: 'Az govorya angliyski.',
          english: 'I speak English.',
        ),
        GrammarExample(
          bulgarian: 'Ти четеш книга.',
          transliteration: 'Ti chetes kniga.',
          english: 'You are reading a book.',
        ),
        GrammarExample(
          bulgarian: 'Те пеят красиво.',
          transliteration: 'Te peyat krasivo.',
          english: 'They sing beautifully.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'How do you say "we speak" using говоря?',
          options: ['ние говоря', 'ние говорим', 'ние говорят', 'ние говориш'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Complete: "Ти ___ книга." (read)',
          options: ['четат', 'чета', 'четеш', 'чете'],
          correctIndex: 2,
        ),
      ],
      level: 'A2',
    ),
    GrammarTopic(
      title: 'Past Tense (Минало свършено)',
      explanation:
          'The simple past tense in Bulgarian (минало свършено време) is used to describe completed actions in the past.\n\n'
          'It is formed from the past stem + personal endings:\n'
          '• аз говорих – I spoke\n'
          '• ти говори – you spoke\n'
          '• той говори – he spoke\n'
          '• ние говорихме – we spoke\n'
          '• вие говорихте – you (pl) spoke\n'
          '• те говориха – they spoke\n\n'
          'Time markers often used with past tense: вчера (yesterday), миналата седмица (last week), преди (before/ago)',
      examples: [
        GrammarExample(
          bulgarian: 'Вчера учих цял ден.',
          transliteration: 'Vchera uchikh tsyal den.',
          english: 'Yesterday I studied all day.',
        ),
        GrammarExample(
          bulgarian: 'Тя пристигна в пет часа.',
          transliteration: 'Tya pristigna v pet chasa.',
          english: 'She arrived at five o\'clock.',
        ),
        GrammarExample(
          bulgarian: 'Ние ядохме заедно.',
          transliteration: 'Nie yadokhme zaedno.',
          english: 'We ate together.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'Which sentence is in the past tense?',
          options: [
            'Аз говоря добре.',
            'Тя пристигна вчера.',
            'Ние ще пътуваме.',
            'Ти четеш книга.',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Вчера means:',
          options: ['today', 'tomorrow', 'yesterday', 'last year'],
          correctIndex: 2,
        ),
      ],
      level: 'A2',
    ),
    GrammarTopic(
      title: 'Future Tense',
      explanation:
          'The future tense in Bulgarian is formed using the particle "ще" + the present tense form of the verb.\n\n'
          'Formation: ще + present tense verb\n'
          '• Аз ще говоря – I will speak\n'
          '• Ти ще говориш – You will speak\n'
          '• Той ще говори – He will speak\n'
          '• Ние ще говорим – We will speak\n\n'
          'Negative future: "няма да" + present tense\n'
          '• Аз няма да говоря – I will not speak',
      examples: [
        GrammarExample(
          bulgarian: 'Утре ще отида на работа.',
          transliteration: 'Utre shte otida na rabota.',
          english: 'Tomorrow I will go to work.',
        ),
        GrammarExample(
          bulgarian: 'Те ще пристигнат следващата седмица.',
          transliteration: 'Te shte pristignat sledvashtata sedmitsa.',
          english: 'They will arrive next week.',
        ),
        GrammarExample(
          bulgarian: 'Няма да вали дъжд.',
          transliteration: 'Nyama da vali dazhduh.',
          english: 'It will not rain.',
        ),
      ],
      quiz: [
        QuizQuestion(
          question: 'How is the future tense formed in Bulgarian?',
          options: [
            'будет + infinitive',
            'ще + present tense',
            'да + past tense',
            'ако + verb',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'How do you say "I will not go" in Bulgarian?',
          options: [
            'Аз ще не отида',
            'Аз ще отида не',
            'Аз няма да отида',
            'Аз не ще отида',
          ],
          correctIndex: 2,
        ),
      ],
      level: 'B1',
    ),
  ];

  // ─────────────────────────── DIALOGUES ───────────────────────────

  static const List<ListeningDialogue> dialogues = [
    ListeningDialogue(
      title: 'Meeting Someone New',
      level: 'A1',
      lines: [
        DialogueLine(
          speaker: 'Иван',
          bulgarian: 'Здравей! Аз съм Иван. Как се казваш?',
          transliteration: 'Zdravey! Az sam Ivan. Kak se kazvash?',
          english: 'Hello! I am Ivan. What is your name?',
        ),
        DialogueLine(
          speaker: 'Мария',
          bulgarian: 'Здравей, Иване! Аз съм Мария. Много ми е приятно.',
          transliteration: 'Zdravey, Ivane! Az sam Mariya. Mnogo mi e priyatno.',
          english: 'Hello, Ivan! I am Maria. Very nice to meet you.',
        ),
        DialogueLine(
          speaker: 'Иван',
          bulgarian: 'И мен. Откъде си?',
          transliteration: 'I men. Otkade si?',
          english: 'Likewise. Where are you from?',
        ),
        DialogueLine(
          speaker: 'Мария',
          bulgarian: 'Аз съм от Пловдив. А ти?',
          transliteration: 'Az sam ot Plovdiv. A ti?',
          english: 'I am from Plovdiv. And you?',
        ),
        DialogueLine(
          speaker: 'Иван',
          bulgarian: 'Аз съм от София. Живея там от десет години.',
          transliteration: 'Az sam ot Sofiya. Zhiveya tam ot deset godini.',
          english: 'I am from Sofia. I have lived there for ten years.',
        ),
      ],
      questions: [
        QuizQuestion(
          question: 'Where is Maria from?',
          options: ['Sofia', 'Varna', 'Plovdiv', 'Burgas'],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'How long has Ivan lived in Sofia?',
          options: ['5 years', '10 years', '15 years', '20 years'],
          correctIndex: 1,
        ),
      ],
    ),
    ListeningDialogue(
      title: 'At the Café',
      level: 'A1',
      lines: [
        DialogueLine(
          speaker: 'Сервитьор',
          bulgarian: 'Добър ден! Какво ще вземете?',
          transliteration: 'Dobur den! Kakvo shte vzemete?',
          english: 'Good afternoon! What will you have?',
        ),
        DialogueLine(
          speaker: 'Клиент',
          bulgarian: 'Едно кафе и парче торта, моля.',
          transliteration: 'Edno kafe i parche torta, molya.',
          english: 'One coffee and a piece of cake, please.',
        ),
        DialogueLine(
          speaker: 'Сервитьор',
          bulgarian: 'Какво кафе искате? Черно или с мляко?',
          transliteration: 'Kakvo kafe iskate? Cherno ili s mlyako?',
          english: 'What kind of coffee do you want? Black or with milk?',
        ),
        DialogueLine(
          speaker: 'Клиент',
          bulgarian: 'С мляко, моля. И без захар.',
          transliteration: 'S mlyako, molya. I bez zakhar.',
          english: 'With milk, please. And without sugar.',
        ),
        DialogueLine(
          speaker: 'Сервитьор',
          bulgarian: 'Веднага. Нещо друго?',
          transliteration: 'Vednaga. Neshto drugo?',
          english: 'Right away. Anything else?',
        ),
        DialogueLine(
          speaker: 'Клиент',
          bulgarian: 'Не, благодаря. Само сметката.',
          transliteration: 'Ne, blagodarya. Samo smetkata.',
          english: 'No, thank you. Just the bill.',
        ),
      ],
      questions: [
        QuizQuestion(
          question: 'What does the customer order?',
          options: [
            'Tea and cake',
            'Coffee and cake',
            'Coffee and sandwich',
            'Two coffees',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'How does the customer want the coffee?',
          options: [
            'Black with sugar',
            'Black without sugar',
            'With milk and sugar',
            'With milk without sugar',
          ],
          correctIndex: 3,
        ),
      ],
    ),
    ListeningDialogue(
      title: 'Asking for Directions',
      level: 'A2',
      lines: [
        DialogueLine(
          speaker: 'Турист',
          bulgarian: 'Извинете, може ли да ми помогнете?',
          transliteration: 'Izvinete, mozhe li da mi pomognete?',
          english: 'Excuse me, can you help me?',
        ),
        DialogueLine(
          speaker: 'Местен',
          bulgarian: 'Да, разбира се. Какво ви трябва?',
          transliteration: 'Da, razbira se. Kakvo vi tryabva?',
          english: 'Yes, of course. What do you need?',
        ),
        DialogueLine(
          speaker: 'Турист',
          bulgarian: 'Търся Националния исторически музей. Далеко ли е?',
          transliteration: 'Tarsya Natsionalniya istoricheski muzey. Daleko li e?',
          english: 'I am looking for the National History Museum. Is it far?',
        ),
        DialogueLine(
          speaker: 'Местен',
          bulgarian:
              'Не, на около десет минути пеша. Вървете направо, после завийте наляво.',
          transliteration:
              'Ne, na okolo deset minuti pesha. Varvete napravo, posle zaviyte nalyavo.',
          english:
              'No, about ten minutes on foot. Go straight, then turn left.',
        ),
        DialogueLine(
          speaker: 'Турист',
          bulgarian: 'Благодаря ви много!',
          transliteration: 'Blagodarya vi mnogo!',
          english: 'Thank you very much!',
        ),
      ],
      questions: [
        QuizQuestion(
          question: 'What is the tourist looking for?',
          options: [
            'The train station',
            'The National History Museum',
            'A hotel',
            'A restaurant',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'How far away is the destination?',
          options: [
            '5 minutes by car',
            '10 minutes on foot',
            '20 minutes by bus',
            'Very far',
          ],
          correctIndex: 1,
        ),
      ],
    ),
  ];

  // ─────────────────────────── SPEAKING PHRASES ───────────────────────────

  static const List<SpeakingPhrase> speakingPhrases = [
    SpeakingPhrase(
      bulgarian: 'Как се казваш?',
      transliteration: 'Kak se kazvash?',
      english: 'What is your name?',
      level: 'A1',
      context: 'Meeting someone new',
    ),
    SpeakingPhrase(
      bulgarian: 'Казвам се...',
      transliteration: 'Kazvam se...',
      english: 'My name is...',
      level: 'A1',
      context: 'Introducing yourself',
    ),
    SpeakingPhrase(
      bulgarian: 'Откъде си?',
      transliteration: 'Otkade si?',
      english: 'Where are you from?',
      level: 'A1',
      context: 'Getting to know someone',
    ),
    SpeakingPhrase(
      bulgarian: 'Колко години си?',
      transliteration: 'Kolko godini si?',
      english: 'How old are you?',
      level: 'A1',
      context: 'Personal information',
    ),
    SpeakingPhrase(
      bulgarian: 'Говориш ли английски?',
      transliteration: 'Govoriš li angliyski?',
      english: 'Do you speak English?',
      level: 'A1',
      context: 'Language abilities',
    ),
    SpeakingPhrase(
      bulgarian: 'Не разбирам.',
      transliteration: 'Ne razbiram.',
      english: 'I do not understand.',
      level: 'A1',
      context: 'Communication difficulty',
    ),
    SpeakingPhrase(
      bulgarian: 'Можете ли да говорите по-бавно?',
      transliteration: 'Mozhete li da govorite po-bavno?',
      english: 'Can you speak more slowly?',
      level: 'A1',
      context: 'Asking for slower speech',
    ),
    SpeakingPhrase(
      bulgarian: 'Колко струва?',
      transliteration: 'Kolko struva?',
      english: 'How much does it cost?',
      level: 'A1',
      context: 'Shopping',
    ),
    SpeakingPhrase(
      bulgarian: 'Къде е тоалетната?',
      transliteration: 'Kade e toaletnata?',
      english: 'Where is the bathroom?',
      level: 'A1',
      context: 'Finding facilities',
    ),
    SpeakingPhrase(
      bulgarian: 'Мога ли да платя с карта?',
      transliteration: 'Moga li da platya s karta?',
      english: 'Can I pay by card?',
      level: 'A2',
      context: 'Payment',
    ),
    SpeakingPhrase(
      bulgarian: 'Имате ли свободна стая?',
      transliteration: 'Imate li svobodna staya?',
      english: 'Do you have a free room?',
      level: 'A2',
      context: 'Hotel booking',
    ),
    SpeakingPhrase(
      bulgarian: 'Бих искал/а да резервирам маса.',
      transliteration: 'Bikh iskal/a da rezerviram masa.',
      english: 'I would like to reserve a table.',
      level: 'A2',
      context: 'Restaurant reservation',
    ),
    SpeakingPhrase(
      bulgarian: 'Какво препоръчвате?',
      transliteration: 'Kakvo preporachvate?',
      english: 'What do you recommend?',
      level: 'A2',
      context: 'Asking for recommendations',
    ),
    SpeakingPhrase(
      bulgarian: 'Имам алергия към...',
      transliteration: 'Imam alergiya kam...',
      english: 'I am allergic to...',
      level: 'B1',
      context: 'Health and food',
    ),
    SpeakingPhrase(
      bulgarian: 'Бихте ли ми помогнали с...',
      transliteration: 'Bikhte li mi pomognali s...',
      english: 'Could you help me with...',
      level: 'B1',
      context: 'Asking for help (formal)',
    ),
  ];

  // ─────────────────────────── READING TEXTS ───────────────────────────

  static const List<ReadingText> readingTexts = [
    ReadingText(
      title: 'Bulgaria',
      level: 'A1',
      bulgarian:
          'България е страна в Югоизточна Европа. Тя е на Балканския полуостров. '
          'Столицата на България е София. В България живеят около седем милиона души. '
          'Официалният език е български. Официалната валута е лев. '
          'България е красива страна с планини, морета и реки.',
      english:
          'Bulgaria is a country in Southeast Europe. It is on the Balkan Peninsula. '
          'The capital of Bulgaria is Sofia. About seven million people live in Bulgaria. '
          'The official language is Bulgarian. The official currency is the lev. '
          'Bulgaria is a beautiful country with mountains, seas and rivers.',
      questions: [
        QuizQuestion(
          question: 'What is the capital of Bulgaria?',
          options: ['Plovdiv', 'Varna', 'Sofia', 'Burgas'],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'What is the official currency of Bulgaria?',
          options: ['Euro', 'Dollar', 'Lev', 'Dinar'],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'Where is Bulgaria located?',
          options: [
            'Western Europe',
            'Southeast Europe',
            'Scandinavia',
            'Central Asia',
          ],
          correctIndex: 1,
        ),
      ],
    ),
    ReadingText(
      title: 'A Day in Sofia',
      level: 'A2',
      bulgarian:
          'Иван живее в София. Всеки ден той става рано сутринта. '
          'Пие кафе и закусва. После отива на работа с метрото. '
          'Работи в офис в центъра. На обяд яде в ресторант близо до офиса. '
          'Вечерта се прибира вкъщи, гледа телевизия и чете книга. '
          'В събота и неделя отива на разходка в Борисовата градина.',
      english:
          'Ivan lives in Sofia. Every day he wakes up early in the morning. '
          'He drinks coffee and has breakfast. Then he goes to work by metro. '
          'He works in an office in the center. At lunch he eats at a restaurant near the office. '
          'In the evening he comes home, watches TV and reads a book. '
          'On Saturday and Sunday he goes for a walk in Borisova Gradina park.',
      questions: [
        QuizQuestion(
          question: 'How does Ivan go to work?',
          options: ['By car', 'By bus', 'By metro', 'On foot'],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'Where does Ivan eat lunch?',
          options: [
            'At home',
            'At the office',
            'At a restaurant near the office',
            'In the park',
          ],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'What does Ivan do on weekends?',
          options: [
            'Goes to the beach',
            'Goes for walks in the park',
            'Works overtime',
            'Travels abroad',
          ],
          correctIndex: 1,
        ),
      ],
    ),
    ReadingText(
      title: 'Bulgarian Cuisine',
      level: 'B1',
      bulgarian:
          'Българската кухня е богата и разнообразна. Тя отразява влиянието на различни народи и култури. '
          'Най-известните ястия включват шопска салата, баница и мусака. '
          'Шопската салата се приготвя с домати, краставици, чушки, лук и сирене. '
          'Баницата е традиционна питка, пълнена обикновено със сирене и яйца. '
          'Мусаката е ястие от картофи и кайма, запечено с яйчена коричка. '
          'Кисело мляко е много популярно в България и се използва в много ястия. '
          'Традиционната алкохолна напитка е ракията, приготвена от плодове.',
      english:
          'Bulgarian cuisine is rich and diverse. It reflects the influence of various peoples and cultures. '
          'The most famous dishes include Shopska salad, banitsa and moussaka. '
          'Shopska salad is made with tomatoes, cucumbers, peppers, onion and white cheese. '
          'Banitsa is a traditional pastry, usually filled with cheese and eggs. '
          'Moussaka is a dish of potatoes and minced meat, baked with an egg topping. '
          'Yogurt is very popular in Bulgaria and is used in many dishes. '
          'The traditional alcoholic drink is rakia, made from fruits.',
      questions: [
        QuizQuestion(
          question: 'What is Shopska salad made with?',
          options: [
            'Meat and rice',
            'Tomatoes, cucumbers, peppers, onion and cheese',
            'Potatoes and eggs',
            'Fish and vegetables',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'What is banitsa?',
          options: [
            'A type of salad',
            'A meat dish',
            'A traditional pastry',
            'A soup',
          ],
          correctIndex: 2,
        ),
        QuizQuestion(
          question: 'What is rakia made from?',
          options: ['Grapes only', 'Wheat', 'Fruits', 'Vegetables'],
          correctIndex: 2,
        ),
      ],
    ),
  ];

  // ─────────────────────────── WRITING EXERCISES ───────────────────────────

  static const List<WritingExercise> writingExercises = [
    WritingExercise(
      type: 'translate',
      prompt: 'Translate to Bulgarian: "Hello, my name is Maria."',
      answer: 'Здравей, казвам се Мария.',
      hint: 'Use Здравей for Hello, казвам се for my name is',
      level: 'A1',
    ),
    WritingExercise(
      type: 'translate',
      prompt: 'Translate to Bulgarian: "I am from Sofia."',
      answer: 'Аз съм от София.',
      hint: 'Аз = I, съм = am, от = from',
      level: 'A1',
    ),
    WritingExercise(
      type: 'translate',
      prompt: 'Translate to Bulgarian: "The book is interesting."',
      answer: 'Книгата е интересна.',
      hint:
          'Note: книгата uses the definite article suffix -та',
      level: 'A1',
    ),
    WritingExercise(
      type: 'fill_blank',
      prompt: 'Fill in the blank: "Аз ___ студент." (I am a student)',
      answer: 'съм',
      hint: 'Use the correct form of "to be" for first person singular',
      level: 'A1',
    ),
    WritingExercise(
      type: 'fill_blank',
      prompt: 'Fill in the blank: "Те ___ приятели." (They are friends)',
      answer: 'са',
      hint: 'Use the correct form of "to be" for third person plural',
      level: 'A1',
    ),
    WritingExercise(
      type: 'fill_blank',
      prompt: 'Fill in the blank: "Утре ___ отида на работа." (I will go to work)',
      answer: 'ще',
      hint: 'Future tense particle in Bulgarian',
      level: 'A2',
    ),
    WritingExercise(
      type: 'translate',
      prompt: 'Translate to Bulgarian: "Thank you very much!"',
      answer: 'Благодаря ти много!',
      hint: 'Благодаря = thank you, много = very/much',
      level: 'A1',
    ),
    WritingExercise(
      type: 'translate',
      prompt: 'Translate to Bulgarian: "We are learning Bulgarian."',
      answer: 'Ние учим български.',
      hint: 'учим is the first person plural of учa (to learn/study)',
      level: 'A2',
    ),
    WritingExercise(
      type: 'fill_blank',
      prompt:
          'Fill in the blank: "Вчера аз ___ цял ден." (Yesterday I studied all day)',
      answer: 'учих',
      hint: 'Past tense of уча for first person singular',
      level: 'A2',
    ),
    WritingExercise(
      type: 'translate',
      prompt: 'Translate to Bulgarian: "I will not go tomorrow."',
      answer: 'Утре няма да отида.',
      hint: 'Negative future uses няма да',
      level: 'B1',
    ),
  ];
}
