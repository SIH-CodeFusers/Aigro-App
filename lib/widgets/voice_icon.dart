import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:velocity_x/velocity_x.dart';


CircleAvatar voiceIcon(BuildContext context) {
    return CircleAvatar(
      backgroundColor: context.theme.focusColor,
      child: Icon(
        FeatherIcons.volume2
      ),
    );
  }