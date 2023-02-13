import 'package:flutter/material.dart';
import 'package:location/dataTypes.dart';

class Dropdown extends StatelessWidget {
  const Dropdown({
    required this.data,
    required this.onValueChange,
    required this.label,
    required this.selectedValue,
    Key? key,
  }) : super(key: key);

  final selectedValue;
  final List<LocationCoordinates> data;
  final Function onValueChange;
  final label;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: 55,
      width: size.width,
      child: DropdownButtonFormField<dynamic>(
        value: selectedValue,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          label: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black)),
              child: Text(label)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.black),
          ),
          labelStyle: const TextStyle(color: Colors.black),
        ),
        items: data
            .map((label) => DropdownMenuItem(
                  value: label.id,
                  child: Text(
                    label.name.toString(),
                  ),
                ))
            .toList(),
        onChanged: (value) => onValueChange(value),
      ),
    );
  }
}
