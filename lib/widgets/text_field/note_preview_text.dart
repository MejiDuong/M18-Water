import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/text_format_helper.dart';


class NotePreviewText extends StatelessWidget {
  final String content;

  const NotePreviewText({Key? key, required this.content}) : super(key: key);

  void _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('Không thể mở: $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: TextFormatHelper.parseContent(content, _launchPhone),
      ),
    );
  }
}
