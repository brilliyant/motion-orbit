import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/state/profile_store.dart';
import '../../../settings/presentation/state/settings_store.dart';
import '../widgets/onboarding_app_bar.dart';
import '../widgets/step_progress_indicator.dart';
import '../widgets/steps/step_about_view.dart';
import '../widgets/steps/step_completion_view.dart';
import '../widgets/steps/step_fitness_view.dart';
import '../widgets/steps/step_preferences_view.dart';
import '../widgets/steps/step_welcome_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.store,
    required this.settingsStore,
    this.editing = false,
  });

  final ProfileStore store;
  final SettingsStore settingsStore;
  final bool editing;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final TextEditingController _name;
  late final TextEditingController _height;
  late final TextEditingController _weight;

  UserProfile get p => widget.store.draft;

  bool _busy = false;
  bool _requiredErrors = false;
  bool _complete = false;
  String? _heightError;
  String? _weightError;
  String? _saveError;
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: p.name);
    _height = TextEditingController(text: p.height);
    _weight = TextEditingController(text: p.weight);
    if (widget.editing) {
      p.step = 1;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _validateAnthropometrics() {
    _heightError = UserProfile.numericError(_height.text, 80, 250, 'cm');
    _weightError = UserProfile.numericError(_weight.text, 30, 300, 'kg');
  }

  void _change(VoidCallback change) {
    setState(change);
    _persist();
  }

  Future<void> _persist() async {
    final revision = ++_revision;
    try {
      await widget.store.saveDraft();
      if (mounted && revision == _revision) {
        setState(() => _saveError = null);
      }
    } catch (_) {
      if (mounted && revision == _revision) {
        setState(
          () => _saveError = 'Your latest changes could not be saved. Keep this screen open and retry.',
        );
      }
    }
  }

  Future<void> _move(int step) async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    final previous = p.step;
    setState(() {
      _busy = true;
      p.step = step;
    });
    ++_revision;
    try {
      await widget.store.saveDraft();
      if (mounted) setState(() => _saveError = null);
    } catch (_) {
      p.step = previous;
      if (mounted) {
        setState(() => _saveError = 'Could not save your place. Please retry.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _back() async {
    if (_busy) return;
    if (_complete) {
      _dashboard();
      return;
    }
    if (widget.editing && p.step == 1) {
      setState(() => _busy = true);
      await _persist();
      if (!mounted) return;
      setState(() => _busy = false);
      if (_saveError == null) Navigator.of(context).pop();
      return;
    }
    await _move(p.step - 1);
  }

  void _continue() {
    if (p.step == 1) {
      _validateAnthropometrics();
      if (_heightError != null || _weightError != null) {
        setState(() {});
        return;
      }
    }
    if (p.step == 2) {
      setState(() => _requiredErrors = true);
      if (p.goal == null || p.level == null) return;
    }
    _move(p.step + 1);
  }

  Future<void> _finish() async {
    if (_busy) return;
    if (!p.valid) {
      setState(() => _requiredErrors = true);
      await _move(p.goal == null || p.level == null ? 2 : 1);
      return;
    }
    setState(() => _busy = true);
    ++_revision;
    try {
      await widget.store.complete();
      if (!mounted) return;
      if (widget.editing) {
        Navigator.of(context).pop();
        return;
      }
      setState(() {
        _complete = true;
        _saveError = null;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _saveError = 'Setup could not be saved. Your inputs are still here. Please retry Finish Setup.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _dashboard() => Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (_) => DashboardScreen(
        store: widget.store,
        settingsStore: widget.settingsStore,
      ),
    ),
    (_) => false,
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy && !_complete && p.step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: AbsorbPointer(
            absorbing: _busy,
            child: Column(
              children: [
                if (p.step > 0 && !_complete)
                  OnboardingAppBar(step: p.step, onBack: _busy ? null : _back),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: SingleChildScrollView(
                        key: ValueKey(_complete ? 4 : p.step),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (p.step > 0 && !_complete)
                              StepProgressIndicator(step: p.step),
                            if (_complete)
                              StepCompletionView(
                                profile: p,
                                onGoToDashboard: _dashboard,
                              )
                            else if (p.step == 0)
                              StepWelcomeView(onGetStarted: () => _move(1))
                            else if (p.step == 1)
                              StepAboutView(
                                profile: p,
                                nameController: _name,
                                heightController: _height,
                                weightController: _weight,
                                heightError: _heightError,
                                weightError: _weightError,
                                isEditing: widget.editing,
                                onChanged: _change,
                                onValidateAnthropometrics:
                                    _validateAnthropometrics,
                                onContinue: _continue,
                                onBack: _back,
                              )
                            else if (p.step == 2)
                              StepFitnessView(
                                profile: p,
                                showErrors: _requiredErrors,
                                onChanged: _change,
                                onContinue: _continue,
                              )
                            else
                              StepPreferencesView(
                                profile: p,
                                isEditing: widget.editing,
                                onChanged: _change,
                                onFinish: _finish,
                                onBack: _back,
                              ),
                            if (_saveError != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.error.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _saveError!,
                                      style: const TextStyle(
                                        color: AppColors.errorText,
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _persist,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 32),
                                      ),
                                      child: const Text(
                                        'Retry saving changes',
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (_busy) ...[
                              const SizedBox(height: 16),
                              const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.outlineFocus,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
