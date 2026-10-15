import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../app_theme.dart';
import '../constants.dart';

class PostDetailsScreen extends StatelessWidget {
  const PostDetailsScreen({super.key});

  static const double heroHeight = 330;
  static const double sheetOverlap = 40;

  // Part 3 (Create): save the post as a Map. The post id is the key,
  // so the same post can never be saved twice.
  void saveToFavorites(BuildContext context, Map<String, dynamic> post) {
    final favoritesBox = Hive.box(favoritesBoxName);
    final int postId = post['id'];

    if (favoritesBox.containsKey(postId)) {
      showMessage(context, 'This post is already in your favorites.');
      return;
    }

    favoritesBox.put(postId, {
      'id': postId,
      'title': post['title'],
      'body': post['body'],
      'note': '',
    });
    showMessage(context, 'Post saved to favorites.');
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // White round button with a soft shadow, used on the colored header.
  Widget buildRoundButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    Color iconColor = inkColor,
  }) {
    return Container(
      width: 46,
      height: 46,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: softShadow,
      ),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: 22, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }

  // The colored header. The post icon takes the place of a photo.
  Widget buildHero(int postId) {
    return Container(
      height: heroHeight,
      width: double.infinity,
      color: postColorFor(postId),
      child: Align(
        alignment: const Alignment(0, 0.1),
        child: Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(36),
            shape: BoxShape.circle,
          ),
          child: Icon(postIconFor(postId), size: 96, color: Colors.white),
        ),
      ),
    );
  }

  // Soft grey pill with a label on the left and a value on the right.
  Widget buildInfoPill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Part 1: retrieve the arguments passed from the Posts screen.
    final post =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int postId = post['id'];
    final String postNumber = postId.toString().padLeft(2, '0');
    final String bodyText = post['body'].toString();
    final int wordCount =
        bodyText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
    final int readMinutes = (wordCount / 200).ceil().clamp(1, 99);
    final favoritesBox = Hive.box(favoritesBoxName);

    // Rebuilds automatically when this post is saved.
    return ValueListenableBuilder(
      valueListenable: favoritesBox.listenable(keys: [postId]),
      builder: (context, box, child) {
        final bool isSaved = box.containsKey(postId);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            centerTitle: true,
            leadingWidth: 70,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: buildRoundButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            title: const Text(
              'Post Details',
              style: TextStyle(
                fontFamily: headingFont,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: buildRoundButton(
                    icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                    tooltip: isSaved ? 'Saved' : 'Not saved yet',
                    onPressed: null,
                    iconColor: primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: buildHero(postId),
              ),
              Positioned(
                top: heroHeight - sheetOverlap,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['title'],
                                  style: const TextStyle(
                                    fontFamily: headingFont,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  bodyText,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.7,
                                    color: mutedTextColor,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  '$readMinutes min read',
                                  style: const TextStyle(
                                    color: primaryGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            buildInfoPill('Post', '#$postNumber'),
                            const SizedBox(width: 12),
                            buildInfoPill('Length', '$wordCount words'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          16,
                          24,
                          MediaQuery.of(context).padding.bottom + 16,
                        ),
                        child: Row(
                          children: [
                            buildRoundButton(
                              icon: isSaved
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              tooltip: 'View favorites',
                              iconColor: primaryGreen,
                              onPressed: () => Navigator.pushNamed(
                                context,
                                favoritesRoute,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    saveToFavorites(context, post),
                                child: Text(
                                  isSaved
                                      ? 'Saved to Favorites'
                                      : 'Save to Favorites',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}