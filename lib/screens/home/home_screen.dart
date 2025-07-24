import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/guardian_provider.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/responsive_widgets.dart';
import '../../widgets/responsive_scaffold.dart';
import '../../core/utils/responsive_utils.dart';

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
    return ResponsiveScaffold(
      title: AppConstants.appName,
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
      padding: ResponsiveHelper.getScreenPadding(context),
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
                  padding: ResponsiveHelper.getScreenPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Stats',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ResponsiveGrid(
                        childAspectRatio: 1.0,
                        children: [
                          ResponsiveStatsCard(
                            title: 'Guardians',
                            value: '${guardianProvider.guardiansCount}',
                            icon: Icons.people,
                            color: Colors.blue,
                            onTap: () {
                              // Navigate to guardians
                            },
                          ),
                          ResponsiveStatsCard(
                            title: 'Sessions',
                            value: '0',
                            icon: Icons.school,
                            color: Colors.green,
                            onTap: () {
                              // Navigate to sessions
                            },
                          ),
                          ResponsiveStatsCard(
                            title: 'Payments',
                            value: '0',
                            icon: Icons.payment,
                            color: Colors.orange,
                            onTap: () {
                              // Navigate to payments
                            },
                          ),
                          ResponsiveStatsCard(
                            title: 'Reports',
                            value: '0',
                            icon: Icons.analytics,
                            color: Colors.purple,
                            onTap: () {
                              // Navigate to reports
                            },
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
      padding: ResponsiveHelper.getScreenPadding(context),
      children: [
        ResponsiveListTile(
          title: 'Theme',
          subtitle: 'Customize app appearance',
          leading: const Icon(Icons.palette),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to theme settings
          },
        ),
        const SizedBox(height: 8),
        ResponsiveListTile(
          title: 'Backup & Restore',
          subtitle: 'Manage your data',
          leading: const Icon(Icons.backup),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to backup settings
          },
        ),
        const SizedBox(height: 8),
        ResponsiveListTile(
          title: 'About',
          subtitle: 'Version ${AppConstants.appVersion}',
          leading: const Icon(Icons.info),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Show about dialog
          },
        ),
      ],
    );
  }
}
