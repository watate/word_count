import 'package:word_count/word_count.dart';

void main() {
  // Basic usage examples
  print('English text: ${wordsCount('Hello World')}'); // 2
  print('Chinese text: ${wordsCount('你好，世界')}'); // 4
  print('Mixed text: ${wordsCount('Hello, 你好。')}'); // 3

  // Using configuration
  const config = WordCountConfig(punctuationAsBreaker: true);
  print(
    'With punctuation as breaker: ${wordsCount("Google's free service", config)}',
  ); // 3

  // Getting word list
  final words = wordsSplit('Hello World');
  print('Words: $words'); // [Hello, World]

  // Full detection result
  final result = wordsDetect('Hello World');
  print(
    'Count: ${result.count}, Words: ${result.words}',
  ); // Count: 2, Words: [Hello, World]
}
