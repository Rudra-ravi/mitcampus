import 'package:flutter_bloc/flutter_bloc.dart';
import '../events/settings_event.dart';
import '../states/settings_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<ShowAboutDialog>((event, emit) async {
      try {
        // Fetch the developer info from Firebase
        final docSnapshot = await FirebaseFirestore.instance.collection('app_info').doc('about').get();
        final developerInfo = docSnapshot.data()?['developer_info'] as String? ?? 'Developed by Ravi Kumar E';
        final version = docSnapshot.data()?['version'] as String? ?? 'Version 1.2.0';

        emit(ShowAboutDialogState(developerInfo: developerInfo, version: version));
      } catch (e) {
        emit(SettingsError(message: 'Failed to load about information'));
      }
    });
  }
}
