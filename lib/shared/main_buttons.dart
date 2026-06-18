import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lootbazarweb/core/theme.dart';

class MainButton extends StatelessWidget {
  const MainButton({super.key, required this.onTap, required this.text});

  final void Function() onTap;
  final String text;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,
      height: 55.h,
      child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        style: ElevatedButton.styleFrom(
          alignment: Alignment.center,
          elevation: 4,
          shadowColor: text=='Edit'?Colors.black:Colors.transparent,
          backgroundColor: text=='Edit'?Colors.white:AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontFamily: 'font',
              color:text=='Edit'?Colors.black: Colors.white,fontSize: 15,fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
