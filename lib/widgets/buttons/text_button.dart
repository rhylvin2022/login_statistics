import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:login_statistics/global/app_colors.dart';
import 'package:login_statistics/helpers/button_conflict_prevention/button_conflict_prevention.dart';

class TextButton extends StatelessWidget {
  final Function onTap;
  final String text;
  MainAxisAlignment mainAxisAlignment;
  Color color;
  TextButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.color = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
            child: GestureDetector(
              onTap: () {
                ButtonConflictPrevention.activate(() {
                  onTap();
                });
              },
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontFamily: 'Satoshi-Bold',
                ),
                maxLines: 2,
              ),
            ),
          )
        ],
      );
}
