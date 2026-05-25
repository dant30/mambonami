import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../core/api_client.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../shared/widgets/app_navigation.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_snackbar.dart';

class SupportPage extends StatefulWidget {
	const SupportPage({super.key});

	@override
	State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
	final _nameController = TextEditingController();
	final _emailController = TextEditingController();
	final _messageController = TextEditingController();
	final _formKey = GlobalKey<FormState>();
	bool _submitting = false;

	@override
	void dispose() {
		_nameController.dispose();
		_emailController.dispose();
		_messageController.dispose();
		super.dispose();
	}

	Future<void> _sendRequest() async {
		if (!_formKey.currentState!.validate()) return;
		setState(() => _submitting = true);
		try {
			final api = GetIt.I<ApiClient>();
			// Try a best-effort API call; backend may implement '/api/support/'
			await api.dio.post('/api/support/', data: {
				'name': _nameController.text.trim(),
				'email': _emailController.text.trim(),
				'message': _messageController.text.trim(),
			});
			CustomSnackbar.showSuccess(context, 'Support request sent — we will get back to you.');
			_formKey.currentState?.reset();
		} catch (e) {
			CustomSnackbar.showError(context, 'Failed to send request: ${e.toString()}');
		} finally {
			setState(() => _submitting = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: const CustomAppBar(title: 'Support'),
			drawer: const AppDrawer(),
			bottomNavigationBar: const AppBottomNavigationBar(),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(16),
				child: Form(
					key: _formKey,
					child: Column(
						children: [
							const Text('Contact support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
							const SizedBox(height: 12),
							CustomTextField(controller: _nameController, label: 'Your name', textInputAction: TextInputAction.next, validator: (v) => v == null || v.isEmpty ? 'Required' : null),
							const SizedBox(height: 12),
							CustomTextField(controller: _emailController, label: 'Email', keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, validator: (v) {
								if (v == null || v.isEmpty) return 'Required';
								return v.contains('@') ? null : 'Enter valid email';
							}),
							const SizedBox(height: 12),
							CustomTextField(controller: _messageController, label: 'Message', maxLines: 6, validator: (v) => v == null || v.isEmpty ? 'Please describe the issue' : null),
							const SizedBox(height: 16),
							CustomButton(onPressed: _sendRequest, isLoading: _submitting, label: 'Send'),
						],
					),
				),
			),
		);
	}
}

