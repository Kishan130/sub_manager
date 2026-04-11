import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/firebase_auth_service.dart';
import '../providers/subscription_provider.dart';
import '../../../../models/subscription.dart';
import '../../data/default_platforms.dart';

class AddSubscriptionScreen extends ConsumerStatefulWidget {
  const AddSubscriptionScreen({super.key});

  @override
  ConsumerState<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends ConsumerState<AddSubscriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _cost = 0;
  String _category = 'Entertainment';
  String _billingCycle = 'monthly';
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  int _colorValue = 0xFF6750A4;
  String _androidPackageName = '';

  bool _isLoading = false;

  void _selectPlatform(Map<String, dynamic> platform) {
    setState(() {
      _name = platform['name'];
      _cost = platform['baseCost'];
      _category = platform['category'];
      _colorValue = platform['color'];
      _androidPackageName = platform['packageName'] ?? '';
    });
    Navigator.pop(context); // Close bottom sheet
  }

  void _showPlatformSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withAlpha(40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Popular Platforms', style: textTheme.titleMedium),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: defaultPlatforms.length,
                itemBuilder: (context, index) {
                  final p = defaultPlatforms[index];
                  final logoUrl = p['logoUrl'] as String?;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: Color(p['color']).withAlpha(200),
                      child: ClipOval(
                        child: (logoUrl != null && logoUrl.isNotEmpty) 
                          ? Image.network(
                              logoUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    p['name'][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                p['name'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                      ),
                    ),
                    title: Text(p['name'], style: textTheme.titleSmall),
                    subtitle: Text('Avg: ₹${p['baseCost']}', style: textTheme.bodySmall),
                    trailing: Icon(Icons.add_circle_outline, color: colorScheme.primary, size: 22),
                    onTap: () => _selectPlatform(p),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final sub = Subscription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.uid,
      name: _name,
      category: _category,
      cost: _cost,
      billingCycle: _billingCycle,
      nextBillingDate: _nextBillingDate,
      logoAssetPath: _colorValue.toString(),
      isActive: true,
      androidPackageName: _androidPackageName,
      usageHistory: [],
    );

    try {
      await ref.read(firestoreServiceProvider).addSubscription(sub);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Subscription')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ─── Platform Selector Button ───────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.outline.withAlpha(50)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.search_rounded, color: colorScheme.primary),
                      ),
                      title: Text('Select from Popular Platforms', style: textTheme.titleSmall),
                      subtitle: Text('Netflix, Spotify, YouTube & more', style: textTheme.bodySmall),
                      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurface.withAlpha(100)),
                      onTap: _showPlatformSelector,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─── Or Divider ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: Divider(color: colorScheme.outline.withAlpha(50))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or enter manually', style: textTheme.bodySmall),
                      ),
                      Expanded(child: Divider(color: colorScheme.outline.withAlpha(50))),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── Name Field ────────────────────────────────────
                  TextFormField(
                    key: ValueKey('name_$_name'),
                    initialValue: _name,
                    decoration: InputDecoration(
                      labelText: 'Subscription Name',
                      prefixIcon: Icon(Icons.label_outline_rounded, color: colorScheme.primary.withAlpha(180)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    onSaved: (val) => _name = val!,
                    onChanged: (val) => _name = val,
                  ),
                  const SizedBox(height: 16),

                  // ─── Cost Field ────────────────────────────────────
                  TextFormField(
                    key: ValueKey('cost_$_cost'),
                    initialValue: _cost > 0 ? _cost.toString() : '',
                    decoration: InputDecoration(
                      labelText: 'Cost (₹)',
                      prefixIcon: Icon(Icons.currency_rupee_rounded, color: colorScheme.primary.withAlpha(180)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) => val == null || double.tryParse(val) == null ? 'Valid amount required' : null,
                    onSaved: (val) => _cost = double.parse(val!),
                  ),
                  const SizedBox(height: 16),

                  // ─── Category Dropdown ─────────────────────────────
                  DropdownButtonFormField<String>(
                    key: ValueKey('category_$_category'),
                    initialValue: _category,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined, color: colorScheme.primary.withAlpha(180)),
                    ),
                    items: ['Entertainment', 'Music', 'Utility', 'Productivity', 'Health', 'Bills']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => _category = val!),
                  ),
                  const SizedBox(height: 16),

                  // ─── Billing Cycle Dropdown ────────────────────────
                  DropdownButtonFormField<String>(
                    initialValue: _billingCycle,
                    decoration: InputDecoration(
                      labelText: 'Billing Cycle',
                      prefixIcon: Icon(Icons.autorenew_rounded, color: colorScheme.primary.withAlpha(180)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                    ],
                    onChanged: (val) => setState(() => _billingCycle = val!),
                  ),
                  const SizedBox(height: 16),

                  // ─── Date Picker Tile ──────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withAlpha(50)),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.calendar_today_rounded, color: colorScheme.primary, size: 20),
                      ),
                      title: Text('Next Billing Date', style: textTheme.bodyMedium),
                      subtitle: Text(
                        "${_nextBillingDate.toLocal()}".split(' ')[0],
                        style: textTheme.titleSmall?.copyWith(color: colorScheme.primary),
                      ),
                      trailing: Icon(Icons.edit_calendar, color: colorScheme.primary, size: 20),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _nextBillingDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (date != null) setState(() => _nextBillingDate = date);
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─── Save Button ───────────────────────────────────
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded, size: 20),
                      label: const Text('Save Subscription', style: TextStyle(fontSize: 16)),
                      onPressed: _saveSubscription,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
