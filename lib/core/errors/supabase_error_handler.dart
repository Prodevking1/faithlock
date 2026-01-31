// import 'package:faithlock/core/errors/custom_exception_impl.dart';
// import 'package:get/get.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SupabaseErrorHandler {
//   static CustomException handleException(dynamic error) {
//     if (error is AuthException) {
//       return CustomException(_handleAuthException(error));
//     } else if (error is PostgrestException) {
//       return CustomException(_handlePostgrestException(error));
//     } else {
//       return CustomException('unexpectedErrorOccurred'.tr);
//     }
//   }

//   static String _handleAuthException(AuthException error) {
//     print(error);
//     switch (error.code) {
//       case 'anonymous_provider_disabled':
//         return 'anonymousProviderDisabled'.tr;
//       case 'bad_code_verifier':
//         return 'badCodeVerifier'.tr;
//       case 'bad_json':
//         return 'badJson'.tr;
//       case 'bad_jwt':
//         return 'badJwt'.tr;
//       case 'bad_oauth_callback':
//       case 'bad_oauth_state':
//         return 'badOauthCallback'.tr;
//       case 'captcha_failed':
//         return 'captchaFailed'.tr;
//       case 'conflict':
//         return 'conflict'.tr;
//       case 'email_address_not_authorized':
//         return 'emailAddressNotAuthorized'.tr;
//       case 'email_conflict_identity_not_deletable':
//         return 'emailConflictIdentityNotDeletable'.tr;
//       case 'email_exists':
//         return 'emailExists'.tr;
//       case 'email_not_confirmed':
//         return 'emailNotConfirmed'.tr;
//       case 'email_provider_disabled':
//         return 'emailProviderDisabled'.tr;
//       case 'flow_state_expired':
//       case 'flow_state_not_found':
//         return 'flowStateExpired'.tr;
//       case 'hook_payload_over_size_limit':
//       case 'hook_timeout':
//       case 'hook_timeout_after_retry':
//         return 'hookTimeout'.tr;
//       case 'identity_already_exists':
//         return 'identityAlreadyExists'.tr;
//       case 'identity_not_found':
//         return 'identityNotFound'.tr;
//       case 'insufficient_aal':
//         return 'insufficientAal'.tr;
//       case 'invite_not_found':
//         return 'inviteNotFound'.tr;
//       case 'invalid_credentials':
//         return 'invalidCredentials'.tr;
//       case 'manual_linking_disabled':
//         return 'manualLinkingDisabled'.tr;
//       case 'mfa_challenge_expired':
//         return 'mfaChallengeExpired'.tr;
//       case 'mfa_factor_name_conflict':
//         return 'mfaFactorNameConflict'.tr;
//       case 'mfa_factor_not_found':
//         return 'mfaFactorNotFound'.tr;
//       case 'mfa_ip_address_mismatch':
//         return 'mfaIpAddressMismatch'.tr;
//       case 'mfa_verification_failed':
//         return 'mfaVerificationFailed'.tr;
//       case 'mfa_verification_rejected':
//         return 'mfaVerificationRejected'.tr;
//       case 'mfa_verified_factor_exists':
//         return 'mfaVerifiedFactorExists'.tr;
//       case 'mfa_totp_enroll_disabled':
//         return 'mfaTotpEnrollDisabled'.tr;
//       case 'mfa_totp_verify_disabled':
//         return 'mfaTotpVerifyDisabled'.tr;
//       case 'mfa_phone_enroll_disabled':
//         return 'mfaPhoneEnrollDisabled'.tr;
//       case 'mfa_phone_verify_disabled':
//         return 'mfaPhoneVerifyDisabled'.tr;
//       case 'no_authorization':
//         return 'noAuthorization'.tr;
//       case 'not_admin':
//         return 'notAdmin'.tr;
//       case 'oauth_provider_not_supported':
//         return 'oauthProviderNotSupported'.tr;
//       case 'otp_disabled':
//         return 'otpDisabled'.tr;
//       case 'otp_expired':
//         return 'otpExpired'.tr;
//       case 'over_email_send_rate_limit':
//         return 'overEmailSendRateLimit'.tr;
//       case 'over_request_rate_limit':
//         return 'overRequestRateLimit'.tr;
//       case 'over_sms_send_rate_limit':
//         return 'overSmsSendRateLimit'.tr;
//       case 'phone_exists':
//         return 'phoneExists'.tr;
//       case 'phone_not_confirmed':
//         return 'phoneNotConfirmed'.tr;
//       case 'phone_provider_disabled':
//         return 'phoneProviderDisabled'.tr;
//       case 'provider_disabled':
//         return 'providerDisabled'.tr;
//       case 'provider_email_needs_verification':
//         return 'providerEmailNeedsVerification'.tr;
//       case 'reauthentication_needed':
//         return 'reauthenticationNeeded'.tr;
//       case 'reauthentication_not_valid':
//         return 'reauthenticationNotValid'.tr;
//       case 'request_timeout':
//         return 'requestTimeout'.tr;
//       case 'same_password':
//         return 'samePassword'.tr;
//       case 'saml_assertion_no_email':
//       case 'saml_assertion_no_user_id':
//       case 'saml_entity_id_mismatch':
//       case 'saml_idp_already_exists':
//       case 'saml_idp_not_found':
//       case 'saml_metadata_fetch_failed':
//       case 'saml_provider_disabled':
//       case 'saml_relay_state_expired':
//       case 'saml_relay_state_not_found':
//         return 'samlError'.tr;
//       case 'session_not_found':
//         return 'sessionNotFound'.tr;
//       case 'signup_disabled':
//         return 'signupDisabled'.tr;
//       case 'single_identity_not_deletable':
//         return 'singleIdentityNotDeletable'.tr;
//       case 'sms_send_failed':
//         return 'smsSendFailed'.tr;
//       case 'sso_domain_already_exists':
//         return 'ssoDomainAlreadyExists'.tr;
//       case 'sso_provider_not_found':
//         return 'ssoProviderNotFound'.tr;
//       case 'too_many_enrolled_mfa_factors':
//         return 'tooManyEnrolledMfaFactors'.tr;
//       case 'unexpected_audience':
//         return 'unexpectedAudience'.tr;
//       case 'unexpected_failure':
//         return 'unexpectedFailure'.tr;
//       case 'user_already_exists':
//         return 'userAlreadyExists'.tr;
//       case 'user_banned':
//         return 'userBanned'.tr;
//       case 'user_not_found':
//         return 'userNotFound'.tr;
//       case 'user_sso_managed':
//         return 'userSsoManaged'.tr;
//       case 'validation_failed':
//         return 'validationFailed'.tr;
//       case 'weak_password':
//         return 'weakPassword'.tr;
//       default:
//         return 'authenticationError'.tr;
//     }
//   }

//   static String _handlePostgrestException(PostgrestException error) {
//     switch (error.code) {
//       case '23505':
//         return 'duplicateRecord'.tr;
//       case '23503': // foreign_key_violation
//         return 'foreignKeyViolation'.tr;
//       case '42P01':
//         return 'resourceNotFound'.tr;
//       case '42501':
//         return 'insufficientPermissions'.tr;
//       default:
//         return 'databaseError'.tr;
//     }
//   }
// }
