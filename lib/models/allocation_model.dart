enum SectorType { living, payDebt, emergency, investment }

enum SubSectorType { essentials, dreamFund, lowRisk, mediumRisk, highRisk }

class AllocationModel {
  final int walletId;
  final SectorType sector;
  final SubSectorType? subSector;
  BigInt amount;

  AllocationModel({
    required this.walletId,
    required this.amount,
    required this.sector,
    this.subSector,
  });

  void income(BigInt income) {
    amount += income;
  }

  void expense(BigInt expense) {
    amount -= expense;
  }

  Map<String, dynamic> toJson() {
    return {
      "wallet_id": walletId,
      "amount": amount.toString(),
      "sector": sector.name,
      "sub_sector": subSector?.name,
    };
  }

  factory AllocationModel.fromJson(Map<String, dynamic> json) {
    return AllocationModel(
      walletId: json['wallet_id'],
      amount: BigInt.parse(json['amount']),
      sector: SectorType.values.firstWhere(
        (e) => e.name == json['sector'],
        orElse: () => SectorType.living,
      ),

      subSector: json['sub_sector'] != null
          ? SubSectorType.values.firstWhere(
              (e) => e.name == json['sub_sector'],
              orElse: () => SubSectorType.essentials,
            )
          : null,
    );
  }
}
