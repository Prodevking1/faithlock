import 'package:faithlock/services/analytics/posthog/export.dart';
import 'package:faithlock/services/analytics/posthog/utils/marketing_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// PostHog Demo Screen - E-commerce App
/// 
/// This screen demonstrates all PostHog modules in action:
/// - Event Tracking
/// - User Analytics
/// - Screen Tracking
/// - Feature Flags
/// - Session Recording
/// - Conversion Funnels
/// - Campaign Tracking
/// - Surveys
class PostHogDemoScreen extends StatefulWidget {
  const PostHogDemoScreen({super.key});

  @override
  State<PostHogDemoScreen> createState() => _PostHogDemoScreenState();
}

class _PostHogDemoScreenState extends State<PostHogDemoScreen> {
  final PostHogService _postHog = PostHogService.instance;
  
  // Demo state
  bool _isUserLoggedIn = false;
  String _userId = '';
  bool _showNewCheckout = false;
  String _buttonColor = 'blue';
  final List<Product> _cart = [];
  double _cartTotal = 0.0;
  
  // Demo products
  final List<Product> _products = [
    Product('1', 'Premium Widget', 29.99, 'electronics'),
    Product('2', 'Super Gadget', 49.99, 'electronics'),
    Product('3', 'Mega Tool', 19.99, 'tools'),
    Product('4', 'Ultra Device', 99.99, 'electronics'),
  ];

  @override
  void initState() {
    super.initState();
    _initializeDemo();
  }

  Future<void> _initializeDemo() async {
    // Wait for PostHog to be initialized
    if (!_postHog.isInitialized) {
      print('PostHog not yet initialized. Waiting...');
      // Wait a bit and try again, or skip demo initialization
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_postHog.isInitialized) {
        print('PostHog still not initialized. Skipping demo initialization.');
        return;
      }
    }

    try {
      // 1. Screen Tracking Module
      await _postHog.screens.trackScreen(
        screenName: 'PostHogDemoScreen',
        properties: {'demo_mode': true, 'products_count': _products.length},
      );

      // 2. Feature Flags Module
      _showNewCheckout = await _postHog.featureFlags.isEnabled('new_checkout_ui');
      final colorVariant = await _postHog.featureFlags.getFlagValue('button_color');
      if (colorVariant != null) {
        setState(() => _buttonColor = colorVariant as String);
      }

      // 3. Session Recording Module
      await _postHog.sessions.startRecording();
      await _postHog.sessions.addSessionTags([
        'demo_session',
        GetPlatform.isMobile ? 'mobile' : 'desktop',
      ]);
    } catch (e) {
      print('Error initializing PostHog demo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PostHog Demo Store'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _showCart,
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cart.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Section
            _buildUserSection(),
            
            // Marketing Campaign Section
            _buildCampaignSection(),
            
            // Products Grid
            _buildProductsSection(),
            
            // Feature Flags Demo
            _buildFeatureFlagsSection(),
            
            // Survey Section
            _buildSurveySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '👤 User Analytics Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          if (!_isUserLoggedIn) ...[
            ListTile(
              title: const Text('Sign Up (New User)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _simulateSignUp,
            ),
            ListTile(
              title: const Text('Login (Existing User)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _simulateLogin,
            ),
          ] else ...[
            ListTile(
              title: Text('Logged in as: $_userId'),
              subtitle: const Text('Tap to update profile'),
              trailing: const Icon(Icons.edit, size: 16),
              onTap: _updateUserProfile,
            ),
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.logout, size: 16),
              onTap: _simulateLogout,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCampaignSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '📈 Marketing Campaign Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Simulate Campaign Click'),
            subtitle: const Text('Track ad campaign interaction'),
            trailing: const Icon(Icons.ads_click, size: 16),
            onTap: _simulateCampaignClick,
          ),
          ListTile(
            title: const Text('Track Email Open'),
            subtitle: const Text('Email campaign tracking'),
            trailing: const Icon(Icons.email, size: 16),
            onTap: _trackEmailCampaign,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '🛍️ Products (Conversion Tracking)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ..._products.map((product) {
            final isInCart = _cart.contains(product);
            return ListTile(
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)} - ${product.category}'),
              trailing: ElevatedButton(
                onPressed: isInCart ? null : () => _addToCart(product),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 36),
                ),
                child: Text(isInCart ? 'In Cart' : 'Add'),
              ),
              onTap: () => _viewProduct(product),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureFlagsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '🚩 Feature Flags Demo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('New Checkout UI'),
            subtitle: Text(_showNewCheckout ? 'Enabled' : 'Disabled'),
            value: _showNewCheckout,
            onChanged: null, // Read-only from feature flag
          ),
          ListTile(
            title: const Text('Button Color Variant'),
            subtitle: Text('Current: $_buttonColor'),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _getColorFromString(_buttonColor),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (_cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getColorFromString(_buttonColor),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text('Checkout (\$${_cartTotal.toStringAsFixed(2)})'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSurveySection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '📋 Surveys & Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Rate Our App (NPS)'),
            subtitle: const Text('Net Promoter Score survey'),
            trailing: const Icon(Icons.star, size: 16),
            onTap: _showNPSSurvey,
          ),
          ListTile(
            title: const Text('Product Feedback'),
            subtitle: const Text('Custom survey example'),
            trailing: const Icon(Icons.feedback, size: 16),
            onTap: _showProductSurvey,
          ),
        ],
      ),
    );
  }

  // ============= User Analytics Methods =============

  Future<void> _simulateSignUp() async {
    if (!_postHog.isInitialized) {
      print('PostHog not initialized. Cannot simulate signup.');
      return;
    }

    try {
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      
      // Track acquisition
      await PostHogMarketingHelpers.trackUserAcquisition(
        source: 'organic',
        medium: 'app',
        campaign: 'demo_signup',
      );
      
      // Track signup event
      await _postHog.events.track(
        PostHogEventType.userSignup,
        {
          'signup_method': 'email',
          'referral_code': 'DEMO123',
          'onboarding_version': 'v2',
        },
      );
      
      // Identify user
      await _postHog.users.identify(
        userId: _userId,
        properties: {
          'email': 'demo@example.com',
          'plan': 'free',
          'created_at': DateTime.now().toIso8601String(),
          'demo_user': true,
        },
      );
      
      setState(() => _isUserLoggedIn = true);
      _showSuccessToast('User signed up and identified!');
    } catch (e) {
      print('Error during signup simulation: $e');
      _showErrorToast('Failed to simulate signup');
    }
  }

  Future<void> _simulateLogin() async {
    _userId = 'user_existing_12345';
    
    await _postHog.events.track(
      PostHogEventType.userLogin,
      {
        'login_method': 'email',
        'device_type': GetPlatform.isMobile ? 'mobile' : 'desktop',
      },
    );
    
    await _postHog.users.identify(
      userId: _userId, 
      properties: {
        'last_login': DateTime.now().toIso8601String(),
        'login_count': 5,
      },
    );
    
    setState(() => _isUserLoggedIn = true);
    _showSuccessToast('User logged in!');
  }

  Future<void> _updateUserProfile() async {
    await _postHog.users.setUserProperties({
      'subscription_tier': 'premium',
      'total_purchases': 3,
      'preferred_category': 'electronics',
      'profile_updated_at': DateTime.now().toIso8601String(),
    });
    
    await _postHog.events.track(
      PostHogEventType.userProfileUpdate,
      {'fields_updated': ['subscription_tier', 'preferred_category']},
    );
    
    _showSuccessToast('User profile updated!');
  }

  Future<void> _simulateLogout() async {
    await _postHog.events.track(PostHogEventType.userLogout, {
      'session_duration_seconds': 300,
      'pages_viewed': 5,
    });
    
    await _postHog.users.reset();
    
    setState(() {
      _isUserLoggedIn = false;
      _userId = '';
      _cart.clear();
      _cartTotal = 0.0;
    });
    
    _showSuccessToast('User logged out and reset!');
  }

  // ============= Campaign Methods =============

  Future<void> _simulateCampaignClick() async {
    await PostHogMarketingHelpers.trackAdCampaignPerformance(
      campaignId: 'summer_sale_2024',
      adSetId: 'electronics_set',
      adId: 'banner_001',
      action: 'click',
      platform: 'facebook',
      cost: 0.50,
    );
    
    await _postHog.events.track(PostHogEventType.adClicked, {
      'ad_position': 'feed_top',
      'ad_format': 'banner',
      'cta_text': 'Shop Now',
    });
    
    _showSuccessToast('Ad campaign click tracked!');
  }

  Future<void> _trackEmailCampaign() async {
    await PostHogMarketingHelpers.trackEmailCampaignPerformance(
      campaignId: 'newsletter_dec_2024',
      action: 'opened',
      email: 'demo@example.com',
      segmentData: {
        'user_segment': 'active_buyers',
        'email_client': 'gmail',
      },
    );
    
    _showSuccessToast('Email campaign open tracked!');
  }

  // ============= Product & Conversion Methods =============

  Future<void> _viewProduct(Product product) async {
    // Track product view
    await _postHog.events.trackCustom('product_viewed', {
      'product_id': product.id,
      'product_name': product.name,
      'product_price': product.price,
      'product_category': product.category,
      'view_source': 'product_list',
    });
    
    // Track screen transition
    await _postHog.screens.trackScreenTransition(
      fromScreen: 'PostHogDemoScreen',
      toScreen: 'ProductDetailScreen',
      properties: {'product_id': product.id},
    );
    
    _showSuccessToast('Product view tracked: ${product.name}');
  }

  Future<void> _addToCart(Product product) async {
    setState(() {
      _cart.add(product);
      _cartTotal += product.price;
    });
    
    // Track add to cart event
    await _postHog.events.trackCustom('add_to_cart', {
      'product_id': product.id,
      'product_name': product.name,
      'product_price': product.price,
      'cart_total': _cartTotal,
      'items_in_cart': _cart.length,
    });
    
    // Track feature usage
    await _postHog.events.trackFeatureUsage(
      'shopping_cart',
      category: 'commerce',
      parameters: {'action': 'add_item'},
    );
    
    _showSuccessToast('Added to cart: ${product.name}');
  }

  Future<void> _showCart() async {
    await _postHog.screens.trackScreen(
      screenName: 'CartScreen', 
      properties: {
        'items_count': _cart.length,
        'cart_value': _cartTotal,
      },
    );
    
    // Show cart modal
    await Get.bottomSheet(
      _buildCartSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildCartSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Shopping Cart',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_cart.isEmpty)
            const Text('Your cart is empty')
          else ...[
            ..._cart.map((product) => ListTile(
              title: Text(product.name),
              trailing: Text('\$${product.price.toStringAsFixed(2)}'),
            )),
            const Divider(),
            ListTile(
              title: const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text(
                '\$${_cartTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _startCheckout() async {
    if (!_isUserLoggedIn) {
      _showErrorToast('Please login first!');
      return;
    }
    
    // Start conversion funnel
    await _postHog.conversions.startFunnel(
      funnelName: 'checkout_flow',
      steps: ['cart_review', 'shipping_info', 'payment_info', 'order_confirmation'],
      context: {
        'cart_value': _cartTotal,
        'items_count': _cart.length,
        'user_id': _userId,
      },
    );
    
    // Track first step
    await _postHog.conversions.trackFunnelStep(
      funnelName: 'checkout_flow',
      stepName: 'cart_review',
      stepProperties: {
        'products': _cart.map((p) => p.id).toList(),
        'total': _cartTotal,
      },
    );
    
    // Simulate checkout flow
    _simulateCheckoutFlow();
  }

  Future<void> _simulateCheckoutFlow() async {
    // Show checkout UI based on feature flag
    final message = _showNewCheckout 
      ? 'Using NEW checkout UI (Feature Flag Enabled)'
      : 'Using classic checkout UI';
    
    _showSuccessToast(message);
    
    // Simulate shipping step
    await Future.delayed(const Duration(seconds: 1));
    await _postHog.conversions.trackFunnelStep(
      funnelName: 'checkout_flow',
      stepName: 'shipping_info',
      stepProperties: {'shipping_method': 'express'},
    );
    
    // Simulate payment step
    await Future.delayed(const Duration(seconds: 1));
    await _postHog.conversions.trackFunnelStep(
      funnelName: 'checkout_flow',
      stepName: 'payment_info',
      stepProperties: {'payment_method': 'credit_card'},
    );
    
    // Complete purchase
    await _completePurchase();
  }

  Future<void> _completePurchase() async {
    final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
    
    // Track final funnel step
    await _postHog.conversions.trackFunnelStep(
      funnelName: 'checkout_flow',
      stepName: 'order_confirmation',
      stepProperties: {'order_id': orderId},
    );
    
    // Track purchase event
    await _postHog.events.track(PostHogEventType.purchaseCompleted, {
      'order_id': orderId,
      'total_amount': _cartTotal,
      'currency': 'USD',
      'items_count': _cart.length,
      'products': _cart.map((p) => {
        'id': p.id,
        'name': p.name,
        'price': p.price,
      }).toList(),
    });
    
    // Track revenue
    await _postHog.conversions.trackRevenue(
      amount: _cartTotal,
      currency: 'USD',
      transactionId: orderId,
      properties: {'payment_method': 'credit_card'},
    );
    
    // Track conversion
    await _postHog.conversions.trackConversion(
      conversionType: 'purchase',
      conversionName: 'product_purchase',
      conversionValue: _cartTotal,
      currency: 'USD',
    );
    
    // Update CLV
    await PostHogMarketingHelpers.trackCustomerLifetimeValue(
      userId: _userId,
      totalRevenue: _cartTotal,
      currency: 'USD',
      totalOrders: 1,
      customerLifespan: const Duration(days: 1),
    );
    
    // Clear cart
    setState(() {
      _cart.clear();
      _cartTotal = 0.0;
    });
    
    _showSuccessToast('Purchase completed! Order ID: $orderId');
  }

  // ============= Survey Methods =============

  Future<void> _showNPSSurvey() async {
    await _postHog.surveys.startSurvey(
      surveyId: 'nps_demo_survey',
      surveyName: 'NPS Demo Survey',
      surveyType: 'nps',
      surveyMetadata: {
        'trigger': 'manual',
        'user_segment': 'demo_users',
      },
    );
    
    // Simulate NPS selection
    final score = await Get.dialog<int>(
      AlertDialog(
        title: const Text('How likely are you to recommend our app?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('0 = Not likely, 10 = Very likely'),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: List.generate(11, (index) => 
                ChoiceChip(
                  label: Text('$index'),
                  selected: false,
                  onSelected: (_) => Get.back(result: index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    
    if (score != null) {
      await _postHog.surveys.trackNPSResponse(
        surveyId: 'nps_demo_survey',
        score: score,
        feedback: 'Great demo app!',
      );
      
      _showSuccessToast('NPS Score recorded: $score');
    }
  }

  Future<void> _showProductSurvey() async {
    await _postHog.surveys.startSurvey(
      surveyId: 'product_feedback_survey',
      surveyName: 'Product Feedback',
      surveyType: 'feedback',
      surveyMetadata: {'product_count': _products.length},
    );
    
    // Simulate survey responses
    await _postHog.surveys.recordResponse(
      surveyId: 'product_feedback_survey',
      questionId: 'q1',
      questionText: 'What is your favorite feature?',
      response: 'shopping_cart',
    );
    
    await _postHog.surveys.recordResponse(
      surveyId: 'product_feedback_survey',
      questionId: 'q2',
      questionText: 'What would you improve?',
      response: 'Add more products',
    );
    
    await _postHog.surveys.completeSurvey(
      surveyId: 'product_feedback_survey',
      completionMetadata: {'completion_time_seconds': 45},
    );
    
    _showSuccessToast('Product survey completed!');
  }

  // ============= Helper Methods =============

  Color _getColorFromString(String color) {
    switch (color.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _showSuccessToast(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showErrorToast(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    // Stop session recording
    _postHog.sessions.stopRecording();
    
    // Track screen exit
    _postHog.screens.trackScreenDuration(
      screenName: 'PostHogDemoScreen',
      duration: const Duration(minutes: 5), // Example duration
    );
    
    super.dispose();
  }
}

// Simple product model
class Product {
  final String id;
  final String name;
  final double price;
  final String category;

  Product(this.id, this.name, this.price, this.category);
}