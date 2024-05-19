import 'package:flutter/material.dart';

class Textfield extends StatelessWidget {
  final String hintText;
  final  IconData icon;
  final TextEditingController? controller;
  final onTap;
  const Textfield({Key? key, required this.hintText, required this.icon,  this.controller, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 38,vertical: 15),
        child: Container(
          width: 284,
          height: 56,
          decoration: BoxDecoration(
              color:const Color.fromRGBO(214, 224, 239, 1),
              borderRadius: BorderRadius.circular(13)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onTap: onTap,
              controller: controller,
              decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  suffixIcon: Icon(icon)

              ),
            ),
          ),

        ));
  }
}


class Button extends StatelessWidget {
  final String text;
  final onTap;
  const Button({Key? key, required this.text, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 38,vertical: 15),
          child: Container(
            width: 284,
            height: 56,
            decoration: BoxDecoration(
                color:const Color.fromRGBO(214, 224, 239, 1),
                borderRadius: BorderRadius.circular(13)),
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(text,style: TextStyle(color: Color.fromRGBO(18, 38, 67, 1),fontSize: 24,fontWeight: FontWeight.bold),)
              ),
            ),

          )),
    );
  }
}