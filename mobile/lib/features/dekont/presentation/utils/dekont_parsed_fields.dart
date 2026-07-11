import 'package:intl/intl.dart';

import '../../../../core/utils/app_intl_locale.dart';

import '../../../../core/utils/iban_utils.dart';
import '../../domain/entities/dekont_entity.dart';
import '../../domain/entities/dekont_status.dart';
class DekontParsedFields {
  DekontParsedFields._();

  static Map<String, dynamic>? _parsedMap(DekontEntity dekont) {
    final raw = dekont.parsedJson;
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  static String? bankCode(DekontEntity dekont) {
    final map = _parsedMap(dekont);
    final fromJson = map?['bankCode']?.toString();
    if (fromJson != null && fromJson.isNotEmpty) return fromJson;
    final profile = dekont.parserProfile?.trim();
    if (profile != null && profile.isNotEmpty && profile != 'OCR_FAILED') {
      return profile;
    }
    return null;
  }

  static String bankDisplayName(dynamic t, String? code) {
    if (code == null || code.isEmpty) return t.bankUnknown as String;
    switch (code.toUpperCase()) {
      case 'KUVEYT_TURK':
        return t.bankKuveytTurk as String;
      case 'ZIRAAT':
        return t.bankZiraat as String;
      case 'ISBANK':
        return t.bankIsbank as String;
      case 'GARANTI':
        return t.bankGaranti as String;
      case 'HALKBANK':
        return t.bankHalkbank as String;
      case 'VAKIFBANK':
        return t.bankVakifbank as String;
      case 'YKB':
        return t.bankYapiKredi as String;
      case 'AKBANK':
        return t.bankAkbank as String;
      case 'QNB':
        return t.bankQnb as String;
      case 'GENERIC_TR':
        return t.bankGeneric as String;
      default:
        return t.bankUnknown as String;
    }
  }

  static String? receiverIban(DekontEntity dekont) {
    final map = _parsedMap(dekont);
    final raw = map?['receiverIban']?.toString();
    if (raw == null || raw.trim().isEmpty) return null;
    final normalized = IbanUtils.normalize(raw);
    return normalized.isEmpty ? null : normalized;
  }

  static String? receiverName(DekontEntity dekont) {
    final map = _parsedMap(dekont);
    final raw = map?['receiverName']?.toString().trim();
    return raw != null && raw.isNotEmpty ? raw : null;
  }

  static String? formattedAmount(DekontEntity dekont) {
    final map = _parsedMap(dekont);
    final amount = map?['amount'];
    if (amount is num) {
      return '${amount.toStringAsFixed(2)} ₺';
    }
    final parsed = dekont.parsedAmount?.trim();
    if (parsed == null || parsed.isEmpty) return null;
    if (parsed.contains('₺') || parsed.toUpperCase().contains('TRY')) {
      return parsed;
    }
    return '$parsed ₺';
  }

  static String? formattedTransactionDate(
    DekontEntity dekont, {
    required String locale,
  }) {
    final date = dekont.transactionDate;
    if (date == null) return null;
    return DateFormat(
      'd MMMM yyyy',
      AppIntlLocale.resolve(locale),
    ).format(date.toLocal());
  }

  static bool isIbanUnreadable(DekontEntity dekont) {
    final iban = receiverIban(dekont);
    if (iban != null && IbanUtils.isValidTrIban(iban)) return false;
    if (dekont.recipientVerified == true) return false;
    return true;
  }

  static bool isIbanVerified(DekontEntity dekont) =>
      dekont.recipientVerified == true;

  static bool isIbanMismatch(DekontEntity dekont) {
    if (isIbanUnreadable(dekont)) return false;
    return dekont.recipientVerified == false ||
        dekont.status == DekontStatus.recipientMismatch;
  }

  static bool hasReadableInsights(DekontEntity dekont) {
    return formattedAmount(dekont) != null ||
        formattedTransactionDate(dekont, locale: 'tr') != null ||
        bankCode(dekont) != null ||
        receiverIban(dekont) != null ||
        dekont.referenceNumber != null;
  }

  static bool isAwaitingPipeline(DekontEntity dekont) =>
      dekont.status.isProcessing ||
      dekont.status == DekontStatus.received ||
      dekont.status == DekontStatus.parsed;
}
