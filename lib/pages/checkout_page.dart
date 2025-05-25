import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutPage extends StatefulWidget {
  final double totalAmount;
  final List<dynamic> cartItems; // Replace with your CartItem type

  const CheckoutPage({
    Key? key,
    required this.totalAmount,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with TickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  String selectedPaymentMethod = 'card';
  String selectedDeliveryMethod = 'standard';
  bool isProcessing = false;

  final List<String> steps = [
    'Delivery Info',
    'Payment',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildCurrentStep(),
            ),
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? const Color(0xFF4DB6AC)
                        : isActive
                            ? const Color(0xFF4DB6AC)
                            : Colors.grey[300],
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.black : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    height: 2,
                    width: 20,
                    color: isCompleted
                        ? const Color(0xFF4DB6AC)
                        : Colors.grey[300],
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildDeliveryInfoStep();
      case 1:
        return _buildPaymentStep();
      case 2:
        return _buildReviewStep();
      default:
        return Container();
    }
  }

  Widget _buildDeliveryInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Contact Information',
              icon: Icons.person_outline,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true)
                      return 'Please enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter your phone' : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Delivery Address',
              icon: Icons.location_on_outlined,
              children: [
                _buildTextField(
                  controller: _addressController,
                  label: 'Street Address',
                  icon: Icons.home,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter your address'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'City',
                        icon: Icons.location_city,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Please enter city' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _postalCodeController,
                        label: 'Postal Code',
                        icon: Icons.markunread_mailbox,
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter postal code'
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDeliveryOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentMethodSelector(),
          const SizedBox(height: 20),
          if (selectedPaymentMethod == 'card') _buildCardPaymentForm(),
          if (selectedPaymentMethod == 'mobile') _buildMobilePaymentForm(),
          if (selectedPaymentMethod == 'cod') _buildCODInfo(),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummary(),
          const SizedBox(height: 20),
          _buildDeliveryDetails(),
          const SizedBox(height: 20),
          _buildPaymentDetails(),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF4DB6AC), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4DB6AC)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    return _buildSectionCard(
      title: 'Delivery Options',
      icon: Icons.local_shipping_outlined,
      children: [
        _buildDeliveryOption(
          value: 'standard',
          title: 'Standard Delivery',
          subtitle: '3-5 business days',
          price: 'Free',
          icon: Icons.local_shipping,
        ),
        const SizedBox(height: 12),
        _buildDeliveryOption(
          value: 'express',
          title: 'Express Delivery',
          subtitle: '1-2 business days',
          price: 'Rs.200',
          icon: Icons.flash_on,
        ),
        const SizedBox(height: 12),
        _buildDeliveryOption(
          value: 'same_day',
          title: 'Same Day Delivery',
          subtitle: 'Within 24 hours',
          price: 'Rs.500',
          icon: Icons.schedule,
        ),
      ],
    );
  }

  Widget _buildDeliveryOption({
    required String value,
    required String title,
    required String subtitle,
    required String price,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => setState(() => selectedDeliveryMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedDeliveryMethod == value
                ? const Color(0xFF4DB6AC)
                : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selectedDeliveryMethod == value
              ? const Color(0xFF4DB6AC).withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selectedDeliveryMethod == value
                  ? const Color(0xFF4DB6AC)
                  : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selectedDeliveryMethod == value
                          ? const Color(0xFF4DB6AC)
                          : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedDeliveryMethod == value
                    ? const Color(0xFF4DB6AC)
                    : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Radio<String>(
              value: value,
              groupValue: selectedDeliveryMethod,
              onChanged: (String? newValue) =>
                  setState(() => selectedDeliveryMethod = newValue!),
              activeColor: const Color(0xFF4DB6AC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return _buildSectionCard(
      title: 'Payment Method',
      icon: Icons.payment,
      children: [
        _buildPaymentOption(
          value: 'card',
          title: 'Credit/Debit Card',
          icon: Icons.credit_card,
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          value: 'mobile',
          title: 'Mobile Banking',
          icon: Icons.phone_android,
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          value: 'cod',
          title: 'Cash on Delivery',
          icon: Icons.money,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String value,
    required String title,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPaymentMethod == value
                ? const Color(0xFF4DB6AC)
                : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selectedPaymentMethod == value
              ? const Color(0xFF4DB6AC).withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selectedPaymentMethod == value
                  ? const Color(0xFF4DB6AC)
                  : Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selectedPaymentMethod == value
                      ? const Color(0xFF4DB6AC)
                      : Colors.black,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selectedPaymentMethod,
              onChanged: (String? newValue) =>
                  setState(() => selectedPaymentMethod = newValue!),
              activeColor: const Color(0xFF4DB6AC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPaymentForm() {
    return _buildSectionCard(
      title: 'Card Details',
      icon: Icons.credit_card,
      children: [
        _buildTextField(
          controller: _cardHolderController,
          label: 'Cardholder Name',
          icon: Icons.person,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Please enter cardholder name' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _cardNumberController,
          label: 'Card Number',
          icon: Icons.credit_card,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CardNumberInputFormatter(),
          ],
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Please enter card number';
            if (value!.replaceAll(' ', '').length < 16) {
              return 'Please enter a valid card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _expiryController,
                label: 'MM/YY',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ExpiryDateInputFormatter(),
                ],
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter expiry date' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _cvvController,
                label: 'CVV',
                icon: Icons.security,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter CVV';
                  if (value!.length < 3) return 'CVV must be 3 digits';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobilePaymentForm() {
    return _buildSectionCard(
      title: 'Mobile Banking',
      icon: Icons.phone_android,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              Icon(Icons.info, color: Colors.blue[700], size: 32),
              const SizedBox(height: 12),
              Text(
                'You will be redirected to your mobile banking app to complete the payment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCODInfo() {
    return _buildSectionCard(
      title: 'Cash on Delivery',
      icon: Icons.money,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            children: [
              Icon(Icons.local_atm, color: Colors.orange[700], size: 32),
              const SizedBox(height: 12),
              Text(
                'Pay with cash when your order is delivered to your doorstep.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Additional charges may apply.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.orange[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return _buildSectionCard(
      title: 'Order Summary',
      icon: Icons.receipt,
      children: [
        ...widget.cartItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1EFDA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // Add product image here
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Name', // Replace with item.product.name
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Qty: 1', // Replace with item.quantity
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rs.100', // Replace with item.product.price
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4DB6AC),
                    ),
                  ),
                ],
              ),
            )),
        const Divider(),
        _buildPriceRow('Subtotal', widget.totalAmount),
        _buildPriceRow('Delivery', _getDeliveryPrice()),
        const Divider(),
        _buildPriceRow(
          'Total',
          widget.totalAmount + _getDeliveryPrice(),
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            'Rs.${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? const Color(0xFF4DB6AC) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return _buildSectionCard(
      title: 'Delivery Details',
      icon: Icons.local_shipping,
      children: [
        _buildDetailRow('Name', _nameController.text),
        _buildDetailRow('Phone', _phoneController.text),
        _buildDetailRow('Address', _addressController.text),
        _buildDetailRow(
            'City', '${_cityController.text}, ${_postalCodeController.text}'),
        _buildDetailRow('Delivery Method', _getDeliveryMethodText()),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return _buildSectionCard(
      title: 'Payment Details',
      icon: Icons.payment,
      children: [
        _buildDetailRow('Payment Method', _getPaymentMethodText()),
        if (selectedPaymentMethod == 'card')
          _buildDetailRow('Card Number',
              '**** **** **** ${_cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4)}'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    currentStep--;
                  });
                  _animationController.reset();
                  _animationController.forward();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF4DB6AC)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF4DB6AC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: isProcessing ? null : _handleNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DB6AC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      currentStep == steps.length - 1
                          ? 'Place Order'
                          : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNextStep() {
    if (currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          currentStep++;
        });
        _animationController.reset();
        _animationController.forward();
      }
    } else if (currentStep == 1) {
      if (_validatePaymentMethod()) {
        setState(() {
          currentStep++;
        });
        _animationController.reset();
        _animationController.forward();
      }
    } else if (currentStep == 2) {
      _processOrder();
    }
  }

  bool _validatePaymentMethod() {
    if (selectedPaymentMethod == 'card') {
      return _cardHolderController.text.isNotEmpty &&
          _cardNumberController.text.replaceAll(' ', '').length >= 16 &&
          _expiryController.text.length >= 5 &&
          _cvvController.text.length >= 3;
    }
    return true;
  }

  void _processOrder() {
    setState(() {
      isProcessing = true;
    });

    // Simulate order processing
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isProcessing = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF4DB6AC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your order #${_generateOrderId()} has been placed successfully. You will receive a confirmation email shortly.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to cart
                    Navigator.of(context).pop(); // Go back to home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB6AC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  double _getDeliveryPrice() {
    switch (selectedDeliveryMethod) {
      case 'express':
        return 200.0;
      case 'same_day':
        return 500.0;
      default:
        return 0.0;
    }
  }

  String _getDeliveryMethodText() {
    switch (selectedDeliveryMethod) {
      case 'express':
        return 'Express Delivery (1-2 days)';
      case 'same_day':
        return 'Same Day Delivery';
      default:
        return 'Standard Delivery (3-5 days)';
    }
  }

  String _getPaymentMethodText() {
    switch (selectedPaymentMethod) {
      case 'card':
        return 'Credit/Debit Card';
      case 'mobile':
        return 'Mobile Banking';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return '';
    }
  }

  String _generateOrderId() {
    return 'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }
}

// Custom input formatters
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < newText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(newText[i]);
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < newText.length && i < 4; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(newText[i]);
    }

    final formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
