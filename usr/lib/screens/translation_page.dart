import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/openai_service.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _inputController = TextEditingController();
  final OpenAIService _openAIService = OpenAIService();
  
  String _outputText = '';
  bool _isLoading = false;
  String _sourceLang = 'Auto';
  String _targetLang = 'Chinese';

  final List<String> _languages = [
    'Auto',
    'English',
    'Chinese',
    'Spanish',
    'French',
    'German',
    'Japanese',
    'Korean',
    'Russian',
    'Portuguese',
    'Italian',
  ];

  List<String> get _targetLanguages => _languages.where((l) => l != 'Auto').toList();

  Future<void> _handleTranslate() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _outputText = '';
    });

    try {
      // Call the service without passing an API key manually
      final result = await _openAIService.translate(
        text: _inputController.text,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
      );

      setState(() {
        _outputText = result;
      });
    } catch (e) {
      setState(() {
        _outputText = 'Error: ${e.toString().replaceAll("Exception: ", "")}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Translator'),
        // Settings button removed
      ),
      body: Column(
        children: [
          // Language Selection Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLanguageDropdown(_sourceLang, _languages, (val) {
                  setState(() => _sourceLang = val!);
                }),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                _buildLanguageDropdown(_targetLang, _targetLanguages, (val) {
                  setState(() => _targetLang = val!);
                }),
              ],
            ),
          ),
          
          // Input Area
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Original Text', style: Theme.of(context).textTheme.labelLarge),
                      if (_inputController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _inputController.clear();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter text to translate...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 18),
                      onChanged: (val) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Output Area
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Translation', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).primaryColor)),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () => _copyToClipboard(_outputText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                            child: Text(
                              _outputText.isEmpty ? '' : _outputText,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          
          // Translate Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _inputController.text.isNotEmpty ? _handleTranslate : null,
                child: const Text('Translate', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(String currentValue, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: currentValue,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
