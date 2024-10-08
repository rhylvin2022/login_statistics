// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:login_statistics/global/app_colors.dart';
import 'package:login_statistics/helpers/alert_dialog_popper/alert_dialog_popper.dart';
import 'package:login_statistics/helpers/button_conflict_prevention/button_conflict_prevention.dart';

class DropdownButton extends StatefulWidget {
  final String dropdownTitle;
  String? currentValue;
  final double horizontalPadding;
  final FocusNode? focusNode;
  final List<String> valueList;
  final Function(String)? onValueChange;
  final bool disableDropdown;
  final int truncateLength;
  final int maxCountUntilScrollable;
  final bool includeSearchBar;
  DropdownButton({
    Key? key,
    required this.dropdownTitle,
    this.horizontalPadding = 20,
    this.focusNode,
    required this.valueList,
    required this.currentValue,
    this.onValueChange,
    this.disableDropdown = false,
    this.truncateLength = 30,
    this.maxCountUntilScrollable = 10,
    this.includeSearchBar = false,
  }) : super(key: key);

  @override
  _DropdownButtonState createState() => _DropdownButtonState();
}

bool mobileHeightIsTooLow(BuildContext context) =>
    MediaQuery.of(context).size.height < 700;

class _DropdownButtonState extends State<DropdownButton> {
  final GlobalKey buttonKey = GlobalKey();
  final ScrollController _controller1 = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// Add a listener to the ScrollController to detect when the user releases the drag
      _controller1.addListener(() {
        ///reset timer if in logged in
      });
    });
  }

  @override
  void dispose() {
    AlertDialogPopper.popDialogContext();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPadding,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              controller: _controller1,
              scrollDirection: Axis.horizontal,
              child: Text(
                widget.dropdownTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Satoshi-Medium',
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  (kIsWeb
                      ? webButtonHeightMultiplier(context: context)
                      : 0.075),
              child: IgnorePointer(
                ignoring: widget.disableDropdown,
                child: ElevatedButton(
                  key: buttonKey,
                  onPressed: () {
                    ButtonConflictPrevention.activate(() {
                      openDropdownDialog();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    primary: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.0),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        kIsWeb
                            ? widget.currentValue ?? ''
                            : truncateName(widget.currentValue ?? ''),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Satoshi-Regular',
                        ),
                      ),
                      widget.disableDropdown
                          ? Container()
                          : const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  String truncateName(String value) {
    try {
      if (value.length > widget.truncateLength) {
        return '${value.substring(0, widget.truncateLength)}...';
      } else {
        return value;
      }
    } catch (e) {
      return value;
    }
  }

  double previousMaxHeight = 0;
  double previousMaxWidth = 0;

  ///developed by: Rhylvin February 2024
  ///recreated dropdown to be an alert dialog
  ///to be able to use listview instead of dropdown
  ///so that I can listen to scrolling and be able to
  ///execute InactivityTimer.reset() if dropdown items are being scrolled
  void openDropdownDialog() async {
    AlertDialogPopper.setEnabled();
    int itemCount = widget.valueList.length;
    double multiplier = MediaQuery.of(context).size.height *
        (kIsWeb
            ? webMultiplier(context: context)
            : mobileHeightMultiplier(context: context));
    double currentHeight = itemCount * multiplier;
    double maxHeight = widget.maxCountUntilScrollable * multiplier;

    double dialogHeight = currentHeight < maxHeight ? currentHeight : maxHeight;

    double doubleDialogHeight = multiplier * 2;

    final RenderBox renderBox =
        buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    double dialogTop = offset.dy + renderBox.size.height;
    double screenHeight = MediaQuery.of(context).size.height;
    if (kIsWeb) {
      if (widget.includeSearchBar) {
        dialogTop = (screenHeight - dialogHeight) / 2;
      } else if (screenHeight <= 854) {
        // If the screen height is large, center the dialog on the screen
        if (dialogHeight > (screenHeight / 2)) {
          dialogTop = (screenHeight - dialogHeight) / 2;
        } else {
          if (dialogTop + doubleDialogHeight > screenHeight) {
            // If the dropdown extends below the screen, adjust it to appear above
            dialogTop = offset.dy - dialogHeight;
          } else {
            // If dialogHeight is small enough, use dialogTop directly
            dialogTop = offset.dy +
                renderBox.size.height -
                webTopOffset(context: context);
          }
        }
      } else if (dialogTop + dialogHeight > screenHeight) {
        // If the dropdown extends below the screen, adjust it to appear above
        dialogTop = offset.dy - dialogHeight;
      } else {
        // Otherwise, normal positioning
        dialogTop = dialogTop - webTopOffset(context: context);
      }
    } else {
      if (dialogHeight > (screenHeight / 2)) {
        dialogTop = (screenHeight - dialogHeight) / 2;
      } else {
        if (dialogTop + dialogHeight > screenHeight) {
          // If the dropdown extends below the screen, adjust it to appear above
          dialogTop = offset.dy - dialogHeight;
        } else {
          // Otherwise, normal positioning
          dialogTop = dialogTop - 8.0;
        }
      }
    }

    final selectedValue = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (BuildContext _dialogContext, BoxConstraints constraints) {
            AlertDialogPopper.setDialogContext(_dialogContext);
            if (kIsWeb && shouldResetDialog(constraints)) {
              if (!(previousMaxHeight == 0 && previousMaxWidth == 0)) {
                Navigator.pop(context);
              }
              previousMaxHeight = constraints.maxHeight;
              previousMaxWidth = constraints.maxWidth;
            }

            return StatefulDropdown(
              currentValue: widget.currentValue,
              dialogHeight: dialogHeight,
              dialogTop: dialogTop,
              includeSearchBar: widget.includeSearchBar,
              offset: offset,
              statefulDropdownContext: _dialogContext,
              valueList: widget.valueList,
              onValueChange: widget.onValueChange,
            );
          },
        );
      },
    );

    if (selectedValue != null) {}
    AlertDialogPopper.setDisabled();
  }

  bool shouldResetDialog(BoxConstraints constraints) {
    return constraints.maxHeight != previousMaxHeight ||
        constraints.maxWidth != previousMaxWidth;
  }

  double webMultiplier({required BuildContext context}) {
    double height = MediaQuery.of(context).size.height;
    return height >= 1071
        ? 0.05
        : height <= 1070 && height >= 855
            ? 0.05
            : height <= 854 && height >= 675
                ? 0.065
                : height <= 674
                    ? 0.08
                    : 0.05;
  }

  double webTopOffset({required BuildContext context}) {
    double height = MediaQuery.of(context).size.height;

    return height >= 1071
        ? 15.0
        : height <= 1070 && height >= 855
            ? 15.0
            : height <= 854 && height >= 675
                ? 20.0
                : height <= 674
                    ? 25.0
                    : 15.0;
  }

  double webButtonHeightMultiplier({required BuildContext context}) {
    double height = MediaQuery.of(context).size.height;

    return height >= 1071
        ? 0.055
        : height <= 1070 && height >= 855
            ? 0.055
            : height <= 854 && height >= 675
                ? 0.06
                : height <= 674
                    ? 0.065
                    : 15.0;
  }

  double mobileHeightMultiplier({required BuildContext context}) {
    return Platform.isAndroid
        ? mobileHeightIsTooLow(context)
            ? 0.09
            : 0.07
        : mobileHeightIsTooLow(context)
            ? 0.07
            : 0.0675;
  }
}

class StatefulDropdown extends StatefulWidget {
  final BuildContext statefulDropdownContext;
  final double dialogTop;
  final double dialogHeight;
  final Offset offset;
  final bool includeSearchBar;
  String? currentValue;
  final Function(String)? onValueChange;
  final List<String> valueList;
  StatefulDropdown({
    Key? key,
    required this.statefulDropdownContext,
    required this.dialogTop,
    required this.dialogHeight,
    required this.offset,
    required this.includeSearchBar,
    required this.currentValue,
    required this.valueList,
    this.onValueChange,
  }) : super(key: key);

  @override
  _StatefulDropdownState createState() => _StatefulDropdownState();
}

class _StatefulDropdownState extends State<StatefulDropdown> {
  TextEditingController searchBarController = TextEditingController();
  final ScrollController _controller2 = ScrollController();

  late List<String> searchValueList = widget.valueList;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// Add a listener to the ScrollController to detect when the user releases the drag
      _controller2.addListener(() {
        ///reset timer if in logged in
      });
    });
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Positioned(
            top: widget.dialogTop -
                (kIsWeb
                    ? 0
                    : Platform.isAndroid || mobileHeightIsTooLow(context)
                        ? 30.0
                        : 60.0),
            left: kIsWeb
                ? widget.offset.dx - webLeftOffset(context: context)
                : null,
            child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                insetPadding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                content: widget.includeSearchBar
                    ? Column(
                        children: [
                          searchBar(),
                          dropdownWidget(widget.dialogHeight,
                              widget.statefulDropdownContext)
                        ],
                      )
                    : dropdownWidget(
                        widget.dialogHeight, widget.statefulDropdownContext)),
          ),
        ],
      );

  Widget dropdownWidget(double dialogHeight, BuildContext dropdownContext) =>
      SizedBox(
        width: kIsWeb
            ? MediaQuery.of(context).size.width * 0.4
            : MediaQuery.of(context).size.width * 0.9,
        height: dialogHeight,
        child: ListView(
          controller: _controller2,
          padding: EdgeInsets.zero,
          children: searchValueList.map((String value) {
            return ListTile(
              title: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Satoshi-Regular',
                ),
              ),
              onTap: () {
                setState(() {
                  widget.currentValue = value;
                  widget.onValueChange?.call(value);
                });
                Navigator.pop(dropdownContext, value);
                AlertDialogPopper.setDisabled();
              },
            );
          }).toList(),
        ),
      );

  Widget searchBar() => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.4),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: TextField(
            cursorColor: AppColors.primaryColor,
            textAlign: TextAlign.left,
            controller: searchBarController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(15),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 3),
                child: Icon(
                  Icons.search,
                  size: 28,
                  color: Colors.grey,
                ),
              ),
            ),
            onChanged: (String value) {
              if (value.length > 2) {
                setState(() {
                  searchValueList = widget.valueList
                      .where((element) =>
                          element.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              } else {
                setState(() {
                  searchValueList = widget.valueList;
                });
              }
            },
          ),
        ),
      );

  double webLeftOffset({required BuildContext context}) {
    double height = MediaQuery.of(context).size.height;

    return height >= 1071
        ? 12.0
        : height <= 1070 && height >= 855
            ? 12.0
            : height <= 854 && height >= 675
                ? 20.0
                : height <= 674
                    ? 25.0
                    : 15.0;
  }
}
