import 'package:flutter/material.dart';

import '../profile_colors.dart';

class ProfileModuleScaffold extends StatelessWidget {
  const ProfileModuleScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.bottomNavigationBar,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
          brightness: Brightness.light,
          scaffoldBackgroundColor: ProfileColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: ProfileColors.blue,
            brightness: Brightness.light,
            surface: ProfileColors.background,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: ProfileColors.background,
            border: OutlineInputBorder(),
          ),
        ),
        child: Scaffold(
          backgroundColor: ProfileColors.background,
          appBar: AppBar(
            backgroundColor: ProfileColors.surface,
            foregroundColor: ProfileColors.textPrimary,
            elevation: 0,
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            actions: actions,
          ),
          body: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: child,
              ),
            ),
          ),
          bottomNavigationBar: bottomNavigationBar,
        ),
      );
}

class ProfileModuleBody extends StatelessWidget {
  const ProfileModuleBody({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: children,
      );
}

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(title.toUpperCase(),
                  style: const TextStyle(
                    color: ProfileColors.textMuted,
                    fontSize: 11,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                  )),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: ProfileColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: child,
      );
}

class ProfileEmptyState extends StatelessWidget {
  const ProfileEmptyState({super.key, required this.title, required this.message, this.icon = Icons.insights_outlined});
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ProfileCard(
        child: Column(
          children: [
            Icon(icon, size: 34, color: ProfileColors.textMuted),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: ProfileColors.textSecondary)),
          ],
        ),
      );
}

String shortDate(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

String metricLabel(String test) => test[0].toUpperCase() + test.substring(1);
