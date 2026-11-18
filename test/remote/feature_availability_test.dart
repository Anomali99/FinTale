// Tes unit FeatureAvailabilityService — matriks status fitur online.
// URL di-inject langsung via konstruktor; tidak membutuhkan dotenv.

import 'package:flutter_test/flutter_test.dart';
import 'package:fintale/remote/auth/auth_token_provider.dart';
import 'package:fintale/remote/enums/online_feature.dart';
import 'package:fintale/remote/services/feature_availability_service.dart';

void main() {
  group('FeatureAvailabilityService — noServer (baseUrlOverride: null)', () {
    test('semua fitur noServer jika baseUrl null', () async {
      final service = FeatureAvailabilityService(
        tokenProvider: const StubAuthTokenProvider(),
        baseUrlOverride: null,
      );
      final statuses = await service.getStatuses();

      for (final feature in OnlineFeature.values) {
        expect(statuses[feature], FeatureStatus.noServer,
            reason: '$feature harus noServer');
      }
    });

    test('getStatus mengembalikan noServer jika baseUrl null', () async {
      final service = FeatureAvailabilityService(
        tokenProvider: const StubAuthTokenProvider(),
        baseUrlOverride: null,
      );
      final status = await service.getStatus(OnlineFeature.receipt);
      expect(status, FeatureStatus.noServer);
    });

    test('semua fitur noServer untuk voice jika baseUrl null', () async {
      final service = FeatureAvailabilityService(
        tokenProvider: const StubAuthTokenProvider(),
        baseUrlOverride: null,
      );
      expect(
        await service.getStatus(OnlineFeature.voice),
        FeatureStatus.noServer,
      );
    });

    test('semua fitur noServer untuk notification jika baseUrl null', () async {
      final service = FeatureAvailabilityService(
        tokenProvider: const StubAuthTokenProvider(),
        baseUrlOverride: null,
      );
      expect(
        await service.getStatus(OnlineFeature.notification),
        FeatureStatus.noServer,
      );
    });
  });
}
