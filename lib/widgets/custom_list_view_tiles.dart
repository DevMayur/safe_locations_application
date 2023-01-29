//packages
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//widgets
import '../widgets/rounded_image.dart';

//models
import '../models/chat_message.dart';
import '../models/chat_user.dart';

class CustomListViewTileWithActivity extends StatelessWidget
{
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final Function onTap;

  CustomListViewTileWithActivity ({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isActivity,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(key: UniqueKey(), imagePath: imagePath, size: height/2, isActive: isActive),
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      subtitle: isActivity
          ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpinKitThreeBounce(
                  color: Colors.white54,
                  size: height * 0.10,
                )
              ],
            )
          : Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white24,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
    );
  }
}