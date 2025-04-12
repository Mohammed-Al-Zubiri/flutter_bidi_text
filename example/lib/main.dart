import 'package:flutter/material.dart';
import 'package:flutter_bidi_text/flutter_bidi_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bidi Text Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextDirection? _lastDirection;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bidi Text Demo'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Instruction section
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bidirectional Text Demo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'This demo showcases automatic detection of text direction '
                        'based on content. Try typing in different languages to see '
                        'the direction change automatically.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // BidiText examples
              const Text(
                'BidiText Widget Examples:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('English (LTR):'),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        child: const BidiText(
                          'Hello world! This is a left-to-right text example.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Arabic (RTL):'),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        child: const BidiText(
                          'مرحبا بالعالم! هذا مثال على النص من اليمين إلى اليسار.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Mixed content:'),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        child: const BidiText(
                          'Hello مرحبا بالعالم! This is mixed content with English and العربية.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // BidiTextField example
              const Text(
                'BidiTextField Widget:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current direction: ${_lastDirection?.name ?? "none"}'),
                      const SizedBox(height: 8),
                      BidiTextField(
                        decoration: const InputDecoration(
                          hintText: 'Type something (اكتب شيئًا)',
                          border: OutlineInputBorder(),
                        ),
                        onDirectionChanged: (direction) {
                          setState(() {
                            _lastDirection = direction;
                          });
                        },
                        sampleLength: 20, // Sample first 20 characters
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Try typing in different languages to see the direction change.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // BidiTextFormField example
              const Text(
                'BidiTextFormField Widget:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BidiTextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Message / رسالة',
                          hintText: 'Enter your message / أدخل رسالتك',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        minLines: 2,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Form submitted successfully')),
                              );
                            }
                          },
                          child: const Text('Submit Form'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sample Length Demo
              const Text(
                'Sample Length Effect:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('With small sample (first 5 chars only):'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        child: const BidiText(
                          'مرحبا Hello world! This is primarily English with Arabic at the start.',
                          sampleLength: 5, // Only analyze first 5 chars (RTL)
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('With full text analysis:'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(8),
                        width: double.infinity,
                        child: const BidiText(
                          'مرحبا Hello world! This is primarily English with Arabic at the start.',
                          sampleLength: null, // Analyze full text
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
