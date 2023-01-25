import 'package:flutter/cupertino.dart' hide Title;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Title;

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_oauth/firebase_ui_oauth.dart'
    hide OAuthProviderButtonBase;

import '../widgets/email_form.dart';
import '../widgets/internal/title.dart';

typedef AuthViewContentBuilder = Widget Function(
  BuildContext context,
  AuthAction action,
);

/// {@template ui.auth.views.login_view}
/// A view that could be used to build a custom [SignInScreen] or
/// [RegisterScreen].
/// {@endtemplate}
class LoginView extends StatefulWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;

  /// {@macro ui.auth.auth_action}
  final AuthAction action;

  /// Indicates whether icon-only or icon and text OAuth buttons should be used.
  /// Icon-only buttons are placed in a row.
  final OAuthButtonVariant? oauthButtonVariant;
  final bool? showTitle;
  final String? email;
  final String? password;
  final TextEditingController? emailCtrl;
  final TextEditingController? passwordCtrl;

  /// When true, allows user to toggle whether to obscure password.
  /// Can't use right now, until Cupertino updates to allow equivalent of
  /// Material UI's Input Decoration. It is currently non-functioning.
  final bool? obscurePasswordToggle;

  /// A callback that is being called when the form was submitted.
  final EmailFormSubmitCallback? onSubmit;

  /// Whether the "Login/Register" link should be displayed. The link changes
  /// the type of the [AuthAction] from [AuthAction.signIn]
  /// and [AuthAction.signUp] and vice versa.
  final bool? showAuthActionSwitch;

  /// {@template ui.auth.views.login_view.footer_builder}
  /// A returned widget would be placed down the authentication related widgets.
  /// {@endtemplate}
  final AuthViewContentBuilder? footerBuilder;

  /// {@template ui.auth.views.login_view.subtitle_builder}
  /// A returned widget would be placed up the authentication related widgets.
  /// {@endtemplate}
  final AuthViewContentBuilder? subtitleBuilder;

  final List<AuthProvider> providers;

  /// A label that would be used for the "Sign in" button.
  final String? actionButtonLabelOverride;

  /// {@macro ui.auth.views.login_view}
  const LoginView({
    Key? key,
    required this.action,
    required this.providers,
    this.oauthButtonVariant = OAuthButtonVariant.icon_and_text,
    this.auth,
    this.showTitle = true,
    this.email,
    this.password,
    this.emailCtrl,
    this.passwordCtrl,
    this.obscurePasswordToggle,
    this.onSubmit,
    this.showAuthActionSwitch,
    this.footerBuilder,
    this.subtitleBuilder,
    this.actionButtonLabelOverride,
  }) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late AuthAction _action = widget.action;
  bool get _showTitle => widget.showTitle ?? true;
  bool get _showAuthActionSwitch => widget.showAuthActionSwitch ?? true;
  bool _buttonsBuilt = false;

  void setAction(AuthAction action) {
    setState(() {
      _action = action;
    });
  }

  Widget _buildOAuthButtons(TargetPlatform platform) {
    final oauthProviders = widget.providers
        .whereType<OAuthProvider>()
        .where((element) => element.supportsPlatform(platform));

    _buttonsBuilt = true;

    final oauthButtonsList = oauthProviders.map((provider) {
      return OAuthProviderButton(
        provider: provider,
        auth: widget.auth,
        action: _action,
      );
    }).toList();

    if (widget.oauthButtonVariant == OAuthButtonVariant.icon_and_text) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: oauthButtonsList,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: oauthButtonsList,
      );
    }
  }

  void _handleDifferentAuthAction(BuildContext context) {
    if (_action == AuthAction.signIn) {
      setState(() {
        _action = AuthAction.signUp;
      });
    } else {
      setState(() {
        _action = AuthAction.signIn;
      });
    }
  }

  List<Widget> _buildHeader(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);

    late String title;
    late String hint;
    late String actionText;

    if (_action == AuthAction.signIn) {
      title = l.signInText;
      hint = l.registerHintText;
      actionText = l.registerText;
    } else if (_action == AuthAction.signUp) {
      title = l.registerText;
      hint = l.signInHintText;
      actionText = l.signInText;
    }

    final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    TextStyle? hintStyle;
    late Color registerTextColor;

    if (isCupertino) {
      final theme = CupertinoTheme.of(context);
      registerTextColor = theme.primaryColor;
      hintStyle = theme.textTheme.textStyle.copyWith(fontSize: 12);
    } else {
      final theme = Theme.of(context);
      hintStyle = Theme.of(context).textTheme.caption;
      registerTextColor = theme.colorScheme.primary;
    }

    return [
      Title(text: title),
      const SizedBox(height: 16),
      if (widget.subtitleBuilder != null)
        widget.subtitleBuilder!(
          context,
          _action,
        ),
      if (_showAuthActionSwitch) ...[
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$hint ',
                style: hintStyle,
              ),
              TextSpan(
                text: actionText,
                style: Theme.of(context).textTheme.button?.copyWith(
                      color: registerTextColor,
                    ),
                mouseCursor: SystemMouseCursors.click,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _handleDifferentAuthAction(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ]
    ];
  }

  @override
  void didUpdateWidget(covariant LoginView oldWidget) {
    if (oldWidget.action != widget.action) {
      _action = widget.action;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final l = FirebaseUILocalizations.labelsOf(context);
    final platform = Theme.of(context).platform;
    _buttonsBuilt = false;

    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_showTitle) ..._buildHeader(context),
          for (var provider in widget.providers)
            if (provider.supportsPlatform(platform))
              if (provider is EmailAuthProvider) ...[
                const SizedBox(height: 8),
                EmailForm(
                  key: ValueKey(_action),
                  auth: widget.auth,
                  action: _action,
                  provider: provider,
                  email: widget.email,
                  password: widget.password,
                  // Commented out cause can't use right now.
                  //obscurePasswordToggle: widget.obscurePasswordToggle,
                  emailCtrl: widget.emailCtrl,
                  passwordCtrl: widget.passwordCtrl,
                  onSubmit: widget.onSubmit,
                  actionButtonLabelOverride: widget.actionButtonLabelOverride,
                )
              ] else if (provider is PhoneAuthProvider) ...[
                const SizedBox(height: 8),
                PhoneVerificationButton(
                  label: l.signInWithPhoneButtonText,
                  action: _action,
                  auth: widget.auth,
                ),
                const SizedBox(height: 8),
              ] else if (provider is EmailLinkAuthProvider) ...[
                const SizedBox(height: 8),
                EmailLinkSignInButton(
                  auth: widget.auth,
                  provider: provider,
                ),
              ] else if (provider is OAuthProvider && !_buttonsBuilt)
                _buildOAuthButtons(platform),
          if (widget.footerBuilder != null)
            widget.footerBuilder!(
              context,
              widget.action,
            ),
        ],
      ),
    );
  }
}
