import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool get isRegistered => FirebaseAuth.instance.currentUser != null;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.white),
        debugShowCheckedModeBanner: false,
        home: Builder(builder: (context) {
          return StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.active) {
                  final isRegistered = snap.data != null;
                  return isRegistered
                      ? const HomePage()
                      : const RegisterOrLogin();
                }
                return const Scaffold();
              });
        }));
  }
}

class RegisterOrLogin extends StatefulWidget {
  const RegisterOrLogin({super.key});

  @override
  State<RegisterOrLogin> createState() => _RegisterOrLoginState();
}

class _RegisterOrLoginState extends State<RegisterOrLogin> {
  String email = "";
  String password = "";
  String errorMessage = "";
  bool isLoading = false;
  bool obscureText = true;
  bool chek = false;

  // FirebaseAuthException uchun o'zbekcha xabarlarni qaytaruvchi funksiya
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bunday foydalanuvchi topilmadi.';
      case 'wrong-password':
        return 'Parol noto‘g‘ri kiritildi.';
      case 'invalid-email':
        return 'Email manzili noto‘g‘ri kiritilgan.';
      case 'user-disabled':
        return 'Bu foydalanuvchi bloklangan.';
      case 'too-many-requests':
        return 'Juda ko‘p urinishlar qilindi. Bir ozdan keyin qayta urinib ko‘ring.';
      case 'email-already-in-use':
        return 'Ushbu email bilan allaqachon ro‘yxatdan o‘tilgan.';
      case 'weak-password':
        return 'Parol juda kuchsiz, kuchliroq parol kiriting.';
      default:
        return 'Xatolik yuz berdi. Iltimos, qaytadan urinib ko‘ring.';
    }
  }

  // Email formatini tekshiruvchi funksiya
  bool isValidEmail(String email) {
    final emailRegExp = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegExp.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Auth"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(
                child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      hintText: "Email",
                      fillColor: Color(0xfff6f6f7),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          icon: chek
                              ? Icon(
                                  Icons.check,
                                  color: Colors.green,
                                )
                              : Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ))),
                  onChanged: (email) {
                    setState(() {
                      this.email = email;
                      chek = isValidEmail(email); // Emailni tekshirish
                    });
                  },
                ),
                SizedBox(
                  height: 24,
                ),
                TextField(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: obscureText ? true : false,
                  decoration: InputDecoration(
                    hintText: "Password",
                    fillColor: Color(0xfff6f6f7),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        icon: Icon(obscureText
                            ? Icons.visibility
                            : Icons.visibility_off)),
                  ),
                  onChanged: (password) => this.password = password,
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
                ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                        errorMessage = "";
                      });

                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email, password: password);
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          errorMessage = getErrorMessage(e);
                        });
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: Text("Hisobga kirish")),
                ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                        errorMessage = "";
                      });

                      try {
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: email, password: password);
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          errorMessage = getErrorMessage(e);
                        });
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: Text("Ro'yxatdan o'tish")),
              ],
            )),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to the App!',
              style: TextStyle(fontSize: 48),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child: Text(
                  "SingOut",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
