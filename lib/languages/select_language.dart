import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectLanguage extends StatelessWidget {

  final List locale =[
    {'name':'ENGLISH','locale': Locale('en','US')},
  ];

  updateLanguage(Locale locale){
    Get.back();
    Get.updateLocale(locale);
  }

  buildLanguageDialog(BuildContext context){
    showDialog(context: context,
        builder: (builder){
           return AlertDialog(
             title: Text('chooselanguage'.tr),
             content: Container(
               width: double.maxFinite,
               child: ListView.separated(
                 shrinkWrap: true,
                   itemBuilder: (context,index){
                     return Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: GestureDetector(child: Text(locale[index]['name']),onTap: (){
                         print(locale[index]['name']);
                         updateLanguage(locale[index]['locale']);
                       },),
                     );
                   }, separatorBuilder: (context,index){
                     return Divider(
                       color: Colors.blue,
                     );
               }, itemCount: locale.length
               ),
             ),
           );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('selectlanguage'.tr),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: (){
                var locale = Locale('en','US');
                Get.updateLocale(locale);
              }, child: Text('English')),

            ],
          ),
          ElevatedButton(onPressed: (){
            buildLanguageDialog(context);
          }, child: Text('changelanguage'.tr)),
        ],
      )
    );
  }
}