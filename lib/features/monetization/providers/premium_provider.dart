import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/premium_product.dart';
import '../services/premium_service.dart';

class PremiumState {
  final bool isPremium;
  final PremiumTier? activeTier;
  final bool isLoading;
  final bool isTrialActive;
  final int trialDaysRemaining;
  final bool hasWidgetAccess;

  const PremiumState({
    required this.isPremium,
    this.activeTier,
    this.isLoading = false,
    this.isTrialActive = true,
    this.trialDaysRemaining = 3,
    this.hasWidgetAccess = true,
  });

  PremiumState copyWith({
    bool? isPremium,
    PremiumTier? activeTier,
    bool? isLoading,
    bool? isTrialActive,
    int? trialDaysRemaining,
    bool? hasWidgetAccess,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      activeTier: activeTier ?? this.activeTier,
      isLoading: isLoading ?? this.isLoading,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      trialDaysRemaining: trialDaysRemaining ?? this.trialDaysRemaining,
      hasWidgetAccess: hasWidgetAccess ?? this.hasWidgetAccess,
    );
  }
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  final PremiumService _service;

  PremiumNotifier(this._service)
      : super(PremiumState(
          isPremium: _service.isPremium,
          activeTier: _service.activeTier,
          isTrialActive: _service.isTrialActive,
          trialDaysRemaining: _service.trialDaysRemaining,
          hasWidgetAccess: _service.hasWidgetAccess,
        )) {
    _service.premiumStatusStream.listen((isPrem) {
      state = state.copyWith(
        isPremium: isPrem,
        activeTier: _service.activeTier,
        isTrialActive: _service.isTrialActive,
        trialDaysRemaining: _service.trialDaysRemaining,
        hasWidgetAccess: _service.hasWidgetAccess,
      );
    });
  }

  Future<void> activateFreeTrial() async {
    await _service.activateFreeTrial();
    state = state.copyWith(
      isTrialActive: _service.isTrialActive,
      trialDaysRemaining: _service.trialDaysRemaining,
      hasWidgetAccess: _service.hasWidgetAccess,
    );
  }

  Future<bool> buyTier(PremiumTier tier) async {
    state = state.copyWith(isLoading: true);
    final success = await _service.buyTier(tier);
    state = state.copyWith(
      isPremium: _service.isPremium,
      activeTier: _service.activeTier,
      isTrialActive: _service.isTrialActive,
      trialDaysRemaining: _service.trialDaysRemaining,
      hasWidgetAccess: _service.hasWidgetAccess,
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
      isTrialActive: _service.isTrialActive,
      trialDaysRemaining: _service.trialDaysRemaining,
      hasWidgetAccess: _service.hasWidgetAccess,
      isLoading: false,
    );
    return success;
  }

  Future<void> toggleDevPremium() async {
    await _service.toggleDevPremium();
    state = state.copyWith(
      isPremium: _service.isPremium,
      activeTier: _service.activeTier,
      isTrialActive: _service.isTrialActive,
      trialDaysRemaining: _service.trialDaysRemaining,
      hasWidgetAccess: _service.hasWidgetAccess,
    );
  }
}

final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  return PremiumNotifier(PremiumService.instance);
});
