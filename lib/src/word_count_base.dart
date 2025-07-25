const List<String> defaultPunctuation = [
  ',', '，', '.', '。', ':', '：', ';', '；', '[', ']', '【', ']', '】', '{', '｛', '}', '｝',
  '(', '（', ')', '）', '<', '《', '>', '》', '\$', '￥', '!', '！', '?', '？', '~', '～',
  "'", "'", '"', '"', '"',
  '*', '/', '\\', '&', '%', '@', '#', '^', '、', '、', '、', '、'
];

class WordCountConfig {
  final bool punctuationAsBreaker;
  final bool disableDefaultPunctuation;
  final List<String> punctuation;

  const WordCountConfig({
    this.punctuationAsBreaker = false,
    this.disableDefaultPunctuation = false,
    this.punctuation = const [],
  });
}

class WordCountResult {
  final List<String> words;
  final int count;

  const WordCountResult({
    required this.words,
    required this.count,
  });
}

const WordCountResult emptyResult = WordCountResult(words: [], count: 0);

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

int wordsCount(String? text, [WordCountConfig config = const WordCountConfig()]) {
  final result = wordsDetect(text, config);
  return result.count;
}

List<String> wordsSplit(String? text, [WordCountConfig config = const WordCountConfig()]) {
  final result = wordsDetect(text, config);
  return result.words;
}
