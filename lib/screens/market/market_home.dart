import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MarketScreen(),
    );
  }
}

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.green,
        // The title now uses an Image instead of Text
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 30, // Adjust height to fit the AppBar nicely
              fit: BoxFit.contain,
            ),
            const Text("Sri Lanka", style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: Text("සිංහල | தமிழ் | EN")),
          )
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Market Discovery",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("Connect directly with buyers & farmers"),

            const SizedBox(height: 15),

            // Prices Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Today's Market Prices"),
                  ),
                  const SizedBox(height: 10),

                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      PriceTile("Tomato", "Rs. 120", "+15%", true),
                      PriceTile("Onion", "Rs. 95", "-8%", false),
                      PriceTile("Chili", "Rs. 150", "+5%", true),
                      PriceTile("Brinjal", "Rs. 75", "-3%", false),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[100],
                    ),
                    onPressed: () {},
                    child: const Text("I Want to Buy"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    onPressed: () {},
                    child: const Text("I Want to Sell"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            TextField(
              decoration: InputDecoration(
                hintText: "Search by crop or location...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(14),
              ),
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text("Post New Listing"),
            ),

            const SizedBox(height: 20),

            const Text(
              "Available from Farmers",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const FarmerCard(
              name: "K.M. Silva",
              location: "Polonnaruwa",
              product: "Paddy (White Raw Rice)",
              qty: "2000 kg",
              price: "Rs. 85/kg",
              time: "2 hours ago",
              verified: true,
            ),

            const FarmerCard(
              name: "R. Perera",
              location: "Anuradhapura",
              product: "Red Onion",
              qty: "1500 kg",
              price: "Rs. 95/kg",
              time: "1 day ago",
              verified: false,
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                NavItem(icon: Icons.home, label: "Home"),
                NavItem(icon: Icons.camera_alt, label: "Diagnose"),
                NavItem(icon: Icons.store, label: "Market", isActive: true),
                NavItem(icon: Icons.eco, label: "Crops"),
              ],
            ),

            const SizedBox(height: 8),

            // Row 2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                NavItem(icon: Icons.cloud, label: "Weather"),
                NavItem(icon: Icons.forum, label: "Forum"),
                NavItem(icon: Icons.person, label: "Profile"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 🔹 NAV ITEM
class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: isActive ? Colors.green : Colors.grey),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}

// 🔹 PRICE TILE
class PriceTile extends StatelessWidget {
  final String name, price, change;
  final bool isUp;

  const PriceTile(this.name, this.price, this.change, this.isUp, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Icon(
                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: isUp ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 3),
              Text("$change this week",
                  style: TextStyle(
                      fontSize: 10,
                      color: isUp ? Colors.green : Colors.red)),
            ],
          ),
        ],
      ),
    );
  }
}

// 🔹 FARMER CARD
class FarmerCard extends StatelessWidget {
  final String name, location, product, qty, price, time;
  final bool verified;

  const FarmerCard({
    super.key,
    required this.name,
    required this.location,
    required this.product,
    required this.qty,
    required this.price,
    required this.time,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  if (verified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("Verified", style: TextStyle(fontSize: 10)),
                    )
                ],
              ),
              Text(time, style: const TextStyle(fontSize: 10)),
            ],
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              const Icon(Icons.location_on, size: 14),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Quantity: $qty", style: const TextStyle(fontSize: 12)),
                    Text(price,
                        style: const TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.message),
                  label: const Text("Message"),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call),
                label: const Text("Call"),
              )
            ],
          )
        ],
      ),
    );
  }
}