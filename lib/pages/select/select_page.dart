import 'package:flutter/material.dart';
import 'package:login_statistics/helpers/base_view/base_view.dart';
import 'package:login_statistics/pages/select/select_content.dart';
import 'package:login_statistics/widgets/app_bar/mobile_app_bar.dart';

class SelectPage extends BaseView {
  const SelectPage({Key? key}) : super(key: key);

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  @override
  build(BuildContext context) => MobileAppBar(
        removeBackButton: true,
        scrollable: false,
        child: const SelectContent(),
      );
}
