# local_auth

This is a fork of the [local_auth](https://github.com/flutter/plugins/tree/master/packages/local_auth)

## Device credentails

The original plugin only supports biometric authentication. This package add a method that allows for device credentials if biometric authentication is not available.

`localAuth.authenticate()` behaves the same as the original plugin's `localAuth.authenticateWithBiometrics()` but also allows device credentials (pin, pattern, passcode) to be use.
