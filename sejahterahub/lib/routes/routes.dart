// lib/routes.dart
import 'package:flutter/material.dart';
import 'package:sejahterahub/views/admin/verifikasi.dart';
import 'package:sejahterahub/views/splashscreen.dart';
import 'package:sejahterahub/views/auth/login_views.dart';
import 'package:sejahterahub/views/auth/register_views.dart';
import 'package:sejahterahub/views/homepage.dart';
import 'package:sejahterahub/views/edukasi/edukasi_page.dart';
import 'package:sejahterahub/views/profil_page.dart';
import 'package:sejahterahub/views/admin/admin_dashboard.dart';
import 'package:sejahterahub/views/tracking_status_page.dart';
import 'package:sejahterahub/views/edit_profil_page.dart';
import 'package:sejahterahub/views/forum/create_diskusi_page.dart';

// Definisikan semua rute di sini
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/home': (context) => const HomePage(),
  '/edukasi': (context) => const EdukasiPage(),
  '/profil': (context) => const ProfilePage(),
  '/admin': (context) => const AdminDashboardPage(),
  '/track_status': (context) => const TrackingStatusPage(),
  '/edit_profile': (context) => const EditProfilePage(),
  '/create_discussion': (context) => const CreateDiscussionPage(),
  '/admin/verification': (context) => const VerificationPage(),
};
