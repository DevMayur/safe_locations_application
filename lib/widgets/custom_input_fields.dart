import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../user_configurations/user_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final Function(String) onSaved;
  final String regEx;
  final String hintText;
  final bool obscureText;
  late UserColors _colors;

  CustomTextFormField({
  required this.onSaved,
  required this.regEx,
  required this.hintText,
  required this.obscureText
  });

  @override
  Widget build(BuildContext context) {
    _colors = GetIt.instance.get<UserColors>();
    return TextFormField(
      onSaved: (_value) => {
        onSaved(_value!)
      },
      cursorColor: Colors.white,
      style: TextStyle(color: _colors.color_text),
      obscureText: obscureText,
      // validator: (_value) {
      //   return RegExp(regEx).hasMatch(_value!) ? null : 'Enter a valid value';
      // },
      decoration: InputDecoration(
        fillColor: _colors.color_input,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: _colors.color_text)
      ),
    );
  }

}

class CustomTextField extends StatelessWidget {
  final Function(String) onEditingComplete;
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  IconData? icon;
  late UserColors _colors;

  CustomTextField({
    required this.onEditingComplete,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.icon
  });

  @override
  Widget build(BuildContext context) {
    _colors = GetIt.instance.get<UserColors>();
    return TextField(
      controller: controller,
      onEditingComplete: () => onEditingComplete(controller.value.text),
      cursorColor: Colors.white,
      style: TextStyle(
        color: _colors.color_text,
      ),
      obscureText: obscureText,
      decoration: InputDecoration(
        fillColor: _colors.color_input,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0,),
          // borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: _colors.color_text,
        ),
        prefixIcon: Icon(
          icon,
          color: _colors.color_text,
        )
      ),
    );
  }

}

class CustomUpdateTextFormField extends StatelessWidget {
  final Function(String) onSaved;
  final String regEx;
  final String text;
  final String hintText;
  final bool obscureText;
  late UserColors _colors;

  CustomUpdateTextFormField({
    required this.onSaved,
    required this.regEx,
    required this.text,
    required this.hintText,
    required this.obscureText
  });

  @override
  Widget build(BuildContext context) {
    _colors = GetIt.instance.get<UserColors>();
    return TextFormField(
      initialValue: text,
      onSaved: (_value) => {
        onSaved(_value!)
      },
      cursorColor: Colors.white,
      style: TextStyle(
          color: _colors.color_text
      ),
      obscureText: obscureText,
      // validator: (_value) {
      //   return RegExp(regEx).hasMatch(_value!) ? null : 'Enter a valid value';
      // },
      decoration: InputDecoration(
          fillColor: _colors.text_boxes,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }

}