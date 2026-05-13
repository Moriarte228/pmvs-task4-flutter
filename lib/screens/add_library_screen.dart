import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/district.dart';
import '../models/library_model.dart';
import '../providers/library_provider.dart';

class AddLibraryScreen extends StatefulWidget {
  const AddLibraryScreen({super.key});

  @override
  State<AddLibraryScreen> createState() => _AddLibraryScreenState();
}

class _AddLibraryScreenState extends State<AddLibraryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameRu = TextEditingController();
  final _nameEn = TextEditingController();
  final _nameBe = TextEditingController();
  final _addressRu = TextEditingController();
  final _addressEn = TextEditingController();
  final _addressBe = TextEditingController();
  final _phone = TextEditingController();
  final _website = TextEditingController();
  final _hours = TextEditingController();
  final _lat = TextEditingController(text: '53.9006');
  final _lng = TextEditingController(text: '27.5590');

  String? _districtId;

  @override
  void dispose() {
    _nameRu.dispose();
    _nameEn.dispose();
    _nameBe.dispose();
    _addressRu.dispose();
    _addressEn.dispose();
    _addressBe.dispose();
    _phone.dispose();
    _website.dispose();
    _hours.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_districtId == null) return;

    final lib = LibraryModel(
      nameRu: _nameRu.text.trim(),
      nameEn: _nameEn.text.trim(),
      nameBe: _nameBe.text.trim().isEmpty ? _nameRu.text.trim() : _nameBe.text.trim(),
      addressRu: _addressRu.text.trim(),
      addressEn: _addressEn.text.trim().isEmpty
          ? _addressRu.text.trim()
          : _addressEn.text.trim(),
      addressBe: _addressBe.text.trim().isEmpty
          ? _addressRu.text.trim()
          : _addressBe.text.trim(),
      district: _districtId!,
      latitude: double.tryParse(_lat.text.trim()) ?? 53.9006,
      longitude: double.tryParse(_lng.text.trim()) ?? 27.5590,
      phone: _phone.text.trim(),
      website: _website.text.trim(),
      workingHours: _hours.text.trim(),
    );

    final ok = await context.read<LibraryProvider>().addLibrary(lib);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginError)),
      );
    }
  }

  String? _req(String? v, AppLocalizations l10n) =>
      (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final districts = District.getDistricts();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addLibrary)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameRu,
              decoration: InputDecoration(
                labelText: '${l10n.name} (ru)',
                border: const OutlineInputBorder(),
              ),
              validator: (v) => _req(v, l10n),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameEn,
              decoration: InputDecoration(
                labelText: '${l10n.name} (en)',
                border: const OutlineInputBorder(),
              ),
              validator: (v) => _req(v, l10n),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameBe,
              decoration: InputDecoration(
                labelText: '${l10n.name} (be)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressRu,
              decoration: InputDecoration(
                labelText: '${l10n.address} (ru)',
                border: const OutlineInputBorder(),
              ),
              validator: (v) => _req(v, l10n),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressEn,
              decoration: InputDecoration(
                labelText: '${l10n.address} (en)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressBe,
              decoration: InputDecoration(
                labelText: '${l10n.address} (be)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _districtId,
              decoration: InputDecoration(
                labelText: l10n.district,
                border: const OutlineInputBorder(),
              ),
              items: districts
                  .map((d) => DropdownMenuItem(
                        value: d.id,
                        child: Text(d.getName(locale)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _districtId = v),
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lat,
                    decoration: InputDecoration(
                      labelText: l10n.latitude,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lng,
                    decoration: InputDecoration(
                      labelText: l10n.longitude,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              decoration: InputDecoration(
                labelText: l10n.phone,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _website,
              decoration: InputDecoration(
                labelText: l10n.website,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _hours,
              decoration: InputDecoration(
                labelText: l10n.workingHours,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(l10n.save),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
