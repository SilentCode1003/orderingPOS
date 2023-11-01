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

var slideImagePaths = [
  'ricemeals.jpg',
  'drinkricemeals.jpg',
  'drinksricemeals2.jpg'
];

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
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
      ),
    )
    .toList();

void main() => runApp(const Dashoboard());

class Dashoboard extends StatelessWidget {
  const Dashoboard({Key? key}) : super(key: key);

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
    var args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var value = args['key'];
    print(value);

    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false, // This line hides the back button

        title: Text('Urban Hideout Cafe'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown,
              ),
              child: Text(
                'Urban Hideout Cafe $value',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_2_rounded),
              title: const Text('Profile'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.pushReplacementNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Orders'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.pushReplacementNamed(context, '/order');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('History'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.pushReplacementNamed(context, '/history');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // Add your action when Settings is tapped
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          // Product Recommendations Section
          const SizedBox(
            height: 5,
          ),
          ExpandableCarousel(
            options: CarouselOptions(
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 10),
              disableCenter: false,
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
                    title: 'Orders',
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
