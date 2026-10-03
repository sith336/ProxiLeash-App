import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:proxileash/models/app_state.dart';

import '../widgets/circle_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppState appState;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<AppState>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [SizedBox(height: 32), _deviceStatus(), SizedBox(height: 32)],
      ),
    );
  }

  Widget _deviceStatus() {
    return Expanded(
      child: CircleContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Device Status
            appState.deviceHasConnected
                // While Connected
                ? (!appState.deviceHasDisconnected
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Monitoring...',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.green,
                              ),
                            ),

                            Text(
                              'Nearby',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              'Signal Strength',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.green,
                              ),
                            ),

                            Text(
                              'Strong',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Device Disconnected!',
                          style: TextStyle(fontSize: 24, color: Colors.red),
                        ))
                // No device connected
                : const Text(
                    'No Device Connected',
                    style: TextStyle(fontSize: 24, color: Colors.red),
                  ),
          ],
        ),
      ),
    );
  }
}
