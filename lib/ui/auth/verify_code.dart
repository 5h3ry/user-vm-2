import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vending_app/ui/Drawer/FabTab.dart';
import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';
import 'package:vending_app/ui/posts/post_screen.dart';
import '../../utils/utils.dart';
import '../../widgets/round_button.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String verficationId;
  const VerifyCodeScreen({super.key, required this.verficationId});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final VerificationCodeController = TextEditingController();
  bool loading = false;
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFCC00),
      appBar: AppBar(
        title: Text('Verify'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: VerificationCodeController,
              decoration: InputDecoration(hintText: '6 digit code'),
            ),
            SizedBox(
              height: 80,
            ),
            RoundButton(
                title: 'Verify',
                loading: loading,
                onTap: () async {
                  setState(() {
                    loading = true;
                  });
                  final credential = PhoneAuthProvider.credential(
                      verificationId: widget.verficationId,
                      smsCode: VerificationCodeController.text.toString());
                  try {
                    await auth.signInWithCredential(credential);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SelectMachineForItems()));
                  } catch (e) {
                    setState(() {
                      loading = false;
                    });
                    Utils().toastMessage(e.toString());
                  }
                },
              buttonColor: Color(0xFFFFCC00),
            )
          ],
        ),
      ),
    );
  }
}
