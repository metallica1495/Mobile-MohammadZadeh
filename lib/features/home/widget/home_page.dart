import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/router/bottom_sheets/bottom_sheets_notifier.dart';
import 'package:hiddify/features/home/widget/connection_button.dart';
import 'package:hiddify/features/home/widget/local_proxy_hint.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/profile/widget/profile_tile.dart';
import 'package:hiddify/features/proxy/active/active_proxy_card.dart';
import 'package:hiddify/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brandRotation = useAnimationController(duration: const Duration(milliseconds: 1500));
    final audioEnabled = useState(true);
    final brandAudioPlayer = useMemoized(AudioPlayer.new);
    useEffect(() {
      brandRotation.forward();
      if (audioEnabled.value) {
        unawaited(brandAudioPlayer.setReleaseMode(ReleaseMode.stop));
        unawaited(brandAudioPlayer.play(
          AssetSource('audio/mobile_sirus_brand_sting.mp3'),
          volume: 0.55,
        ));
      }
      return null;
    }, const []);
    useEffect(() => () => brandAudioPlayer.dispose(), [brandAudioPlayer]);
    final t = ref.watch(translationsProvider).requireValue;
    // final hasAnyProfile = ref.watch(hasAnyProfileProvider);
    final activeProfile = ref.watch(activeProfileProvider);

    return Scaffold(
      appBar: AppBar(
        // leading: (RootScaffold.stateKey.currentState?.hasDrawer ?? false) && showDrawerButton(context)
        //     ? DrawerButton(
        //         onPressed: () {
        //           RootScaffold.stateKey.currentState?.openDrawer();
        //         },
        //       )
        //     : null,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF090909),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD6A63A), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Color(0x33D6A63A), blurRadius: 8, spreadRadius: 1),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                'SM',
                style: TextStyle(
                  color: Color(0xFFFFD36A),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
            ),
            const Gap(10),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: Constants.appName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: " "),
                    const WidgetSpan(child: AppVersionLabel(), alignment: PlaceholderAlignment.middle),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: audioEnabled.value ? 'قطع صدای معرفی' : 'پخش صدای معرفی',
            onPressed: () {
              audioEnabled.value = !audioEnabled.value;
              if (audioEnabled.value) {
                unawaited(brandAudioPlayer.play(
                  AssetSource('audio/mobile_sirus_brand_sting.mp3'),
                  volume: 0.55,
                ));
              } else {
                unawaited(brandAudioPlayer.stop());
              }
            },
            icon: Icon(
              audioEnabled.value ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: const Color(0xFFD6A63A),
            ),
          ),
          // IconButton(
          //     onPressed: () => const QuickSettingsRoute().push(context),
          //     icon: const Icon(FluentIcons.options_24_filled),
          //     material: (context, platform) => MaterialIconButtonData(
          //           tooltip: t.config.quickSettings,
          //         )),
          // IconButton(
          //     onPressed: () => const AddProfileRoute().push(context),
          //     icon: const Icon(FluentIcons.add_circle_24_filled),
          //     material: (context, platform) => MaterialIconButtonData(
          //           tooltip: t.profile.add.buttonText,
          //         )),
          Semantics(
            key: const ValueKey("profile_add_button"),
            label: t.pages.profiles.add,
            child: IconButton(
              icon: Icon(Icons.add_rounded, color: theme.colorScheme.primary),
              onPressed: () => ref.read(bottomSheetsNotifierProvider.notifier).showAddProfile(),
            ),
          ),
          const Gap(8),
        ],
      ),
      // The sky and the map are drawn once into their own layer: a ripple or a label changing on
      // the page no longer redraws the whole map image under it.
      body: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: DecoratedBox(
              decoration: BoxDecoration(
                // A sky behind the connect button, as at an eclipse: in dark mode a touch lighter round
                // the button, fading to the theme's own dark; in light mode brightest there, a touch
                // darker towards the edges. Both barely there, centred on where the button sits.
                gradient: theme.brightness == Brightness.dark
                    ? RadialGradient(
                        center: const Alignment(0, -.15),
                        radius: .85,
                        colors: [
                          Colors.white.withValues(alpha: .045),
                          Colors.white.withValues(alpha: .015),
                          Colors.white.withValues(alpha: 0),
                        ],
                        stops: const [0, .45, 1],
                      )
                    : RadialGradient(
                        center: const Alignment(0, -.15),
                        radius: 1.1,
                        colors: [
                          Colors.white.withValues(alpha: .55),
                          Colors.white.withValues(alpha: 0),
                          Colors.black.withValues(alpha: .045),
                        ],
                        stops: const [0, .5, 1],
                      ),
                image: DecorationImage(
                  image: const AssetImage('assets/images/world_map.png'), // Replace with your image path
                  fit: BoxFit.cover,
                  opacity: 0.09,
                  colorFilter: theme.brightness == Brightness.dark
                      ? ColorFilter.mode(Colors.white.withValues(alpha: .15), BlendMode.srcIn) //
                      : ColorFilter.mode(
                          Colors.grey.withValues(alpha: 1),
                          BlendMode.srcATop,
                        ), // Apply white tint in dark mode
                ),
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 600, // Set the maximum width here
                  ),
                  // The page does not move under the finger: no bounce (iOS) or stretch (Android) when it
                  // fits the screen. It still scrolls, without them, when it does not (a small screen or a
                  // large font).
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                    child: CustomScrollView(
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        // switch (activeProfile) {
                        // AsyncData(value: final profile?) =>
                        MultiSliver(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                              child: RotationTransition(
                                turns: Tween<double>(begin: 0, end: 1).animate(
                                  CurvedAnimation(parent: brandRotation, curve: Curves.easeInOutCubic),
                                ),
                                child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF080808),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: const Color(0xFFD6A63A), width: 1.2),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 6)),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/mobile_sirus_brand_logo.webp',
                                      width: 190,
                                      height: 190,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                    ),
                                    const Gap(4),
                                    const Text(
                                      'خدمات و پشتیبانی موبایل',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(0xFFBFA66D), fontSize: 12),
                                    ),
                                  ],
                                ),
                                ),
                              ),
                            ),
                            // const Gap(100),
                            switch (activeProfile) {
                              AsyncData(value: final profile?) => ProfileTile(
                                profile: profile,
                                isMain: true,
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              _ => const Text(""),
                            },
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [ConnectionButton(), ActiveProxyDelayIndicator()],
                                    ),
                                  ),
                                  ActiveProxyFooter(),
                                  Gap(32),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // AsyncData() => switch (hasAnyProfile) {
                        //     AsyncData(value: true) => const EmptyActiveProfileHomeBody(),
                        //     _ => const EmptyProfilesHomeBody(),
                        //   },
                        // AsyncError(:final error) => SliverErrorBodyPlaceholder(t.presentShortError(error)),
                        // _ => const SliverToBoxAdapter(),
                        // },
                      ],
                    ),
                  ),
                ),
              ),
              if (ref.watch(hasAnyProfileProvider).value ?? false)
                Positioned(
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    // tabs of either height stand on the bottom edge
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // in proxy mode, a smaller tab beside this one on how to point apps at the proxy
                      const Flexible(child: LocalProxyHint()),
                      Material(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          onTap: () => ref.read(bottomSheetsNotifierProvider.notifier).showQuickSettings(),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(t.pages.home.quickSettings),
                                const Gap(4),
                                const Icon(Icons.arrow_drop_up_rounded, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppVersionLabel extends HookConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final theme = Theme.of(context);

    final version = ref.watch(appInfoProvider).requireValue.presentVersion;
    if (version.isBlank) return const SizedBox();

    return Semantics(
      label: t.common.version,
      button: false,
      child: Container(
        decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        child: Text(
          version,
          textDirection: TextDirection.ltr,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSecondaryContainer),
        ),
      ),
    );
  }
}
