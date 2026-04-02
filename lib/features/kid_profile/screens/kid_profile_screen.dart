import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/kid_model.dart';
import '../../../data/repositories/kid_repository.dart';
import '../../../shared/widgets/kid_avatar.dart';
import '../../../shared/widgets/gradient_button.dart';

class KidProfileScreen extends ConsumerStatefulWidget {
  final int? kidId; // kept for router compat; we use String IDs internally
  final String? kidStringId;

  const KidProfileScreen({
    super.key,
    this.kidId,
    this.kidStringId,
  });

  @override
  ConsumerState<KidProfileScreen> createState() => _KidProfileScreenState();
}

class _KidProfileScreenState extends ConsumerState<KidProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _favFoodCtrl = TextEditingController();
  final _favSnacksCtrl = TextEditingController();
  final _favFruitsCtrl = TextEditingController();

  DateTime? _dob;
  String? _photoBase64;
  bool _saving = false;
  KidModel? _existing;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  void _loadExisting() {
    final id = widget.kidStringId;
    if (id == null) return;
    final repo = ref.read(kidRepositoryProvider);
    final kid = repo.getById(id);
    if (kid == null) return;
    _existing = kid;
    _nameCtrl.text = kid.name;
    _favFoodCtrl.text = kid.favFood;
    _favSnacksCtrl.text = kid.favSnacks;
    _favFruitsCtrl.text = kid.favFruits;
    _dob = kid.dob;
    _photoBase64 = kid.photoBase64;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _favFoodCtrl.dispose();
    _favSnacksCtrl.dispose();
    _favFruitsCtrl.dispose();
    super.dispose();
  }

  // ── Image picker ────────────────────────────────────────────
  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 80,
      );
      if (xFile == null) return;
      final bytes = await xFile.readAsBytes();
      setState(() => _photoBase64 = base64Encode(bytes));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  // ── Date picker ─────────────────────────────────────────────
  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 6),
      firstDate: DateTime(now.year - 18),
      lastDate: DateTime(now.year - 1),
      helpText: 'Select Date of Birth',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  // ── Save ────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date of birth')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(kidRepositoryProvider);
      final isNew = _existing == null;

      final kid = KidModel(
        id: _existing?.id ??
            '${DateTime.now().millisecondsSinceEpoch}_${_nameCtrl.text.hashCode.abs()}',
        name: _nameCtrl.text.trim(),
        dob: _dob!,
        photoBase64: _photoBase64,
        favFood: _favFoodCtrl.text.trim(),
        favSnacks: _favSnacksCtrl.text.trim(),
        favFruits: _favFruitsCtrl.text.trim(),
        currentLevel: _existing?.currentLevel ?? 1,
        createdAt: _existing?.createdAt ?? DateTime.now(),
      );

      await repo.save(kid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNew
                ? '🎉 ${kid.name} added!'
                : '✅ Profile updated!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Delete ──────────────────────────────────────────────────
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Child?'),
        content: Text(
          'This will permanently delete ${_existing?.name}\'s profile and all their habit records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || _existing == null) return;
    await ref.read(kidRepositoryProvider).delete(_existing!.id);
    if (mounted) Navigator.of(context).pop();
  }

  // ── UI ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isNew = _existing == null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isNew ? 'Add Child' : 'Edit Profile'),
        actions: [
          if (!isNew)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger),
              tooltip: 'Remove child',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Photo ────────────────────────────────────────
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    KidAvatar(
                      name: _nameCtrl.text.isEmpty
                          ? '?'
                          : _nameCtrl.text,
                      photoBase64: _photoBase64,
                      size: AppConstants.avatarSizeLg * 1.2,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _photoBase64 == null ? 'Tap to add photo' : 'Tap to change photo',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 28),

              // ── Name ─────────────────────────────────────────
              _field(
                controller: _nameCtrl,
                label: 'Child\'s Name',
                hint: 'e.g. Arjun',
                icon: Icons.person_outline_rounded,
                onChanged: (_) => setState(() {}),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // ── DOB ──────────────────────────────────────────
              GestureDetector(
                onTap: _pickDob,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake_rounded,
                          color: AppColors.textMuted, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date of Birth',
                                style: AppTextStyles.labelSmall),
                            const SizedBox(height: 2),
                            Text(
                              _dob == null
                                  ? 'Select birthday'
                                  : '${NallaDateUtils.formatShortDate(_dob!)}  •  ${NallaDateUtils.formatAge(_dob!)}',
                              style: _dob == null
                                  ? AppTextStyles.body.copyWith(
                                      color: AppColors.textDisabled)
                                  : AppTextStyles.body,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.primary, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Preferences section ──────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Favourite Things 🌟',
                    style: AppTextStyles.h4),
              ),
              const SizedBox(height: 12),

              _field(
                controller: _favFoodCtrl,
                label: 'Favourite Food',
                hint: 'e.g. Dosa, Biriyani',
                icon: Icons.restaurant_rounded,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _favSnacksCtrl,
                label: 'Favourite Snacks',
                hint: 'e.g. Murukku, Biscuit',
                icon: Icons.cookie_rounded,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _favFruitsCtrl,
                label: 'Favourite Fruits',
                hint: 'e.g. Mango, Banana',
                icon: Icons.apple_rounded,
              ),
              const SizedBox(height: 36),

              // ── Save ─────────────────────────────────────────
              GradientButton(
                label: isNew ? 'Add Child 🎉' : 'Save Changes',
                onPressed: _save,
                loading: _saving,
                icon: isNew ? Icons.person_add_rounded : Icons.save_rounded,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      ),
    );
  }
}
