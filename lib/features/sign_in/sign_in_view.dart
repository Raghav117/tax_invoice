import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tax_invoice_new/services/auth/sign_in_helper.dart';
import 'package:tax_invoice_new/features/invoice_generation/invoice_generation_page.dart';
import 'package:tax_invoice_new/features/generic_component/casting_door_button.dart';
import 'package:tax_invoice_new/features/resources/custom_color.dart';
import 'package:tax_invoice_new/features/resources/custom_text_style.dart';
import 'package:tax_invoice_new/services/sync/sync_manager.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  GoogleSignInAccount? _currentUser;
  bool isAuthorized = false;

  @override
  void initState() {
    super.initState();

    SignInHelper.signInSilently(
      onSignIn: (GoogleSignInAccount? account) async {
        if (account != null) {
          setState(() {
            _currentUser = account;
          });

          if (hardSignIn) {
            await SyncManager().checkAndSyncIfNeeded();
          }
          if (context.mounted) {
            SyncManager().checkAndSyncIfNeeded();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const InvoiceGenerationPage(),
              ),
            );
          }
        } else {}
      },
    );
  }

  bool hardSignIn = false;

  Future<void> _handleSignIn() async {
    try {
      hardSignIn = true;
      await SignInHelper.signedIn();
    } catch (error) {
      print(error);
    }
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      // The user is Authenticated
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(identity: user),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          Center(child: CircularProgressIndicator(color: Colors.orange)),
        ],
      );
    } else {
      // The user is NOT Authenticated
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[buildSignInButton(onPressed: _handleSignIn)],
      );
    }
  }

  buildSignInButton({required VoidCallback onPressed}) {
    return CastingDoorButton(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onEnableCta: () {
        onPressed();
      },
      isDisabled: false,
      child: Text(
        "Please Sign In For Forward",
        style: CustomTextStyle.heading12Bold.copyWith(
          color: CustomColor.mainWhiteColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: context.height * 0.3),
          Container(
            width: context.width / 3,
            child: Image.asset("images/vyapar_setu.png"),
          ),
          SizedBox(height: 12),
          Text('Vyapar Setu', style: CustomTextStyle.heading18),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
