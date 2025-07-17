import 'package:anime_hub/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anime_hub/newreleasepage.dart';
import 'services.dart';
import 'model.dart';

class Details extends StatefulWidget {
  final Anime anime;
  const Details({super.key, required this.anime});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  late Future<List<Anime>> trendingFuture;
  late Future<List<Anime>> trendingAnimeFuture;

  @override
  void initState() {
    super.initState();
    trendingFuture = ApiService.fetchTopMovies();
    trendingAnimeFuture = ApiService.fetchTopMovies();// or a trending-specific method if you have one
  }

  @override
  Widget build(BuildContext context) {
    final anime = widget.anime;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CachedNetworkImage(
                  imageUrl: anime.trailerThumbnail ?? anime.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_circle_left_outlined, color: Colors.redAccent,size: 50,),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: -70,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: anime.imageUrl,
                            height: 200,
                            width: 150,
                            fit: BoxFit.cover,
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
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Year: ${anime.year ?? 'Unknown'}",
                                style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "IMDB Score: ${anime.score ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rating: ${anime.rating ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                anime.genres.join(', '),
                                style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 90),

            // ▶ Play Trailer Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  if (anime.trailerUrl != null) {
                    launchUrl(Uri.parse(anime.trailerUrl!));
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 120, vertical: 13),
                  child: Text("Play Trailer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                "Anime Synopsis",
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(maxLines: 5,
                overflow: TextOverflow.ellipsis,
                anime.synopsis ?? "No synopsis available.",
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14),
              ),
            ),

            // Trending Anime Section

            const SizedBox(height: 30),
            sectionHeader("Trending Anime", () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NewRelease()));
            }),
            animeListBuilder(trendingAnimeFuture, showScore: true),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
Widget sectionHeader(String title, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        InkWell(
          onTap: onTap,
          child: const Text("View All", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
        ),
      ],
    ),
  );
}

Widget animeListBuilder(Future<List<Anime>> futureList, {bool showScore = false}) {
  return FutureBuilder<List<Anime>>(
    future: futureList,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const ShimmerListLoader();
      } else if (snapshot.hasError) {
        return const Center(child: Text("Error loading anime", style: TextStyle(color: Colors.white)));
      }

      final trendingList = snapshot.data!;
      return SizedBox(
        height: 320,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: trendingList.length,
          itemBuilder: (context, index) {
            final anime = trendingList[index];
            return InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Details(anime: anime)));
              },
              child: Container(
                width: 170,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: anime.imageUrl,
                              height: 250,
                              width: 170,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const ShimmerLoader.rectangular(width: 170, height: 250),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.broken_image, color: Colors.white),
                            ),
                          ),
                          if (showScore && anime.score != null)
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                height: 30,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.red,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star, color: Colors.white, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      anime.score!.toStringAsFixed(1),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ]
                    ),
                    const SizedBox(height: 4),
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
