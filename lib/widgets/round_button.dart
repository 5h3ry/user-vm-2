import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool loading;
  final Color buttonColor;

  const RoundButton({
    Key? key,
    required this.title,
    required this.onTap,
    this.loading = false,
    this.buttonColor = Colors.deepPurple,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: loading
              ? CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.white,
          )
              : Text(
            title,
            style: TextStyle(
              color: Colors.black, // Set text color to black
              fontWeight: FontWeight.bold, // Set text to bold
            ),
          ),
        ),
      ),
    );
  }
}


