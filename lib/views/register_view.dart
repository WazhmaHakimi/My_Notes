import 'package:flutter/material.dart';
import 'package:my_notes/constants/routes.dart';
import 'package:my_notes/services/auth/auth_exceptions.dart';
import 'package:my_notes/services/auth/auth_service.dart';
import 'package:my_notes/utilities/show_dialog_error.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),

      body: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, asyncSnapshot) {
          return Column(
            children: [
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Please enter your email',
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'Please enter your password',
                ),
              ),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    await AuthService.firebase().createUser(
                      email: email,
                      password: password,
                    );

                    final user = AuthService.firebase().currentUser;

                    await AuthService.firebase().sendEmailVerification();

                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  } on WeakPasswordException {
                    await showErrorDialog(context, 'Weak Password');
                  } on EmailAlreadyInUseException {
                    await showErrorDialog(context, 'Email already in use!');
                  } on InvalidEmailException {
                    await showErrorDialog(context, 'This is an invalid email!');
                  } on GenericAuthException {
                    await showErrorDialog(context, 'Failed to register');
                  } catch (e) {
                    await showErrorDialog(context, e.toString());
                  }
                },
                child: Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: Text('Already registered? Login here!'),
              ),
            ],
          );
        },
      ),
    );
  }
}
