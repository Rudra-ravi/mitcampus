abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsError extends SettingsState {
  final String message;

  SettingsError({required this.message});
}

class ShowAboutDialogState extends SettingsState {
  final String developerInfo;
  final String version;

  ShowAboutDialogState({required this.developerInfo, required this.version});
}
