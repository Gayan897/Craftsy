import 'dart:convert';
import 'dart:io';

import 'package:craft/pages/cart_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String name;
  String email;
  String phoneNumber;
  String address;
  String profileImage;
  List<Map<String, dynamic>> orderHistory;
  String memberSince;

  UserProfile({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.profileImage,
    required this.orderHistory,
    required this.memberSince,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? 'Guest User',
      email: json['email'] ?? 'guest@example.com',
      phoneNumber: json['phoneNumber'] ?? '+1 234 567 8900',
      address: json['address'] ?? 'No address specified',
      profileImage: json['profileImage'] ?? 'assets/default_profile.jpg',
      orderHistory: List<Map<String, dynamic>>.from(json['orderHistory'] ?? []),
      memberSince: json['memberSince'] ?? 'May 2025',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImage': profileImage,
      'orderHistory': orderHistory,
      'memberSince': memberSince,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? profileImage,
    List<Map<String, dynamic>>? orderHistory,
    String? memberSince,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
      orderHistory: orderHistory ?? this.orderHistory,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({Key? key}) : super(key: key);

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfile _userProfile = UserProfile(
    name: 'Guest User',
    email: 'guest@example.com',
    phoneNumber: '+1 234 567 8900',
    address: '123 Crafts Avenue, Artisan City,',
    profileImage: 'assets/default_profile.jpg',
    orderHistory: [],
    memberSince: 'May 2025',
  );

  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Track loyalty points and membership level
  int _loyaltyPoints = 250;
  String _membershipLevel = 'Silver';

  // Cart manager for order data
  // ignore: unused_field
  final CartManager _cartManager = CartManager();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); // Reduced from 3 to 2 tabs
    _loadUserProfile();

    // Initialize text controllers
    _nameController.text = _userProfile.name;
    _emailController.text = _userProfile.email;
    _phoneController.text = _userProfile.phoneNumber;
    _addressController.text = _userProfile.address;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Load user profile from SharedPreferences
  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userProfileJson = prefs.getString('userProfile');

      if (userProfileJson != null) {
        final userProfileData = jsonDecode(userProfileJson);
        setState(() {
          _userProfile = UserProfile.fromJson(userProfileData);
          _nameController.text = _userProfile.name;
          _emailController.text = _userProfile.email;
          _phoneController.text = _userProfile.phoneNumber;
          _addressController.text = _userProfile.address;

          // Calculate loyalty points based on order history
          _calculateLoyaltyPointsAndLevel();
        });
      }
    } catch (e) {
      _showSnackBar('Error loading profile: $e');
    }
  }

  // Save user profile to SharedPreferences
  Future<void> _saveUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userProfileJson = jsonEncode(_userProfile.toJson());
      await prefs.setString('userProfile', userProfileJson);
    } catch (e) {
      _showSnackBar('Error saving profile: $e');
    }
  }

  void _calculateLoyaltyPointsAndLevel() {
    // Calculate points based on order history (10 points per Rs.100 spent)
    double totalSpent = 0;
    for (var order in _userProfile.orderHistory) {
      totalSpent += order['total'] as double;
    }

    setState(() {
      _loyaltyPoints = (totalSpent / 100 * 10).round();

      // Set membership level based on points
      if (_loyaltyPoints >= 1000) {
        _membershipLevel = 'Platinum';
      } else if (_loyaltyPoints >= 500) {
        _membershipLevel = 'Gold';
      } else if (_loyaltyPoints >= 200) {
        _membershipLevel = 'Silver';
      } else {
        _membershipLevel = 'Bronze';
      }
    });
  }

  // Show a snackbar with message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        backgroundColor: Colors.black,
      ),
    );
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final newPath = await _saveImageToAppDirectory(pickedFile.path);
        setState(() {
          _userProfile = _userProfile.copyWith(profileImage: newPath);
        });
        _saveUserProfile();
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e');
    }
  }

  // Save an image to app's documents directory for persistence
  Future<String> _saveImageToAppDirectory(String originalPath) async {
    final File originalFile = File(originalPath);
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String newPath = '${appDir.path}/$fileName';

    // Copy the file to app's documents directory
    await originalFile.copy(newPath);
    return newPath;
  }

  // Show image source selector dialog
  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Save profile edits
  void _saveProfileEdits() {
    setState(() {
      _userProfile = _userProfile.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
      );
      _isEditing = false;
    });
    _saveUserProfile();
    _showSnackBar('Profile updated successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Account',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit_outlined,
                  color: Colors.black),
              onPressed: () {
                if (_isEditing) {
                  _saveProfileEdits();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showComingSoonDialog('Orders Feature');
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.shopping_bag_outlined),
        label: const Text('My Orders'),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$feature Coming Soon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.engineering_outlined,
                size: 60,
                color: Colors.amber[700],
              ),
              const SizedBox(height: 16),
              Text(
                'We\'re working hard to bring you the $feature. Stay tuned for updates!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header with image and basic info
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildProfileImage(_userProfile.profileImage),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _isEditing ? '' : _userProfile.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEditing ? '' : 'Member since ${_userProfile.memberSince}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // Loyalty card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _membershipLevel == 'Platinum'
                          ? [const Color(0xFFE5E4E2), const Color(0xFFB4B4B4)]
                          : _membershipLevel == 'Gold'
                              ? [
                                  const Color(0xFFFFD700),
                                  const Color(0xFFFCC200)
                                ]
                              : _membershipLevel == 'Silver'
                                  ? [
                                      const Color(0xFFC0C0C0),
                                      const Color(0xFFE6E6E6)
                                    ]
                                  : [
                                      const Color(0xFFCD7F32),
                                      const Color(0xFFE6BB8A)
                                    ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_userProfile.name.split(' ')[0]}\'s Rewards',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _membershipLevel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_loyaltyPoints points',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Earn 10 points for every Rs.100 spent',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _membershipLevel == 'Bronze'
                            ? _loyaltyPoints / 200.0
                            : _membershipLevel == 'Silver'
                                ? _loyaltyPoints / 500.0
                                : _membershipLevel == 'Gold'
                                    ? _loyaltyPoints / 1000.0
                                    : 1.0,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _membershipLevel == 'Platinum'
                            ? 'You\'ve reached our highest tier!'
                            : _membershipLevel == 'Gold'
                                ? '${1000 - _loyaltyPoints} points until Platinum'
                                : _membershipLevel == 'Silver'
                                    ? '${500 - _loyaltyPoints} points until Gold'
                                    : '${200 - _loyaltyPoints} points until Silver',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Personal information fields
          _isEditing
              ? Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.home_outlined,
                      maxLines: 3,
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildInfoItem(
                      label: 'Full Name',
                      value: _userProfile.name,
                      icon: Icons.person_outline,
                    ),
                    _buildInfoItem(
                      label: 'Email',
                      value: _userProfile.email,
                      icon: Icons.email_outlined,
                    ),
                    _buildInfoItem(
                      label: 'Phone Number',
                      value: _userProfile.phoneNumber,
                      icon: Icons.phone_outlined,
                    ),
                    _buildInfoItem(
                      label: 'Address',
                      value: _userProfile.address,
                      icon: Icons.home_outlined,
                    ),
                  ],
                ),
          const SizedBox(height: 32),
          const Text(
            'Available Offers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Offers/Coupons
          _buildOfferCard(
            title: 'Easter Special Discount',
            description: 'Get 50% off on selected items',
            code: 'EASTER50',
            expiry: 'Valid till May 30, 2025',
            color: Colors.purple.shade100,
          ),
          const SizedBox(height: 12),
          _buildOfferCard(
            title: '${_membershipLevel} Member Exclusive',
            description: 'Free shipping on orders above Rs.1500',
            code: 'FREESHIP',
            expiry: 'Valid till June 15, 2025',
            color: Colors.green.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Change your account password',
            onTap: () {
              _showSnackBar('Change password feature coming soon');
            },
          ),
          _buildSettingItem(
            icon: Icons.payment,
            title: 'Payment Methods',
            subtitle: 'Add or remove payment methods',
            onTap: () {
              _showSnackBar('Payment methods management coming soon');
            },
          ),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage your notification preferences',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                _showSnackBar(
                    value ? 'Notifications enabled' : 'Notifications disabled');
              },
              activeColor: Colors.black,
            ),
          ),
          _buildSettingItem(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'Change app language',
            trailing: const Text(
              'English',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            onTap: () {
              _showSnackBar('Language settings coming soon');
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'Get help with your orders and account',
            onTap: () {
              _showSnackBar('Help center coming soon');
            },
          ),
          _buildSettingItem(
            icon: Icons.policy_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              _showSnackBar('Privacy policy coming soon');
            },
          ),
          _buildSettingItem(
            icon: Icons.contact_support_outlined,
            title: 'Contact Us',
            subtitle: 'Get in touch with our support team',
            onTap: () {
              _showSnackBar('Contact support coming soon');
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Danger Zone',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and data',
            iconColor: Colors.red,
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _showSnackBar('Logged out successfully');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'App Version 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String imagePath) {
    try {
      // For asset images
      if (imagePath.startsWith('assets/')) {
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 80);
          },
        );
      }
      // For network images
      else if (imagePath.startsWith('http://') ||
          imagePath.startsWith('https://')) {
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 80);
          },
        );
      }
      // For local file images
      else {
        final file = File(imagePath);
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 80);
          },
        );
      }
    } catch (e) {
      return const Icon(Icons.person, size: 80);
    }
  }

  Widget _buildInfoItem(
      {required String label, required String value, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildOfferCard({
    required String title,
    required String description,
    required String code,
    required String expiry,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                expiry,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = Colors.black54,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar('Account deletion feature coming soon');
              },
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
