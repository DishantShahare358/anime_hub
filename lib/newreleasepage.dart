import 'package:anime_hub/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail.dart';
import 'model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'services.dart';

class NewRelease extends StatefulWidget {
  const NewRelease({super.key});

  @override
  State<NewRelease> createState() => _NewReleaseState();
}

class _NewReleaseState extends State<NewRelease> {
  late Future<List<Anime>> newReleaseFuture;

  @override
  void initState() {
    super.initState();
    newReleaseFuture = ApiService.fetchUpcomingAnime();
  }

  Future<void> _onRefresh() async {
    setState(() {
      newReleaseFuture = ApiService.fetchUpcomingAnime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("New Releases",
            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Anime>>(
        future: newReleaseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show shimmer layout
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLoader.rectangular(width: 120, height: 150),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerLoader.rectangular(width: double.infinity, height: 20),
                          SizedBox(height: 8),
                          ShimmerLoader.rectangular(width: 200, height: 16),
                          SizedBox(height: 6),
                          ShimmerLoader.rectangular(width: 150, height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white)),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No new anime found.",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            );
          }

          final allAnime = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: Colors.redAccent,
            backgroundColor: Colors.black,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: allAnime.length,
              itemBuilder: (context, index) {
                final anime = allAnime[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Details(anime: anime)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: anime.imageUrl,
                            width: 200,
                            height: 250,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                            const ShimmerLoader.rectangular(width: 120, height: 150),
                            errorWidget: (_, __, ___) =>
                            const Icon(Icons.error, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                anime.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    anime.releaseDate != null
                                        ? DateFormat.yMMMd().format(DateTime.parse(anime.releaseDate!))
                                        : 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Genres: ${anime.genres.join(', ')}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Description: ${anime.synopsis}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
