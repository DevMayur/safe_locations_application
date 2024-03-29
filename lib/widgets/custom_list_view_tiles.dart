//packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//widgets
import '../widgets/rounded_image.dart';

//models
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import 'message_bubble.dart';

import 'package:get_it/get_it.dart';
import 'package:safe_locations_application/user_configurations/user_colors.dart';

class CustomListViewTile extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isSelected;
  final Function onTap;
  late UserColors _colors;

  CustomListViewTile ({
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    _colors = GetIt.instance.get<UserColors>();
    return ListTile(
      trailing: isSelected ? Icon( Icons.check, color: Colors.white ) : null,
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
        leading: RoundedImageNetworkWithStatusIndicator(
            key: UniqueKey(),
            imagePath: imagePath,
            size: height / 2,
            isActive: isActive),
      title: Text(
        title,
        style: TextStyle(
          color: _colors.color_text,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: _colors.color_text,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

}

class CustomListViewTileWithActivity extends StatelessWidget
{
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final Function onTap;
  late UserColors _colors;

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
    _colors = GetIt.instance.get<UserColors>();
    return ListTile(
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(key: UniqueKey(), imagePath: imagePath, size: height/2, isActive: isActive),
      title: Text(
        title,
        style: TextStyle(
            color: _colors.color_text, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      subtitle: isActivity
          ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpinKitThreeBounce(
                  color: _colors.color_text,
                  size: height * 0.10,
                )
              ],
            )
          : Text(
              subtitle,
              style: TextStyle(
                color: _colors.color_text,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
    );
  }
}

class CustomListViewTileWithSafetyStatus extends StatelessWidget
{
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final Function onTap;
  late UserColors _colors;

  CustomListViewTileWithSafetyStatus ({
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
    _colors = GetIt.instance.get<UserColors>();
    return ListTile(
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
      leading: RoundedImageNetworkWithStatusIndicator(key: UniqueKey(), imagePath: imagePath, size: height/2, isActive: isActive),
      title: Text(
        title,
        style: TextStyle(
            color: _colors.color_text, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      subtitle: isActivity
          ? Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SpinKitThreeBounce(
            color: _colors.color_text,
            size: height * 0.10,
          )
        ],
      )
          : Text(
        subtitle,
        style: TextStyle(
          color: _colors.color_text,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Container(
        child: isActive ? Text('Safe', style: TextStyle(
          color: Colors.green
        )) : Text('Not Safe', style: TextStyle(
            color: Colors.red
        )),
      ),
    );
  }
}


class CustomChatListViewTile extends StatelessWidget {
  final double width;
  final double deviceHeight;
  final bool isOwnMessage;
  final ChatMessage message;
  final ChatUser sender;

  CustomChatListViewTile({
    required this.width,
    required this.deviceHeight,
    required this.isOwnMessage,
    required this.message,
    required this.sender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          !isOwnMessage ? RoundedImageNetwork(key: UniqueKey(), imagePath: sender.imageURL, size: width * 0.04) : Container(),
          SizedBox(
            width: width * 0.05,
          ),
          message.type == MessageType.TEXT
              ? TextMessageBubble(isOwnMessage: isOwnMessage, message: message, height: deviceHeight * 0.06, width: width * 0.3)
              : ImageMessageBubble(isOwnMessage: isOwnMessage, message: message, height: deviceHeight * 0.3, width: width * 0.35)
        ],
      ),

    );
  }
}

