import 'package:flutter/material.dart';

import 'package:motion_orbit/core/constants/profile_constants.dart';
import 'package:motion_orbit/core/widgets/motion_orbit_logo.dart';
import 'package:motion_orbit/features/profile/domain/entities/user_profile.dart';
import 'package:motion_orbit/features/profile/presentation/profile_colors.dart';
import 'package:motion_orbit/features/profile/presentation/state/profile_store.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({
    super.key,
    required this.store,
    required this.latestWeight,
    required this.onOpenMeasurements,
    this.onSaved,
  });

  final ProfileStore store;
  final double? latestWeight;
  final Future<double?> Function() onOpenMeasurements;
  final VoidCallback? onSaved;

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  static const _equipment = ProfileConstants.availableEquipmentOptions;
  static const _environments = ProfileConstants.environmentOptions;
  static const _blue = Color(0xFF2563EB);
  static const _paleBlue = Color(0xFFDBEAFE);
  static const _subtle = Color(0xFFF1F5F9);

  late final UserProfile _draft;
  late final TextEditingController _name;
  late final TextEditingController _height;
  late final TextEditingController _limitations;
  late DateTime? _birthDate;
  late String? _sex;
  late String? _environment;
  late String? _experience;
  late final Set<String> _selectedEquipment;
  late double? _latestWeight;
  bool _saving = false;
  bool _showSaved = false;

  @override
  void initState() {
    super.initState();
    final current = widget.store.profile!;
    _draft = current.copy();
    _name = TextEditingController(text: _draft.name);
    _height = TextEditingController(text: _draft.height);
    _limitations = TextEditingController(text: _draft.limitations);
    _birthDate = DateTime.tryParse(_draft.dateOfBirth ?? '');
    _sex = _draft.biologicalSex;
    _environment =
        _draft.primaryEnvironment ??
        (_draft.location == 'Both' ? 'Hybrid' : _draft.location);
    _experience = _draft.level;
    _selectedEquipment = _draft.availableEquipment.isNotEmpty
        ? {..._draft.availableEquipment}
        : _draft.equipment
              .map(
                (item) => item == 'Resistance Band'
                    ? 'Resistance Bands'
                    : item == 'Bodyweight'
                    ? 'Bodyweight Only'
                    : item,
              )
              .where(_equipment.contains)
              .toSet();
    _latestWeight = widget.latestWeight;
  }

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _limitations.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );
    if (selected != null) setState(() => _birthDate = selected);
  }

  Future<void> _save() async {
    final heightError = UserProfile.numericError(_height.text, 80, 250, 'cm');
    if (heightError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(heightError)));
      return;
    }
    setState(() {
      _saving = true;
      _showSaved = false;
    });
    _draft.name = _name.text.trim();
    _draft.height = _height.text.trim();
    _draft.dateOfBirth = _birthDate?.toIso8601String().split('T').first;
    _draft.biologicalSex = _sex;
    _draft.primaryEnvironment = _environment;
    _draft.level = _experience;
    _draft.limitations = _limitations.text.trim();
    _draft.availableEquipment
      ..clear()
      ..addAll(_selectedEquipment);
    try {
      widget.store.draft = _draft;
      await widget.store.complete();
      widget.onSaved?.call();
      if (mounted) setState(() => _showSaved = true);
      Future<void>.delayed(const Duration(milliseconds: 2200), () {
        if (mounted) setState(() => _showSaved = false);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save profile details locally.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _openMeasurements() async {
    final latestWeight = await widget.onOpenMeasurements();
    if (mounted) setState(() => _latestWeight = latestWeight);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: ProfileColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _blue,
          brightness: Brightness.light,
          surface: ProfileColors.background,
        ),
      ),
      child: Scaffold(
        backgroundColor: ProfileColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha: .96),
            foregroundColor: ProfileColors.textPrimary,
            elevation: 0,
            leadingWidth: 56,
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, size: 24),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                const MotionOrbitLogoMark(size: 30),
                const SizedBox(width: 9),
                const Flexible(
                  child: Text(
                    'Personal Information',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ProfileColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: _subtle,
                  child: Icon(
                    Icons.person,
                    size: 19,
                    color: ProfileColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Athlete Profile',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: ProfileColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Keep your baseline metrics current for accurate load calculation',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: ProfileColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                        SizedBox(width: 6),
                        Text(
                          'Synced Local',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.badge_outlined,
                title: 'Basic Information',
                subtitle: 'Core demographics for heart rate zone scaling',
                children: [
                  _label('Display Name'),
                  _input(
                    child: TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        'Enter full name',
                        Icons.person_outline,
                      ),
                    ),
                  ),
                  _label('Date of Birth'),
                  _input(
                    child: InkWell(
                      onTap: _pickBirthDate,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _birthDate == null
                                  ? 'Select date of birth'
                                  : _formatDate(_birthDate!),
                              style: TextStyle(
                                fontSize: 14,
                                color: _birthDate == null
                                    ? ProfileColors.textMuted
                                    : ProfileColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: ProfileColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _label('Biological Sex'),
                  _choiceRow(
                    ['male', 'female', 'unspecified'],
                    _sex,
                    (value) => setState(() => _sex = value),
                    labels: const ['Male', 'Female', 'Prefer not to say'],
                  ),
                  _label('Height'),
                  _input(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _height,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: _inputDecoration('175'),
                          ),
                        ),
                        const Text(
                          'cm',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ProfileColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.fitness_center,
                title: 'Training Background',
                subtitle: 'Contextualizes workout volume and auto-progression',
                children: [
                  _label('Fitness Experience'),
                  _choiceRow(
                    const ['Beginner', 'Intermediate', 'Advanced'],
                    _experience,
                    (value) => setState(() => _experience = value),
                    pill: true,
                  ),
                  _label('Primary Environment'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _environments
                        .map((item) => _environmentChip(item))
                        .toList(),
                  ),
                  _label('Available Equipment'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _equipment
                        .map((item) => _equipmentChip(item))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.medical_services_outlined,
                title: 'Physical Considerations',
                subtitle: 'Injuries, structural limits, or rehab focus',
                children: [
                  _label('Active Limitations (Optional)'),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _subtle,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: TextField(
                      controller: _limitations,
                      minLines: 3,
                      maxLines: 3,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'e.g. Lower back tightness during heavy deadlifts...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _subtle,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 19,
                          color: ProfileColors.textMuted,
                        ),
                        SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Your physical notes are kept strictly offline on this device.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.35,
                              color: ProfileColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _weightCard(_latestWeight),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            height: 72,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .97),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 16,
                  offset: Offset(0, -3),
                ),
              ],
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 568),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 48,
                      child: TextButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.maybePop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: _subtle,
                          foregroundColor: ProfileColors.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          icon: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined, size: 19),
                          label: Text(
                            _saving ? 'Saving...' : 'Save Changes',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: _showSaved
            ? Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: ProfileColors.textPrimary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33000000), blurRadius: 12),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Color(0xFF10B981),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Profile updated successfully',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : null,
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      ),
    );
  }

  Widget _weightCard(double? weight) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionIcon(icon: Icons.monitor_weight_outlined),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Current Weight',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ProfileColors.textPrimary,
                ),
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _subtle,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Read-only from latest measurement',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: ProfileColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _subtle,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      weight == null ? '--' : weight.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 28,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: ProfileColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'kg',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ProfileColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _openMeasurements,
                style: TextButton.styleFrom(
                  foregroundColor: _blue,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward, size: 15),
                label: const Text(
                  'Update in Body Measurements',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _equipmentChip(String item) {
    final active = _selectedEquipment.contains(item);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => setState(
        () => active
            ? _selectedEquipment.remove(item)
            : _selectedEquipment.add(item),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _paleBlue : _subtle,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active) ...[
              const Icon(Icons.check, size: 15, color: _blue),
              const SizedBox(width: 5),
            ],
            Text(
              item,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: active ? _blue : ProfileColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _environmentChip(String item) {
    final active = _environment == item;
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () => setState(() => _environment = item),
      child: Container(
        width: (MediaQuery.sizeOf(context).width.clamp(0, 600) - 48) / 2,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _paleBlue : _subtle,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: active ? _blue : ProfileColors.textSecondary,
                ),
              ),
            ),
            Icon(
              active ? Icons.check : Icons.check,
              size: 16,
              color: active ? _blue : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceRow(
    List<String> values,
    String? selected,
    ValueChanged<String> onSelect, {
    List<String>? labels,
    bool pill = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _subtle,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: InkWell(
                  borderRadius: BorderRadius.circular(pill ? 30 : 7),
                  onTap: () => onSelect(values[i]),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: pill ? 9 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected == values[i]
                          ? (pill ? _paleBlue : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(pill ? 30 : 7),
                      boxShadow: selected == values[i]
                          ? const [
                              BoxShadow(
                                color: Color(0x10000000),
                                blurRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      labels?[i] ?? values[i],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        color: selected == values[i]
                            ? (pill ? _blue : ProfileColors.textPrimary)
                            : ProfileColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _label(String value) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 7),
    child: Text(
      value,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: .1,
        color: ProfileColors.textSecondary,
      ),
    ),
  );

  Widget _input({required Widget child}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    decoration: BoxDecoration(
      color: _subtle,
      borderRadius: BorderRadius.circular(9),
    ),
    child: child,
  );

  InputDecoration _inputDecoration(
    String hint, [
    IconData? icon,
  ]) => InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: ProfileColors.textMuted),
    suffixIcon: icon == null
        ? null
        : Icon(icon, size: 19, color: ProfileColors.textMuted),
    suffixIconConstraints: const BoxConstraints(minWidth: 22, minHeight: 20),
    border: InputBorder.none,
    contentPadding: EdgeInsets.zero,
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _SectionIcon(icon: icon),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: ProfileColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.25,
                      color: ProfileColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

class _SectionIcon extends StatelessWidget {
  const _SectionIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, size: 19, color: const Color(0xFF2563EB)),
  );
}
