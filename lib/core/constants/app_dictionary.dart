class TermPair {
  final String normal;
  final String rpg;

  const TermPair({required this.normal, required this.rpg});

  String get(bool isRpgMode) => isRpgMode ? rpg : normal;
}

class AppDictionary {
  static const TermPair balance = TermPair(
    normal: 'Total Saldo',
    rpg: 'Total HP',
  );
  static const TermPair expenseBudget = TermPair(
    normal: 'Alokasi Biaya Hidup',
    rpg: 'Mana / Potion',
  );
  static const TermPair emergencyFund = TermPair(
    normal: 'Dana Darurat',
    rpg: 'Tanker (Pertahanan)',
  );
  static const TermPair income = TermPair(
    normal: 'Pemasukan / Gaji',
    rpg: 'Loot / Drop',
  );

  static const TermPair debt = TermPair(
    normal: 'Daftar Hutang',
    rpg: 'Boss Raid',
  );
  static const TermPair debtRemaining = TermPair(
    normal: 'Sisa Pokok Hutang',
    rpg: 'Darah Boss',
  );
  static const TermPair payDebt = TermPair(
    normal: 'Bayar Hutang',
    rpg: 'Serang Boss',
  );
  static const TermPair monthlyBill = TermPair(
    normal: 'Tagihan Rutin',
    rpg: 'Quest Bulanan',
  );

  static const TermPair investStock = TermPair(
    normal: 'Saham',
    rpg: 'Fighter (Menengah)',
  );
  static const TermPair investCrypto = TermPair(
    normal: 'Crypto',
    rpg: 'Assassin (Berisiko)',
  );
  static const TermPair withdrawInvest = TermPair(
    normal: 'Cairkan Investasi',
    rpg: 'Tactical Retreat',
  );
  static const TermPair takeProfit = TermPair(
    normal: 'Keuntungan Investasi',
    rpg: 'Rare Loot',
  );

  static const TermPair dashboard = TermPair(
    normal: 'Beranda',
    rpg: 'Guild Hall',
  );
  static const TermPair settings = TermPair(
    normal: 'Pengaturan',
    rpg: 'Sistem',
  );
  static const TermPair logout = TermPair(
    normal: 'Keluar',
    rpg: 'Log Out / Retreat',
  );
  static const TermPair dailyLimit = TermPair(
    normal: 'Batas Harian',
    rpg: 'Ransum Harian',
  );
}
