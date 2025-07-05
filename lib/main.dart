import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:signloop/Configurations/app_routes.dart';
import 'package:signloop/Configurations/generate_routes.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  await GetStorage.init();
  runApp(const ProviderScope(child : MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
       theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFF4CFDF),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
            size: 30,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // Couleur de fond
          selectedItemColor: Colors.deepPurple, // Couleur de l'item sélectionné
          unselectedItemColor: Colors.grey, // Couleur des items non sélectionnés
          selectedIconTheme: IconThemeData(size: 30), // Taille des icônes sélectionnées
          unselectedIconTheme: IconThemeData(size: 24), // Taille des icônes non sélectionnées
          elevation: 8, // Élévation de la barre
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Sign Loop',
      initialRoute: AppRoutes.home,
      getPages: GenerateRoutes.getPages,  
    );
  }
}
