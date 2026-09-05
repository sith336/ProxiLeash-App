import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:proxileash/models/app_state.dart';

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

        children: [
          SizedBox(height: 32),

          _buildProximityIndicator(),

          Spacer(),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProximityIndicator() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // circle size
        final size = 350.0;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,

            shape: BoxShape.circle,

            border: Border.all(color: const Color(0xFFD9DAEC), width: 5),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (appState.isDeviceConnected) ...[
                Text(
                  (appState.isInProximity ? "Alert!" : "Monitoring..."),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
              ],

              Text(
                appState.isDeviceConnected
                    ? (appState.isInProximity
                          ? "Disconnected"
                          : "Monitoring...")
                    : "No Device Connected",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: appState.isDeviceConnected
                      ? (appState.isInProximity
                            ? Color(0xFF555BAF)
                            : Colors.black)
                      : Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
