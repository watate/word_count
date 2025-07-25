# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2024-07-25

### Changed
- Ran 'dart format .' to fix file formatting
- Made repository public

## [1.0.0] - 2024-07-25

### Added
- Multi-language word counting support for 85+ languages
- Three main functions for different use cases:
  - `wordsCount()` - Returns word count as integer
  - `wordsSplit()` - Returns array of words
  - `wordsDetect()` - Returns both count and words in structured result
- Comprehensive CJK (Chinese, Japanese, Korean) language support
- Configurable punctuation handling with three options:
  - `punctuationAsBreaker` - Treat punctuation as word separators
  - `disableDefaultPunctuation` - Use only custom punctuation
  - `punctuation` - Add custom punctuation characters
- Extensive default punctuation set covering multiple languages
- Support for major language families:
  - East Asian (Chinese, Japanese, Korean)
  - European (English, French, German, Spanish, Russian, Polish, Dutch, etc.)
  - South Asian (Hindi, Bengali, Urdu, Telugu, Gujarati, Punjabi, etc.)
  - Southeast Asian (Thai, Vietnamese, Indonesian, Malay, Filipino)
  - Middle Eastern (Arabic, Hebrew, Persian, Turkish, Kurdish)
  - African (Swahili, Amharic, Yoruba, Hausa, Igbo, etc.)
- Comprehensive test suite with 118+ tests covering all supported languages
- Complete API documentation following Dart documentation guidelines
- Usage examples and configuration demonstrations

### Technical Details
- Proper Unicode RegExp patterns for different writing systems
- Character-level tokenization for CJK languages
- Space-separated word tokenization for European languages
- Configurable symbol and whitespace processing
- Null-safe implementation compatible with Dart 3.8.1+

[1.0.0]: https://github.com/your-org/word_count/releases/tag/v1.0.0
