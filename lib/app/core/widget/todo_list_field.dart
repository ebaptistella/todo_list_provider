import 'package:flutter/material.dart';
import 'package:todo_list_provider/app/core/ui/todo_list_icons.dart';

class TodoListField extends StatelessWidget {
  final String label;
  final IconButton? sufficIconButton;
  final bool obscureText;
  final ValueNotifier<bool> obscureTextNotifier;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;

  TodoListField({
    Key? key,
    required this.label,
    this.sufficIconButton,
    this.obscureText = false,
    required this.controller,
    this.validator,
  })  : assert(obscureText == true ? sufficIconButton == null : true,
            'ObscureText não pode ser enviado em conjunto com SuffixIconButton'),
        obscureTextNotifier = ValueNotifier(obscureText),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: obscureTextNotifier,
      builder: (_, obscureTextValue, child) {
        return TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 15, color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red),
            ),
            isDense: true,
            suffixIcon: sufficIconButton ??
                (obscureText == true
                    ? IconButton(
                        icon: Icon(
                          !obscureTextValue
                              ? TodoListIcons.eye
                              : TodoListIcons.eye_slash,
                          size: 15,
                        ),
                        onPressed: () {
                          obscureTextNotifier.value = !obscureTextValue;
                        },
                      )
                    : null),
          ),
          obscureText: obscureTextValue,
        );
      },
    );
  }
}
