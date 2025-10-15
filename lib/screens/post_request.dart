import 'package:flutter/material.dart';
import '../theme.dart';

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  bool anonymous = false;
  String? category = 'Food';
  String urgency = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(color: AppTheme.warmGradient.colors.first, borderRadius: BorderRadius.circular(6)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)), const SizedBox(width: 8), Text('Post Help Request', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 6),
              Text('Let the community know how they can help', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Title *'),
              const SizedBox(height: 6),
              TextFormField(decoration: InputDecoration(hintText: 'E.g., Need food supplies for elderly neighbor', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), validator: (v) => (v == null || v.isEmpty) ? 'Please fill out this field.' : null),
              const SizedBox(height: 12),
              Text('Description *'),
              const SizedBox(height: 6),
              TextFormField(decoration: InputDecoration(hintText: 'Provide details about what help you need...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))), maxLines: 6, validator: (v) => (v == null || v.isEmpty) ? 'Please fill out this field.' : null),
              const SizedBox(height: 12),
              Text('Category *'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: category,
                items: ['Food', 'Books', 'Clothes', 'Medical', 'Elderly Care', 'Education', 'Emergency', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => category = v),
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.white),
              ),
              const SizedBox(height: 12),
              Text('Urgency Level'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: ChoiceChip(label: const Text('High Priority'), selected: urgency == 'High', selectedColor: AppTheme.destructive, onSelected: (_) => setState(() => urgency = 'High'))),
                const SizedBox(width: 8),
                Expanded(child: ChoiceChip(label: const Text('Medium'), selected: urgency == 'Medium', selectedColor: Color.fromARGB(255, 255, 244, 196), onSelected: (_) => setState(() => urgency = 'Medium'))),
                const SizedBox(width: 8),
                Expanded(child: ChoiceChip(label: const Text('Low Priority'), selected: urgency == 'Low', selectedColor: AppTheme.success, onSelected: (_) => setState(() => urgency = 'Low'))),
              ]),
              const SizedBox(height: 12),
              Text('Location *'),
              const SizedBox(height: 6),
              TextFormField(decoration: InputDecoration(hintText: 'E.g., Downtown area, Street name...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.white), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () { if (_formKey.currentState?.validate() ?? false) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted (dummy)'))); Navigator.pop(context); } }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warmGradient.colors.first, padding: const EdgeInsets.symmetric(vertical: 14)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.send), SizedBox(width: 8), Text('Submit Request')]))),
              ])
            ]),
          )
        ],
      ),
      bottomNavigationBar: const SizedBox(height: 0),
    );
  }
}
