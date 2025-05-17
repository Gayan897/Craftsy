import 'package:craft/data/onboarding_data.dart';
import 'package:craft/pages/login.dart';
import 'package:craft/pages/onboarding/front_page.dart';
import 'package:craft/pages/onboarding/shared_onboarding_screen.dart';
import 'package:craft/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardinScreen extends StatefulWidget {
  const OnboardinScreen({super.key});

  @override
  State<OnboardinScreen> createState() => _OnboardinScreenState();
}

class _OnboardinScreenState extends State<OnboardinScreen> {
  final PageController _controller = PageController(); //define the controller
  bool showDetailsPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                //onboarding view
                PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      showDetailsPage = index == 3;
                    });
                  },
                  children: [
                    FrontPage(),
                    SharedOnboardingScreen(
                      title: OnboardingData.onboardingDataList[0].title,
                      imagePath: OnboardingData.onboardingDataList[0].imagePath,
                      description:
                          OnboardingData.onboardingDataList[0].description,
                    ),
                    SharedOnboardingScreen(
                      title: OnboardingData.onboardingDataList[1].title,
                      imagePath: OnboardingData.onboardingDataList[1].imagePath,
                      description:
                          OnboardingData.onboardingDataList[1].description,
                    ),
                    SharedOnboardingScreen(
                      title: OnboardingData.onboardingDataList[2].title,
                      imagePath: OnboardingData.onboardingDataList[2].imagePath,
                      description:
                          OnboardingData.onboardingDataList[2].description,
                    ),
                  ],
                ),

                //page dot indicators

                Container(
                  alignment: Alignment(0, 0.60),
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: 4,
                    effect: const WormEffect(
                      activeDotColor: Color.fromARGB(255, 24, 182, 255),
                      dotColor: Colors.grey,
                    ),
                  ),
                ),

                //Navigation buutons
                Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: !showDetailsPage
                          ? GestureDetector(
                              onTap: () {
                                _controller.animateToPage(
                                  _controller.page!.toInt() + 1,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: CustomButton(
                                ButtonName:
                                    showDetailsPage ? "Get Started" : "Next",
                                buttonColor: Colors.blue,
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                //navigate to login screen
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Login(),
                                    ));
                              },
                              child: CustomButton(
                                ButtonName:
                                    showDetailsPage ? "Get Started" : "Next",
                                buttonColor: Colors.blue,
                              ),
                            ),
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
