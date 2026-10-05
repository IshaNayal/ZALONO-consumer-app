import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/zalono_provider.dart';
import 'booking_confirmation_screen.dart';

/// Payment + verification step of the booking flow.
///
/// Three short stages in one screen: confirm the mobile number, verify it with
/// an OTP, then pay. A successful payment confirms the booking automatically
/// and moves straight to the confirmation screen.
///
/// OTP delivery note: no SMS gateway is wired up yet, so the generated code is
/// surfaced in a labelled banner instead of being texted. The verification
/// logic itself is real — swap [_requestOtp] for an API call when a provider
/// is available and nothing else has to change.
class PaymentVerificationScreen extends StatefulWidget {
  final Salon salon;

  /// One or more services chosen on the salon page. Prices and durations are
  /// summed for the payment step.
  final List<ServiceItem> services;

  final LiveSlot seat;

  const PaymentVerificationScreen({
    super.key,
    required this.salon,
    required this.services,
    required this.seat,
  });

  /// Combined price of [services].
  double get totalPrice =>
      services.fold<double>(0, (sum, s) => sum + s.price);

  @override
  State<PaymentVerificationScreen> createState() =>
      _PaymentVerificationScreenState();
}

enum _Stage { mobile, otp, payment }

class _PaymentVerificationScreenState extends State<PaymentVerificationScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _otpFocus = FocusNode();

  _Stage _stage = _Stage.mobile;
  String? _expectedOtp;
  String? _errorText;
  bool _isWorking = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text =
        context.read<ZalonoProvider>().userPhone.replaceAll(RegExp(r'\D'), '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  bool get _isPhoneValid =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '').length >= 10;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _stage == _Stage.mobile,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _stage != _Stage.mobile) {
          setState(() {
            _stage = _Stage.mobile;
            _errorText = null;
          });
        }
      },
      child: Scaffold(
        backgroundColor: ZalonoTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: ZalonoTheme.backgroundLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              if (_stage == _Stage.mobile) {
                Navigator.pop(context);
              } else {
                setState(() {
                  _stage = _Stage.mobile;
                  _errorText = null;
                });
              }
            },
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              // Services stay hidden until the number is verified: showing the
              // basket before the user is identified is a spoiler for anyone
              // picking up the phone.
              if (_stage == _Stage.payment) ...[
                _buildSummary(),
                const SizedBox(height: 24),
              ],
              _buildStage(),
            ],
          ),
        ),
      ),
    );
  }

  /// What is being booked: salon, every selected service and the combined
  /// total. Only rendered on the payment stage, after verification.
  Widget _buildSummary() {
    final services = widget.services;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZalonoTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.salon.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ZalonoTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '₹${widget.totalPrice.toInt()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ZalonoTheme.primaryBurgundy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final service in services)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 13,
                    color: ZalonoTheme.accentGreen,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      service.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: ZalonoTheme.textMuted,
                      ),
                    ),
                  ),
                  Text(
                    '₹${service.price.toInt()}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: ZalonoTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case _Stage.mobile:
        return _buildMobileStage();
      case _Stage.otp:
        return _buildOtpStage();
      case _Stage.payment:
        return _buildPaymentStage();
    }
  }

  Widget _buildMobileStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StageHeading(
          title: 'Verify your mobile number',
          subtitle: 'We will send a one-time code to confirm it is you.',
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 15,
          onChanged: (_) => setState(() => _errorText = null),
          decoration: const InputDecoration(
            labelText: 'Mobile number',
            prefixText: '+91  ',
            border: OutlineInputBorder(),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'Send OTP',
          isBusy: _isWorking,
          onPressed: _isPhoneValid ? _requestOtp : null,
        ),
      ],
    );
  }

  Widget _buildOtpStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StageHeading(
          title: 'Enter the OTP',
          subtitle: 'Check your messages for the 6-digit code.',
        ),
        const SizedBox(height: 16),
        // No SMS provider is configured, so the code is shown rather than
        // pretending it was delivered.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: ZalonoTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: ZalonoTheme.primaryBurgundy,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Demo build: your code is ${_expectedOtp ?? '------'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ZalonoTheme.primaryBurgundy,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _otpController,
          focusNode: _otpFocus,
          keyboardType: TextInputType.number,
          maxLength: 6,
          autofocus: true,
          onChanged: (_) => setState(() => _errorText = null),
          decoration: const InputDecoration(
            labelText: '6-digit OTP',
            border: OutlineInputBorder(),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'Verify & Continue',
          isBusy: _isWorking,
          onPressed: _verifyOtp,
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _requestOtp,
            child: const Text(
              'Resend OTP',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ZalonoTheme.primaryBurgundy,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _StageHeading(
          title: 'Payment',
          subtitle: 'Pay now to confirm your appointment.',
        ),
        const SizedBox(height: 20),
        _PaymentMethodTile(
          label: 'UPI',
          subtitle: 'Pay using any UPI app',
          icon: Icons.account_balance_wallet_rounded,
          isSelected: true,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _PaymentMethodTile(
          label: 'Pay at salon',
          subtitle: 'Cash, UPI or card at the counter',
          icon: Icons.storefront_rounded,
          onTap: () {},
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Amount to pay',
              style: TextStyle(fontSize: 14, color: ZalonoTheme.textMuted),
            ),
            Text(
              '₹${widget.totalPrice.toInt()}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ZalonoTheme.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _PrimaryButton(
          label: 'Pay ₹${widget.totalPrice.toInt()} & Confirm',
          isBusy: _isWorking,
          onPressed: _pay,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _requestOtp() async {
    setState(() {
      _isWorking = true;
      _errorText = null;
    });

    // Stands in for the OTP send API call.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final code = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString();

    if (!mounted) return;
    setState(() {
      _expectedOtp = code;
      _stage = _Stage.otp;
      _isWorking = false;
      _otpController.clear();
    });
    _otpFocus.requestFocus();
  }

  Future<void> _verifyOtp() async {
    final entered = _otpController.text.trim();
    if (entered.length != 6) {
      setState(() => _errorText = 'Enter the 6-digit code.');
      return;
    }
    if (entered != _expectedOtp) {
      setState(() => _errorText = 'That code is not correct. Try again.');
      return;
    }

    setState(() {
      _isWorking = true;
      _errorText = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _stage = _Stage.payment;
      _isWorking = false;
    });
  }

  Future<void> _pay() async {
    setState(() => _isWorking = true);

    // Stands in for the payment gateway call.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final zalono = context.read<ZalonoProvider>();
    final phone = _phoneController.text.trim();
    final booking = zalono.holdBooking(
      salon: widget.salon,
      seat: widget.seat,
      services: widget.services,
      phone: phone,
    );
    // Payment succeeded and the number is verified: confirm automatically.
    zalono.confirmBooking(booking, phone: phone);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BookingConfirmationScreen(booking: booking)),
    );
  }
}

class _StageHeading extends StatelessWidget {
  const _StageHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: ZalonoTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: ZalonoTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isBusy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ZalonoTheme.primaryBurgundy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ZalonoTheme.primaryBurgundy.withValues(alpha: 0.4),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isBusy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? ZalonoTheme.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ZalonoTheme.primaryBurgundy
                  : ZalonoTheme.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 20, color: ZalonoTheme.primaryBurgundy),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ZalonoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ZalonoTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: ZalonoTheme.primaryBurgundy,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
