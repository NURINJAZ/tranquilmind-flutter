import 'package:flutter/material.dart';
import 'package:tranquil_mindv1/components/login_form.dart';
import 'package:tranquil_mindv1/components/sign_up_form.dart';
//import 'package:tranquil_mindv1/components/social_button.dart';
import 'package:tranquil_mindv1/utils/config.dart';
import 'package:tranquil_mindv1/utils/text.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isSignIn = true;

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppText.enText['welcome_text']!,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Config.spaceSmall,
                // Center the logo image
                Center(
                  child: Image.asset(
                    'assets/logo_tm.png', // Adjust the path to your logo image
                    height: 200, // Set the desired height for your logo
                  ),
                ),
                Config.spaceSmall,
                Text(
                  isSignIn
                      ? AppText.enText['signIn_text']!
                      : AppText.enText['register_text']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Config.spaceSmall,
                isSignIn ? const LoginForm() : SignUpForm(),
                Config.spaceSmall,
                isSignIn
                    ? Center(
                        /*child: TextButton(
                          onPressed: () {},
                          child: Text(
                            AppText.enText['forgot-password']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),*/
                        )
                    : Container(),
                Config.spaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      isSignIn
                          ? AppText.enText['signUp_text']!
                          : AppText.enText['registered_text']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 151, 150, 150),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isSignIn = !isSignIn;
                        });
                      },
                      child: Text(
                        isSignIn ? 'Sign Up' : 'Sign In',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
