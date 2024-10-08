import 'package:flutter/material.dart';
import 'package:login_statistics/global/app_colors.dart';
import 'package:login_statistics/helpers/button_conflict_prevention/button_conflict_prevention.dart';

class PrimaryButton extends StatelessWidget {
  final String buttonText;
  final double buttonWidthRatio;
  final bool enabled;
  final Function? onPressed;
  final double roundedRectangleRadius;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? textFontSize;
  final Widget? leading;
  final bool lightButton;
  final double? buttonHeightRatio;
  final bool centerText;

  const PrimaryButton({
    Key? key,
    required this.buttonText,
    this.enabled = true,
    this.buttonWidthRatio = 0.9,
    this.onPressed,
    this.roundedRectangleRadius = 13,
    this.verticalPadding = 0,
    this.horizontalPadding = 0,
    this.textFontSize = 19,
    this.leading,
    this.lightButton = false,
    this.buttonHeightRatio = .07,
    this.centerText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding ?? 0,
        horizontal: horizontalPadding ?? 0,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * buttonWidthRatio,
        height: MediaQuery.of(context).size.height * (buttonHeightRatio ?? .07),
        child: ElevatedButton(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(1),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(roundedRectangleRadius),
              ),
            ),
            backgroundColor: lightButton
                ? MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return AppColors.titleTextColor;
                      }
                      if (states.contains(MaterialState.disabled)) {
                        return AppColors.disabledPrimaryButtonColorTheme;
                      }
                      return AppColors.titleTextColor;
                    },
                  )
                : MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return AppColors.enabledPrimaryButtonColorTheme;
                      }
                      if (states.contains(MaterialState.disabled)) {
                        return AppColors.disabledPrimaryButtonColorTheme;
                      }
                      return AppColors.enabledPrimaryButtonColorTheme;
                    },
                  ),
            textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return TextStyle(
                    fontSize: textFontSize,
                    fontFamily: 'Satoshi-Regular',
                  );
                }
                if (states.contains(MaterialState.disabled)) {
                  return TextStyle(
                    fontSize: textFontSize,
                    fontFamily: 'Satoshi-Regular',
                  );
                }
                return TextStyle(
                  fontSize: textFontSize,
                  fontFamily: 'Satoshi-Regular',
                );
              },
            ),
            foregroundColor: lightButton
                ? MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return AppColors.mainColorTheme;
                      }
                      if (states.contains(MaterialState.disabled)) {
                        return AppColors.mainColorTheme;
                      }
                      return AppColors.mainColorTheme;
                    },
                  )
                : MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return AppColors.white;
                      }
                      if (states.contains(MaterialState.disabled)) {
                        return AppColors.white;
                      }
                      return AppColors.white;
                    },
                  ),
          ),
          onPressed: enabled
              ? () {
                  ButtonConflictPrevention.activate(() {
                    onPressed!();
                  });
                }
              : null,
          child: Stack(
            children: [
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: leading == null ? 0 : 30),
                child: Row(
                  mainAxisAlignment: centerText
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        buttonText,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              leading != null
                  ? Container(
                      alignment: Alignment.centerLeft,
                      child: leading!,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
