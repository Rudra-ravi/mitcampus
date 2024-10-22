import 'package:flutter/material.dart';

abstract class SettingsEvent {}

class ShowAboutDialog extends SettingsEvent {
  final BuildContext context;

  ShowAboutDialog({required this.context});
}
