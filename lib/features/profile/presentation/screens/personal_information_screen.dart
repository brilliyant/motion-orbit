import 'package:flutter/material.dart';

import '../../../../core/constants/profile_constants.dart';
import '../../../../profile_store.dart';
import '../../data/models/profile_model.dart';
import '../profile_colors.dart';
import '../state/profile_store.dart';
import '../widgets/profile_module_widgets.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key, required this.store, this.onSaved});
  final ProfileStore store;
  final VoidCallback? onSaved;

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final LocalProfile _draft;
  late final TextEditingController _name;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final current = widget.store.profile!;
    _draft = LocalProfile.fromJson(current.toJson());
    _name = TextEditingController(text: _draft.name);
    _height = TextEditingController(text: _draft.height);
    _weight = TextEditingController(text: _draft.weight);
  }

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    _draft.name = _name.text.trim();
    _draft.height = _height.text.trim();
    _draft.weight = _weight.text.trim();
    try {
      widget.store.draft = _draft;
      await widget.store.complete();
      widget.onSaved?.call();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save profile details locally.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => ProfileModuleScaffold(
        title: 'Personal Information',
        child: ProfileModuleBody(children: [
          ProfileCard(child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Your details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
            const SizedBox(height: 14),
            TextFormField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _draft.age,
              decoration: const InputDecoration(labelText: 'Age range'),
              items: ProfileConstants.ages.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) => setState(() => _draft.age = value),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _height,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Height', suffixText: 'cm'),
              validator: (value) => UserProfile.numericError(value ?? '', 80, 250, 'cm'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Weight', suffixText: 'kg'),
              validator: (value) => UserProfile.numericError(value ?? '', 30, 300, 'kg'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Training profile', style: TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _draft.goal,
              decoration: const InputDecoration(labelText: 'Primary fitness goal'),
              items: ProfileConstants.goals.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) => setState(() => _draft.goal = value),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _draft.level,
              decoration: const InputDecoration(labelText: 'Experience level'),
              items: ProfileConstants.levels.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) => setState(() => _draft.level = value),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _draft.location,
              decoration: const InputDecoration(labelText: 'Training location'),
              items: ProfileConstants.locations.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) => setState(() => _draft.location = value),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _draft.duration,
              decoration: const InputDecoration(labelText: 'Preferred session duration'),
              items: ProfileConstants.durations.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) => setState(() => _draft.duration = value),
            ),
            const SizedBox(height: 14),
            const Text('Available equipment', style: TextStyle(color: ProfileColors.textSecondary)),
            for (final option in ProfileConstants.equipmentOptions)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(option, style: const TextStyle(color: ProfileColors.textPrimary)),
                value: _draft.equipment.contains(option),
                onChanged: (selected) => setState(() => selected == true ? _draft.equipment.add(option) : _draft.equipment.remove(option)),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            const SizedBox(height: 10),
            const Text('Preferred training days', style: TextStyle(color: ProfileColors.textSecondary)),
            for (final day in ProfileConstants.dayOptions)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(day, style: const TextStyle(color: ProfileColors.textPrimary)),
                value: _draft.days.contains(day),
                onChanged: (selected) => setState(() => selected == true ? _draft.days.add(day) : _draft.days.remove(day)),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            const SizedBox(height: 14),
            FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save changes')),
          ]))),
        ]),
      );
}
