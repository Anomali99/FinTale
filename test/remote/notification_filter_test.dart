// Tes unit NotificationFilter — klasifikasi transaksi vs promo vs ambigu.
// Semua data dalam tes adalah FIKTIF.

import 'package:flutter_test/flutter_test.dart';
import 'package:fintale/remote/notification/notification_filter.dart';

void main() {
  group('NotificationFilter.classify — transaksi (data fiktif)', () {
    test('kata "berhasil" + nominal → likelyTransaction', () {
      const text = 'Pembayaran berhasil Rp 50.000 ke Toko Fiktif';
      expect(
        NotificationFilter.classify(text),
        NotificationClassification.likelyTransaction,
      );
    });

    test('kata "debit" + nominal → likelyTransaction', () {
      const text = 'Debit Rp 125.000 pada rekening fiktif Anda';
      expect(
        NotificationFilter.classify(text),
        NotificationClassification.likelyTransaction,
      );
    });

    test('kata "transfer" + nominal → likelyTransaction', () {
      const text = 'Transfer Rp 200.000 berhasil dikirim';
      expect(
        NotificationFilter.classify(text),
        NotificationClassification.likelyTransaction,
      );
    });

    test('kata "top up" + nominal → likelyTransaction', () {
      const text = 'Top up Rp 100.000 berhasil';
      expect(
        NotificationFilter.classify(text),
        NotificationClassification.likelyTransaction,
      );
    });
  });

  group('NotificationFilter.classify — promo (data fiktif)', () {
    test('kata "promo" tanpa kata transaksi → promo', () {
      const text = 'Promo spesial akhir tahun! Dapatkan hadiah menarik';
      expect(
        NotificationFilter.classify(text),
        NotificationClassification.promo,
      );
    });

    test('kata "diskon" tanpa nominal transaksi → promo', () {
      const text = 'Diskon 50% untuk semua produk hari ini!';
      expect(
        NotificationFilter.classify(text),
        NotificationClassification.promo,
      );
    });

    test('kata "cashback" tanpa kata transaksi → promo', () {
      const text = 'Cashback menanti kamu! Klaim sekarang.';
      expect(
        NotificationFilter.classify(text),
        NotificationClassification.promo,
      );
    });

    test('kata "voucher" saja → promo', () {
      const text = 'Voucher gratis untuk pelanggan setia';
      expect(
        NotificationFilter.classify(text),
        NotificationClassification.promo,
      );
    });
  });

  group('NotificationFilter.classify — ambigu (data fiktif)', () {
    test('teks kosong → ambigu', () {
      expect(
        NotificationFilter.classify(''),
        NotificationClassification.ambiguous,
      );
    });

    test('kata generik tanpa nominal dan tanpa kata transaksi → ambigu', () {
      const text = 'Notifikasi baru dari aplikasi fiktif Anda';
      expect(
        NotificationFilter.classify(text),
        NotificationClassification.ambiguous,
      );
    });

    test('kata transaksi tanpa nominal → ambigu', () {
      const text = 'Pembayaran menunggu konfirmasi Anda';
      expect(
        NotificationFilter.classify(text),
        NotificationClassification.ambiguous,
      );
    });
  });
}
