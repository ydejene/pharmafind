import '../../data/models/user_model.dart';

class ProfileCompletion {
  ProfileCompletion._();

  static double percentage(UserModel user) {
    int filled = 0;
    int total = 5;

    if (user.displayName.isNotEmpty) filled++;
    if (user.email.isNotEmpty) filled++;
    if (user.phone != null && user.phone!.isNotEmpty) filled++;
    if (user.insuranceProvider != null && user.insuranceProvider!.isNotEmpty) {
      filled++;
    }
    if (user.insuranceId != null && user.insuranceId!.isNotEmpty) filled++;

    return filled / total;
  }

  static List<String> missingFields(UserModel user, String locale) {
    final missing = <String>[];

    if (user.displayName.isEmpty) missing.add('display_name');
    if (user.email.isEmpty) missing.add('email');
    if (user.phone == null || user.phone!.isEmpty) missing.add('phone');
    if (user.insuranceProvider == null || user.insuranceProvider!.isEmpty) {
      missing.add('insurance_provider');
    }
    if (user.insuranceId == null || user.insuranceId!.isEmpty) {
      missing.add('insurance_id');
    }

    return missing;
  }

  static bool isComplete(UserModel user) => percentage(user) >= 1.0;
}
