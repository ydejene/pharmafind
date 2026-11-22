/// Application configuration constants for external services.
///
/// NOTE: For the project demonstration, Cloudinary uploads use an unsigned
/// preset with public delivery. Document URLs are accessible to anyone with the URL.
/// Test documents (not real licences or ID) should be used during evaluation.
class AppConfig {
  AppConfig._();

  /// Cloudinary cloud name for partner document verification.
  static const String cloudinaryCloudName = 'dvod3pvz';

  /// Unsigned upload preset configured in Cloudinary.
  static const String cloudinaryUploadPreset = 'pharmafind_partner_documents';

  /// Target folder in Cloudinary for verification documents.
  static const String cloudinaryUploadFolder = 'pharmafind/partner-verification';
}
