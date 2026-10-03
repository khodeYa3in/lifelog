import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskItem {
 String id,title,note,category,status; DateTime start,end; int priority,progress,focusMinutes;
 TaskItem({required this.id,required this.title,required this.start,required this.end,this.note='',this.category='شخصی',this.status='planned',this.priority=1,this.progress=0,this.focusMinutes=0});
 Map<String,dynamic> toJson()=>{'id':id,'title':title,'note':note,'category':category,'status':status,'start':start.toIso8601String(),'end':end.toIso8601String(),'priority':priority,'progress':progress,'focusMinutes':focusMinutes};
 factory TaskItem.fromJson(Map<String,dynamic> j)=>TaskItem(id:j['id'],title:j['title'],note:j['note']??'',category:j['category']??'شخصی',status:j['status']??'planned',start:DateTime.parse(j['start']),end:DateTime.parse(j['end']),priority:j['priority']??1,progress:j['progress']??0,focusMinutes:j['focusMinutes']??0);
}
class AppState extends ChangeNotifier {
 List<TaskItem> tasks=[]; List<Map<String,dynamic>> journal=[],sleep=[],habits=[],goals=[]; Map<String,dynamic> reviews={}; int focusMinutes=0;
 Future<void> load() async {final p=await SharedPreferences.getInstance(); final raw=p.getString('lifelog_data');if(raw!=null){final j=jsonDecode(raw);tasks=(j['tasks'] as List? ?? []).map((e)=>TaskItem.fromJson(e)).toList();journal=List<Map<String,dynamic>>.from(j['journal']??[]);sleep=List<Map<String,dynamic>>.from(j['sleep']??[]);habits=List<Map<String,dynamic>>.from(j['habits']??[]);goals=List<Map<String,dynamic>>.from(j['goals']??[]);reviews=Map<String,dynamic>.from(j['reviews']??{});focusMinutes=j['focusMinutes']??0;}notifyListeners();}
 Future<void> save() async {final p=await SharedPreferences.getInstance();await p.setString('lifelog_data',jsonEncode({'tasks':tasks.map((e)=>e.toJson()).toList(),'journal':journal,'sleep':sleep,'habits':habits,'goals':goals,'reviews':reviews,'focusMinutes':focusMinutes}));notifyListeners();}
}
