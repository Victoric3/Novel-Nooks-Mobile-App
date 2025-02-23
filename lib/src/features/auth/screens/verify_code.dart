import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:eulaiq/src/common/common.dart';
import 'package:eulaiq/src/common/constants/global_state.dart';
import 'package:eulaiq/src/features/auth/blocs/verify_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class ConfirmationCodeInputScreen extends StatefulWidget {
  const ConfirmationCodeInputScreen({super.key});

  @override
  _ConfirmationCodeInputScreenState createState() =>
      _ConfirmationCodeInputScreenState();
}

class _ConfirmationCodeInputScreenState
    extends State<ConfirmationCodeInputScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isResendButtonDisabled = true;
  int _resendCooldown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _isResendButtonDisabled = true;
      _resendCooldown = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          _isResendButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              toolbarHeight: 150,
              backgroundColor: lightAccent,
              automaticallyImplyLeading: false,
              title: Stack(
                children: [
                  // Manually add a back button
                  Positioned(
                    left: 0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            size: 20), // Arrow back icon
                        onPressed: () {
                          Navigator.of(context)
                              .pop(); // Go back to the previous screen
                        },
                      ),
                    ),
                  ),
                  // Centered title
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/app-icon.png',
                            fit: BoxFit.contain,
                            height: 50,
                          ),
                        ),
                        const Text(
                          'NovelNooks',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20), // Adjust text style as needed
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(color: lightAccent),
              child: Container(
                padding: const EdgeInsets.only(
                  top: 40,
                  left: 16,
                  right: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                ),
                child: Consumer(builder: (context, ref, child) {
                  final isLoading = ref.watch(loadingProvider);
                  final errorMessage = ref.watch(errorProvider);
                  final successMessage = ref.watch(successProvider);
                  final statusCode = ref.watch(statusCodeProvider);
                  final status = ref.watch(statusProvider);
                  final VerifyCode verify = VerifyCode();

                  void verifyCode() async {
                    final code = _controllers
                        .map((controller) => controller.text)
                        .join();
                    // Logic to verify the code
                    verify.collectFormData({"token": code});
                    print('status:');
                    print(status);
                    if (status == "temporary user" || statusCode == 404) {
                      await verify.confirmEmail(context, ref);
                    } else {
                      await verify.verifyUnUsualsignIn(context, ref);
                    }
                  }

                  void resendCode() async {
                    _startCooldown();
                    // Logic to resend the verification code
                    await verify.resendverificationtoken(context, ref);
                  }

                  return Column(
                    children: [
                      Text(
                        'Enter Verification Code',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 40,
                            height: 45,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: lightAccent,
                                  ),
                                ),
                                counterText: '',
                              ),
                              style: const TextStyle(color: Colors.black),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context)
                                      .requestFocus(_focusNodes[index + 1]);
                                }
                                if (value.isEmpty && index > 0) {
                                  FocusScope.of(context)
                                      .requestFocus(_focusNodes[index - 1]);
                                }
                                if (index == 5) {
                                  verifyCode();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      if (errorMessage != null)
                        Text(
                          errorMessage,
                          style: const TextStyle(color: error),
                        ),
                      if (successMessage != null && errorMessage == null)
                        Text(
                          successMessage,
                          style: const TextStyle(color: success),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            backgroundColor: lightAccent,
                          ),
                          onPressed: verifyCode,
                          child: isLoading
                              ? SizedBox(
                                  height: 24, // Set the size of the spinner
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Verify",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: _isResendButtonDisabled ? null : resendCode,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: null, // Disable individual button tap
                            ),
                            const SizedBox(width: 5),
                            Text(_isResendButtonDisabled
                                ? 'Resend in $_resendCooldown s'
                                : 'Resend Code'),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
