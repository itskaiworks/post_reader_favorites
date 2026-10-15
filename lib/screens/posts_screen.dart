import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_theme.dart';
import '../constants.dart';
import '../widgets/add_post_dialog.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> posts = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Posts whose title matches what the user typed in the search bar.
  List<dynamic> get filteredPosts {
    final String query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return posts;
    return posts
        .where((post) => post['title'].toString().toLowerCase().contains(query))
        .toList();
  }

  // Part 2: GET request. Parse only when statusCode is 200.
  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(postsApiUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedPosts = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          posts = decodedPosts;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Could not load posts. Server returned status code ${response.statusCode}.';
          isLoading = false;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage =
            'Could not load posts. Please check your internet connection.\n($error)';
        isLoading = false;
      });
    }
  }

  // Part 2: POST request. 201 means success, anything else is a failure.
  Future<void> sendNewPost(Map<String, String> newPost) async {
    try {
      final response = await http.post(
        Uri.parse(postsApiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'title': newPost['title'],
          'body': newPost['body'],
          'userId': 1,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        showMessage('Post created successfully (status code 201).');
      } else {
        showMessage(
          'Failed to create post. Status code: ${response.statusCode}.',
          isError: true,
        );
      }
    } catch (error) {
      if (!mounted) return;
      showMessage('Failed to create post. $error', isError: true);
    }
  }

  Future<void> openAddPostDialog() async {
    final newPost = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddPostDialog(),
    );

    if (newPost != null) {
      await sendNewPost(newPost);
    }
  }

  void showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorColor : successColor,
      ),
    );
  }

  void openPostDetails(Map<String, dynamic> post) {
    // Part 1: pass id, title and body as arguments.
    Navigator.pushNamed(
      context,
      detailsRoute,
      arguments: {
        'id': post['id'],
        'title': post['title'],
        'body': post['body'],
      },
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: softShadow,
        ),
        child: TextField(
          controller: searchController,
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search a post',
            hintStyle: const TextStyle(color: mutedTextColor),
            prefixIcon: const Icon(Icons.search, color: mutedTextColor),
            suffixIcon: searchQuery.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close, color: mutedTextColor),
                    onPressed: () {
                      searchController.clear();
                      setState(() => searchQuery = '');
                    },
                  ),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget buildPostCard(Map<String, dynamic> post) {
    final int postId = post['id'];
    final Color accentColor = postColorFor(postId);
    final String postNumber = postId.toString().padLeft(2, '0');
    final String bodyPreview = post['body'].toString().replaceAll('\n', ' ');

    return SoftCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: InkWell(
        onTap: () => openPostDetails(post),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AccentStrip(postId: postId),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['title'],
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
                            label: 'User ${post['userId']}',
                            dotColor: accentColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        bodyPreview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: mutedTextColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Center(
                  child: Icon(Icons.chevron_right, color: mutedTextColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: mutedTextColor),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: mutedTextColor, height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: fetchPosts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return buildErrorView();
    }

    final shownPosts = filteredPosts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSearchBar(),
        SectionHeader(
          title: 'All posts',
          trailingText: '${shownPosts.length} posts',
        ),
        Expanded(
          child: shownPosts.isEmpty
              ? const Center(
                  child: Text(
                    'No posts match your search.',
                    style: TextStyle(color: mutedTextColor),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: shownPosts.length,
                  itemBuilder: (context, index) {
                    return buildPostCard(
                      shownPosts[index] as Map<String, dynamic>,
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Reader'),
        actions: [
          CircleIconButton(
            icon: Icons.favorite,
            tooltip: 'Favorites',
            onPressed: () => Navigator.pushNamed(context, favoritesRoute),
          ),
        ],
      ),
      body: buildBody(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New post',
        onPressed: openAddPostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}