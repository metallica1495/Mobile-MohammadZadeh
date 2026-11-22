import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/router/go_router/helper/active_breakpoint_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FixBtn extends ConsumerWidget {
  const FixBtn({super.key, required this.height, required this.title, required this.icon, required this.onTap});

  final double height;
  final String title;
  final IconData icon;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = Breakpoint(context).isMobile();
    final color = theme.colorScheme.primary;
    final borderRadius = BorderRadius.circular(18);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          alignment: Alignment.center,
          // a minimum: a language whose letters are taller (Chinese, Burmese) needs more than the square
          constraints: BoxConstraints(minHeight: height),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: borderRadius,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isMobile ? 48 : 56,
                height: isMobile ? 48 : 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: isMobile ? 27 : 32,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Gap(isMobile ? 8 : 10),
              Text(
                title,
                style: isMobile
                    ? theme.textTheme.titleSmall!.copyWith(color: color)
                    : theme.textTheme.titleMedium!.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
