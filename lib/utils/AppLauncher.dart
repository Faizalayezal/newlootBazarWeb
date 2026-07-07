import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class AppLauncher {
  static Future<void> openWhatsApp({
    required String phone,
  }) async {
    String formattedPhone = phone.replaceAll(RegExp(r'[+\s-]'), '');

    if (formattedPhone.length == 10) {
      formattedPhone = '91$formattedPhone';
    }

    // Bypass canLaunchUrl to avoid persistent channel errors on some Android setups
    final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$formattedPhone');
    final Uri webUri = Uri.parse('https://wa.me/$formattedPhone');

    try {
      debugPrint('Attempting to launch WhatsApp: $whatsappUri');
      // On some platforms, launchUrl itself might trigger the channel error
      final bool launched = await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      
      if (!launched) {
        debugPrint('WhatsApp app not found, falling back to web link');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('WhatsApp Launch Exception: $e');
      
      // If direct launch fails or channel is missing, always try the universal web link
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (innerError) {
        debugPrint('WhatsApp Web Fallback Error: $innerError');
      }
    }
  }
}
