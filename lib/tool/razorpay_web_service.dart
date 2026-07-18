import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS()
external JSObject get JSON;

@JS('Razorpay')
extension type RazorpayJS._(JSObject _) implements JSObject {
  external factory RazorpayJS(JSObject options);
  external void open();
  external void on(JSAny event, JSFunction handler);
}

class RazorpayWebService {
  void open(
    Map<String, dynamic> options, {
    required void Function(String paymentId) onSuccess,
    required void Function(String message) onError,
  }) {
    // Nested maps/lists ko JS object me convert karne ke liye JSON.parse use karo
    final jsonString = jsonEncode(options).toJS;
    final parseFn = JSON.getProperty<JSFunction>('parse'.toJS);
    final jsOptions = parseFn.callAsFunction(JSON, jsonString) as JSObject;

    // Payment success handler attach karo
    jsOptions.setProperty(
      'handler'.toJS,
      ((JSObject response) {
        final paymentId =
            (response.getProperty('razorpay_payment_id'.toJS) as JSString?)
                    ?.toDart ??
                '';
        onSuccess(paymentId);
      }).toJS,
    );

    // Modal dismiss (user ne checkout band kar diya) handler
    final modal = JSObject();
    modal.setProperty(
      'ondismiss'.toJS,
      (() {
        onError('Payment cancelled by user');
      }).toJS,
    );
    jsOptions.setProperty('modal'.toJS, modal);

    final rzp = RazorpayJS(jsOptions);

    // Payment failed event
    rzp.on(
      'payment.failed'.toJS,
      ((JSObject response) {
        final errorObj = response.getProperty('error'.toJS) as JSObject?;
        final desc = errorObj != null
            ? (errorObj.getProperty('description'.toJS) as JSString?)?.toDart
            : null;
        onError(desc ?? 'Payment failed');
      }).toJS,
    );

    rzp.open();
  }
}
