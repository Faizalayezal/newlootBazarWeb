class RazorpayWebService {
  void open(
    Map<String, dynamic> options, {
    required void Function(String paymentId) onSuccess,
    required void Function(String message) onError,
  }) {
    throw UnsupportedError('RazorpayWebService is only supported on Web.');
  }
}
