import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:login_statistics/global/app_colors.dart';
import 'package:login_statistics/widgets/buttons/primary_button.dart';
import 'package:login_statistics/widgets/buttons/secondary_button.dart';

abstract class BaseView extends StatefulWidget {
  const BaseView({Key? key}) : super(key: key);
}

abstract class BaseViewState extends State<BaseView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: rootWidget(context));
  }

  Widget rootWidget(BuildContext context);

  ///This is for show the loading
  showLoadingDialog() {
    return EasyLoading.show(
      status: 'loading...',
      maskType: EasyLoadingMaskType.black,
    );
  }

  ///This is for hide the loading
  hideLoadingDialog() {
    return EasyLoading.dismiss();
  }

  ///show confirmation
  openConfirmationAlertBox({String? body, Function? onConfirm}) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        barrierColor: Colors.black.withOpacity(0.7),
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              backgroundColor: AppColors.white,
              contentPadding: EdgeInsets.zero,
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              content: SizedBox(
                height: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Padding(
                    //   padding: EdgeInsets.zero,
                    //   child: Center(
                    //     child: SizedBox(
                    //       height:150,
                    //       width:  150,
                    //       child: FittedBox(
                    //           fit: BoxFit.contain,
                    //           child:
                    //           Image.asset(AppImages.ctbcConfirmationImage)),
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                      ),
                      child: SingleChildScrollView(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.only(
                              left: 0,
                              right: 0,
                            ),
                            child: Text(
                              body!,
                              style: const TextStyle(
                                fontFamily: 'Satoshi-Bold',
                                fontSize: 18,
                                color: AppColors.alertDialogTextColorTheme,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: PrimaryButton(
                            buttonWidthRatio: 0.3,
                            buttonText: 'Yes',
                            onPressed: () async {
                              Navigator.pop(context);
                              onConfirm!();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.only(right: 0.0),
                          child: SecondaryButton(
                              buttonWidthRatio: 0.3,
                              buttonText: 'No',
                              onPressed: () async {
                                Navigator.pop(context);
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
