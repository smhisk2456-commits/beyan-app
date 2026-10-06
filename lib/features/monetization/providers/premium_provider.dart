import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/premium_product.dart';
import '../services/premium_service.dart';

class PremiumState {
  final bool isPremium;
  final PremiumTier? activeTier;
  final bool isLoading;

  const PremiumState({
    required this.isPremium,
    this.activeTier,
    this.isLoading = false,
  });

  PremiumState copyWith({
    bool? isPremium,
    PremiumTier? activeTier,
    bool? isLoading,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      activeTier: activeTier ?? this.activeTier,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  final PremiumService _service;

  PremiumNotifier(this._service)
      : super(PremiumState(
          isPremium: _service.isPremium,
          activeTier: _service.activeTier,
        )) {
    _service.premiumStatusStream.listen((isPrem) {
      state = state.copyWith(
        isPremium: isPrem,
        activeTier: _service.activeTier,
      );
    });
  }

  Future<bool> buyTier(PremiumTier tier) async {
    state = state.copyWith(isLoading: true);
    final success = await _service.buyTier(tier);
    state = state.copyWith(
      isPremium: _service.isPremium,
      activeTier: _service.activeTier,
      isLoading: false,
    );
    return success;
  }

  Future<bool> restorePurchases() async {
    state = state.copyWith(isLoading: true);
    final success = await _service.restorePurchases();
    state = state.copyWith(
      isPremium: _service.isPremium,
      activeTier: _service.activeTier,
      isLoading: false,
    );
    return success;
  }

  Future<void> toggleDevPremium() async {
    await _service.toggleDevPremium();
    state = state.copyWith(
      isPremium: _service.isPremium,
      activeTier: _service.activeTier,
    );
  }
}

final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  return PremiumNotifier(PremiumService.instance);
});
