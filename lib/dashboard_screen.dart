import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class Slide {
  Slide({
    required this.title,
    required this.height,
    required this.imagePath,
  });

  final String imagePath;
  final double height;
  final String title;
}

const double uniformSlideHeight = 250.0;

var slideImagePaths = ['mc1.jpg', 'mc2.jpg', 'mc3.png', 'mc4.png'];

var slides = List.generate(
  slideImagePaths.length,
  (index) => Slide(
    title: 'Slide ${index + 1}',
    height: uniformSlideHeight,
    imagePath: 'assets/${slideImagePaths[index]}',
  ),
);

final List<Widget> sliders = slides
    .map(
      (item) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          child: SizedBox(
            width: double.infinity,
            height: item.height,
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    )
    .toList();

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App Title',
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This line hides the back button

        title: const Text('Dashboard'),
      ),
      body: Column(
        children: <Widget>[
          // Product Recommendations Section
          ExpandableCarousel(
            options: CarouselOptions(
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 20),
              disableCenter: true,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              slideIndicator: const CircularSlideIndicator(),
            ),
            items: sliders,
          ),

          // Dashboard Buttons Section
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                children: <Widget>[
                  DashboardItem(
                    title: 'Menu',
                    icon: Icons.shopping_cart,
                    onTap: () {
                      Navigator.pushNamed(context, '/product_listing');
                    },
                  ),
                  DashboardItem(
                    title: 'Cart',
                    icon: Icons.assignment,
                    onTap: () {
                      Navigator.pushNamed(context, '/orders');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onTap;

  const DashboardItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 64),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
