import 'package:flutter/material.dart';
import '../core/utils/responsive_utils.dart';

class ResponsiveStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ResponsiveStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, constraints) => _buildCard(context, constraints),
      tablet: (context, constraints) => _buildCard(context, constraints),
      desktop: (context, constraints) => _buildCard(context, constraints),
    );
  }

  Widget _buildCard(BuildContext context, BoxConstraints constraints) {
    final isLargeScreen = constraints.maxWidth >= ResponsiveBreakpoints.tablet;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isLargeScreen ? 12 : 8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isLargeScreen ? 28 : 24,
                  ),
                ),
              ),
              SizedBox(height: isLargeScreen ? 12 : 8),
              Flexible(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 20 : 18,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: isLargeScreen ? 6 : 4),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: isLargeScreen ? 14 : 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, constraints) => _buildGrid(context, 2),
      tablet: (context, constraints) => _buildGrid(context, 3),
      desktop: (context, constraints) => _buildGrid(context, 4),
    );
  }

  Widget _buildGrid(BuildContext context, int crossAxisCount) {
    // Adjust aspect ratio based on screen size to prevent overflow
    double aspectRatio = childAspectRatio ?? 1.0;
    if (crossAxisCount <= 2) {
      aspectRatio = childAspectRatio ?? 1.1; // Mobile - more height
    } else if (crossAxisCount == 3) {
      aspectRatio = childAspectRatio ?? 1.05; // Tablet - slightly more height
    } else {
      aspectRatio = childAspectRatio ?? 1.0; // Desktop - square-ish
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: aspectRatio,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      children: children,
    );
  }
}

class ResponsiveListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ResponsiveListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, constraints) => _buildMobileListTile(context),
      tablet: (context, constraints) => _buildTabletListTile(context),
      desktop: (context, constraints) => _buildDesktopListTile(context),
    );
  }

  Widget _buildMobileListTile(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildTabletListTile(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: subtitle != null
            ? Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium)
            : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildDesktopListTile(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
