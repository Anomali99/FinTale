import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/category_model.dart';
import '../models/icon_model.dart';
import '../models/term_model.dart';

class InvestDict {
  static const String claim = 'Klaim';
  static const String asset = 'Pilih Aset';
  static const String risk = 'Tingkat Risiko';
  static const String unit = 'Satuan';
  static const String newAsset = 'Aset Baru';
  static const String addModal = 'Tambah Modal';
  static const String updateAsset = 'Perbarui Data Aset';
  static const String updatePrice = 'Perbarui Harga Pasar';
  static const String totalDeviden = 'Total Deviden';
  static const String buyOrAddModal = 'Beli Lagi (Tambah Modal)';
  static const String claimDeviden = 'Klaim Dividen / Bunga';
  static const String buyNewAsset = 'Beli Aset Baru';
  static const String addInvestModal = 'Tambah Modal Investasi';
  static const String requiredAsset = 'Silakan pilih aset ynag akan ditambah.';
  static const String requiredRisk = 'Silakan pilih tingkat risiko.';
  static const String requiredUnit = 'Satuan tidak boleh kosong.';
  static const String requiredTotalDeviden =
      'Total dividen tidak boleh kosong.';
  static const String devidenCheck = 'Aset Menghasilkan Dividen/Bunga?';
  static const String devidenCheckDesc =
      'Aktifkan jika instrumen ini memberikan imbal hasil rutin (seperti dividen saham atau kupon obligasi) yang nantinya dapat Anda klaim ke dompet.';
  static const String updateDesc =
      'Memperbarui Total Harga Pasar tidak akan mengubah catatan modal awal (Invested) yang sudah Anda keluarkan. Ini murni untuk memantau nilai aset Anda saat ini.';
  static const String devidenDesc =
      'Klaim dividen akan langsung ditambahkan sebagai saldo (Pemasukan) ke dompet pilihan Anda tanpa mengubah nilai buku investasi awal Anda.';

  static const TermModel total = TermModel(
    normal: 'Total Portofolio',
    rpg: 'Total Kekuatan Pasukan',
  );

  static const TermModel invested = TermModel(
    normal: 'Modal Diinvestasikan',
    rpg: 'Gold Dikerahkan',
  );

  static const TermModel value = TermModel(
    normal: 'Nilai Saat Ini',
    rpg: 'Power Saat Ini',
  );

  static const TermModel empty = TermModel(
    normal: 'Belum ada aset di sini.\nTambah sekarang!',
    rpg: 'Belum ada pasukan di divisi ini.\nRekrut sekarang!',
  );

  static const CategoryModel add = CategoryModel(
    terminology: TermModel(normal: 'Tambah Aset', rpg: 'Rekrut Pasukan'),
    icons: IconModel(
      normal: FontAwesomeIcons.folderPlus,
      rpg: FontAwesomeIcons.flag,
    ),
  );

  static String generatePricePerUnit(String unitName) =>
      'Harga Beli per $unitName';

  static String generateDevidenPerUnit(String unitName) =>
      'Dividen per $unitName';

  static String generateNote(String name, String amount) =>
      'Sisa saldo **$name** yang belum dialokasikan adalah **$amount**. Pembelian investasi ini akan memotong saldo tersebut.';
}
