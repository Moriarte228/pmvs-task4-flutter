import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/library_model.dart';
import '../providers/library_provider.dart';
import '../services/notification_service.dart';
import 'library_detail_screen.dart';
import 'add_library_screen.dart';

class LibraryListScreen extends StatefulWidget {
  const LibraryListScreen({super.key});

  @override
  State<LibraryListScreen> createState() => _LibraryListScreenState();
}

class _LibraryListScreenState extends State<LibraryListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(LibraryModel lib, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteLibrary),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ok = await context.read<LibraryProvider>().removeLibrary(lib.id!);
    if (!mounted) return;
    if (ok) {
      NotificationService.instance.success(context, l10n.deleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.allLibraries),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: l10n.allLibraries,
            onPressed: () {
              _searchController.clear();
              context.read<LibraryProvider>().clearFilter();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<LibraryProvider>().setSearchQuery('');
                          setState(() {});
                        },
                      ),
              ),
              onChanged: (v) {
                context.read<LibraryProvider>().setSearchQuery(v);
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: Consumer<LibraryProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final libraries = provider.filteredLibraries;

                if (libraries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(provider.searchQuery.isNotEmpty
                            ? l10n.noResults
                            : l10n.noLibraries),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: libraries.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final lib = libraries[index];
                    return _LibraryCard(
                      library: lib,
                      locale: locale,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LibraryDetailScreen(library: lib),
                        ),
                      ),
                      onDelete: lib.id == null
                          ? null
                          : () => _confirmDelete(lib, l10n),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddLibraryScreen()),
          );
          if (!mounted) return;
          if (added == true) {
            NotificationService.instance.success(context, l10n.added);
          }
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addLibrary),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final LibraryModel library;
  final String locale;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _LibraryCard({
    required this.library,
    required this.locale,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Используем Dismissible для свайпа на мобильных.
    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.local_library,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: Text(library.getName(locale)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(library.getAddress(locale)),
            const SizedBox(height: 2),
            Text(
              '🕒 ${library.workingHours}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: onDelete != null
            ? IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                tooltip: 'Удалить',
                onPressed: onDelete,
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );

    if (onDelete == null) return card;

    return Dismissible(
      key: ValueKey('library_${library.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        onDelete!();
        return false;
      },
      child: card,
    );
  }
}
