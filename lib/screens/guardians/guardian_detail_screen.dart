import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/guardian_provider.dart';
import '../../routes/app_routes.dart';

class GuardianDetailScreen extends StatelessWidget {
  final String guardianId;

  const GuardianDetailScreen({super.key, required this.guardianId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.pushNamed(
                    context,
                    AppRoutes.guardiansEdit,
                    arguments: {AppRoutes.idParam: guardianId},
                  );
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Delete'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<GuardianProvider>(
        builder: (context, provider, child) {
          final guardian = provider.getGuardianById(guardianId);

          if (guardian == null) {
            return const Center(child: Text('Guardian not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            guardian.name.isNotEmpty
                                ? guardian.name[0].toUpperCase()
                                : 'G',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          guardian.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        if (guardian.profession != null &&
                            guardian.profession!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            guardian.profession!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Contact Information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        if (guardian.email != null &&
                            guardian.email!.isNotEmpty) ...[
                          _DetailRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: guardian.email!,
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (guardian.phone != null &&
                            guardian.phone!.isNotEmpty) ...[
                          _DetailRow(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: guardian.phone!,
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (guardian.emergencyContact != null &&
                            guardian.emergencyContact!.isNotEmpty) ...[
                          _DetailRow(
                            icon: Icons.emergency,
                            label: 'Emergency Contact',
                            value: guardian.emergencyContact!,
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (guardian.address != null &&
                            guardian.address!.isNotEmpty) ...[
                          _DetailRow(
                            icon: Icons.location_on,
                            label: 'Address',
                            value: guardian.address!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (guardian.notes != null && guardian.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            guardian.notes!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Metadata
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        _DetailRow(
                          icon: Icons.calendar_today,
                          label: 'Created',
                          value: _formatDate(guardian.createdAt),
                        ),
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.update,
                          label: 'Last Updated',
                          value: _formatDate(guardian.updatedAt),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guardian'),
        content: const Text(
          'Are you sure you want to delete this guardian? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final provider = Provider.of<GuardianProvider>(
                context,
                listen: false,
              );
              await provider.deleteGuardian(guardianId);
              if (context.mounted) {
                Navigator.pop(context); // Go back to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Guardian deleted successfully'),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
