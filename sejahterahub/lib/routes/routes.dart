// lib/routes/routes.dart
import 'package:flutter/material.dart';
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
import 'package:sejahterahub/views/admin/verifikasi.dart';
import 'package:sejahterahub/views/admin/manage_article_page.dart';
import 'package:sejahterahub/views/submissions_form_page.dart'; // <-- Import halaman baru
import 'package:sejahterahub/views/chatbot_page.dart'; // <-- Import halaman baru

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/home': (context) => const HomePage(),
  '/edukasi': (context) => const EdukasiPage(),
  '/profil': (context) => const ProfilePage(),
  '/admin': (context) => const AdminDashboardPage(),
  '/tracking': (context) => const TrackingStatusPage(),
  '/edit_profile': (context) => const EditProfilePage(),
  '/create_discussion': (context) => const CreateDiscussionPage(),
  '/admin/verification': (context) => const VerificationPage(),
  '/admin/manage_articles': (context) => const ManageArticlesPage(),
  '/submit_application':
      (context) => const SubmissionFormPage(), // <-- Tambahkan rute ini
  '/chatbot': (context) => const ChatbotPage(), // <-- Tambahkan rute ini
};
