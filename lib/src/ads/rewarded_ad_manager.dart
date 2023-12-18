import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdManager {
  late RewardedAd _rewardedAd;
  bool _isRewardedAdLoaded = false;

  final void Function(int rewardAmount) onReward;

  RewardedAdManager({required this.onReward});

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId:
          'ca-app-pub-2117177152504343/3173112185', // Replace with your ad unit ID
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _isRewardedAdLoaded = true;
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showRewardedAd() {
    if (!_isRewardedAdLoaded) {
      print('The rewarded ad isn\'t loaded yet.');
      return;
    }
    _rewardedAd.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onReward(10);
    });
    _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (AdWithoutView ad) {
        ad.dispose();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (AdWithoutView ad, AdError error) {
        print('Failed to show the rewarded ad: $error');
        ad.dispose();
        loadRewardedAd();
      },
    );
  }

  void dispose() {
    _rewardedAd.dispose();
  }
}
