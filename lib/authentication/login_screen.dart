import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uober/authentication/signup_screen.dart';
import 'package:uober/controllers/authentication_controller.dart';
import 'package:uober/homeScreen/dashboard.dart';
import 'package:uober/widgets/custom_text_field_widget.dart';
import 'package:uober/widgets/loading_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();
  bool showProgressBar = false;
  var controllerAuth = AuthenticationController.authController;

  checkIfNetworkIsAvailable() {
    controllerAuth.checkConnectivity(context);
    signInFormValidation();
  }

  signInFormValidation() {
    if (!emailtextEditingController.text.contains("@stu.uob.edu.bh")) {
      Get.snackbar(
          "Email incorrect", "Please use your university email to login");
    } else if (passwordtextEditingController.text.trim().length < 8) {
      Get.snackbar("Password incorrect", "Please use a valid password");
    } else {
      signInUser();
    }
  }

  signInUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          const LoadingDialog(messageText: "Please wait..."),
    );

    final User? userFirebase = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
      email: emailtextEditingController.text.trim(),
      password: passwordtextEditingController.text.trim(),
    )
            .catchError((errorMsg) {
      Navigator.pop(context);
      Get.snackbar("Login unsuccessful", "Error occurred: $errorMsg");
    }))
        .user;

    if (!context.mounted) return;
    Navigator.pop(context);

    if (userFirebase != null) {
      DatabaseReference usersRef = FirebaseDatabase.instance
          .ref()
          .child("users")
          .child(userFirebase.uid);
      usersRef.once().then((snap) {
        if (snap.snapshot.value != null) {
          if (!userFirebase.emailVerified) {
            Get.dialog(
              AlertDialog(
                title: const Text('Email Not Verified'),
                content: const Text(
                    'Your email address has not been verified. Do you want to resend the verification email?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () async {
                      await userFirebase.sendEmailVerification();
                      Get.back();
                      Get.snackbar('Email Sent',
                          'Verification email has been resent to ${userFirebase.email}.');
                    },
                    child: const Text('Resend Email'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => Dashboard()));
          } else {
            FirebaseAuth.instance.signOut();
            Get.snackbar("Your account is blocked",
                "Please contact admin: zahidmohmmad918@gmail.com");
          }
        } else {
          FirebaseAuth.instance.signOut();
          Get.snackbar("Not found", "Your account was not found as a user");
        }
      });
    }
  }

  forgotPassword() async {
    if (emailtextEditingController.text.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            const LoadingDialog(messageText: "Please wait..."),
      );

      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailtextEditingController.text)
          .then((_) {
        Navigator.pop(context);
        Get.snackbar("Password Reset Email Sent",
            "Please check your email to reset your password.");
      }).catchError((errorMsg) {
        Navigator.pop(context);
        Get.snackbar("Password Reset Failed", "Error occurred: $errorMsg");
      });
    } else {
      Get.snackbar("Email Required", "Please enter your email address");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.orange,
                  child: ClipOval(
                    child: Image.asset(
                      "images/logo3.png",
                      width: 200,
                      height: 200,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Uober: Carpooling App",
                  style: GoogleFonts.roboto(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Login to reach UOB",
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 28,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 65,
                  child: CustomTextFieldWidget(
                    editingController: emailtextEditingController,
                    labelText: "Email",
                    iconData: Icons.email_outlined,
                    isObscure: false,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 65,
                  child: CustomTextFieldWidget(
                    editingController: passwordtextEditingController,
                    labelText: "Password",
                    iconData: Icons.lock_open_outlined,
                    isObscure: true,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    checkIfNetworkIsAvailable();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 55,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Login",
                        style: GoogleFonts.roboto(
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(const SignupScreen());
                      },
                      child: Text(
                        "Register here",
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    forgotPassword();
                  },
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                showProgressBar
                    ? const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.yellow),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
