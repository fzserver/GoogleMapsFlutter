import 'package:flutter/material.dart';

class TextFieldWithDropDown extends StatelessWidget {
  const TextFieldWithDropDown(
      {required this.controller,
      required this.options,
      required this.placeholder,
      Key? key})
      : super(key: key);

  final String placeholder;
  final List<String> options;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: placeholder,
          suffixIcon: PopupMenuButton<String>(
            icon: const Icon(Icons.arrow_drop_down),
            onSelected: ((String value) {
              controller.text = value;
            }),
            itemBuilder: (BuildContext context) {
              return options.map<PopupMenuItem<String>>((String value) {
                return PopupMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
