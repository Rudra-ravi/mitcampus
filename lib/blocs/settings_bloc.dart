import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../events/settings_event.dart';
import '../states/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<ShowAboutDialog>(_onShowAboutDialog);
  }

  Future<void> _onShowAboutDialog(ShowAboutDialog event, Emitter<SettingsState> emit) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = 'Version: ${packageInfo.version}';
      const developerInfo = 'Developed by Ravi Kumar E';
      
      emit(ShowAboutDialogState(developerInfo: developerInfo, version: version));
    } catch (e) {
      emit(SettingsError(message: 'Failed to load app information'));
    }
  }
}
