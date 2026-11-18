// Service status ketersediaan fitur online FinTale.
// Urutan cek: noServer -> offline -> notSubscribed -> available.
// Entitlement di-cache singkat di memori (TTL 5 menit) dan disegarkan saat app aktif kembali.
// Saat offline atau noServer, seluruh fitur online dinonaktifkan.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../auth/auth_token_provider.dart';
import '../config/app_config.dart';
import '../enums/online_feature.dart';
import '../exceptions/api_exception.dart';

class FeatureAvailabilityService extends ChangeNotifier {
  final AuthTokenProvider _tokenProvider;
  /// URL yang di-override dari luar — dipakai di tes agar tidak bergantung pada dotenv.
  final String? _baseUrlOverride;
  ApiClient? _apiClient;

  // Cache entitlement
  Map<OnlineFeature, FeatureStatus>? _cachedStatuses;
  DateTime? _cacheTime;
  static const _cacheTtl = Duration(minutes: 5);

  FeatureAvailabilityService({
    required AuthTokenProvider tokenProvider,
    /// Hanya untuk pengujian — isi URL secara langsung tanpa membaca dotenv.
    String? baseUrlOverride,
  }) : _tokenProvider = tokenProvider,
       _baseUrlOverride = baseUrlOverride {
    _buildClientIfNeeded();
  }

  String? get _effectiveBaseUrl => _baseUrlOverride ?? AppConfig.apiBaseUrl;

  void _buildClientIfNeeded() {
    final baseUrl = _effectiveBaseUrl;
    if (baseUrl != null) {
      _apiClient = ApiClient(baseUrl: baseUrl, tokenProvider: _tokenProvider);
    }
  }

  /// Status semua fitur online. Memanggil server jika cache kadaluarsa.
  Future<Map<OnlineFeature, FeatureStatus>> getStatuses() async {
    // Jika cache masih segar, kembalikan langsung
    if (_cachedStatuses != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < _cacheTtl) {
        return Map.unmodifiable(_cachedStatuses!);
      }
    }
    return _fetchAndCache();
  }

  /// Status satu fitur spesifik.
  Future<FeatureStatus> getStatus(OnlineFeature feature) async {
    final all = await getStatuses();
    return all[feature] ?? FeatureStatus.noServer;
  }

  /// Dipanggil saat aplikasi kembali aktif (AppLifecycleState.resumed).
  /// Menghapus cache dan memperbarui status.
  Future<void> refreshOnResume() async {
    _invalidateCache();
    await _fetchAndCache();
    notifyListeners();
  }

  void _invalidateCache() {
    _cachedStatuses = null;
    _cacheTime = null;
  }

  Future<Map<OnlineFeature, FeatureStatus>> _fetchAndCache() async {
    final statuses = await _computeStatuses();
    _cachedStatuses = statuses;
    _cacheTime = DateTime.now();
    notifyListeners();
    return Map.unmodifiable(statuses);
  }

  Future<Map<OnlineFeature, FeatureStatus>> _computeStatuses() async {
    // Langkah 1: cek konfigurasi server
    if (_effectiveBaseUrl == null) {
      return _allStatuses(FeatureStatus.noServer);
    }

    // Langkah 2: cek koneksi internet
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none) ||
        connectivity.isEmpty) {
      return _allStatuses(FeatureStatus.offline);
    }

    // Langkah 3: cek keterjangkauan server dan entitlement
    try {
      final client = _apiClient;
      if (client == null) return _allStatuses(FeatureStatus.noServer);

      final response = await client.get('/v1/entitlement');
      final subscribed = response['subscribed'] as bool? ?? false;
      if (!subscribed) {
        return _allStatuses(FeatureStatus.notSubscribed);
      }

      // Periksa fitur mana saja yang diaktifkan oleh server
      final enabledFeatures =
          (response['features'] as List<dynamic>?)?.cast<String>() ?? [];

      return {
        OnlineFeature.receipt: enabledFeatures.contains('receipt')
            ? FeatureStatus.available
            : FeatureStatus.notSubscribed,
        OnlineFeature.voice: enabledFeatures.contains('voice')
            ? FeatureStatus.available
            : FeatureStatus.notSubscribed,
        OnlineFeature.notification: enabledFeatures.contains('notification')
            ? FeatureStatus.available
            : FeatureStatus.notSubscribed,
      };
    } on NotSubscribedException {
      return _allStatuses(FeatureStatus.notSubscribed);
    } on ApiException {
      return _allStatuses(FeatureStatus.offline);
    } catch (_) {
      // Gagal terhubung ke server (timeout, DNS error, dll)
      return _allStatuses(FeatureStatus.offline);
    }
  }

  static Map<OnlineFeature, FeatureStatus> _allStatuses(FeatureStatus status) {
    return {
      OnlineFeature.receipt: status,
      OnlineFeature.voice: status,
      OnlineFeature.notification: status,
    };
  }
}
