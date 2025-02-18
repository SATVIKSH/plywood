import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:plywood_project/table.dart';

class HomeScreen extends HookWidget {
  final Map<String, dynamic> responseData;
  const HomeScreen({super.key, required this.responseData});
  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(0);
    final pageController = usePageController();

    void onPageChanged(int index) {
      currentIndex.value = index;
    }

    void onNavTapped(int index) {
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wood Vision',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          ImageScreen(
              imageUrl:
                  "https://fast-api-5dm5.onrender.com/outputs/output_image.jpg"),
          ImageScreen(
              imageUrl:
                  "https://fast-api-5dm5.onrender.com/outputs/log_circumference_distribution.png"),
          LogDataTableScreen(
            responseData: responseData,
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex.value,
        onTap: onNavTapped,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.image), label: "Output Image"),
          BottomNavigationBarItem(
              icon: Icon(Icons.insert_chart), label: "Chart"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Logs"),
        ],
      ),
    );
  }
}

class ImageScreen extends HookWidget {
  final String imageUrl;
  ImageScreen({required this.imageUrl});

  Future<void> _downloadImage() async {
    try {
      var imageId = await ImageDownloader.downloadImage(imageUrl);
      if (imageId == null) {
        return;
      }
      print("Image downloaded successfully!");
    } catch (error) {
      print("Failed to download image: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) =>
              Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => Icon(Icons.error),
          width: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    );
  }
}
