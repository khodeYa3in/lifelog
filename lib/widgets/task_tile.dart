import 'package:flutter/material.dart';
import '../models/app_state.dart';
class TaskTile extends StatelessWidget{
 final TaskItem task; final VoidCallback onToggle,onFocus;
 const TaskTile({super.key,required this.task,required this.onToggle,required this.onFocus});
 @override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.black.withOpacity(.18),borderRadius:BorderRadius.circular(17),border:Border.all(color:Colors.white.withOpacity(.06))),child:Row(children:[
 SizedBox(width:48,child:Text('${task.start.hour.toString().padLeft(2,'0')}:${task.start.minute.toString().padLeft(2,'0')}',style:const TextStyle(fontWeight:FontWeight.bold))),
 Container(width:4,height:42,decoration:BoxDecoration(color:const Color(0xFF91A8FF),borderRadius:BorderRadius.circular(5))),const SizedBox(width:12),
 Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(task.title,style:TextStyle(fontWeight:FontWeight.w700,decoration:task.status=='completed'?TextDecoration.lineThrough:null)),const SizedBox(height:4),Text('${task.category} • ${task.focusMinutes}m',style:TextStyle(fontSize:11,color:Colors.white.withOpacity(.45)))])),
 IconButton(onPressed:onFocus,icon:const Icon(Icons.play_arrow_rounded)),IconButton(onPressed:onToggle,icon:Icon(task.status=='completed'?Icons.replay:Icons.check_rounded))
 ]));
}
