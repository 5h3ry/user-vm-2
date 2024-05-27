import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vending_app/ui/MachineIntro/select_machine_for_item.dart';
import '../../utils/utils.dart';
import '../../widgets/round_button.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String verficationId;
  const VerifyCodeScreen({super.key, required this.verficationId});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  // ignore: non_constant_identifier_names
  final VerificationCodeController = TextEditingController();
  bool loading = false;
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFCC00),
      appBar: AppBar(
        title: const Text('Verify'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: VerificationCodeController,
              decoration: const InputDecoration(hintText: '6 digit code'),
            ),
            const SizedBox(
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
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SelectMachineForItems()));
                  } catch (e) {
                    setState(() {
                      loading = false;
                    });
                    Utils().toastMessage(e.toString());
                  }
                },
              buttonColor: const Color(0xFFFFCC00),
            )
          ],
        ),
      ),
    );
  }
}
