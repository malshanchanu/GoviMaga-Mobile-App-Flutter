import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../widgets/login_required_dialog.dart';

class MarketHome extends StatelessWidget {
  final String language;
  const MarketHome({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return MarketScreen(language: language);
  }
}

class MarketScreen extends StatefulWidget {
  final String language;
  const MarketScreen({super.key, required this.language});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'All';
  String _selectedType = 'buy'; // 'buy' or 'sell'
  String _selectedProductType = 'Vegetables';

  final List<String> _categories = [
    'All',
    'My Listings',
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
    'Tools',
  ];
  final List<String> _productTypes = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
    'Tools',
    'Seeds',
    'Fertilizer',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  String _t(String key) {
    final Map<String, Map<String, String>> translations = {
      'EN': {
        'title': 'Marketplace',
        'subtitle': 'Buy & sell farm products directly',
        'search': 'Search products...',
        'all': 'All',
        'my_listings': 'My Listings',
        'vegetables': 'Vegetables',
        'fruits': 'Fruits',
        'grains': 'Grains',
        'dairy': 'Dairy',
        'tools': 'Tools',
        'buy': 'I want to BUY',
        'sell': 'I want to SELL',
        'post_listing': 'Post New Listing',
        'product_name': 'Product Name',
        'price': 'Price (Rs.)',
        'quantity': 'Quantity',
        'location': 'Location',
        'description': 'Description',
        'post': 'Post Listing',
        'cancel': 'Cancel',
        'listings': 'Recent Listings',
        'contact': 'Contact Seller',
        'message': 'Message',
        'call': 'Call',
        'kg': 'kg',
        'litre': 'litre',
        'piece': 'piece',
        'verified': 'Verified',
        'negotiable': 'Negotiable',
        'urgent': 'Urgent Sale',
        'no_listings': 'No listings found',
        'login_to_post': 'Login to post',
        'sign_in': 'Sign In',
      },
      'SI': {
        'title': 'වෙළඳපොළ',
        'subtitle': 'සෘජුවම ගොවි නිෂ්පාදන මිලදී ගන්න සහ විකුණන්න',
        'search': 'නිෂ්පාදන සොයන්න...',
        'all': 'සියල්ල',
        'my_listings': 'මගේ දැන්වීම්',
        'vegetables': 'එළවළු',
        'fruits': 'පලතුරු',
        'grains': 'ධාන්‍ය',
        'dairy': 'කිරි ආශ්‍රිත',
        'tools': 'මෙවලම්',
        'buy': 'මම මිලදී ගැනීමට කැමතියි',
        'sell': 'මම විකිණීමට කැමතියි',
        'post_listing': 'නව දැන්වීමක් පළ කරන්න',
        'product_name': 'නිෂ්පාදනයේ නම',
        'price': 'මිල (රු.)',
        'quantity': 'ප්‍රමාණය',
        'location': 'ස්ථානය',
        'description': 'විස්තර',
        'post': 'දැන්වීම පළ කරන්න',
        'cancel': 'අවලංගු කරන්න',
        'listings': 'මෑත දැන්වීම්',
        'contact': 'විකුණුම්කරු අමතන්න',
        'message': 'පණිවිඩය',
        'call': 'අමතන්න',
        'kg': 'කිලෝ',
        'litre': 'ලීටර්',
        'piece': 'කෑලි',
        'verified': 'සත්‍යාපනය කළා',
        'negotiable': 'මිල සාකච්ඡා කළ හැක',
        'urgent': 'හදිසි විකිණීම',
        'no_listings': 'දැන්වීම් නැත',
        'login_to_post': 'දැන්වීමක් පළ කිරීමට පිවිසෙන්න',
        'sign_in': 'පිවිසෙන්න',
      },
      'TA': {
        'title': 'சந்தை',
        'subtitle': 'பண்ணை பொருட்களை நேரடியாக வாங்கவும் விற்கவும்',
        'search': 'பொருட்களைத் தேடுங்கள்...',
        'all': 'அனைத்தும்',
        'my_listings': 'எனது பட்டியல்கள்',
        'vegetables': 'காய்கறிகள்',
        'fruits': 'பழங்கள்',
        'grains': 'தானியங்கள்',
        'dairy': 'பால் பொருட்கள்',
        'tools': 'கருவிகள்',
        'buy': 'நான் வாங்க விரும்புகிறேன்',
        'sell': 'நான் விற்க விரும்புகிறேன்',
        'post_listing': 'புதிய பட்டியலை இடுகையிடுக',
        'product_name': 'பொருளின் பெயர்',
        'price': 'விலை (ரூ.)',
        'quantity': 'அளவு',
        'location': 'இடம்',
        'description': 'விளக்கம்',
        'post': 'இடுகையிடுக',
        'cancel': 'ரத்து செய்',
        'listings': 'சமீபத்திய பட்டியல்கள்',
        'contact': 'விற்பனையாளரை தொடர்பு கொள்ளுங்கள்',
        'message': 'செய்தி',
        'call': 'அழைக்கவும்',
        'kg': 'கிலோ',
        'litre': 'லிட்டர்',
        'piece': 'துண்டு',
        'verified': 'சரிபார்க்கப்பட்டது',
        'negotiable': 'பேரம் பேசலாம்',
        'urgent': 'அவசர விற்பனை',
        'no_listings': 'எந்த பட்டியல்களும் இல்லை',
        'login_to_post': 'இடுகையிட உள்நுழைக',
        'sign_in': 'உள்நுழைக',
      },
    };
    return translations[widget.language]?[key] ?? translations['EN']![key]!;
  }

  String _formatPrice(int price) {
    final format = NumberFormat('#,###');
    return 'Rs. ${format.format(price)}';
  }

  Future<void> _postListing() async {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    if (authProvider.isGuest || authProvider.user == null) {
      LoginRequiredDialog.show(context: context, action: 'post a listing');
      return;
    }
    
    if (_productController.text.trim().isEmpty || _priceController.text.trim().isEmpty) return;
    int? parsedPrice = int.tryParse(_priceController.text.trim());
    if (parsedPrice == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid numeric price.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('market_listings').add({
        'productName': _productController.text.trim(),
        'productType': _selectedProductType,
        'price': parsedPrice,
        'quantity': _quantityController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'type': _selectedType, // 'buy' or 'sell'
        'sellerId': authProvider.user?.uid ?? 'anonymous',
        'sellerName': authProvider.user?.displayName ?? 'Anonymous Farmer',
        'sellerPhone': authProvider.user?.phoneNumber ?? 'Not provided',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
        'views': 0,
        'contacts': 0,
      });

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing posted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateListing(String docId) async {
    if (_productController.text.trim().isEmpty || _priceController.text.trim().isEmpty) return;
    int? parsedPrice = int.tryParse(_priceController.text.trim());
    if (parsedPrice == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid numeric price.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('market_listings').doc(docId).update({
        'productName': _productController.text.trim(),
        'productType': _selectedProductType,
        'price': parsedPrice,
        'quantity': _quantityController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'type': _selectedType,
      });

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _deleteListing(String docId) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_t('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => _isLoading = true);
              try {
                await _firestore.collection('market_listings').doc(docId).delete();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing deleted successfully!')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
              setState(() => _isLoading = false);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _productController.clear();
    _priceController.clear();
    _quantityController.clear();
    _locationController.clear();
    _descriptionController.clear();
  }


  void _showPostListingDialog({DocumentSnapshot? listingToEdit}) {

    if (listingToEdit != null) {
      final data = listingToEdit.data() as Map<String, dynamic>;
      _productController.text = data['productName'] ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _quantityController.text = data['quantity'] ?? '';
      _locationController.text = data['location'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _selectedType = data['type'] ?? 'sell';
      _selectedProductType = data['productType'] ?? 'Vegetables';
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(listingToEdit != null ? 'Edit Listing' : _t('post_listing')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'sell',
                    label: Text('SELL'),
                    icon: Icon(Icons.sell),
                  ),
                  ButtonSegment(
                    value: 'buy',
                    label: Text('BUY'),
                    icon: Icon(Icons.shopping_cart),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (set) =>
                    setState(() => _selectedType = set.first),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedProductType,
                items: _productTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedProductType = value!),
                decoration: const InputDecoration(
                  labelText: 'Product Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _productController,
                decoration: InputDecoration(
                  hintText: _t('product_name'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  hintText: _t('price'),
                  border: const OutlineInputBorder(),
                  prefixText: 'Rs. ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  hintText: _t('quantity'),
                  border: const OutlineInputBorder(),
                  suffixText: _selectedProductType == 'Grains'
                      ? _t('kg')
                      : _t('piece'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: _t('location'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: _t('description'),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (listingToEdit != null) {
                _updateListing(listingToEdit.id);
              } else {
                _postListing();
              }
            },
            child: Text(listingToEdit != null ? 'Save Changes' : _t('post')),
          ),
        ],
      ),
    );
  }


  void _contactSeller(Map<String, dynamic> listing) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              child: Text(listing['sellerName'][0].toUpperCase()),
            ),
            const SizedBox(height: 12),
            Text(
              listing['sellerName'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              listing['location'],
              style: TextStyle(color: Colors.grey[600]),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                // Implement chat functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.call, color: Colors.blue),
              title: const Text('Call'),
              onTap: () {
                Navigator.pop(context);
                // Implement call functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context);
    final currentUser = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F4),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.storefront,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('title'),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _t('subtitle'),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (currentUser != null)
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: currentUser.photoURL != null
                              ? NetworkImage(currentUser.photoURL!)
                              : null,
                          child: currentUser.photoURL == null
                              ? Text(currentUser.displayName?[0] ?? '?')
                              : null,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: _t('search'),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // Categories
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category == 'My Listings' ? _t('my_listings') : (category == 'All' ? _t('all') : _t(category.toLowerCase()))),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : 'All';
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.green[100],
                    ),
                  );
                },
              ),
            ),

            // Listings
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('market_listings')
                          .where('status', isEqualTo: 'active')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        var listings = snapshot.data!.docs.toList();
                        listings.sort((a, b) {
                          final aData = a.data() as Map<String, dynamic>;
                          final bData = b.data() as Map<String, dynamic>;
                          final aTime = aData['timestamp'] as Timestamp?;
                          final bTime = bData['timestamp'] as Timestamp?;
                          if (aTime == null && bTime == null) return 0;
                          if (aTime == null) return 1; // Put nulls at the bottom
                          if (bTime == null) return -1;
                          return bTime.compareTo(aTime); // Descending order
                        });

                        // Filter by category
                        if (_selectedCategory == 'My Listings') {
                          listings = listings.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['sellerId'] == currentUser?.uid;
                          }).toList();
                        } else if (_selectedCategory != 'All') {
                          listings = listings.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['productType'] == _selectedCategory;
                          }).toList();
                        }

                        // Filter by search
                        if (_searchController.text.isNotEmpty) {
                          listings = listings.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['productName'].toLowerCase().contains(
                              _searchController.text.toLowerCase(),
                            );
                          }).toList();
                        }

                        if (listings.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _t('no_listings'),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: listings.length,
                          itemBuilder: (context, index) {
                            final doc = listings[index];
                            final listing = doc.data() as Map<String, dynamic>;
                            final timestamp = listing['timestamp'] as Timestamp?;
                            final isOwner = listing['sellerId'] == currentUser?.uid;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: listing['type'] == 'sell'
                                                    ? Colors.red[50]
                                                    : Colors.green[50],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                listing['type'] == 'sell'
                                                    ? 'FOR SALE'
                                                    : 'WANTED',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      listing['type'] == 'sell'
                                                      ? Colors.red[700]
                                                      : Colors.green[700],
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.amber[50],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                listing['productType'],
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.amber[800],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          listing['productName'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                listing['location'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.agriculture,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${listing['quantity']} ${listing['productType'] == 'Grains' ? _t('kg') : _t('piece')}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Text(
                                              _formatPrice(listing['price']),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1B5E20),
                                              ),
                                            ),
                                            const Spacer(),
                                            if (isOwner)
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                                    onPressed: () => _showPostListingDialog(listingToEdit: doc),
                                                    tooltip: 'Edit Listing',
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () => _deleteListing(doc.id),
                                                    tooltip: 'Delete Listing',
                                                  ),
                                                ],
                                              )
                                            else if (listing['type'] == 'sell')
                                              ElevatedButton.icon(
                                                onPressed: () =>
                                                    _contactSeller(listing),
                                                icon: const Icon(
                                                  Icons.message,
                                                  size: 16,
                                                ),
                                                label: Text(_t('contact')),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (timestamp != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Text(
                                              'Posted: ${DateFormat('MMM d, yyyy').format(timestamp.toDate())}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),

            // Post Listing Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
                  if (authProvider.isGuest || authProvider.user == null) {
                    LoginRequiredDialog.show(context: context, action: 'post a listing');
                    return;
                  }
                  _showPostListingDialog();
                },
                icon: const Icon(Icons.add),
                label: Text(_t('post_listing')),
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
