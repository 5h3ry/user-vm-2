import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vending_app/ui/auth/verify_code.dart';
import '../../utils/utils.dart';
import '../../widgets/round_button.dart';

class LoginWithPhoneNumber extends StatefulWidget {
  const LoginWithPhoneNumber({super.key});

  @override
  State<LoginWithPhoneNumber> createState() => _LoginWithPhoneNumberState();
}

class _LoginWithPhoneNumberState extends State<LoginWithPhoneNumber> {
  final  phoneNumberController = TextEditingController();
  bool loading = false;
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffffcc00),
        title: Text('Login') ,
      ),
      body:Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 80,),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: phoneNumberController,
              decoration: InputDecoration(
                  hintText:  '+1 234 3455 234'
              ),

            ),
            SizedBox(height: 80,),

            RoundButton(title: 'Login', loading: loading, onTap: () {
              setState(() {
                loading= true;
              });
              auth.verifyPhoneNumber(
                  phoneNumber: phoneNumberController.text,
                  verificationCompleted: (_) {
                    setState(() {
                      loading= false;
                    });

                  },
                  verificationFailed: (e) {
                    setState(() {
                      loading= false;
                    });
                    Utils().toastMessage(e.toString());

                  },
                  codeSent: (String verficationId, int ?token) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)
                        =>VerifyCodeScreen(
                          verficationId: verficationId,))
                    );
                    setState(() {
                      loading= false;
                    });
                  },
                  codeAutoRetrievalTimeout: (e) {
                    Utils().toastMessage(e.toString());
                    setState(() {
                      loading= false;
                    });
                  });
            },
            buttonColor: Color(0xFFFFCC00),
            )



          ],
        ),
      ) ,
    );
  }
}