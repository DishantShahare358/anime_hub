import 'package:anime_hub/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:anime_hub/model.dart';
import 'package:anime_hub/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'detail.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late Future<List<Anime>> animeFuture;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    animeFuture = ApiService.searchAnime(""); // Load all anime initially
  }

  void _filterAnime(String query) {
    setState(() {
      animeFuture = ApiService.searchAnime(query); // Query can be empty or user input
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      animeFuture = ApiService.searchAnime(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 12, right: 12, bottom: 12),
            child: TextField(
              controller: _controller,
              onChanged: _filterAnime,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: "Search Anime",
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.redAccent,
              backgroundColor: Colors.black,
              child: FutureBuilder<List<Anime>>(
                future: animeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      itemCount: 6,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            ShimmerLoader.rectangular(height: 170),
                            SizedBox(height: 6),
                            ShimmerLoader.rectangular(width: 100, height: 14),
                          ],
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("Error loading anime", style: TextStyle(color: Colors.white)),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No anime found", style: TextStyle(color: Colors.white)),
                    );
                  }

                  final List<Anime> animeList = snapshot.data!;
                  return GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    itemCount: animeList.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final anime = animeList[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Details(anime: anime)),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: anime.imageUrl,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                const ShimmerLoader.rectangular(height: 170),
                                errorWidget: (_, __, ___) =>
                                const Icon(Icons.error, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            anime.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, color: Colors.white),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
