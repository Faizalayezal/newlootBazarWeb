import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'razorpay_web_service.dart' if (dart.library.io) 'razorpay_service_stub.dart';

class RazorpayService {
  Razorpay? _razorpay;

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    }
  }

  void open(
      Map<String, dynamic> options, {
        required Function(Map) onWebSuccess,
        required Function(String) onWebError,
      }) {
    if (kIsWeb) {
      RazorpayWebService().open(
        options,
        onSuccess: (paymentId) => onWebSuccess({'razorpay_payment_id': paymentId}),
        onError: onWebError,
      );
    } else {
      _razorpay!.open(options);
    }
  }

  void dispose() {
    if (!kIsWeb) {
      _razorpay?.clear();
    }
  }
}
