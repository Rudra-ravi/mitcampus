import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../events/settings_event.dart';
import '../states/settings_state.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFDC2626),
              ),
            );
          } else if (state is ShowAboutDialogState) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('About', style: TextStyle(color: Color(0xFF2563EB))),
                  content: Text('${state.developerInfo}\n\n${state.version}',
                    style: const TextStyle(color: Color(0xFF1F2937))),
                  backgroundColor: Colors.white,
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Close', style: TextStyle(color: Color(0xFF0EA5E9))),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings', style: TextStyle(color: Color(0xFF1F2937))),
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
            ),
            body: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Color(0xFF2563EB)),
                  title: const Text('Logout', style: TextStyle(color: Color(0xFF1F2937))),
                  onTap: () {
                    BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info, color: Color(0xFF2563EB)),
                  title: const Text('About', style: TextStyle(color: Color(0xFF1F2937))),
                  onTap: () {
                    context.read<SettingsBloc>().add(ShowAboutDialog(context: context));
                  },
                ),
              ],
            ),
            backgroundColor: Colors.white,
          );
        },
      ),
    );
  }
}
