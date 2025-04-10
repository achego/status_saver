import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/app/presentation/screens/dashboard.dart';
import 'package:status_saver/app/shared/components/custom_button.dart';
import 'package:status_saver/app/shared/components/dialogs/permision_dilog.dart';
import 'package:status_saver/app/view_models/status_view_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:status_saver/core/utils/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? _isPermissionGranted;
  int tries = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final viewModel = context.read<StatusViewModel>();

    final permissionStatus = await Permission.manageExternalStorage.isGranted;
    if (tries > 0) {
      setState(() {
        _isPermissionGranted = permissionStatus;
      });
    }
    if (!permissionStatus) {
      if (tries <= 0) {
        return;
      }

      final granted = await _showPermissionDialog();
      setState(() {
        _isPermissionGranted = granted;
      });
      if (granted) {
        final status = await Permission.manageExternalStorage.request();
        setState(() {
          _isPermissionGranted = status.isGranted;
        });
        if (!status.isGranted) {
          return;
        }
      } else {
        return;
      }
    }

    await viewModel.refreshStatuses();
    await viewModel.getSavedStatuses();

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    }
  }

  Future<bool> _showPermissionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionModal(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final contentHeight = screenHeight * 0.6;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: screenHeight - contentHeight,
                  child: SizedBox(
                    width: screenWidth * 0.6,
                    child: Image.asset(AppImages.splashBg),
                  ),
                ),
                Container(
                  height: contentHeight,
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                          child: Center(
                        child: CircularProgressIndicator(
                          strokeCap: StrokeCap.round,
                        ),
                      )),
                      Text(
                        'Whatsapp Status Saver',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color,
                            ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Save your favorite statuses from WhatsApp and share them with your friends.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 50),
                      CustomButton(
                        title: _isPermissionGranted == null
                            ? 'Get Started'
                            : (_isPermissionGranted! ? 'Welcome' : 'Retry'),
                        onTap: () {
                          if (_isPermissionGranted == null) {
                            tries += 1;
                          }
                          _initialize();
                        },
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
