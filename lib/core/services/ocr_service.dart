import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  final _textRecognizer = TextRecognizer();

  Future<String> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    
    return recognizedText.text;
  }

  // Parse text to extract food items (simple implementation)
  // In a real app, you might use regex or an LLM
  List<Map<String, dynamic>> parseMenuText(String text) {
    final List<Map<String, dynamic>> items = [];
    final lines = text.split('\n');
    
    // Improved Regex to catch prices like 10.99, 10,99, $10, 10.00
    final priceRegex = RegExp(r'[\$£€]?\s*(\d+[\.,]\d{2}|\d+)');
    
    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      final match = priceRegex.firstMatch(line);
      
      if (match != null) {
        final priceString = match.group(1)!.replaceAll(',', '.');
        final price = double.tryParse(priceString);
        
        if (price != null) {
          // Remove the price part and common separators to get the name
          var name = line.replaceFirst(match.group(0)!, '').trim();
          name = name.replaceAll(RegExp(r'[.\-_:=]'), '').trim();
          
          // Filter out garbage matches (e.g. just symbols or very short text)
          if (name.length > 2 && !RegExp(r'^[\d\W]+$').hasMatch(name)) {
            items.add({
              'name': name,
              'price': price,
            });
          }
        }
      }
    }
    
    return items;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
