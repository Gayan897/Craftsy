import 'package:craftsy/pages/landing_page.dart';
import 'package:craftsy/pages/login.dart';
import 'package:craftsy/services/auth.dart';
import 'package:craftsy/widgets/button.dart';
import 'package:craftsy/widgets/footer_log_sign.dart';
import 'package:craftsy/widgets/snack_bar.dart';
import 'package:craftsy/widgets/textfields.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void signUpUser() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showSnackBar(context, "Please fill all fields");
      return;
    }
    setState(() {
      isLoading = true; // Start loading
    });

    String res = await AuthService().signUpUser(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
    );
    if (res == "success") {
      if (!mounted) return; // Check if the widget is still mounted
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LandingPage(),
        ),
      );
    } else {
      if (!mounted) return; // Check if the widget is still mounted
      showSnackBar(context, res);
    }

    setState(() {
      isLoading = false; // Stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "Assets/login_signup.jpg",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.28),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Your Crafting Adventure Awaits!",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Textfields(
                      textEditingController: nameController,
                      hintText: "Enter the name",
                      icon: Icons.person,
                    ),
                    SizedBox(height: 30),
                    Textfields(
                      textEditingController: emailController,
                      hintText: "Enter the email",
                      icon: Icons.email,
                    ),
                    SizedBox(height: 30),
                    Textfields(
                      textEditingController: passwordController,
                      hintText: "Enter the password",
                      icon: Icons.lock,
                      isPass: true,
                    ),
                    SizedBox(height: 40),
                    MyButton(onTab: signUpUser, text: "Sign up"),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                          child: Text(
                            "Log in",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 56,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white,
                            margin: EdgeInsets.only(right: 10),
                          ),
                        ),
                        Text(
                          "Or Continue With:",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white,
                            margin: EdgeInsets.only(left: 10),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: FooterLogSign(
                            imageUrl: "Assets/google.jpg",
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(150),
                          child: FooterLogSign(
                            imageUrl: "Assets/facebook.png",
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(150),
                          child: FooterLogSign(
                            imageUrl: "Assets/Apple-Logo.png",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
