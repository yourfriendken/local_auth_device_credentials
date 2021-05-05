// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth_device_credentials/local_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalAuthentication auth = LocalAuthentication();
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  bool? _isSupported;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then((isSupported) => setState(() => _isSupported = isSupported));
  }

  Future<void> _checkBiometrics() async {
    bool? canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() => _canCheckBiometrics = canCheckBiometrics);
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType>? availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() => _availableBiometrics = availableBiometrics);
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      setState(() => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
    } on PlatformException catch (e) {
      setState(() => _authorized = e.message ?? "Error");
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticateWithBiometrics(
        localizedReason: 'Use biometrics to authenticate',
        useErrorDialogs: true,
        stickyAuth: true,
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = authenticated ? 'Authorized' : 'Not Authorized';
      });
    } on PlatformException catch (e) {
      setState(() => _authorized = e.message ?? "Error");
    } finally {
      setState(() => _isAuthenticating = false);
    }
  }

  void _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 30),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (_isSupported == null) //
                    ? CircularProgressIndicator()
                    : (_isSupported ?? false) //
                        ? Text("This device is supported")
                        : Text("This device is not supported"),
                Divider(height: 100),
                Text('Can check biometrics: $_canCheckBiometrics\n'),
                RaisedButton(
                  child: const Text('Check biometrics'),
                  onPressed: _checkBiometrics,
                ),
                Divider(height: 100),
                Text('Available biometrics: $_availableBiometrics\n'),
                RaisedButton(
                  child: const Text('Get available biometrics'),
                  onPressed: _getAvailableBiometrics,
                ),
                Divider(height: 100),
                Text('Current State: $_authorized\n'),
                (_isAuthenticating)
                    ? RaisedButton(
                        onPressed: _cancelAuthentication,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Cancel Authentication"),
                            Icon(Icons.cancel),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          RaisedButton(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Authenticate'),
                                Icon(Icons.perm_device_information),
                              ],
                            ),
                            onPressed: _authenticate,
                          ),
                          RaisedButton(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_isAuthenticating ? 'Cancel' : 'Authenticate: biometrics only'),
                                Icon(Icons.person_pin),
                              ],
                            ),
                            onPressed: _authenticateWithBiometrics,
                          ),
                        ],
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
