import 'dart:async';
import 'package:anime_hub/detail.dart';
import 'package:anime_hub/services.dart';
import 'package:anime_hub/shimmer_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'newreleasepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Anime>> trendingAnimeFuture;
  late Future<List<Anime>> upcomingAnimeFuture;
  List<Anime> topFiveAnime = [];

  final PageController _pageController = PageController();
  int currentPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    trendingAnimeFuture = ApiService.fetchTopMovies();
    upcomingAnimeFuture = ApiService.fetchUpcomingAnime();

    final animeList = await trendingAnimeFuture;
    if (animeList.isNotEmpty) {
      setState(() {
        topFiveAnime = animeList.take(5).toList();
      });

      _bannerTimer?.cancel();
      _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_pageController.hasClients) {
          currentPage = (currentPage + 1) % topFiveAnime.length;
          _pageController.animateToPage(
            currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      topFiveAnime.clear();
    });
    await _loadData();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        color: Colors.red,
        backgroundColor: Colors.black,
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.50,
                child: Stack(
                  children: [
                    IgnorePointer(
                      ignoring: true,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: topFiveAnime.length,
                        onPageChanged: (index) {
                          setState(() => currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          final anime = topFiveAnime[index];
                          return CachedNetworkImage(
                            imageUrl: anime.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (context, url) => const ShimmerLoader.rectangular(
                              height: double.infinity,
                              width: double.infinity,
                            ),
                            errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, color: Colors.white),
                          );
                        },
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.9),
                            Colors.transparent,
                            Colors.black.withOpacity(1.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      left: 20,
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.black87,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (_) => const SizedBox(height: 0),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 30,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (topFiveAnime.isNotEmpty)
                            Text(
                              topFiveAnime[currentPage].title,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(height: 5),
                          if (topFiveAnime.isNotEmpty &&
                              topFiveAnime[currentPage].synopsis != null &&
                              topFiveAnime[currentPage].synopsis!.isNotEmpty)
                            Text(
                              topFiveAnime[currentPage].synopsis!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (topFiveAnime.isNotEmpty)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Details(anime: topFiveAnime[currentPage]),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text("Play",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              const SizedBox(width: 15),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.add),
                                label: const Text("My List",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(topFiveAnime.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: currentPage == index ? 12 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color:
                                  currentPage == index ? Colors.redAccent : Colors.white54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              sectionHeader("Trending Anime", () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => NewRelease()));
              }),
              animeListBuilder(trendingAnimeFuture, showScore: true),
              const SizedBox(height: 20),
              sectionHeader("Upcoming Anime", () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => NewRelease()));
              }),
              animeListBuilder(upcomingAnimeFuture, showScore: false),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          InkWell(
            onTap: onTap,
            child: const Text("View All",
                style: TextStyle(color: Colors.redAccent, fontSize: 16)),
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
          return const Center(
              child: Text("Error loading anime", style: TextStyle(color: Colors.white)));
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
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Details(anime: anime)));
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
                              placeholder: (context, url) =>
                              const ShimmerLoader.rectangular(width: 170, height: 250),
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
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
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
}
