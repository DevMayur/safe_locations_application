import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:safe_locations_application/user_configurations/user_colors.dart';

class TopBar extends StatelessWidget {
  String _barTitle;
  Widget? primaryAction;
  Widget? secondaryAction;
  double? fontSize;
  Function onTap;
  late UserColors _colors;

  late double _deviceHeight;
  late double _deviceWidth;

  TopBar(this._barTitle,{
    this.primaryAction,
    this.secondaryAction,
    this.fontSize = 35,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _colors = GetIt.instance.get<UserColors>();
    return _buildUI();
  }

  Widget _buildUI() {
    return Container(
      height: _deviceHeight * 0.10,
      width: _deviceWidth,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (secondaryAction != null) secondaryAction!,
          _titleBar(),
          if (primaryAction != null) primaryAction!,
        ],
      ),
    );
  }

  Widget _titleBar() {
    return TextButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        _barTitle,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: _colors.heading_color, fontSize: fontSize, fontWeight: FontWeight.w700),
      ),
    );
  }
}