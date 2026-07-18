import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lootbazarweb/bottomNav/NavBarController.dart';
import 'package:lootbazarweb/constant/AppToast.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/CityState.dart';
import 'package:lootbazarweb/providerd/currantUserListning/CurrentProductNotifier.dart';
import 'package:lootbazarweb/providerd/store_product/StoreProductNotifier.dart';
import 'package:lootbazarweb/providerd/store_product/store_product_state.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';
import 'package:lootbazarweb/shared/CityPickerSheet.dart';
import 'package:lootbazarweb/shared/ListingSuccessDialog.dart';
import 'package:lootbazarweb/shared/PremiumLoadingButton.dart';
import 'package:lootbazarweb/shared/my_listing.dart';
import 'package:lootbazarweb/tool/MyListingShimmer.dart';
import 'package:lootbazarweb/tool/RazorpayService.dart';
import 'package:lootbazarweb/tool/SwipeButton.dart';
import 'package:lootbazarweb/utils/preferences.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:confetti/confetti.dart';
import 'package:lootbazarweb/providerd/di/repositoryProvider.dart';
import 'package:audioplayers/audioplayers.dart';

final sellScreenImagesProvider = StateProvider<List<XFile>>((ref) => []);

class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});

  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _moqController = TextEditingController();
  final _priceController = TextEditingController();
  final _pcsController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _applyCouponController = TextEditingController();
  final _categoryController = TextEditingController();

  final ValueNotifier<bool> _isChecked = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isDropdownOpen = ValueNotifier(false);

  final ValueNotifier<List<Map<String, dynamic>>> dataString = ValueNotifier(
    [],
  );

  List<XFile> get selectedImages => ref.watch(sellScreenImagesProvider);
  List<String> get imagePaths => selectedImages.map((f) => f.path).toList();

  int? paymentStatus;

  GlobalKey<FormState> mFormKey = GlobalKey<FormState>();

 // late Razorpay _razorpay;
  late final RazorpayService _paymentService;
  String? _currentProductId;

  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, dynamic>? _couponResult;
  bool _isCouponValidating = false;
  double _finalAmount = 33.0;

  @override
  void initState() {
    super.initState();
   // _razorpay = Razorpay();
    //_razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    //_razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    //_razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _paymentService = RazorpayService();
    _paymentService.init(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
      onExternalWallet: (response) {
        debugPrint("External wallet: ${response.walletName}");
      },
    );


    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoriesFromPrefs();
      ref.read(currentProductProvider.notifier).getCurrentUserProducts();
      _cityController.text = SharedPrefs().getString(address) ?? '';
      _phoneController.text = SharedPrefs().getString(phoneNumber) ?? '';
      
      final savedAmount = SharedPrefs().getString(listingAmount);
      if (savedAmount != null) {
        setState(() {
          _finalAmount = double.tryParse(savedAmount) ?? 33.0;
        });
      }
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_currentProductId != null) {
      await ref.read(storeProductProvider.notifier).updatePaymentStatus(
        productId: _currentProductId!,
        userId: SharedPrefs().getString(userId) ?? '',
        paymentStatus: 'paid',
      );
      _showSuccessDialog();
      _clearForm();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    AppToast.error("Payment Failed: ${response.message}");
  }

  void _onWebPaymentSuccess(String paymentId) async {
    if (_currentProductId != null) {
      await ref.read(storeProductProvider.notifier).updatePaymentStatus(
        productId: _currentProductId!,
        userId: SharedPrefs().getString(userId) ?? '',
        paymentStatus: 'paid',
      );
      _showSuccessDialog();
      _clearForm();
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<void> _loadCategoriesFromPrefs() async {
    final categories = await SharedPrefs().getCategories();
    dataString.value = categories
        .map(
          (c) => {
            'id': c.id,
            'name': c.name,
            'selected': false,
          },
        )
        .toList();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    try {
      final currentImages = ref.read(sellScreenImagesProvider);

      if (currentImages.length >= 20) {
        AppToast.info("Maximum 20 photos reached");
        return;
      }

      List<XFile>? pickedFiles = await picker.pickMultiImage(
        imageQuality: 70,
        limit: 20,
      );

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        final List<XFile> combined = [...currentImages, ...pickedFiles];
        // Ensure strictly max 20 images total
        ref.read(sellScreenImagesProvider.notifier).state = combined.take(20).toList();
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _selectItem(int index) {
    final newList = [...dataString.value];
    newList[index] = {
      ...newList[index],
      'selected': !(newList[index]['selected'] as bool),
    };
    dataString.value = newList;
    _categoryController.text = newList
        .where((e) => e['selected'] == true)
        .map((e) => e['name'])
        .join(', ');
  }

  List<String> get _selectedCategoryIds {
    return dataString.value
        .where((e) => e['selected'] == true)
        .map((e) => e['id'].toString())
        .toList();
  }

  Future<void> _openCityPicker() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final cityState = ref.read(cityProvider);
    if (cityState.cities.isEmpty && !cityState.isLoading) {
      ref.read(cityProvider.notifier).loadCities();
    }
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CityPickerSheet(),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    if (!mounted) return;
    if (selected != null && selected.isNotEmpty) {
      setState(() => _cityController.text = selected);
    }
  }

  @override
  void dispose() {
   // _razorpay.clear();
    _paymentService.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    _categoryController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _moqController.dispose();
    _priceController.dispose();
    _pcsController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _applyCouponController.dispose();
    _isChecked.dispose();
    _isDropdownOpen.dispose();
    dataString.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<StoreProductState>(storeProductProvider, (prev, next) async {
      if (next.isSuccess && next.productId != null) {
        Navigator.of(context).pop();
        await _handlePaymentFlow(next.productId!);
        ref.read(storeProductProvider.notifier).reset();
        ref.read(currentProductProvider.notifier).getCurrentUserProducts();
      } else if (next.isSuccess) {
        Navigator.of(context).pop();
        _showSuccessDialog();
        ref.read(storeProductProvider.notifier).reset();
        ref.read(currentProductProvider.notifier).getCurrentUserProducts();
        _clearForm();
      } else if (next.status == ProductStatus.error) {
        AppToast.error(next.errorMessage ?? 'Something went wrong');
      }
    });
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: () async {
              ref.read(currentProductProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 7.w),
                child: Consumer(
                  builder: (context, ref, child) {
                    final currentProductState = ref.watch(currentProductProvider);
                    final bool isLoading = currentProductState.isLoading;
                    final products = currentProductState.currantProductResponse?.currantProductData ?? [];
                    return Column(
                      children: [
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("My Listing", style: AppTextStyle.regular(size: 18.sp, color: Colors.black)),
                            Visibility(
                              visible: products.isNotEmpty,
                              child: GestureDetector(
                                onTap: () => context.pushNamed(AppRoutes.myListing),
                                child: Text(
                                  products.length > 2 ? "View all" : '',
                                  style: AppTextStyle.regular(size: 13.sp, color: Colors.green),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        if (products.isEmpty && !isLoading)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            decoration: BoxDecoration(
                              color: AppTheme.card.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 32.sp, color: Colors.grey.shade400),
                                SizedBox(height: 8.h),
                                Text(
                                  "No listings found",
                                  style: AppTextStyle.medium(size: 13.sp, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: isLoading ? 2 : (products.length > 2 ? 2 : products.length),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (isLoading) return const MyListingShimmer();
                              final product = products[index];
                              return MyListing(
                                onTap: () {
                                  context.pushNamed(AppRoutes.productDetail,
                                      extra: {'productId': product.id});
                                },
                                imageUrl: product.firstImageUrl,
                                title: product.title,
                                rate: product.price.toStringAsFixed(0),
                                pcs: product.stock.toString(),
                                moq: product.moq.toString(),
                                location: product.location ?? '-',
                                status: product.paymentStatus.toLowerCase() == 'pending'
                                    ? 'Pending'
                                    : product.paymentStatus.toLowerCase() == 'cancel'
                                        ? 'Cancelled'
                                        : product.status,
                              );
                            },
                          ),
                        SizedBox(height: 15.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Create New Listing", style: AppTextStyle.regular(size: 16.sp, color: Colors.black)),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14.r)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                            child: Form(
                              key: mFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ValueListenableBuilder<bool>(
                                    valueListenable: _isDropdownOpen,
                                    builder: (context, isOpen, child) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _isDropdownOpen.value = !_isDropdownOpen.value,
                                            child: AbsorbPointer(
                                              child: TextFormField(
                                                controller: _categoryController,
                                                readOnly: true,
                                                style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                                validator: (value) => (value == null || value.isEmpty) ? 'Select category!' : null,
                                                decoration: _inputDecoration(
                                                  hintText: 'Select Category',
                                                  suffixIcon: Icon(
                                                    isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                                    color: Colors.black54, size: 24.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (isOpen)
                                            Container(
                                              margin: EdgeInsets.only(top: 6.h),
                                              height: 200.h,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10.r),
                                                border: Border.all(color: Colors.grey.shade300),
                                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                              ),
                                              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                                                valueListenable: dataString,
                                                builder: (context, list, child) {
                                                  return ListView.separated(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    itemCount: list.length,
                                                    separatorBuilder: (context, idx) => Divider(height: 1, color: Colors.grey.shade100),
                                                    itemBuilder: (context, i) {
                                                      final isSelected = list[i]['selected'] as bool;
                                                      return ListTile(
                                                        dense: true,
                                                        title: Text(list[i]['name'] ?? '', style: TextStyle(fontSize: 13.5.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppTheme.primary : Colors.black87)),
                                                        trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
                                                        onTap: () => _selectItem(i),
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                  SizedBox(height: 12.h),
                                  TextFormField(
                                    controller: _titleController,
                                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter product title' : null,
                                    decoration: _inputDecoration(hintText: 'Product Title'),
                                  ),
                                  SizedBox(height: 12.h),
                                  TextFormField(
                                    controller: _descriptionController,
                                    maxLines: 3,
                                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                    decoration: _inputDecoration(hintText: 'Description'),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _pcsController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          style: TextStyle(fontSize: 14.sp),
                                          validator: (value) => (value == null || value.isEmpty) ? 'Enter quantity' : null,
                                          decoration: _inputDecoration(hintText: 'Total Quantity'),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _moqController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          style: TextStyle(fontSize: 14.sp),
                                          validator: (value) { 
                                            if (value == null || value.isEmpty) return 'Enter MOQ';
                                            final int moq = int.tryParse(value) ?? 0;
                                            final int totalQty = int.tryParse(_pcsController.text) ?? 0;
                                            if (moq > totalQty) return 'Max: $totalQty Pcs';
                                            return null;
                                          },
                                          decoration: _inputDecoration(hintText: 'MOQ'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _openCityPicker,
                                          child: AbsorbPointer(
                                            child: TextFormField(
                                              focusNode: FocusNode(canRequestFocus: false),
                                              controller: _cityController,
                                              style: TextStyle(fontSize: 14.sp),
                                              validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter city' : null,
                                              decoration: _inputDecoration(hintText: 'Location (city)'),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _priceController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          style: TextStyle(fontSize: 14.sp),
                                          validator: (value) => (value == null || value.isEmpty) ? 'Enter price' : null,
                                          decoration: _inputDecoration(hintText: 'Price per PCS'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                                    validator: (value) => (value == null || value.length < 10) ? 'Enter valid mobile' : null,
                                    decoration: _inputDecoration(hintText: '90811 81218').copyWith(counterText: ''),
                                  ),
                                  SizedBox(height: 16.h),
                                  GestureDetector(
                                    onTap: _pickImages,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                      decoration: BoxDecoration(color: const Color(0xFFF8E7BE), borderRadius: BorderRadius.circular(12.r)),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Upload Product photos", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E1E1E))),
                                              SizedBox(height: 3.h),
                                              Text(imagePaths.isNotEmpty ? "${imagePaths.length} photos selected" : "Upto 20 photos", style: TextStyle(fontSize: 11.sp, color: Colors.black54)),
                                            ],
                                          ),
                                          const Spacer(),
                                          Icon(Icons.image_outlined, size: 28.sp, color: Colors.black87),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  PremiumLoadingButton(
                                    isLoading: false,
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      await Future.delayed(const Duration(milliseconds: 100));
                                      if (mFormKey.currentState!.validate()) {
                                        if (imagePaths.isNotEmpty) {
                                          NavBarController.showNavBar.value = false;
                                          await _openBottomSheet();
                                          NavBarController.showNavBar.value = true;
                                        } else {
                                          AppToast.info('Please select images.');
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 100.h),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const ListingSuccessDialog());
  }

  Future<void> _validateCoupon({VoidCallback? updateSheet}) async {
    final code = _applyCouponController.text.trim();
    if (code.isEmpty) return;
    setState(() { _isCouponValidating = true; });
    updateSheet?.call();
    try {
      final repo = ref.read(repositoryProvider);
      final baseAmount = double.tryParse(SharedPrefs().getString(listingAmount) ?? '33.0') ?? 33.0;
      final result = await repo.validateCoupon(code: code, orderAmount: baseAmount);
      setState(() {
        _couponResult = result;
        _finalAmount = (result['finalAmount'] as num).toDouble();
        _isCouponValidating = false;
      });
      updateSheet?.call();
      _confettiController.play();
      _audioPlayer.play(AssetSource('tone.mp3'));
    } catch (e) {
      setState(() { _isCouponValidating = false; _couponResult = null; _finalAmount = double.tryParse(SharedPrefs().getString(listingAmount) ?? '33.0') ?? 33.0; });
      updateSheet?.call();
      if (mounted)AppToast.error(e.toString().replaceAll('Exception:', ''));
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponResult = null;
      _applyCouponController.clear();
      _finalAmount = double.tryParse(SharedPrefs().getString(listingAmount) ?? '33.0') ?? 33.0;
    });
  }

  Future<void> _handlePaymentFlow(String productId) async {
    _currentProductId = productId;
    final String userIdValue = SharedPrefs().getString(userId) ?? '';
    final String userPhone = SharedPrefs().getString(phoneNumber) ?? '';
    final String rzpKey = SharedPrefs().getString(razorpayKey) ?? 'rzp_test_T8wMbzaBD7SRid';

    if (_finalAmount == 0) {
      await ref.read(storeProductProvider.notifier).updatePaymentStatus(
        productId: productId,
        userId: userIdValue,
        paymentStatus: 'paid',
      );
      _showSuccessDialog();
      _clearForm();
      return;
    }

    var options = {
      'key': rzpKey,
      'amount': (_finalAmount * 100).toInt(),
      'name': 'LootBazar',
      'description': 'Product Listing Fee',
      'prefill': {'contact': userPhone, 'email': ''},
      'notes': {'productId': productId, 'userId': userIdValue},
      'config': {
        'display': {
          'blocks': {
            'upi': {
              'name': 'UPI Payments Only',
              'instruments': [
                {'method': 'upi'}
              ],
            },
          },
          'sequence': ['block.upi'],
          'preferences': {'show_default_blocks': false},
        },
      },
    };

    try {
      if (!kIsWeb) {
        await Workmanager().registerOneOffTask(
          "payment_status_$productId",
          "updatePaymentStatusTask",
          inputData: {'productId': productId, 'userId': userIdValue},
          initialDelay: const Duration(minutes: 5),
          constraints: Constraints(networkType: NetworkType.connected),
        );
      }

      _paymentService.open(
        options,
        onWebSuccess: (response) {
          // Web success response se manually PaymentSuccessResponse jaisa flow trigger karo
          _onWebPaymentSuccess(response['razorpay_payment_id']);
        },
        onWebError: (message) {
          AppToast.error(message);
        },
      );
    } catch (e) {
      debugPrint("Razorpay Error: $e");
    }
  }


  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _moqController.clear();
    _priceController.clear();
    _pcsController.clear();
    _cityController.clear();
    _phoneController.clear();
    _categoryController.clear();
    _applyCouponController.clear();
    ref.read(sellScreenImagesProvider.notifier).state = [];
    setState(() {
      _couponResult = null;
      _finalAmount = double.tryParse(SharedPrefs().getString(listingAmount) ?? '33.0') ?? 33.0;
    });
    final reset = dataString.value.map((e) => {...e, 'selected': false}).toList();
    dataString.value = reset;
  }

  Future<void> _callStoreProductApi() async {
    final phone = '91${_phoneController.text.trim()}';
    await ref.read(storeProductProvider.notifier).storeProduct(title: _titleController.text.trim(), description: _descriptionController.text.trim(), price: double.parse(_priceController.text.trim()), stock: int.parse(_pcsController.text.trim()), moq: int.parse(_moqController.text.trim()), categoryIds: _selectedCategoryIds, userId: SharedPrefs().getString(userId) ?? '', phoneNumber: phone, location: _cityController.text.trim(), imagePaths: selectedImages);
  }

  InputDecoration _inputDecoration({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5.sp),
        suffixIcon: suffixIcon,
        isDense: true,
        errorMaxLines: 1,
        errorStyle: TextStyle(fontSize: 10.sp, height: 0.8),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Color(0xFFFF5216), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Colors.red, width: 1)));
  }

  Future<void> _openBottomSheet() async {
    return showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: AppTheme.card,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      context: context,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Consumer(
              builder: (context, ref, child) {
                final storeState = ref.watch(storeProductProvider);
                final bool isApiLoading = storeState.isLoading;
                final baseAmount = double.tryParse(SharedPrefs().getString(listingAmount) ?? '33.0') ?? 33.0;

                return Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 10, bottom: MediaQuery.of(context).viewInsets.bottom + 220),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 180.h,
                              child: GridView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.0),
                                itemCount: selectedImages.length < 20 ? selectedImages.length + 1 : selectedImages.length,
                                itemBuilder: (context, index) {
                                  if (index == selectedImages.length) {
                                    return GestureDetector(
                                      onTap: () async {
                                        await _pickImages();
                                        setSheetState(() {});
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(10.r),
                                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade600, size: 20.sp),
                                            SizedBox(height: 2.h),
                                            Text("Add", style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  final image = selectedImages[index];
                                  return Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10.r),
                                          child: kIsWeb
                                              ? Image.network(image.path, fit: BoxFit.cover)
                                              : Image.file(File(image.path), fit: BoxFit.cover),
                                        ),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: GestureDetector(
                                          onTap: () {
                                            final newList = List<XFile>.from(selectedImages);
                                            newList.removeAt(index);
                                            ref.read(sellScreenImagesProvider.notifier).state = newList;
                                            setSheetState(() {});
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                            child: Icon(Icons.close, size: 14.sp, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(_titleController.text, style: AppTextStyle.bold(size: 18.sp)),
                            SizedBox(height: 6.h),
                            Text(_descriptionController.text, style: AppTextStyle.regular(color: Colors.grey, size: 13.sp), maxLines: 2),
                            SizedBox(height: 20.h),
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.r)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _statColumn('₹ ${_priceController.text}', 'Rate'),
                                  _statColumn(_pcsController.text, 'Pcs'),
                                  _statColumn(_moqController.text, 'MOQ'),
                                  _statColumn(_cityController.text, 'City'),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            
                            // Advanced Coupon UI
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: _couponResult == null 
                                ? Container(
                                    key: const ValueKey('coupon_input'),
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.local_offer_outlined, color: AppTheme.primary, size: 20.sp),
                                            SizedBox(width: 10.w),
                                            Text("Apply Coupon", style: AppTextStyle.bold(size: 14.sp)),
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _applyCouponController,
                                                textCapitalization: TextCapitalization.characters,
                                                decoration: InputDecoration(
                                                  hintText: "Enter Code",
                                                  isDense: true,
                                                  fillColor: Colors.grey.shade50,
                                                  filled: true,
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            SizedBox(
                                              width: 90.w,
                                              height: 44.h,
                                              child: ElevatedButton(
                                                onPressed: _isCouponValidating ? null : () async {
                                                  await _validateCoupon(updateSheet: () => setSheetState(() {}));
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                                                child: _isCouponValidating 
                                                  ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) 
                                                  : Text("Apply", style: AppTextStyle.bold(size: 13.sp)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    key: const ValueKey('coupon_applied'),
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8.w),
                                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                                          child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 22.sp),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("'${_applyCouponController.text}' Applied", style: AppTextStyle.bold(size: 14.sp, color: Colors.green.shade800)),
                                              Text(_couponResult!['message'] ?? 'Discount applied successfully', style: AppTextStyle.regular(size: 11.sp, color: Colors.green.shade700)),
                                            ],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _removeCoupon();
                                            setSheetState(() {});
                                          },
                                          child: Text("Remove", style: AppTextStyle.bold(size: 13.sp, color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Advanced Payment Bar
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w,16.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, -5))],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Payment Total", style: AppTextStyle.regular(size: 12.sp, color: Colors.grey)),
                                    Row(
                                      children: [
                                        Text("₹$baseAmount", style: TextStyle(decoration: _couponResult != null ? TextDecoration.lineThrough : null, fontSize: 14.sp, color: Colors.grey)),
                                        if (_couponResult != null) ...[
                                          SizedBox(width: 8.w),
                                          Text("₹$_finalAmount", style: AppTextStyle.bold(size: 18.sp, color: Colors.black)),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)),
                                  child: Row(
                                    children: [
                                      Icon(Icons.verified_user_outlined, size: 20.sp, color: Colors.blue.shade800),
                                      SizedBox(width: 8.w),
                                      Text("Secure Pay", style: AppTextStyle.bold(size: 13.sp, color: Colors.blue.shade800)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30.h),
                            SwipeButton(
                              isChecked: _isChecked.value,
                              status: paymentStatus,
                              isApiLoading: isApiLoading,
                              amount: _finalAmount,
                              onCall: () async {
                                FocusScope.of(context).unfocus();
                                if (selectedImages.length < 2) {
                                  AppToast.error('At least 2 images are required');
                                  return;
                                }
                                await _callStoreProductApi();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          shouldLoop: false,
                          colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                        ),
                      ),
                    ),
                  ],
                );
              }
            );
          }
        );
      },
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyle.bold(size: 16.sp, color: Colors.black)),
        Text(label, style: AppTextStyle.regular(size: 12.sp, color: Colors.grey)),
      ],
    );
  }
}
