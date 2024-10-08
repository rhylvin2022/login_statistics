import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:login_statistics/global/app_colors.dart';
import 'package:login_statistics/helpers/button_conflict_prevention/button_conflict_prevention.dart';

class BackButton extends StatelessWidget {
  final bool enabled;
  final String? route;

  const BackButton({
    Key? key,
    this.enabled = true,
    this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ButtonConflictPrevention.activate(() {
          if (route == null) {
            Beamer.of(context).beamBack();
          } else {
            Beamer.of(context, root: true).beamToNamed(route!);
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        width: 50.0,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
