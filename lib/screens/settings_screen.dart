import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../events/settings_event.dart';
import '../states/settings_state.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.info, color: Color(0xFF2563EB)),
                      SizedBox(width: 8),
                      Text('About', 
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.developerInfo,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1F2937)
                        )
                      ),
                      const SizedBox(height: 8),
                      Text(state.version,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600]
                        )
                      ),
                      const SizedBox(height: 16),
                      const Text('Connect with me:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)
                        )
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Image.asset('assets/img/linkedin.png',
                              width: 32, height: 32),
                            onPressed: () => _launchURL('https://www.linkedin.com/in/ravi-kumar-e'),
                          ),
                          IconButton(
                            icon: Image.asset('assets/img/website.png',
                              width: 32, height: 32),
                            onPressed: () => _launchURL('https://ravikumar-dev.me'),
                          ),
                          IconButton(
                            icon: Image.asset('assets/img/whatsapp.png',
                              width: 32, height: 32),
                            onPressed: () => _launchURL('https://wa.me/qr/WXCYGAAJSITSK1'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  backgroundColor: Colors.white,
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Close',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold
                        )
                      ),
                      onPressed: () => Navigator.of(context).pop(),
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
              title: const Text('Settings',
                style: TextStyle(color: Colors.white)),
              backgroundColor: const Color(0xFF2563EB),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(Icons.logout,
                          color: Color(0xFF2563EB)),
                      ),
                      title: const Text('Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)
                        )
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                        color: Color(0xFF2563EB), size: 16),
                      onTap: () {
                        BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(Icons.info,
                          color: Color(0xFF2563EB)),
                      ),
                      title: const Text('About',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)
                        )
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios,
                        color: Color(0xFF2563EB), size: 16),
                      onTap: () {
                        context.read<SettingsBloc>().add(
                          ShowAboutDialog(context: context)
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
