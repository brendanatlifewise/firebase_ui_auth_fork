import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';

import '../widgets/internal/loading_button.dart';
import '../validators.dart';

/// {@template ui.auth.widgets.email_form.forgot_password_action}
/// An action that indicates that password recovery was triggered from the UI.
///
/// Could be used to show a [ForgotPasswordScreen] or trigger a custom
/// logic:
///
/// ```dart
/// SignInScreen(
///   actions: [
///     ForgotPasswordAction((context, email) {
///       Navigator.of(context).push(
///         MaterialPageRoute(
///           builder: (context) => ForgotPasswordScreen(),
///         ),
///       );
///     }),
///   ]
/// );
/// ```
/// {@endtemplate}
class ForgotPasswordAction extends FirebaseUIAction {
  /// A callback that is being called when a password recovery flow was
  /// triggered.
  final void Function(BuildContext context, String? email) callback;

  /// {@macro ui.auth.widgets.email_form.forgot_password_action}
  ForgotPasswordAction(this.callback);
}

typedef EmailFormSubmitCallback = void Function(
    String email, String password, BuildContext context);

/// {@template ui.auth.widgets.email_form.email_form_style}
/// An object that is being used to apply styles to the email form.
///
/// For example:
///
/// ```dart
/// EmailForm(
///   style: EmailFormStyle(
///     signInButtonVariant: ButtonVariant.text,
///   ),
/// );
/// ```
/// {@endtemplate}
class EmailFormStyle extends FirebaseUIStyle {
  /// A [ButtonVariant] that should be used for the sign in button.
  final ButtonVariant? signInButtonVariant;

  /// An override of the global [ThemeData.inputDecorationTheme].
  final InputDecorationTheme? inputDecorationTheme;

  /// {@macro ui.auth.widgets.email_form.email_form_style}
  const EmailFormStyle({
    this.signInButtonVariant = ButtonVariant.outlined,
    this.inputDecorationTheme,
  });

  @override
  Widget applyToMaterialTheme(BuildContext context, Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: inputDecorationTheme,
      ),
      child: child,
    );
  }
}

/// {@template ui.auth.widgets.email_form}
/// An email form widget.
/// {@endtemplate}
class EmailForm extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;

  /// An instance of the [EmailAuthProvider] that is being used to authenticate.
  final EmailAuthProvider? provider;

  /// A callback that is being called when the form was submitted.
  final EmailFormSubmitCallback? onSubmit;

  /// An email that should be pre-filled in the form.
  final String? email;

  /// An password that should be pre-filled in the form.
  final String? password;

  /// Access to controller for the email field in [EmailForm].
  /// If no controller passed in, EmailForm creates its own interal controller.
  final TextEditingController? emailCtrl;

  /// Access to controller for the password field in [EmailForm].
  /// If no controller passed in, EmailForm creates its own interal controller.
  final TextEditingController? passwordCtrl;

  /// When true, allows user to toggle whether to obscure password.
  /// Can't use right now, until Cupertino updates to allow equivalent of
  /// Material UI's Input Decoration. It is currently non-functioning.
  final bool? obscurePasswordToggle;

  /// A label that would be used for the "Sign in" button.
  final String? actionButtonLabelOverride;

  /// {@macro ui.auth.widgets.email_form}
  const EmailForm({
    Key? key,
    this.action,
    this.auth,
    this.provider,
    this.onSubmit,
    this.email,
    this.password,
    this.obscurePasswordToggle,
    this.emailCtrl,
    this.passwordCtrl,
    this.actionButtonLabelOverride,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = _SignInFormContent(
      action: action ?? AuthAction.signIn,
      auth: auth,
      provider: provider,
      email: email,
      password: password,
      emailCtrl: emailCtrl,
      passwordCtrl: passwordCtrl,
      // Commented out cause can't use right now.
      //obscurePasswordToggle: obscurePasswordToggle,
      onSubmit: onSubmit,
      actionButtonLabelOverride: actionButtonLabelOverride,
    );

    return AuthFlowBuilder<EmailAuthController>(
      auth: auth,
      action: action,
      provider: provider,
      child: child,
    );
  }
}

class _SignInFormContent extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;
  final EmailFormSubmitCallback? onSubmit;

  /// {@macro ui.auth.auth_action}
  final AuthAction? action;
  final String? email;
  final String? password;
  final EmailAuthProvider? provider;
  final TextEditingController? emailCtrl;
  final TextEditingController? passwordCtrl;

  /// When true, allows user to toggle whether to obscure password.
  final bool? obscurePasswordToggle;

  final String? actionButtonLabelOverride;

  const _SignInFormContent({
    Key? key,
    this.auth,
    this.onSubmit,
    this.action,
    this.email,
    this.password,
    this.emailCtrl,
    this.passwordCtrl,
    this.obscurePasswordToggle,
    this.provider,
    this.actionButtonLabelOverride,
  }) : super(key: key);

  @override
  _SignInFormContentState createState() => _SignInFormContentState();
}

class _SignInFormContentState extends State<_SignInFormContent> {
  @override
  void initState() {
    super.initState();
    // If controllers passed in, use them.
    // Assign email and password passed in to proper controller if they were passed in.
    // Called after this Widget's build. Needed so that top widget is not deactivated
    // when setting the text fields of the controllers.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // If controllers passed in but email/password not, do not assign a value to the controllers.

      // Null check, so can safely cast as String.
      if (widget.email != null) {
        widget.emailCtrl == null
            ? emailCtrl.text = widget.email as String
            : widget.emailCtrl?.text = widget.email as String;
      }
      if (widget.password != null) {
        widget.passwordCtrl == null
            ? passwordCtrl.text = widget.password as String
            : widget.passwordCtrl?.text = widget.password as String;
      }
    });
  }

  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  String _chooseButtonLabel() {
    final ctrl = AuthController.ofType<EmailAuthController>(context);
    final l = FirebaseUILocalizations.labelsOf(context);

    switch (ctrl.action) {
      case AuthAction.signIn:
        return widget.actionButtonLabelOverride ?? l.signInActionText;
      case AuthAction.signUp:
        return l.registerActionText;
      case AuthAction.link:
        return l.linkEmailButtonText;
      default:
        throw Exception('Invalid auth action: ${ctrl.action}');
    }
  }

  void _submit([String? password]) {
    final ctrl = AuthController.ofType<EmailAuthController>(context);
    final email =
        (widget.email ?? (widget.emailCtrl?.text ?? emailCtrl.text)).trim();

    if (formKey.currentState!.validate()) {
      if (widget.onSubmit != null) {
        widget.onSubmit!(
            email, widget.passwordCtrl?.text ?? passwordCtrl.text, context);
      } else {
        ctrl.setEmailAndPassword(
          email,
          password ?? (widget.passwordCtrl?.text ?? passwordCtrl.text),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    const spacer = SizedBox(height: 16);

    final children = [
      EmailInput(
        focusNode: emailFocusNode,
        controller: widget.emailCtrl ?? emailCtrl,
        onSubmitted: (v) {
          formKey.currentState?.validate();
          FocusScope.of(context).requestFocus(passwordFocusNode);
        },
      ),
      spacer,
      PasswordInput(
        focusNode: passwordFocusNode,
        controller: widget.passwordCtrl ?? passwordCtrl,
        obscurePasswordToggle: widget.obscurePasswordToggle,
        onSubmit: _submit,
        placeholder: l.passwordInputLabel,
      ),
      if (widget.action == AuthAction.signIn) ...[
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: ForgotPasswordButton(
            onPressed: () {
              final navAction =
                  FirebaseUIAction.ofType<ForgotPasswordAction>(context);

              if (navAction != null) {
                navAction.callback(
                    context, widget.emailCtrl?.text ?? emailCtrl.text);
              } else {
                showForgotPasswordScreen(
                  context: context,
                  email: emailCtrl.text,
                  auth: widget.auth,
                );
              }
            },
          ),
        ),
      ],
      if (widget.action == AuthAction.signUp ||
          widget.action == AuthAction.link) ...[
        const SizedBox(height: 8),
        PasswordInput(
          autofillHints: const [AutofillHints.newPassword],
          focusNode: confirmPasswordFocusNode,
          controller: confirmPasswordCtrl,
          onSubmit: _submit,
          validator: Validator.validateAll([
            NotEmpty(l.confirmPasswordIsRequiredErrorText),
            ConfirmPasswordValidator(
              widget.passwordCtrl ?? passwordCtrl,
              l.confirmPasswordDoesNotMatchErrorText,
            )
          ]),
          placeholder: l.confirmPasswordInputLabel,
        ),
        const SizedBox(height: 8),
      ],
      const SizedBox(height: 8),
      Builder(
        builder: (context) {
          final state = AuthState.of(context);
          final style = FirebaseUIStyle.ofType<EmailFormStyle>(
            context,
            const EmailFormStyle(),
          );

          return LoadingButton(
            variant: style.signInButtonVariant,
            label: _chooseButtonLabel(),
            isLoading: state is SigningIn || state is SigningUp,
            onTap: _submit,
          );
        },
      ),
      Builder(
        builder: (context) {
          final authState = AuthState.of(context);
          if (authState is AuthFailed) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ErrorText(
                textAlign: TextAlign.center,
                exception: authState.exception,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    ];

    return AutofillGroup(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}
