import 'package:meta/meta.dart';
import 'package:task_manager/common_widgets/platform_alert_dialog.dart';
import 'package:flutter/services.dart';

class PlatformExceptionAlertDialog extends PlatformAlertDialog {
  PlatformExceptionAlertDialog(
      {@required String title, @required PlatformException exception})
      : super(
          title: title,
          content: _message(exception),
          defaultActionText: 'OK',
        );

  static String _message(PlatformException exception) {
    return _errors[exception.code] ?? exception.message;
  }

  static Map<String, String> _errors = {
  ///   • `ERROR_INVALID_EMAIL` - If the [email] address is malformed.
    'ERROR_INVALID_EMAIL': 'The email is invalid',
  ///   • `ERROR_WRONG_PASSWORD` - If the [password] is wrong.
    'ERROR_WRONG_PASSWORD': 'The password is invalid',
  ///   • `ERROR_USER_NOT_FOUND` - If there is no user corresponding to the given [email] address, or if the user has been deleted.
    'ERROR_USER_NOT_FOUND': 'The password is invalid',
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
    'ERROR_USER_DISABLED': 'The password is invalid',
  ///   • `ERROR_TOO_MANY_REQUESTS` - If there was too many attempts to sign in as this user.
    'ERROR_TOO_MANY_REQUESTS': 'The password is invalid',
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
    'ERROR_OPERATION_NOT_ALLOWED': 'The password is invalid',
  ///   • `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
    'ERROR_WEAK_PASSWORD': 'The password is invalid',
  ///   • `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
    'ERROR_EMAIL_ALREADY_IN_USE': 'The password is invalid',
    'PERMISSION_DENIED': 'Missing or insufficient permission',
  };
}
