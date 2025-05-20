import 'package:craft/pages/landing_page.dart';
import 'package:craft/pages/login.dart';
import 'package:craft/services/auth.dart';
import 'package:craft/widgets/button.dart';
import 'package:craft/widgets/textfields.dart';
import 'package:flutter/material.dart';

// Enhanced SnackBar function (to replace the import from snack_bar.dart)
enum SnackBarType {
  success,
  error,
  info,
  warning,
}

void showAnimatedSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
  SnackBarType type = SnackBarType.info,
  bool dismissible = true,
}) {
  // Clear any existing SnackBars first
  ScaffoldMessenger.of(context).clearSnackBars();

  // Define colors and icons based on type
  final Color backgroundColor;
  final IconData icon;

  switch (type) {
    case SnackBarType.success:
      backgroundColor = Colors.green.shade800;
      icon = Icons.check_circle_outline;
      break;
    case SnackBarType.error:
      backgroundColor = Colors.red.shade800;
      icon = Icons.error_outline;
      break;
    case SnackBarType.warning:
      backgroundColor = Colors.orange.shade800;
      icon = Icons.warning_amber_outlined;
      break;
    case SnackBarType.info:
    // ignore: unreachable_switch_default
    default:
      backgroundColor = Colors.blue.shade800;
      icon = Icons.info_outline;
  }

  final snackBar = SnackBar(
    content: TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, iconValue, child) {
                    return Transform.scale(
                      scale: iconValue,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Icon(icon, color: Colors.white),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    duration: duration,
    dismissDirection: DismissDirection.horizontal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isLoading = false;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void signUpUser() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showAnimatedSnackBar(
        context,
        message: "Please fill all fields",
        type: SnackBarType.warning,
      );
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

      // Show success message before navigation
      showAnimatedSnackBar(
        context,
        message: "Account created successfully!",
        type: SnackBarType.success,
        duration: const Duration(seconds: 2),
      );

      // Short delay before navigation for better UX
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LandingPage(),
          ),
        );
      });
    } else {
      if (!mounted) return; // Check if the widget is still mounted

      showAnimatedSnackBar(
        context,
        message: res,
        type: SnackBarType.error,
        duration: const Duration(seconds: 4),
      );
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
                    isLoading
                        ? AnimatedBuilder(
                            animation: _loadingController,
                            builder: (context, child) {
                              return Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Transform.rotate(
                                        angle: _loadingController.value * 6.3,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          backgroundColor: Colors.blue.shade300,
                                        ),
                                      ),
                                      Text(
                                        "Creating...",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : MyButton(onTab: signUpUser, text: "Sign up"),
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
