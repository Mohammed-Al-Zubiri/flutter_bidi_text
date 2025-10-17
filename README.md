# flutter_bidi_text

[![pub package](https://img.shields.io/pub/v/flutter_bidi_text.svg)](https://pub.dev/packages/flutter_bidi_text)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter Platform](https://img.shields.io/badge/platform-all-green.svg)](https://pub.dev/packages/flutter_bidi_text)

A Flutter package that provides text widgets with automatic bidirectional (RTL/LTR) text direction detection. This package is ideal for multilingual applications that need to handle both right-to-left and left-to-right text seamlessly.

<div align="center">
  <img src="https://raw.githubusercontent.com/Mohammed-Al-Zubiri/flutter_bidi_text/main/assets/demos/bidirectional_demo.jpg" alt="BidiText Demo" width="300"/>
</div>

## Features

- **Automatic Direction Detection**: Text direction is automatically determined based on content.
- **Direction Change Callbacks**: Be notified when text direction changes.
- **Text Widget Types**:
  - `BidiText`: A drop-in replacement for Flutter's `Text` widget
  - `BidiRichText`: A drop-in replacement for Flutter's `RichText` widget with `TextSpan` support
  - `BidiTextField`: An input field with automatic direction detection
  - `BidiTextFormField`: A form field with automatic direction detection
- **Support for Mixed Content**: Handles mixed RTL/LTR content intelligently.
- **Configurable Sampling**: Control how much text is analyzed for direction detection.
- **Complete Drop-in Replacement**: All widgets inherit from Flutter's standard widgets, so they support all the same properties and can be used as direct replacements.

## Why Use flutter_bidi_text?

If your app supports multiple languages with different writing directions, you've likely encountered these challenges:

- Text direction needs to be manually set based on language
- Mixed language content displays incorrectly
- Direction changes require manual intervention

This package solves all these problems by automatically detecting and setting the appropriate text direction in real-time.

## Technical Background

**Bidirectional text** (often abbreviated as **BiDi**) refers to text that contains both right-to-left (RTL) and left-to-right (LTR) text directionalities. This is common in multilingual applications where, for example, English text (LTR) is mixed with Arabic or Hebrew text (RTL).

### Understanding the Unicode Bidirectional Algorithm

The [Unicode Standard](https://www.unicode.org/reports/tr9/) provides a sophisticated algorithm for handling bidirectional text. Unicode characters are categorized into different types:

- **Strong Characters**: Characters with a definite direction (e.g., Latin letters for LTR, Arabic/Hebrew letters for RTL)
- **Weak Characters**: Characters with vague direction (e.g., numbers, arithmetic symbols)
- **Neutral Characters**: Characters with indeterminate direction (e.g., whitespace, common punctuation)
- **Explicit Formatting**: Special Unicode control characters that override default behavior

### How This Package Works

This package implements a practical text direction detection algorithm that:

1. **Analyzes Character Content**: Scans the text for strong directional characters
2. **Counts Directional Runs**: Groups consecutive characters with the same directionality
3. **Applies Threshold Logic**: Determines overall direction based on the ratio of RTL to LTR content
4. **Handles Mixed Content**: Makes intelligent decisions when text contains both directions

The algorithm uses a threshold-based approach: if RTL characters exceed approximately 40% of strongly directional characters, the text is considered RTL; otherwise, it defaults to LTR. This provides robust handling of real-world multilingual content.

### Real-World Example

Consider the text: `"Hello مرحبا 123"` (English + Arabic + numbers)
- "Hello" → Strong LTR characters
- "مرحبا" → Strong RTL characters  
- "123" → Weak characters (inherit direction from context)

The package analyzes the ratio of strong characters and determines the appropriate text direction automatically.

### Further Reading

For a deeper understanding of bidirectional text handling, see:
- [Bidirectional text on Wikipedia](https://en.wikipedia.org/wiki/Bidirectional_text)
- [Unicode Bidirectional Algorithm (UAX #9)](https://www.unicode.org/reports/tr9/)
- [W3C Guidelines on Bidirectional Text](https://www.w3.org/International/articles/inline-bidi-markup/)

## Installation

Add this dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_bidi_text: ^1.1.0
```

Then run:

```
flutter pub get
```

## Usage

### Drop-in Replacement

The widgets in this package are designed as direct replacements for Flutter's standard text widgets. Simply add "Bidi" before the original widget name:

| Flutter Widget | Bidirectional Replacement |
|----------------|---------------------------|
| `Text`         | `BidiText`                |
| `RichText`     | `BidiRichText`            |
| `TextField`    | `BidiTextField`           |
| `TextFormField`| `BidiTextFormField`       |

Since our widgets inherit from Flutter's standard widgets, they support all the same properties and can be used as direct replacements with minimal code changes.

### BidiText

A simple drop-in replacement for the standard Flutter `Text` widget:

```dart
import 'package:flutter_bidi_text/flutter_bidi_text.dart';

// Automatically displays in LTR direction
BidiText('Hello world')

// Automatically displays in RTL direction
BidiText('مرحبا بالعالم')

// Configure how much text to sample for direction detection
BidiText(
  'مرحبا بالعالم Hello world',
  sampleLength: 10, // Only analyze first 10 characters
)

// Use null to analyze the entire text
BidiText(
  longText,
  sampleLength: null,
)
```

<div align="center">
  <img src="https://raw.githubusercontent.com/Mohammed-Al-Zubiri/flutter_bidi_text/main/assets/demos/bidi_text.jpg" alt="BidiText Widget Demo" width="300"/>
</div>

### BidiRichText

A drop-in replacement for Flutter's `RichText` widget with automatic direction detection for styled text using `TextSpan`:

```dart
import 'package:flutter_bidi_text/flutter_bidi_text.dart';

// English text with different styles (LTR)
BidiRichText(
  text: TextSpan(
    style: TextStyle(fontSize: 16, color: Colors.black),
    children: [
      TextSpan(text: 'This is '),
      TextSpan(
        text: 'bold',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: ' and this is '),
      TextSpan(
        text: 'italic',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      TextSpan(text: ' text.'),
    ],
  ),
)

// Arabic text with different styles (RTL)
BidiRichText(
  text: TextSpan(
    style: TextStyle(fontSize: 16, color: Colors.black),
    children: [
      TextSpan(text: 'هذا نص '),
      TextSpan(
        text: 'عريض',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: ' وهذا نص '),
      TextSpan(
        text: 'مائل',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ],
  ),
)

// Mixed content with colors
BidiRichText(
  text: TextSpan(
    style: TextStyle(fontSize: 16, color: Colors.black),
    children: [
      TextSpan(
        text: 'English text',
        style: TextStyle(color: Colors.blue),
      ),
      TextSpan(text: ' with '),
      TextSpan(
        text: 'نص عربي',
        style: TextStyle(color: Colors.red),
      ),
    ],
  ),
)

// With icons using WidgetSpan
BidiRichText(
  text: TextSpan(
    style: TextStyle(fontSize: 16, color: Colors.black),
    children: [
      TextSpan(text: 'Rate us '),
      WidgetSpan(
        child: Icon(Icons.star, size: 18, color: Colors.amber),
      ),
      TextSpan(text: ' on the app store!'),
    ],
  ),
)
```

The `BidiRichText` widget analyzes all text content in the `TextSpan` tree (including nested children) to determine the overall text direction, while ignoring `WidgetSpan` elements.

<div align="center">
  <img src="https://raw.githubusercontent.com/Mohammed-Al-Zubiri/flutter_bidi_text/main/assets/demos/bidi_rich_text.jpg" alt="BidiRichText Widget Demo" width="300"/>
</div>

### BidiTextField

A text input that automatically adjusts its direction based on content:

```dart
import 'package:flutter_bidi_text/flutter_bidi_text.dart';

BidiTextField(
  decoration: InputDecoration(hintText: 'Enter text'),
  onDirectionChanged: (TextDirection? direction) {
    print('Text direction changed to: $direction');
  },
  // sampleLength: 50, // Analyze first 50 characters (default)
)
```

<div align="center">
  <img src="https://raw.githubusercontent.com/Mohammed-Al-Zubiri/flutter_bidi_text/main/assets/demos/bidi_text_field.gif" alt="BidiTextField Widget Demo" width="300"/>
</div>

### BidiTextFormField

A form field that automatically adjusts text direction:

```dart
import 'package:flutter_bidi_text/flutter_bidi_text.dart';

BidiTextFormField(
  decoration: InputDecoration(
    labelText: 'Message',
    border: OutlineInputBorder(),
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  },
  onDirectionChanged: (TextDirection? direction) {
    print('Text direction changed to: $direction');
  },
  // sampleLength: 50,
)
```

<div align="center">
  <img src="https://raw.githubusercontent.com/Mohammed-Al-Zubiri/flutter_bidi_text/main/assets/demos/bidi_text_form_field.gif" alt="BidiTextFormField Widget Demo" width="300"/>
</div>

## Advanced Usage

### Utility Functions

The package also provides utility functions for direction detection in a convenient `BidiHelper` class:

```dart
import 'package:flutter_bidi_text/flutter_bidi_text.dart';

// Using the BidiHelper class
TextDirection? direction = BidiHelper.estimateDirectionOfText('مرحبا بالعالم');
// Returns TextDirection.rtl

bool isRtl = BidiHelper.detectRtlDirectionality('Hello world');
// Returns false

// You can also use the standalone functions if preferred
TextDirection? direction2 = estimateDirectionOfText('مرحبا بالعالم');
bool isRtl2 = detectRtlDirectionality('Hello world');
```

### Custom Controllers

You can use your own TextEditingController with both input widgets:

```dart
final controller = TextEditingController(text: 'Initial text');

BidiTextField(
  controller: controller,
  onDirectionChanged: (direction) {
    // Handle direction change
  },
)
```

### Performance Optimization

For very long text, you can control how much text is sampled to determine direction:

```dart
// Only analyze first 20 characters (faster)
BidiText(
  veryLongText,
  sampleLength: 20,
)

// Analyze entire text (more accurate but potentially slower)
BidiText(
  mixedDirectionText,
  sampleLength: null,
)
```

## Real-World Examples

### Multilingual Chat Application

```dart
BidiTextField(
  controller: messageController,
  decoration: InputDecoration(
    hintText: 'Type a message...',
    suffixIcon: IconButton(
      icon: Icon(Icons.send),
      onPressed: sendMessage,
    ),
  ),
  onDirectionChanged: (direction) {
    // Align the send button based on text direction
    setState(() {
      sendButtonAlignment = direction == TextDirection.rtl
          ? Alignment.centerLeft
          : Alignment.centerRight;
    });
  },
)
```

### Multilingual Form

```dart
Form(
  key: _formKey,
  child: Column(
    children: [
      BidiTextFormField(
        decoration: InputDecoration(labelText: 'Name / الاسم'),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
      BidiTextFormField(
        decoration: InputDecoration(labelText: 'Address / العنوان'),
        validator: (value) => value!.isEmpty ? 'Required' : null,
        maxLines: 3,
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Submit form
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

## Contributing

Contributions are welcome! If you'd like to contribute, please feel free to submit a PR or open an issue.

### Setting Up Development Environment

1. Clone the repository
   ```
   git clone https://github.com/Mohammed-Al-Zubiri/flutter_bidi_text.git
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Run tests
   ```
   flutter test
   ```

## Frequently Asked Questions

### Q: How does direction detection work?
**A:** The package analyzes the text content to detect RTL characters. If the proportion of RTL characters exceeds a threshold, the text is considered RTL. For optimization, you can control how much text is sampled.

### Q: Can I use this with Flutter's `Directionality` widget?
**A:** Yes! You can wrap your widgets in `Directionality` for a default direction, and the BidiText widgets will still override as needed based on content.

### Q: How does this handle numbers and special characters?
**A:** Numbers and most special characters are considered neutral in terms of directionality and don't affect the direction detection.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
