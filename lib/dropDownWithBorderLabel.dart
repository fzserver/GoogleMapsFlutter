import 'package:flutter/material.dart';

class DropDownWithBorderLabel extends StatelessWidget {
  const DropDownWithBorderLabel(
      {Key? key,
      required this.selectedValue,
      required this.data,
      required this.onValueChange,
      required this.label,
      this.height = 55,
      this.backgroundColor = Colors.white,
      this.width})
      : super(key: key);

  final String label;
  final String selectedValue;
  final List<String> data;
  final Function onValueChange;
  final double? height;
  final double? width;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SizedBox(
        height: height,
        width: width,
        child: DropdownButtonFormField(
            value: selectedValue,
            decoration: InputDecoration(
              filled: true,
              fillColor: backgroundColor,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              label: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: Text(label)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
              labelStyle: const TextStyle(
                color: Colors.black,
              ),
            ),
            items: data
                .map((label) => DropdownMenuItem(
                      child: Text(label.toString()),
                      value: label,
                    ))
                .toList(),
            onChanged: (String? value) => onValueChange(value!)),
      ),
    );
  }
}
