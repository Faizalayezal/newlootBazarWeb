class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://lootbazar.vercel.app/api';

  static const String register = '/frontend/register';
  static const String verifyOtp = '/frontend/verify-otp';
  static const String getCategory = '/frontend/categories';
  static const String updateProfile = '/frontend/profile';
  static const String getProducts = '/frontend/products';
  static const String getCurrentUserProducts  = '/frontend/products/user/';
  static const String storeProduct = '/frontend/products/store';
  static const String productDetail = '/frontend/products/details';
  static const String uploadVideo = '/frontend/upload-video';
  static const String videosApi = '/frontend/videos';
  static const String deleteStatus = '/frontend/status';
  static const String uploadImage = '/frontend/products/upload-image';
  static const String getNotification = '/frontend/notifications';

  // ---------- Countries/Cities API (different base) ----------
  static const String citiesBaseUrl = 'https://countriesnow.space/api/v0.1';
  static const String citiesPopulation = '$citiesBaseUrl/countries/population/cities';

}
