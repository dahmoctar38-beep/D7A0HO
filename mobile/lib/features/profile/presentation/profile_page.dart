import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/di/providers.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/ns_loading.dart';
import '../domain/user_preferences.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(userPreferencesProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: prefsAsync.when(
        loading: () => const NsLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (prefs) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User info
            Card(
              child: user.when(
                loading: () => const ListTile(title: Text('Loading...')),
                error: (e, _) => ListTile(title: Text(e.toString())),
                data: (appUser) => ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(appUser?.email ?? 'Guest'),
                  subtitle: Text(appUser == null ? 'Not signed in' : 'Signed in'),
                  trailing: appUser != null
                      ? TextButton(
                          onPressed: () async {
                            await ref.read(authServiceProvider).signOut();
                            ref.invalidate(currentUserProvider);
                            if (context.mounted) context.go(AppRoutes.login);
                          },
                          child: const Text('Sign Out'),
                        )
                      : TextButton(
                          onPressed: () => context.push(AppRoutes.login),
                          child: const Text('Sign In'),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Health Profile',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  _PrefTile(
                    title: 'Diabetic',
                    subtitle: 'Show extra warnings for sugar content',
                    icon: Icons.monitor_heart_outlined,
                    value: prefs.isDiabetic,
                    onChanged: (v) => _save(
                        ref, prefs.copyWith(isDiabetic: v)),
                  ),
                  _PrefTile(
                    title: 'Hypertensive',
                    subtitle: 'Show sodium warnings',
                    icon: Icons.favorite_border,
                    value: prefs.isHypertensive,
                    onChanged: (v) => _save(
                        ref, prefs.copyWith(isHypertensive: v)),
                  ),
                  _PrefTile(
                    title: 'Vegan',
                    subtitle: 'Flag animal-derived ingredients',
                    icon: Icons.eco_outlined,
                    value: prefs.veganMode,
                    onChanged: (v) => _save(
                        ref, prefs.copyWith(veganMode: v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Legal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  AppStrings.disclaimerText,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save(WidgetRef ref, UserPreferences prefs) {
    ref.read(preferencesServiceProvider).save(prefs);
    ref.invalidate(userPreferencesProvider);
  }
}

class _PrefTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrefTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primary),
      title: Text(title),
      subtitle: Text(subtitle,
          style: Theme.of(context).textTheme.labelSmall),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.primary,
    );
  }
}
