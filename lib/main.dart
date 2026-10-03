import 'package:flutter/material.dart';
import 'core/theme.dart'; import 'models/app_state.dart'; import 'screens/home.dart';
void main() async {WidgetsFlutterBinding.ensureInitialized();final state=AppState();await state.load();runApp(LifeLog(state:state));}
class LifeLog extends StatelessWidget{final AppState state;const LifeLog({super.key,required this.state});@override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'LifeLog',theme:AppTheme.dark(),locale:const Locale('fa'),home:HomeScreen(state:state));}
