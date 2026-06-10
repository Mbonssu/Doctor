import 'package:flutter/material.dart';
import 'app_routes.dart';

class NavigationHelper {
  // Navigation simple
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  // Navigation avec remplacement
  static Future<T?> navigateAndReplace<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, void>(context, routeName, arguments: arguments);
  }

  // Navigation avec suppression de toutes les routes précédentes
  static Future<T?> navigateAndRemoveUntil<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // Retour
  static void goBack<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  // Retour jusqu'à une route spécifique
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  // Vérifier si on peut revenir en arrière
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  // Routes spécifiques pour faciliter l'utilisation

  // Auth
  static Future<void> goToLogin(BuildContext context) {
    return navigateTo(context, AppRoutes.login);
  }

  static Future<void> goToRegister(BuildContext context) {
    return navigateTo(context, AppRoutes.register);
  }

  static Future<void> goToForgotPassword(BuildContext context) {
    return navigateTo(context, AppRoutes.forgotPassword);
  }

  static Future<void> goToResetPassword(BuildContext context, {required String email, required String code}) {
    return navigateTo(context, AppRoutes.resetPassword, arguments: {'email': email, 'code': code});
  }

  static Future<void> goToEmailVerification(BuildContext context, {required String email}) {
    return navigateTo(context, AppRoutes.emailVerification, arguments: email);
  }

  // Main
  static Future<void> goToMain(BuildContext context, {bool clearStack = false}) {
    if (clearStack) {
      return navigateAndRemoveUntil(context, AppRoutes.main);
    }
    return navigateTo(context, AppRoutes.main);
  }

  // Doctors
  static Future<void> goToDoctorDetail(BuildContext context, {Map<String, dynamic>? arguments}) {
    return navigateTo(context, AppRoutes.doctorDetail, arguments: arguments);
  }

  static Future<void> goToDoctorReviews(BuildContext context) {
    return navigateTo(context, AppRoutes.doctorReviews);
  }

  static Future<void> goToFavoriteDoctors(BuildContext context) {
    return navigateTo(context, AppRoutes.favoriteDoctors);
  }

  // Appointments
  static Future<void> goToAppointmentDetail(BuildContext context) {
    return navigateTo(context, AppRoutes.appointmentDetail);
  }

  // Booking
  static Future<void> goToBookingFlow(BuildContext context) {
    return navigateTo(context, AppRoutes.bookingFlow);
  }

  static Future<void> goToBookingSuccess(BuildContext context) {
    return navigateTo(context, AppRoutes.bookingSuccess);
  }

  // Profile
  static Future<void> goToChangePassword(BuildContext context) {
    return navigateTo(context, AppRoutes.changePassword);
  }

  static Future<void> goToNotificationSettings(BuildContext context) {
    return navigateTo(context, AppRoutes.notificationSettings);
  }

  // Medical
  static Future<void> goToMedicalRecord(BuildContext context) {
    return navigateTo(context, AppRoutes.medicalRecord);
  }

  static Future<void> goToPrescriptionsList(BuildContext context) {
    return navigateTo(context, AppRoutes.prescriptionsList);
  }

  static Future<void> goToPrescriptionDetail(BuildContext context) {
    return navigateTo(context, AppRoutes.prescriptionDetail);
  }

  static Future<void> goToLabResults(BuildContext context) {
    return navigateTo(context, AppRoutes.labResults);
  }

  static Future<void> goToVaccination(BuildContext context) {
    return navigateTo(context, AppRoutes.vaccination);
  }

  // Payment
  static Future<void> goToPaymentMethods(BuildContext context) {
    return navigateTo(context, AppRoutes.paymentMethods);
  }

  static Future<void> goToPayment(BuildContext context) {
    return navigateTo(context, AppRoutes.payment);
  }

  static Future<void> goToPaymentHistory(BuildContext context) {
    return navigateTo(context, AppRoutes.paymentHistory);
  }

  static Future<void> goToInvoice(BuildContext context) {
    return navigateTo(context, AppRoutes.invoice);
  }

  // Map
  static Future<void> goToMapView(BuildContext context) {
    return navigateTo(context, AppRoutes.mapView);
  }

  static Future<void> goToHospitalLocator(BuildContext context) {
    return navigateTo(context, AppRoutes.hospitalLocator);
  }

  // Support
  static Future<void> goToChatSupport(BuildContext context) {
    return navigateTo(context, AppRoutes.chatSupport);
  }

  static Future<void> goToFaq(BuildContext context) {
    return navigateTo(context, AppRoutes.faq);
  }

  static Future<void> goToContactSupport(BuildContext context) {
    return navigateTo(context, AppRoutes.contactSupport);
  }

  // Family
  static Future<void> goToFamilyMembers(BuildContext context) {
    return navigateTo(context, AppRoutes.familyMembers);
  }

  static Future<void> goToAddFamilyMember(BuildContext context) {
    return navigateTo(context, AppRoutes.addFamilyMember);
  }

  // Emergency
  static Future<void> goToEmergencyContacts(BuildContext context) {
    return navigateTo(context, AppRoutes.emergencyContacts);
  }

  // Health
  static Future<void> goToHealth(BuildContext context) {
    return navigateTo(context, AppRoutes.health);
  }

  // Search
  static Future<void> goToSearch(BuildContext context) {
    return navigateTo(context, AppRoutes.search);
  }

  // Notifications
  static Future<void> goToNotifications(BuildContext context) {
    return navigateTo(context, AppRoutes.notifications);
  }

  // Chat
  static Future<void> goToChat(BuildContext context, {required String doctorName, required String doctorId}) {
    return navigateTo(context, AppRoutes.chat, arguments: {'doctorName': doctorName, 'doctorId': doctorId});
  }

  // Splash & onboarding
  static Future<void> goToSplash(BuildContext context) {
    return navigateAndRemoveUntil(context, AppRoutes.splash);
  }

  static Future<void> goToOnboarding(BuildContext context) {
    return navigateAndRemoveUntil(context, AppRoutes.onboarding);
  }

  // Doctor role (interface médecin)
  static Future<void> goToDoctorMain(BuildContext context, {bool clearStack = false}) {
    if (clearStack) return navigateAndRemoveUntil(context, AppRoutes.doctorMain);
    return navigateTo(context, AppRoutes.doctorMain);
  }

  static Future<void> goToDoctorDashboard(BuildContext context) {
    return navigateTo(context, AppRoutes.doctorDashboard);
  }

  static Future<void> goToDoctorProfile(BuildContext context) {
    return navigateTo(context, AppRoutes.doctorProfile);
  }

  static Future<void> goToDoctorSchedule(BuildContext context) {
    return navigateTo(context, AppRoutes.doctorSchedule);
  }

  static Future<void> goToDoctorAppointments(BuildContext context) {
    return navigateTo(context, AppRoutes.doctorAppointments);
  }

  // Debug
  static Future<void> goToConnectionTest(BuildContext context) {
    return navigateTo(context, AppRoutes.connectionTest);
  }
}
