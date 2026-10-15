import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../app_theme.dart';
import '../constants.dart';
import '../widgets/edit_note_dialog.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // Part 3 (Update): change the personal note and put the post back in the box.
  Future<void> editNote(
    BuildContext context,
    Map<dynamic, dynamic> savedPost,
  ) async {
    final String? newNote = await showDialog<String>(
      context: context,
      builder: (context) =>
          EditNoteDialog(currentNote: (savedPost['note'] ?? '') as String),
    );

    if (newNote == null) return;

    final updatedPost = Map<dynamic, dynamic>.from(savedPost);
    updatedPost['note'] = newNote;
    await Hive.box(favoritesBoxName).put(savedPost['id'], updatedPost);

    if (!context.mounted) return;
    showMessage(context, 'Note updated.');
  }

  // Part 3 (Delete): remove the post from the box.
  Future<void> deleteFavorite(
    BuildContext context,
    Map<dynamic, dynamic> savedPost,
  ) async {
    await Hive.box(favoritesBoxName).delete(savedPost['id']);

    if (!context.mounted) return;
    showMessage(context, 'Removed from favorites.');
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget buildEmptyMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: chipColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 40,
                color: primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No favorites yet',
              style: TextStyle(
                fontFamily: headingFont,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Open a post and tap "Save to Favorites".',
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFavoriteCard(
    BuildContext context,
    Map<dynamic, dynamic> savedPost,
  ) {
    final int postId = savedPost['id'];
    final String postNumber = postId.toString().padLeft(2, '0');
    final String note = (savedPost['note'] ?? '') as String;
    final bool hasNote = note.isNotEmpty;

    return SoftCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccentStrip(postId: postId),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      savedPost['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: headingFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        InfoChip(label: 'Post $postNumber', icon: Icons.tag),
                        InfoChip(
                          label: 'Saved',
                          dotColor: postColorFor(postId),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        hasNote ? note : 'No note yet',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: hasNote ? inkColor : mutedTextColor,
                          fontStyle:
                              hasNote ? FontStyle.normal : FontStyle.italic,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Edit note',
                          icon: const Icon(Icons.edit_outlined),
                          color: primaryGreen,
                          onPressed: () => editNote(context, savedPost),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                          color: errorColor,
                          onPressed: () => deleteFavorite(context, savedPost),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesBox = Hive.box(favoritesBoxName);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      // Part 3 (Read): list everything in the box using box.values.
      body: ValueListenableBuilder(
        valueListenable: favoritesBox.listenable(),
        builder: (context, box, child) {
          final savedPosts = box.values.toList();

          if (savedPosts.isEmpty) {
            return buildEmptyMessage();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'Saved posts',
                trailingText: '${savedPosts.length} saved',
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: savedPosts.length,
                  itemBuilder: (context, index) {
                    return buildFavoriteCard(
                      context,
                      savedPosts[index] as Map<dynamic, dynamic>,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}