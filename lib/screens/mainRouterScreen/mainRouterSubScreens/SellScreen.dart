import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lootbazarweb/bottomNav/NavBarController.dart';
import 'package:lootbazarweb/core/theme.dart';
import 'package:lootbazarweb/providerd/Products/ProductNotifier.dart';
import 'package:lootbazarweb/providerd/currantUserListning/CurrentProductNotifier.dart';
import 'package:lootbazarweb/providerd/store_product/StoreProductNotifier.dart';
import 'package:lootbazarweb/providerd/store_product/store_product_state.dart';
import 'package:lootbazarweb/route/AppRoutes.dart';
import 'package:lootbazarweb/shared/AppTextStyle.dart';
import 'package:lootbazarweb/shared/ListingSuccessDialog.dart';
import 'package:lootbazarweb/shared/PremiumLoadingButton.dart';
import 'package:lootbazarweb/shared/apply_buttons.dart';
import 'package:lootbazarweb/shared/get_photo_card.dart';
import 'package:lootbazarweb/shared/main_buttons.dart';
import 'package:lootbazarweb/shared/my_listing.dart';
import 'package:lootbazarweb/tool/MyListingShimmer.dart';
import 'package:lootbazarweb/tool/SwipeButton.dart';
import 'package:lootbazarweb/utils/preferences.dart';
import 'package:lootbazarweb/utils/preferences_key.dart';
import 'package:page_transition/page_transition.dart';

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

  // ✅ Categories ValueNotifier — SharedPrefs se populate hoga
  final ValueNotifier<List<Map<String, dynamic>>> dataString = ValueNotifier(
    [],
  );

  List<String> imagePaths = [];
  List<XFile> selectedImages = [];

  int? paymentStatus; // Google Pay response status

  GlobalKey<FormState> mFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategoriesFromPrefs();
      ref.read(currentProductProvider.notifier).getCurrentUserProducts();
    });
  }

  Future<void> _loadCategoriesFromPrefs() async {
    final categories = await SharedPrefs().getCategories();
    dataString.value = categories
        .map(
          (c) => {
            'id': c.id, // CategoryModel ka id field
            'name': c.name, // CategoryModel ka name field
            'selected': false,
          },
        )
        .toList();
  }

  Future<void> _requestPermissions() async {
    /* var status = await Permission.photos.request();
    if (!status.isGranted) {
      openAppSettings();
    } else {

    }*/
    _pickImages();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    try {
      List<XFile>? pickedFiles = await picker.pickMultiImage(imageQuality: 70);
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        selectedImages = pickedFiles;
        imagePaths = pickedFiles.map((f) => f.path).toList();
        setState(() {});
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

    // selected names TextField me show karne ke liye
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

  @override
  void dispose() {
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
    // ✅ Store product state listen — success par action lo
    ref.listen<StoreProductState>(storeProductProvider, (prev, next) {
      if (next.isSuccess) {
        // BottomSheet band karo
        Navigator.of(context).pop();

        // Success Popup
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const ListingSuccessDialog(),
        );

        ref.read(storeProductProvider.notifier).reset();
        ref.read(currentProductProvider.notifier).getCurrentUserProducts();
        _clearForm();
      } else if (next.status == ProductStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Something went wrong'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
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
                    final currentProductState = ref.watch(
                      currentProductProvider,
                    );
                    final bool isLoading = currentProductState.isLoading;
                    final products =
                        currentProductState
                            .currantProductResponse
                            ?.currantProductData ??
                        [];
                    return Column(
                      children: [
                        SizedBox(height: 10.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "My Listing  ",
                              style: AppTextStyle.regular(
                                size: 18.sp,
                                color: Colors.black,
                              ),
                            ),
                            Visibility(
                              visible: products.isNotEmpty,
                              child: GestureDetector(
                                onTap: () {
                                  context.pushNamed(AppRoutes.myListing);
                                },
                                child: Text(
                                  products.length > 2 ? "View all" : '',
                                  style: AppTextStyle.regular(
                                    size: 13.sp,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.vertical,
                          itemCount: isLoading
                              ? 2
                              : products.length > 2
                              ? 2
                              : products.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (isLoading) {
                              return const MyListingShimmer();
                            }
                            final product = products[index];
                            return MyListing(
                              onTap: () {
                                context.pushNamed(
                                  AppRoutes.productDetail,
                                  extra: {
                                    'productId': product.id,
                                  },
                                );
                                // navigate to product detail
                              },
                              imageUrl: product.firstImageUrl,
                              title: product.title,
                              rate: product.price.toStringAsFixed(0),
                              pcs: product.stock.toString(),
                              moq: product.moq.toString(),
                              location: product.location ?? '-',
                              status: product.status,
                            );
                          },
                        ),
                        SizedBox(height: 15.h),

                        // ─── Create New Listing ───
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Create New Listing",
                            style: AppTextStyle.regular(
                              size: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                            child: Form(
                              key: mFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  // Category Dropdown
                                  ValueListenableBuilder<bool>(
                                    valueListenable: _isDropdownOpen,
                                    builder: (context, isOpen, child) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _isDropdownOpen.value = !_isDropdownOpen.value;
                                            },
                                            child: AbsorbPointer(
                                              child: TextFormField(
                                                controller: _categoryController,
                                                readOnly: true,
                                                style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Select category!';
                                                  }
                                                  return null;
                                                },
                                                decoration: _inputDecoration(
                                                  hintText: 'Select Category',
                                                  suffixIcon: Icon(
                                                    isOpen
                                                        ? Icons.keyboard_arrow_up_rounded
                                                        : Icons.keyboard_arrow_down_rounded,
                                                    color: Colors.black54,
                                                    size: 24.sp,
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
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    )
                                                  ]
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
                                                        title: Text(
                                                          list[i]['name'] ?? '',
                                                          style: TextStyle(
                                                            fontSize: 13.5.sp,
                                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                            color: isSelected ? AppTheme.primary : Colors.black87,
                                                          ),
                                                        ),
                                                        trailing: isSelected
                                                            ? const Icon(Icons.check_circle, color: AppTheme.primary)
                                                            : null,
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

                                  // Product Title textfield
                                  TextFormField(
                                    controller: _titleController,
                                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Enter product title';
                                      }
                                      return null;
                                    },
                                    decoration: _inputDecoration(hintText: 'Product Title'),
                                  ),

                                  SizedBox(height: 12.h),

                                  // Description textfield (Optional)
                                  TextFormField(
                                    controller: _descriptionController,
                                    maxLines: 3,
                                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                                    decoration: _inputDecoration(hintText: 'Description'),
                                  ),

                                  SizedBox(height: 12.h),

                                  // Quantity & MOQ row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _pcsController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          style: TextStyle(fontSize: 14.sp),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) return 'Enter quantity';
                                            return null;
                                          },
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
                                            return null;
                                          },
                                          decoration: _inputDecoration(hintText: 'MOQ'),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 12.h),

                                  // Location & Price row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _cityController,
                                          style: TextStyle(fontSize: 14.sp),
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) return 'Enter city';
                                            return null;
                                          },
                                          decoration: _inputDecoration(hintText: 'Location (city)'),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _priceController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          style: TextStyle(fontSize: 14.sp),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) return 'Enter price';
                                            return null;
                                          },
                                          decoration: _inputDecoration(hintText: 'Price per PCS'),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 12.h),

                                  // Mobile Number Input Field (styled exactly like the image)
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                                    validator: (value) {
                                      if (value == null || value.length != 10) {
                                        return 'Enter valid 10-digit mobile';
                                      }
                                      return null;
                                    },
                                    decoration: _inputDecoration(
                                      hintText: '91 90811 81218',
                                    ).copyWith(counterText: ''),
                                  ),

                                  SizedBox(height: 16.h),

                                  // Upload banner block (with soft yellow background Color(0xFFF8E7BE))
                                  GestureDetector(
                                    onTap: _pickImages,
                                    child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF8E7BE),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Upload Product photos",
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF1E1E1E),
                                                ),
                                              ),
                                              SizedBox(height: 3.h),
                                              Text(
                                                imagePaths.isNotEmpty
                                                    ? "${imagePaths.length} photos selected"
                                                    : "Upto 20 photos",
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Icon(
                                            Icons.image_outlined,
                                            size: 28.sp,
                                            color: Colors.black87,
                                          ),
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
                                      // setProductData();
                                      if (mFormKey.currentState!.validate()) {
                                        if (imagePaths.isNotEmpty) {
                                          NavBarController.showNavBar.value =
                                              false;
                                          await _openBottomSheet();
                                          NavBarController.showNavBar.value =
                                              true;
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please select images.',
                                              ),
                                            ),
                                          );
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

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _moqController.clear();
    _priceController.clear();
    _pcsController.clear();
    _cityController.clear();
    _phoneController.clear();
    _categoryController.clear();
    setState(() {
      imagePaths = [];
      selectedImages = [];
    });
    // categories deselect karo
    final reset = dataString.value
        .map((e) => {...e, 'selected': false})
        .toList();
    dataString.value = reset;
  }

  Future<void> _callStoreProductApi() async {
    // Phone number ke aage 91 lagao
    final phone = '91${_phoneController.text.trim()}';

    await ref
        .read(storeProductProvider.notifier)
        .storeProduct(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          stock: int.parse(_pcsController.text.trim()),
          moq: int.parse(_moqController.text.trim()),
          categoryIds: _selectedCategoryIds,
          userId: SharedPrefs().getString(userId) ?? '',
          phoneNumber: phone,
          location: _cityController.text.trim(),
          imagePaths: imagePaths,
        );

  }
  InputDecoration _inputDecoration({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 13.5.sp,
      ),
      suffixIcon: suffixIcon,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Color(0xFFFF5216), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }


  Future<void> _openBottomSheet() async {
    return showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      context: context,
      builder: (BuildContext sheetContext) {
        return Consumer(
          builder: (context, ref, child) {
            final storeState = ref.watch(storeProductProvider);
            final bool isApiLoading = storeState.isLoading;

            return Stack(
              children: [
                // ─── Main BottomSheet Content ───
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 180,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Preview Grid
                        SizedBox(
                          height: 200,
                          child: GridView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 1.0,
                                ),
                            itemCount: selectedImages.length,
                            itemBuilder: (context, index) {
                              final image = selectedImages[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.r),
                                ),
                                child: kIsWeb
                                    ? Image.network(
                                        image.path,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(image.path),
                                        fit: BoxFit.cover,
                                      ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Description
                        Text(
                          _titleController.text,
                          style: AppTextStyle.bold(
                            size: 18.sp,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          _descriptionController.text,
                          style: AppTextStyle.regular(
                            color: Colors.grey,
                            size: 14.sp,
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statColumn('₹ ${_priceController.text}', 'Rate'),
                            _statColumn(_pcsController.text, 'Pcs'),
                            _statColumn(_moqController.text, 'MOQ'),
                            _statColumn(_cityController.text, 'Location'),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Category
                        Text(
                          'Category: ${_categoryController.text}',
                          style: AppTextStyle.regular(
                            size: 13.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Edit Button
                        MainButton(
                          onTap: () => Navigator.pop(context),
                          text: 'Edit',
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Bottom Payment Bar ───
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 11.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0.r),
                        topRight: Radius.circular(16.0.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Google Pay row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 35,
                                  width: 35,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5.r),
                                    ),
                                  ),
                                  child: Image.asset(
                                    'assets/images/pay.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 11.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pay using',
                                      style: AppTextStyle.regular(size: 12.sp),
                                    ),
                                    Text(
                                      'Google Pay',
                                      style: AppTextStyle.bold(size: 16.sp),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: _isChecked,
                              builder: (context, isChecked, child) {
                                return Row(
                                  children: [
                                    Checkbox(
                                      value: isChecked,
                                      activeColor: AppTheme.primary,
                                      onChanged: (value) {
                                        _isChecked.value = value ?? false;
                                      },
                                    ),
                                    Text(
                                      'Apply Coupon',
                                      style: AppTextStyle.bold(size: 12.sp),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),

                        // Coupon field
                        ValueListenableBuilder<bool>(
                          valueListenable: _isChecked,
                          builder: (context, isChecked, child) {
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: isChecked
                                  ? Padding(
                                      key: const ValueKey('coupon'),
                                      padding: EdgeInsets.only(top: 12.h),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  _applyCouponController,
                                              textCapitalization:
                                                  TextCapitalization.characters,
                                              decoration: InputDecoration(
                                                labelText: 'Apply Coupon',
                                                hintText: 'Enter coupon code',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10.r,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 7.w),
                                          ApplyButtons(
                                            onTap: () async {},
                                            text: 'Apply',
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey('empty'),
                                    ),
                            );
                          },
                        ),

                        SizedBox(height: 16.h),

                        // ✅ SwipeButton
                        SwipeButton(
                          isChecked: _isChecked.value,
                          status: paymentStatus,
                          isApiLoading: isApiLoading,
                          onCall: () async {
                            FocusScope.of(context).unfocus();
                            await _callStoreProductApi();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _statColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyle.bold(size: 16.sp, color: Colors.black),
        ),
        Text(
          label,
          style: AppTextStyle.regular(size: 12.sp, color: Colors.black),
        ),
      ],
    );
  }
}
