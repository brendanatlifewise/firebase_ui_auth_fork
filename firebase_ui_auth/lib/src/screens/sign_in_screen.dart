import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import '../widgets/email_form.dart';
import 'internal/login_screen.dart';
import 'internal/multi_provider_screen.dart';

/// {@template ui.auth.screens.sign_in_screen}
/// A screen displaying a fully styled Sign In flow for Authentication.
/// {@endtemplate}
class SignInScreen extends MultiProviderScreen {
  /// {@macro ui.auth.screens.responsive_page.header_max_extent}
  final double? headerMaxExtent;

  /// {@macro ui.auth.screens.responsive_page.header_builder}
  final HeaderBuilder? headerBuilder;

  /// {@macro ui.auth.screens.responsive_page.side_builder}
  final SideBuilder? sideBuilder;

  /// Indicates whether icon-only or icon and text OAuth buttons should be used.
  /// Icon-only buttons are placed in a row.
  final OAuthButtonVariant? oauthButtonVariant;

  /// {@macro ui.auth.screens.responsive_page.desktop_layout_direction}
  final TextDirection? desktopLayoutDirection;

  /// A email that [EmailForm] would be pre-filled with.
  final String? email;

  /// A password that [EmailForm] would be pre-filled with.
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

  /// A callback that is being called when the form was submitted.
  final EmailFormSubmitCallback? onSubmit;

  /// See [Scaffold.resizeToAvoidBottomInset]
  final bool? resizeToAvoidBottomInset;

  /// Whether the "Login/Register" link should be displayed. The link changes
  /// the type of the [AuthAction] from [AuthAction.signIn]
  /// and [AuthAction.signUp] and vice versa.
  final bool? showAuthActionSwitch;

  /// {@macro ui.auth.views.login_view.subtitle_builder}
  final AuthViewContentBuilder? subtitleBuilder;

  /// {@macro ui.auth.views.login_view.subtitle_builder}
  final AuthViewContentBuilder? footerBuilder;

  /// A [Key] that would be passed down to the [LoginView].
  final Key? loginViewKey;

  /// [SignInScreen] could invoke these actions:
  ///
  /// * [EmailLinkSignInAction]
  /// * [VerifyPhoneAction]
  /// * [ForgotPasswordAction]
  /// * [AuthStateChangeAction]
  ///
  /// These actions could be used to trigger route transtion or display
  /// a dialog.
  ///
  /// ```dart
  /// SignInScreen(
  ///   actions: [
  ///     ForgotPasswordAction((context, email) {
  ///       Navigator.pushNamed(
  ///         context,
  ///         '/forgot-password',
  ///         arguments: {'email': email},
  ///       );
  ///     }),
  ///     VerifyPhoneAction((context, _) {
  ///       Navigator.pushNamed(context, '/phone');
  ///     }),
  ///     AuthStateChangeAction<SignedIn>((context, state) {
  ///       if (!state.user!.emailVerified) {
  ///         Navigator.pushNamed(context, '/verify-email');
  ///       } else {
  ///         Navigator.pushReplacementNamed(context, '/profile');
  ///       }
  ///     }),
  ///     EmailLinkSignInAction((context) {
  ///       Navigator.pushReplacementNamed(context, '/email-link-sign-in');
  ///     }),
  ///   ],
  /// )
  /// ```
  final List<FirebaseUIAction> actions;

  /// {@macro ui.auth.screens.responsive_page.breakpoint}
  final double breakpoint;

  /// A set of styles that are provided to the descendant widgets.
  ///
  /// Possible styles are:
  /// * [EmailFormStyle]
  final Set<FirebaseUIStyle>? styles;

  /// {@macro ui.auth.screens.sign_in_screen}
  const SignInScreen({
    Key? key,
    List<AuthProvider>? providers,
    FirebaseAuth? auth,
    this.headerMaxExtent,
    this.headerBuilder,
    this.sideBuilder,
    this.oauthButtonVariant = OAuthButtonVariant.icon_and_text,
    this.desktopLayoutDirection,
    this.resizeToAvoidBottomInset = true,
    this.showAuthActionSwitch,
    this.email,
    this.password,
    this.emailCtrl,
    this.passwordCtrl,
    this.obscurePasswordToggle,
    this.onSubmit,
    this.subtitleBuilder,
    this.footerBuilder,
    this.loginViewKey,
    this.actions = const [],
    this.breakpoint = 800,
    this.styles,
  }) : super(key: key, providers: providers, auth: auth);

  Future<void> _signInWithDifferentProvider(
    BuildContext context,
    DifferentSignInMethodsFound state,
  ) async {
    await showDifferentMethodSignInDialog(
      availableProviders: state.methods,
      providers: providers,
      context: context,
      auth: auth,
      onSignedIn: () {
        Navigator.of(context).pop();
      },
    );

    await auth.currentUser!.linkWithCredential(state.credential!);
  }

  @override
  Widget build(BuildContext context) {
    final handlesDifferentSignInMethod = this
        .actions
        .whereType<AuthStateChangeAction<DifferentSignInMethodsFound>>()
        .isNotEmpty;

    final actions = [
      ...this.actions,
      if (!handlesDifferentSignInMethod)
        AuthStateChangeAction(_signInWithDifferentProvider)
    ];

    return FirebaseUIActions(
      actions: actions,
      child: LoginScreen(
        styles: styles,
        loginViewKey: loginViewKey,
        action: AuthAction.signIn,
        providers: providers,
        auth: auth,
        headerMaxExtent: headerMaxExtent,
        headerBuilder: headerBuilder,
        sideBuilder: sideBuilder,
        desktopLayoutDirection: desktopLayoutDirection,
        oauthButtonVariant: oauthButtonVariant,
        email: email,
        password: password,
        emailCtrl: emailCtrl,
        passwordCtrl: passwordCtrl,
        // Commented out cause can't use right now.
        //obscurePasswordToggle: obscurePasswordToggle,
        onSubmit: onSubmit,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        showAuthActionSwitch: showAuthActionSwitch,
        subtitleBuilder: subtitleBuilder,
        footerBuilder: footerBuilder,
        breakpoint: breakpoint,
      ),
    );
  }
}
