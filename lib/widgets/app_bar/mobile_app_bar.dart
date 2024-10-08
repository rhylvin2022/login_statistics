import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:login_statistics/global/app_colors.dart';
import 'package:login_statistics/global/app_images.dart';
import 'package:login_statistics/helpers/button_conflict_prevention/button_conflict_prevention.dart';

import 'package:login_statistics/widgets/buttons/back_button.dart' as back;

class MobileAppBar extends StatefulWidget {
  final Function? refreshFunction;
  final Widget child;
  bool removeBackButton;
  bool scrollable;
  MobileAppBar({
    Key? key,
    required this.child,
    this.removeBackButton = false,
    this.scrollable = true,
    this.refreshFunction,
  }) : super(key: key);

  @override
  State<MobileAppBar> createState() => _MobileAppBarState();
}

class _MobileAppBarState extends State<MobileAppBar> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.addListener(() {});
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: Stack(
          children: [
            ///background
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: AppColors.white,
                image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: AssetImage(
                    'assets/images/background.png',
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.025,
                left: MediaQuery.of(context).size.width * 0.025,
                right: MediaQuery.of(context).size.width * 0.025,
              ),
              child: !widget.scrollable
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.removeBackButton ? Container() : backButton(),
                        widget.child
                      ],
                    )
                  : widget.refreshFunction == null
                      ? SingleChildScrollView(
                          controller: _controller,
                          child: Column(
                            children: [
                              widget.removeBackButton
                                  ? Container()
                                  : backButton(),
                              widget.child
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshData,
                          child: SingleChildScrollView(
                            controller: _controller,
                            child: Center(
                              child: Column(
                                children: [
                                  widget.removeBackButton
                                      ? Container()
                                      : backButton(),
                                  widget.child
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      );

  Future _refreshData() async {
    widget.refreshFunction!();
    await Future.delayed(const Duration(seconds: 2)).whenComplete(() {});
  }

  Widget backButton() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const back.BackButton(),
          Container(),
        ],
      );
}
