import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Auth screens
import '../../presentation/screens/auth/welcome_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/reset_password_screen.dart';
import '../../presentation/screens/auth/email_verification_screen.dart';

// Main navigation
import '../../presentation/screens/home/main_navigation.dart';
import '../../presentation/screens/home/home_screen.dart';

// Doctors
import '../../presentation/screens/doctors/doctors_screen.dart';
import '../../presentation/screens/doctors/doctor_detail_screen.dart';
import '../../presentation/screens/doctors/doctor_reviews_screen.dart';
import '../../presentation/screens/doctors/favorite_doctors_screen.dart';

// Appointments
import '../../presentation/screens/appointments/appointments_screen.dart';
import '../../presentation/screens/appointments/appointment_detail_screen.dart';

// Booking
import '../../presentation/screens/booking/booking_flow_screen.dart';
import '../../presentation/screens/booking/booking_success_screen.dart';

// Profile
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/change_password_screen.dart';
import '../../presentation/screens/profile/notification_settings_screen.dart';

// Medical
import '../../presentation/screens/medical/medical_record_screen.dart';
import '../../presentation/screens/medical/prescriptions_list_screen.dart';
import '../../presentation/screens/medical/prescription_detail_screen.dart';
import '../../presentation/screens/medical/lab_results_screen.dart';
import '../../presentation/screens/medical/vaccination_screen.dart';

// Payment
import '../../presentation/screens/payment/payment_methods_screen.dart';
import '../../presentation/screens/payment/payment_screen.dart';
import '../../presentation/screens/payment/payment_history_screen.dart';
import '../../presentation/screens/payment/invoice_screen.dart';

// Map
import '../../presentation/screens/map/map_view_screen.dart';
import '../../presentation/screens/map/hospital_locator_screen.dart';

// Support
import '../../presentation/screens/support/chat_support_screen.dart';
import '../../presentation/screens/support/faq_screen.dart';
import '../../presentation/screens/support/contact_support_screen.dart';

// Family
import '../../presentation/screens/family/family_members_screen.dart';
import '../../presentation/screens/family/add_family_member_screen.dart';

// Emergency
import '../../presentation/screens/emergency/emergency_contacts_screen.dart';

// Health
import '../../presentation/screens/health/health_screens.dart';

// Search
import '../../presentation/screens/search/search_screen.dart';

// Notifications
import '../../presentation/screens/notifications/notifications_screen.dart';

// Chat
import '../../presentation/screens/chat/chat_screen.dart';

class AppRoutes {
  // Auth routes
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String emailVerification = '/email-verification';

  // Main routes
  static const String main = '/main';
  static const String home = '/home';

  // Doctors routes
  static const String doctors = '/doctors';
  static const String doctorDetail = '/doctor-detail';
  static const String doctorReviews = '/doctor-reviews';
  static const String favoriteDoctors = '/favorite-doctors';

  // Appointments routes
  static const String appointments = '/appointments';
  static const String appointmentDetail = '/appointment-detail';

  // Booking routes
  static const String bookingFlow = '/booking-flow';
  static const String bookingSuccess = '/booking-success';

  // Profile routes
  static const String profile = '/profile';
  static const String changePassword = '/change-password';
  static const String notificationSettings = '/notification-settings';

  // Medical routes
  static const String medicalRecord = '/medical-record';
  static const String prescriptionsList = '/prescriptions-list';
  static const String prescriptionDetail = '/prescription-detail';
  static const String labResults = '/lab-results';
  static const String vaccination = '/vaccination';

  // Payment routes
  static const String paymentMethods = '/payment-methods';
  static const String payment = '/payment';
  static const String paymentHistory = '/payment-history';
  static const String invoice = '/invoice';

  // Map routes
  static const String mapView = '/map-view';
  static const String hospitalLocator = '/hospital-locator';

  // Support routes
  static const String chatSupport = '/chat-support';
  static const String faq = '/faq';
  static const String contactSupport = '/contact-support';

  // Family routes
  static const String familyMembers = '/family-members';
  static const String addFamilyMember = '/add-family-member';

  // Emergency routes
  static const String emergencyContacts = '/emergency-contacts';

  // Health routes
  static const String health = '/health';

  // Search routes
  static const String search = '/search';

  // Notifications routes
  static const String notifications = '/notifications';

  // Chat routes
  static const String chat = '/chat';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth routes
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: args?['email'] ?? '',
          ),
        );
      case emailVerification:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(email: email),
        );

      // Main routes
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // Doctors routes
      case doctors:
        return MaterialPageRoute(builder: (_) => const DoctorsScreen());
      case doctorDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DoctorDetailScreen(
            id: args?['id'] ?? 0,
            name: args?['name'] ?? 'Médecin',
            specialty: args?['specialty'] ?? '',
            rating: args?['rating'] ?? 4.5,
            reviews: args?['reviews'] ?? 0,
            price: args?['price'] ?? '0 FCFA',
            available: args?['available'] ?? true,
            initials: args?['initials'] ?? 'MD',
            color: args?['color'] ?? AppColors.primary,
            experience: args?['experience'] ?? '5 ans',
          ),
        );
      case doctorReviews:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DoctorReviewsScreen(
            doctorId: args?['doctorId'] ?? 0,
            doctorName: args?['doctorName'] ?? 'Médecin',
          ),
        );
      case favoriteDoctors:
        return MaterialPageRoute(builder: (_) => const FavoriteDoctorsScreen());

      // Appointments routes
      case appointments:
        return MaterialPageRoute(builder: (_) => const AppointmentsScreen());
      case appointmentDetail:
        return MaterialPageRoute(builder: (_) => const AppointmentDetailScreen());

      // Booking routes
      case bookingFlow:
        return MaterialPageRoute(builder: (_) => const BookingFlowScreen());
      case bookingSuccess:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(
            doctorName: args?['doctorName'] ?? 'Médecin',
            specialty: args?['specialty'] ?? '',
            date: args?['date'] ?? DateTime.now(),
            time: args?['time'] ?? '10:00',
            location: args?['location'] ?? '',
            consultType: args?['consultType'] ?? 'Consultation',
            bookingRef: args?['bookingRef'] ?? '',
            initials: args?['initials'] ?? 'MD',
            color: args?['color'] ?? AppColors.primary,
            motif: args?['motif'] ?? '',
          ),
        );

      // Profile routes
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case notificationSettings:
        return MaterialPageRoute(builder: (_) => const NotificationSettingsScreen());

      // Medical routes
      case medicalRecord:
        return MaterialPageRoute(builder: (_) => const MedicalRecordScreen());
      case prescriptionsList:
        return MaterialPageRoute(builder: (_) => const PrescriptionsListScreen());
      case prescriptionDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PrescriptionDetailScreen(
            prescriptionId: args?['prescriptionId'] ?? '',
            doctorName: args?['doctorName'] ?? 'Médecin',
            date: args?['date'] ?? DateTime.now(),
            specialty: args?['specialty'] ?? '',
            color: args?['color'] ?? AppColors.primary,
          ),
        );
      case labResults:
        return MaterialPageRoute(builder: (_) => const LabResultsScreen());
      case vaccination:
        return MaterialPageRoute(builder: (_) => const VaccinationScreen());

      // Payment routes
      case paymentMethods:
        return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());
      case payment:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            amount: args?['amount'] ?? 0.0,
            description: args?['description'] ?? '',
            doctorName: args?['doctorName'] ?? 'Médecin',
          ),
        );
      case paymentHistory:
        return MaterialPageRoute(builder: (_) => const PaymentHistoryScreen());
      case invoice:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => InvoiceScreen(
            invoiceNumber: args?['invoiceNumber'] ?? '',
            amount: args?['amount'] ?? 0.0,
            date: args?['date'] ?? DateTime.now(),
            doctorName: args?['doctorName'] ?? 'Médecin',
            description: args?['description'] ?? '',
          ),
        );

      // Map routes
      case mapView:
        return MaterialPageRoute(builder: (_) => const MapViewScreen());
      case hospitalLocator:
        return MaterialPageRoute(builder: (_) => const HospitalLocatorScreen());

      // Support routes
      case chatSupport:
        return MaterialPageRoute(builder: (_) => const ChatSupportScreen());
      case faq:
        return MaterialPageRoute(builder: (_) => const FaqScreen());
      case contactSupport:
        return MaterialPageRoute(builder: (_) => const ContactSupportScreen());

      // Family routes
      case familyMembers:
        return MaterialPageRoute(builder: (_) => const FamilyMembersScreen());
      case addFamilyMember:
        return MaterialPageRoute(builder: (_) => const AddFamilyMemberScreen());

      // Emergency routes
      case emergencyContacts:
        return MaterialPageRoute(builder: (_) => const EmergencyContactsScreen());

      // Health routes
      case health:
        return MaterialPageRoute(builder: (_) => const HealthDashboardScreen());

      // Search routes
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      // Notifications routes
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      // Chat routes
      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            doctorName: args?['doctorName'] ?? 'Médecin',
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route non trouvée: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
