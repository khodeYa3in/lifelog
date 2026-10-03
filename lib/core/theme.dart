import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  static const bg=Color(0xFF070A12), accent=Color(0xFF91A8FF);
  static ThemeData dark()=>ThemeData(
    brightness: Brightness.dark, scaffoldBackgroundColor:bg, useMaterial3:true,
    colorScheme:ColorScheme.fromSeed(seedColor:accent,brightness:Brightness.dark),
    navigationBarTheme:const NavigationBarThemeData(backgroundColor:Color(0xCC101521),indicatorColor:Color(0x334F68D8)),
    inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white.withOpacity(.05),border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide(color:Colors.white.withOpacity(.08)))),
  );
}
class Glass extends StatelessWidget {
 final Widget child; final EdgeInsets padding;
 const Glass({super.key,required this.child,this.padding=const EdgeInsets.all(18)});
 @override Widget build(BuildContext context)=>ClipRRect(borderRadius:BorderRadius.circular(24),child:BackdropFilter(filter:ImageFilter.blur(sigmaX:18,sigmaY:18),child:Container(padding:padding,decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),border:Border.all(color:Colors.white.withOpacity(.09)),gradient:LinearGradient(colors:[Colors.white.withOpacity(.085),Colors.white.withOpacity(.025)])),child:child)));
}
