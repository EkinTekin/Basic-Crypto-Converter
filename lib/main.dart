import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:ui';

void main() {
  runApp(const CryptoConverterApp());
}

class CryptoConverterApp extends StatelessWidget {
  const CryptoConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: AnimatedSplashScreen(
        duration: 2500,
        splash: Stack(
          alignment: Alignment.center,
          children: [
            // Animated background particles
            const ParticleBackground(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated rotating icon
                TweenAnimationBuilder(
                  tween: Tween(begin: 0.0, end: 2.0 * 3.14),
                  duration: const Duration(seconds: 2),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value,
                      child: const Icon(
                        Icons.monetization_on,
                        size: 100,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),


                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Colors.blue, Colors.white],
                  ).createShader(bounds),
                  child: const Text(
                    "Crypto Convert",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        nextScreen: const CryptoHome(),
        splashTransition: SplashTransition.fadeTransition,
        pageTransitionType: PageTransitionType.fade,
        backgroundColor: Colors.black,
      ),
    );
  }
}


class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_controller.value),
          child: Container(),
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animation;

  ParticlePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Add particle painting logic here
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class CryptoHome extends StatefulWidget {
  const CryptoHome({super.key});

  @override
  _CryptoHomeState createState() => _CryptoHomeState();
}

class _CryptoHomeState extends State<CryptoHome> with TickerProviderStateMixin {
  String selectedCrypto = 'bitcoin';
  double amount = 1.0;
  double convertedValue = 0.0;
  bool isLoading = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  List<String> cryptos = [
    'bitcoin',
    'ethereum',
    'dogecoin',
    'cardano',
    'ripple'
  ];

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> convertCrypto() async {
    setState(() => isLoading = true);
    final url = Uri.parse(
        'https://api.coingecko.com/api/v3/simple/price?ids=$selectedCrypto&vs_currencies=usd');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        convertedValue = amount * data[selectedCrypto]['usd'];
      });
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Crypto Converter",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade900,
              Colors.blue.shade900,
              Colors.black,
            ],
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassmorphic card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCrypto,
                                dropdownColor: Colors.black.withOpacity(0.8),
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white),
                                isExpanded: true,
                                items: cryptos.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        Icon(
                                          getCryptoIcon(value),
                                          color: getCryptoColor(value),
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          value.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCrypto = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Miktar",
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white24,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onChanged: (value) {
                            setState(() {
                              amount = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        // Convert button with animation
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: ElevatedButton(
                            onPressed: () {
                              _scaleController.forward().then((_) {
                                _scaleController.reverse();
                              });
                              convertCrypto();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    "Convert",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Animated result display
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: Text(
                      convertedValue > 0
                          ? "\$${convertedValue.toStringAsFixed(2)}"
                          : "",
                      key: ValueKey<double>(convertedValue),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData getCryptoIcon(String crypto) {
    switch (crypto) {
      case 'bitcoin':
        return Icons.currency_bitcoin;
      case 'ethereum':
        return Icons.currency_exchange;
      case 'dogecoin':
        return Icons.money;
      case 'cardano':
        return Icons.account_balance;
      case 'ripple':
        return Icons.waves;
      default:
        return Icons.currency_bitcoin;
    }
  }

  Color getCryptoColor(String crypto) {
    switch (crypto) {
      case 'bitcoin':
        return Colors.orange;
      case 'ethereum':
        return Colors.blue;
      case 'dogecoin':
        return Colors.amber;
      case 'cardano':
        return Colors.blue.shade300;
      case 'ripple':
        return Colors.blue.shade700;
      default:
        return Colors.white;
    }
  }
}
