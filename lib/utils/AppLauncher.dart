import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class AppLauncher {
  static Future<void> openWhatsApp({
    required String phone,
  }) async {
    String formattedPhone = phone.replaceAll(RegExp(r'[+\s-]'), '');

    if (formattedPhone.length == 10) {
      formattedPhone = '91$formattedPhone';
    }

    if (kIsWeb) {
      // For Web: Use wa.me link which automatically opens in a new tab
      final Uri webUri = Uri.parse('https://wa.me/$formattedPhone');
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('WhatsApp Web Launch Error: $e');
      }
      return;
    }

    // For Mobile (Android/iOS)
    final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$formattedPhone');
    final Uri webUri = Uri.parse('https://wa.me/$formattedPhone');

    try {
      debugPrint('Attempting to launch WhatsApp: $whatsappUri');
      final bool launched = await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      
      if (!launched) {
        debugPrint('WhatsApp app not found, falling back to web link');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('WhatsApp Launch Exception: $e');
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (innerError) {
        debugPrint('WhatsApp Web Fallback Error: $innerError');
      }
    }
  }
}
