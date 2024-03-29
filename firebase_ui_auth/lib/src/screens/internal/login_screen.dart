import 'package:flutter/widgets.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;

import '../../widgets/email_form.dart';
import '../../widgets/internal/universal_scaffold.dart';

import 'responsive_page.dart';

class LoginScreen extends StatelessWidget {
  /// {@macro ui.auth.auth_controller.auth}
  final FirebaseAuth? auth;
  final AuthAction action;
  final List<AuthProvider> providers;

  /// {@macro ui.auth.screens.responsive_page.header_builder}
  final HeaderBuilder? headerBuilder;

  /// {@macro ui.auth.screens.responsive_page.header_max_extent}
  final double? headerMaxExtent;

  /// Indicates whether icon-only or icon and text OAuth buttons should be used.
  /// Icon-only buttons are placed in a row.
  final OAuthButtonVariant? oauthButtonVariant;

  /// {@macro ui.auth.screens.responsive_page.side_builder}
  final SideBuilder? sideBuilder;

  /// {@macro ui.auth.screens.responsive_page.desktop_layout_direction}
  final TextDirection? desktopLayoutDirection;
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

  /// See [Scaffold.resizeToAvoidBottomInset]
  final bool? resizeToAvoidBottomInset;

  /// A returned widget would be placed up the authentication related widgets.
  final AuthViewContentBuilder? subtitleBuilder;

  /// A returned widget would be placed down the authentication related widgets.
  final AuthViewContentBuilder? footerBuilder;
  final Key? loginViewKey;

  /// {@macro ui.auth.screens.responsive_page.breakpoint}
  final double breakpoint;
  final Set<FirebaseUIStyle>? styles;

  const LoginScreen({
    Key? key,
    required this.action,
    required this.providers,
    this.auth,
    this.oauthButtonVariant,
    this.headerBuilder,
    this.headerMaxExtent = defaultHeaderImageHeight,
    this.sideBuilder,
    this.desktopLayoutDirection = TextDirection.ltr,
    this.email,
    this.password,
    this.emailCtrl,
    this.passwordCtrl,
    this.obscurePasswordToggle,
    this.onSubmit,
    this.showAuthActionSwitch,
    this.resizeToAvoidBottomInset = false,
    this.subtitleBuilder,
    this.footerBuilder,
    this.loginViewKey,
    this.breakpoint = 800,
    this.styles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginContent = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: LoginView(
          key: loginViewKey,
          action: action,
          auth: auth,
          providers: providers,
          oauthButtonVariant: oauthButtonVariant,
          email: email,
          password: password,
          emailCtrl: emailCtrl,
          passwordCtrl: passwordCtrl,
          // Commented out cause can't use right now.
          //obscurePasswordToggle: obscurePasswordToggle,
          onSubmit: onSubmit,
          showAuthActionSwitch: showAuthActionSwitch,
          subtitleBuilder: subtitleBuilder,
          footerBuilder: footerBuilder,
        ),
      ),
    );

    final body = ResponsivePage(
      breakpoint: breakpoint,
      desktopLayoutDirection: desktopLayoutDirection,
      headerBuilder: headerBuilder,
      headerMaxExtent: headerMaxExtent,
      sideBuilder: sideBuilder,
      child: loginContent,
    );

    return FirebaseUITheme(
      styles: styles ?? const {},
      child: UniversalScaffold(
        body: body,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}
