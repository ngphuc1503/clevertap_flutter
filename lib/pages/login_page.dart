import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'product_page.dart';
import 'package:firebase_core/firebase_core.dart';        
import 'package:firebase_messaging/firebase_messaging.dart'; 


class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginPageState();
}

class _LoginPageState extends State<Loginpage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _logMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final identity = _idController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      final profile = {
        'Name': name,
        'Identity': identity,
        'Email': email,
        'Phone': phone,
        'stuff': ['bags', 'shoes'],
      };

      await CleverTapPlugin.onUserLogin(profile);
      await CleverTapPlugin.recordEvent('Login', {'method': 'email_password'});

      setState(() {
        _logMessage =
            '[Login] Name: $name | ID: $identity | Email: $email | Phone: $phone | Password: $password';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final identity = _idController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();

      final profile = {
        'Name': name,
        'Identity': identity,
        'Email': email,
        'Phone': phone,
        'stuff': ['bags', 'shoes'],
      };

      await CleverTapPlugin.profileSet(profile);

      setState(() {
        _logMessage = '[Update] Đã cập nhật profile cho ID $identity ';
        _fetchCleverTapId();
      });
    }
  }

  Future<void> _fetchCleverTapId() async {
  try {
    final CT_id = await CleverTapPlugin.getCleverTapID();
    debugPrint('CleverTap ID: $CT_id');
    setState(() {
      _logMessage = '[CleverTap ID] Đã log CT_id: $CT_id';
    });
  } catch (e) {
    debugPrint('Lấy CleverTap ID lỗi: $e');
    }
  }

  Future<void> _syncLocationToCleverTap() async {
  LocationPermission perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) {
    perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) return;        
  }
  if (perm == LocationPermission.deniedForever) return;   

  Position p = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    ),
  );
  CleverTapPlugin.setLocation(p.latitude, p.longitude);   
    setState(() {
      _logMessage = '[Location] Đã gửi vị trí: (${p.latitude}, ${p.longitude})';
    });
  }

  void _goToProductPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) =>  Productpage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập Name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(labelText: 'Identity'),
                  validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập Identity' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập Email' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Update Profile'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _goToProductPage,
                  child: const Text('Go to Products'),
                ),
                const SizedBox(height: 16),
                                ElevatedButton(
                  onPressed: _syncLocationToCleverTap,
                  child: const Text('Sync Location'),
                ),
                const SizedBox(height: 16),
                Text(
                  _logMessage,
                  style: const TextStyle(color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
