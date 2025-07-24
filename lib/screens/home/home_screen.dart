import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/guardian_provider.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const GuardiansTab(),
    const CalendarTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Guardians'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to ${AppConstants.appName}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Consumer<GuardianProvider>(
            builder: (context, guardianProvider, child) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Stats',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatCard(
                            title: 'Guardians',
                            value: '${guardianProvider.guardiansCount}',
                            icon: Icons.people,
                            color: Colors.blue,
                          ),
                          _StatCard(
                            title: 'Sessions',
                            value: '0',
                            icon: Icons.school,
                            color: Colors.green,
                          ),
                          _StatCard(
                            title: 'Payments',
                            value: '0',
                            icon: Icons.payment,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.green),
              title: const Text('Add Guardian'),
              subtitle: const Text('Start by adding your first guardian'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.guardiansAdd);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 32, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class GuardiansTab extends StatelessWidget {
  const GuardiansTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GuardianProvider>(
      builder: (context, guardianProvider, child) {
        if (guardianProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (guardianProvider.guardians.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No guardians yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first guardian to get started',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.guardiansAdd);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Guardian'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: guardianProvider.guardians.length,
          itemBuilder: (context, index) {
            final guardian = guardianProvider.guardians[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    guardian.name.isNotEmpty
                        ? guardian.name[0].toUpperCase()
                        : 'G',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(guardian.name),
                subtitle: guardian.email != null
                    ? Text(guardian.email!)
                    : guardian.phone != null
                    ? Text(guardian.phone!)
                    : const Text('No contact info'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Navigator.pushNamed(
                          context,
                          AppRoutes.guardiansEdit,
                          arguments: {AppRoutes.idParam: guardian.id},
                        );
                        break;
                      case 'delete':
                        _showDeleteDialog(
                          context,
                          guardianProvider,
                          guardian.id,
                        );
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
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.guardiansDetail,
                    arguments: {AppRoutes.idParam: guardian.id},
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    GuardianProvider provider,
    String id,
  ) {
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
              Navigator.pop(context);
              await provider.deleteGuardian(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Calendar view coming soon...'));
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Customize app appearance'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to theme settings
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Manage your data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to backup settings
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: Text('Version ${AppConstants.appVersion}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Show about dialog
            },
          ),
        ),
      ],
    );
  }
}
