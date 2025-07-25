/// Default punctuation characters from multiple languages.
///
/// Includes punctuation from Latin, CJK, and other writing systems:
/// - Basic punctuation: comma, period, colon, semicolon
/// - Brackets and quotes: (), [], {}, "", ''
/// - CJK punctuation: 、，。：；【】《》
/// - Currency and symbols: $, ￥, *, /, \, &, %, @, #, ^
///
/// These characters are removed from text by default, or converted to spaces
/// when [WordCountConfig.punctuationAsBreaker] is true.
const List<String> defaultPunctuation = [
  ',', '，', '.', '。', ':', '：', ';', '；', '[', ']', '【', ']', '】', '{', '｛', '}', '｝',
  '(', '（', ')', '）', '<', '《', '>', '》', '\$', '￥', '!', '！', '?', '？', '~', '～',
  "'", "'", '"', '"', '"',
  '*', '/', '\\', '&', '%', '@', '#', '^', '、', '、', '、', '、'
];

/// Configuration options for word counting behavior.
///
/// Controls how punctuation is handled during word counting and allows
/// customization of the punctuation character set.
///
/// Example:
/// ```dart
/// // Treat punctuation as word separators
/// const config1 = WordCountConfig(punctuationAsBreaker: true);
/// wordsCount("don't", config1); // Returns 2
///
/// // Add custom punctuation
/// const config2 = WordCountConfig(punctuation: ['-']);
/// wordsCount('multi-word', config2); // Returns 1 (removes hyphen)
///
/// // Use only custom punctuation
/// const config3 = WordCountConfig(
///   punctuation: ['-'], 
///   disableDefaultPunctuation: true
/// );
/// ```
class WordCountConfig {
  /// Whether to treat punctuation as word separators instead of removing them.
  ///
  /// When `true`, punctuation characters are replaced with spaces, potentially
  /// creating additional words. When `false`, punctuation is simply removed.
  final bool punctuationAsBreaker;
  
  /// Whether to disable the default punctuation list.
  ///
  /// When `true`, only characters specified in [punctuation] are treated as
  /// punctuation. When `false`, [punctuation] is added to [defaultPunctuation].
  final bool disableDefaultPunctuation;
  
  /// Custom punctuation characters to use in addition to or instead of defaults.
  ///
  /// These characters will be processed according to [punctuationAsBreaker].
  /// If [disableDefaultPunctuation] is `true`, only these characters are
  /// treated as punctuation.
  final List<String> punctuation;

  /// Creates a new word count configuration.
  const WordCountConfig({
    this.punctuationAsBreaker = false,
    this.disableDefaultPunctuation = false,
    this.punctuation = const [],
  });
}

/// Result object containing both word count and word array.
///
/// Returned by [wordsDetect] to provide both pieces of information
/// in a single function call.
///
/// Example:
/// ```dart
/// WordCountResult result = wordsDetect('Hello World');
/// print('Found ${result.count} words: ${result.words}');
/// // Output: Found 2 words: [Hello, World]
/// ```
class WordCountResult {
  /// The array of words found in the text.
  ///
  /// Words are extracted according to the language-specific rules and
  /// configuration options provided.
  final List<String> words;
  
  /// The total number of words found.
  ///
  /// This is always equal to `words.length`.
  final int count;

  /// Creates a new word count result.
  const WordCountResult({
    required this.words,
    required this.count,
  });
}

/// Predefined empty result for null or empty text inputs.
const WordCountResult emptyResult = WordCountResult(words: [], count: 0);

/// Detects and counts words in text, returning both count and word array.
///
/// This is the core function that performs word detection and counting for
/// 85+ languages including CJK (Chinese, Japanese, Korean), European, South
/// Asian, African, and Middle Eastern languages.
///
/// The function handles different writing systems appropriately:
/// - CJK languages: Character-level tokenization
/// - European languages: Space-separated word tokenization  
/// - Mixed text: Proper handling of multilingual content
///
/// Returns [emptyResult] for null, empty, or whitespace-only text.
///
/// Example:
/// ```dart
/// // Basic usage
/// WordCountResult result = wordsDetect('Hello World');
/// print('${result.count} words: ${result.words}'); // 2 words: [Hello, World]
///
/// // Chinese text
/// WordCountResult chinese = wordsDetect('你好世界');
/// print('${chinese.count} words: ${chinese.words}'); // 4 words: [你, 好, 世, 界]
///
/// // With configuration
/// const config = WordCountConfig(punctuationAsBreaker: true);
/// WordCountResult result2 = wordsDetect("don't", config);
/// print('${result2.count} words: ${result2.words}'); // 2 words: [don, t]
/// ```
WordCountResult wordsDetect(String? text, [WordCountConfig config = const WordCountConfig()]) {
  if (text == null || text.isEmpty) return emptyResult;
  
  String words = text;
  if (words.trim().isEmpty) return emptyResult;
  
  final punctuationReplacer = config.punctuationAsBreaker ? ' ' : '';
  final defaultPunctuations = config.disableDefaultPunctuation ? <String>[] : defaultPunctuation;
  final customizedPunctuations = config.punctuation;
  final combinedPunctuations = [...defaultPunctuations, ...customizedPunctuations];
  
  // Remove punctuations or change to empty space
  for (final punct in combinedPunctuations) {
    final punctuationReg = RegExp(RegExp.escape(punct));
    words = words.replaceAll(punctuationReg, punctuationReplacer);
  }
  
  // Remove all kind of symbols
  words = words.replaceAll(RegExp(r'[\uFF00-\uFFEF\u2000-\u206F]'), '');
  
  // Format white space character
  words = words.replaceAll(RegExp(r'\s+'), ' ');
  
  // Split words by white space (For European languages)
  List<String> wordsList = words.split(' ');
  wordsList = wordsList.where((word) => word.trim().isNotEmpty).toList();
  
  // Match latin, cyrillic, Malayalam letters and numbers
  final common = r'(\d+)|[a-zA-Z\u00C0-\u00FF\u0100-\u017F\u0180-\u024F\u0250-\u02AF\u1E00-\u1EFF\u0400-\u04FF\u0500-\u052F\u0D00-\u0D7F]+|';
  
  // Match Chinese Hànzì, the Japanese Kanji and the Korean Hanja
  final cjk = r'\u2E80-\u2EFF\u2F00-\u2FDF\u3000-\u303F\u31C0-\u31EF\u3200-\u32FF\u3300-\u33FF\u3400-\u3FFF\u4000-\u4DBF\u4E00-\u4FFF\u5000-\u5FFF\u6000-\u6FFF\u7000-\u7FFF\u8000-\u8FFF\u9000-\u9FFF\uF900-\uFAFF';
  
  // Match Japanese Hiragana, Katakana, Rōmaji
  final jp = r'\u3040-\u309F\u30A0-\u30FF\u31F0-\u31FF\u3190-\u319F';
  
  // Match Korean Hangul
  final kr = r'\u1100-\u11FF\u3130-\u318F\uA960-\uA97F\uAC00-\uAFFF\uB000-\uBFFF\uC000-\uCFFF\uD000-\uD7AF\uD7B0-\uD7FF';
  
  final reg = RegExp('$common[$cjk$jp$kr]');
  
  List<String> detectedWords = [];
  
  for (final word in wordsList) {
    final carry = <String>[];
    
    final matches = reg.allMatches(word);
    for (final match in matches) {
      carry.add(match.group(0)!);
    }
    
    if (carry.isEmpty) {
      if (word.isNotEmpty) {
        detectedWords.add(word);
      }
    } else {
      detectedWords.addAll(carry);
    }
  }
  
  return WordCountResult(
    words: detectedWords,
    count: detectedWords.length,
  );
}

/// Counts words in text and returns the count as an integer.
///
/// This is a convenience function that calls [wordsDetect] and returns only
/// the word count. Use this when you only need the number of words.
///
/// Supports 85+ languages with proper handling for different writing systems.
/// Returns 0 for null, empty, or whitespace-only text.
///
/// Example:
/// ```dart
/// int count = wordsCount('Hello World'); // 2
/// int chinese = wordsCount('你好世界'); // 4
/// int mixed = wordsCount('Hello, 你好!'); // 3
///
/// // With configuration
/// const config = WordCountConfig(punctuationAsBreaker: true);
/// int count2 = wordsCount("don't", config); // 2
/// ```
int wordsCount(String? text, [WordCountConfig config = const WordCountConfig()]) {
  final result = wordsDetect(text, config);
  return result.count;
}

/// Splits text into words and returns them as a list of strings.
///
/// This is a convenience function that calls [wordsDetect] and returns only
/// the word array. Use this when you need access to the individual words.
///
/// Supports 85+ languages with proper handling for different writing systems.
/// Returns an empty list for null, empty, or whitespace-only text.
///
/// Example:
/// ```dart
/// List<String> words = wordsSplit('Hello World'); // ['Hello', 'World']
/// List<String> chinese = wordsSplit('你好世界'); // ['你', '好', '世', '界'] 
/// List<String> mixed = wordsSplit('Hello, 你好!'); // ['Hello', '你', '好']
///
/// // With configuration
/// const config = WordCountConfig(punctuationAsBreaker: true);
/// List<String> words2 = wordsSplit("don't", config); // ['don', 't']
/// ```
List<String> wordsSplit(String? text, [WordCountConfig config = const WordCountConfig()]) {
  final result = wordsDetect(text, config);
  return result.words;
}
