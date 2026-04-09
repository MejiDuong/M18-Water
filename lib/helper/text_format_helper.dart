import 'package:flutter/material.dart';

class TextFormatHelper {
  static final _phoneRegex = RegExp(r'\b\d{8,15}\b');
  static final _listBulletRegex = RegExp(r'^\s*•\s');
  static final _rawBulletRegex = RegExp(r'^\s*-\s');
  static final _numberedListRegex = RegExp(r'^\s*(\d+)\.\s');
  static final _checkboxRegex = RegExp(r'^\s*☐\s');
  static final _headingRegex = RegExp(r'^\s*##\s');
  static final _quoteRegex = RegExp(r'^\s*>\s');

  /// Gọi trong `onChanged` hoặc `onSubmitted` để xử lý định dạng khi người dùng gõ
  static void handleFormat(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;

    if (selection.baseOffset < 1) return;

    final lines = text.substring(0, selection.baseOffset).split('\n');
    final currentLine = lines.isNotEmpty ? lines.last : '';
    final startOfLineOffset = selection.baseOffset - currentLine.length;

    String? replacement;

    // Xử lý các dạng list (bullet, số, checkbox)
    if (_rawBulletRegex.hasMatch(currentLine)) {
      replacement = '• ';
    } else if (_numberedListRegex.hasMatch(currentLine)) {
      replacement = '1. ';
    } else if (_checkboxRegex.hasMatch(currentLine)) {
      replacement = '☐ ';
    } else if (_headingRegex.hasMatch(currentLine)) {
      replacement = '## ';
    } else if (_quoteRegex.hasMatch(currentLine)) {
      replacement = '> ';
    }

    if (replacement != null) {
      final newText = text.replaceRange(
        startOfLineOffset,
        selection.baseOffset,
        replacement,
      );

      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: startOfLineOffset + replacement.length),
      );
    }

    // Auto thêm bullet/số khi nhấn Enter từ một list
    if (selection.baseOffset >= 2 && text[selection.baseOffset - 1] == '\n') {
      final beforeCursor = text.substring(0, selection.baseOffset);
      final prevLine = beforeCursor.split('\n').reversed.skip(1).firstOrNull ?? '';

      final bulletMatch = RegExp(r'^•\s+').firstMatch(prevLine);
      final numberMatch = RegExp(r'^(\d+)\.\s+').firstMatch(prevLine);

      if (bulletMatch != null) {
        // Nếu dòng chỉ là "• ", bỏ bullet
        if (prevLine.trim() == '•') {
          _removeEmptyListLine(controller);
        } else {
          _insertNextLine(controller, '• ');
        }
      } else if (numberMatch != null) {
        if (prevLine.trim() == '${numberMatch.group(1)}.') {
          _removeEmptyListLine(controller);
        } else {
          final nextNumber = int.parse(numberMatch.group(1)!) + 1;
          _insertNextLine(controller, '$nextNumber. ');
        }
      }
    }

    // Xóa item list khi nhấn backspace
    if (selection.baseOffset > 0 && text[selection.baseOffset - 1] == '\n') {
      final beforeCursor = text.substring(0, selection.baseOffset);
      final prevLine = beforeCursor.split('\n').reversed.skip(1).firstOrNull ?? '';

      if (_rawBulletRegex.hasMatch(prevLine) ||
          _numberedListRegex.hasMatch(prevLine) ||
          _checkboxRegex.hasMatch(prevLine)) {
        // Nếu là item trong list, xóa item
        _removeListItem(controller);
      }
    }
  }

  // Hàm xóa item list khi nhấn backspace
  static void _removeListItem(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;
    final before = text.substring(0, selection.baseOffset);
    final after = text.substring(selection.baseOffset);

    final lines = before.split('\n');
    if (lines.isEmpty) return;

    // Loại bỏ dòng cuối cùng (dòng của item list)
    lines.removeLast();

    final updatedText = lines.join('\n') + '\n' + after;

    controller.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: lines.join('\n').length + 1),
    );
  }

  static void _insertNextLine(TextEditingController controller, String prefix) {
    final text = controller.text;
    final selection = controller.selection;
    final insertOffset = selection.baseOffset;

    final newText = text.replaceRange(
      insertOffset,
      insertOffset,
      prefix,
    );

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: insertOffset + prefix.length),
    );
  }

  static void _removeEmptyListLine(TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;
    final before = text.substring(0, selection.baseOffset);
    final after = text.substring(selection.baseOffset);

    final lines = before.split('\n');
    if (lines.length < 2) return;

    lines.removeLast(); // Dòng hiện tại
    final updatedText = lines.join('\n') + '\n' + after;

    controller.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: lines.join('\n').length + 1),
    );
  }

  /// Phân tích nội dung để tạo danh sách `InlineSpan` và nhận diện số điện thoại
  static List<InlineSpan> parseContent(String content, void Function(String) onPhoneTap) {
    final spans = <InlineSpan>[];
    final matches = _phoneRegex.allMatches(content);
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: content.substring(currentIndex, match.start)));
      }

      final phone = match.group(0) ?? '';
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: GestureDetector(
          onTap: () => onPhoneTap(phone),
          child: Text(
            phone,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ));
      currentIndex = match.end;
    }

    if (currentIndex < content.length) {
      spans.add(TextSpan(text: content.substring(currentIndex)));
    }

    return spans;
  }
}
