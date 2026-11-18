// Mesin pencocokan dan ekstraksi field dari notifikasi.
// Logika dipisah dari data template (NotificationTemplate).
// JANGAN log teks mentah notifikasi.

import '../parsers/notification_parser.dart';
import 'templates/notification_template.dart';

/// Hasil pencocokan template terhadap satu notifikasi.
class TemplateMatchResult {
  final bool matched;
  final NotificationExtract? extract;

  const TemplateMatchResult.noMatch() : matched = false, extract = null;
  const TemplateMatchResult.match(NotificationExtract this.extract) : matched = true;
}

class NotificationTemplateEngine {
  final List<NotificationTemplate> _templates;

  /// Pola nomor rekening/kartu — deret 10 digit atau lebih, dibuang sebelum kirim.
  static final _accountNumberPattern = RegExp(r'\d{10,}');

  const NotificationTemplateEngine(this._templates);

  /// Mencoba mencocokkan [packageName] ke template yang terdaftar.
  /// Mengembalikan null jika tidak ada template untuk package ini.
  NotificationTemplate? findTemplate(String packageName) {
    try {
      return _templates.firstWhere((t) => t.packageName == packageName);
    } catch (_) {
      return null;
    }
  }

  /// Mencocokkan notifikasi dengan template dan mengekstrak field.
  /// [text] adalah gabungan title+body notifikasi — TIDAK dicatat di log.
  /// Mengembalikan [TemplateMatchResult.noMatch] jika tidak ada template,
  /// notifikasi adalah promo, ambigu, atau ekstraksi amount gagal.
  TemplateMatchResult process({
    required String packageName,
    required String text,
    required DateTime occurredAt,
  }) {
    final template = findTemplate(packageName);
    if (template == null) return const TemplateMatchResult.noMatch();

    // Cek pola promo — jika cocok, buang diam-diam
    for (final promoPattern in template.promoExclusionPatterns) {
      if (promoPattern.hasMatch(text)) return const TemplateMatchResult.noMatch();
    }

    // Cek pola transaksi — minimal satu harus cocok
    final isTransaction = template.transactionPatterns.any((p) => p.hasMatch(text));
    if (!isTransaction) return const TemplateMatchResult.noMatch();

    // Ekstraksi field
    final fields = _extractFields(template.extractionRules, text);

    // amount wajib ada dan valid
    final rawAmount = fields['amount'];
    if (rawAmount == null) return const TemplateMatchResult.noMatch();
    final amount = _parseAmount(rawAmount);
    if (amount == null || amount <= 0) return const TemplateMatchResult.noMatch();

    // Tentukan direction
    final rawDirection = fields['direction'];
    final direction = _normalizeDirection(rawDirection);

    // Merchant — buang nomor rekening/kartu jika ada
    final rawMerchant = fields['merchant'];
    final merchant = rawMerchant != null
        ? _sanitizeAccountNumbers(rawMerchant)
        : null;

    return TemplateMatchResult.match(
      NotificationExtract(
        sourceApp: packageName,
        amount: amount,
        occurredAt: occurredAt,
        direction: direction,
        merchant: merchant?.isEmpty == true ? null : merchant,
      ),
    );
  }

  Map<String, String> _extractFields(
    List<ExtractionRule> rules,
    String text,
  ) {
    final result = <String, String>{};
    for (final rule in rules) {
      final match = rule.pattern.firstMatch(text);
      if (match != null && match.groupCount >= rule.groupIndex) {
        final value = match.group(rule.groupIndex)?.trim();
        if (value != null && value.isNotEmpty) {
          result[rule.field] = value;
        }
      }
    }
    return result;
  }

  int? _parseAmount(String raw) {
    // Hapus titik/koma ribuan lalu parse
    final cleaned = raw.replaceAll(RegExp(r'[.,]'), '');
    return int.tryParse(cleaned);
  }

  String? _normalizeDirection(String? raw) {
    if (raw == null) return null;
    final lower = raw.toLowerCase();
    if (RegExp(r'masuk|diterima|top.?up|kredit|income').hasMatch(lower)) {
      return 'in';
    }
    if (RegExp(r'keluar|dikirim|bayar|pembayaran|debit|kirim').hasMatch(lower)) {
      return 'out';
    }
    return null;
  }

  /// Membuang deret angka 10 digit atau lebih (nomor rekening/kartu).
  String _sanitizeAccountNumbers(String input) {
    return input.replaceAll(_accountNumberPattern, '***');
  }
}
