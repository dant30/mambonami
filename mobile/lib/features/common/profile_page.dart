import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/constants.dart';
import '../../core/api_client.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../shared/widgets/app_navigation.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_snackbar.dart';

class ProfilePage extends StatefulWidget {
	const ProfilePage({super.key});

	@override
	State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
	final _usernameController = TextEditingController();
	final _emailController = TextEditingController();
	final _displayNameController = TextEditingController();
	final _phoneController = TextEditingController();
	final _formKey = GlobalKey<FormState>();
	bool _loading = true;

	final AuthRepository _authRepository = GetIt.I<AuthRepository>();

	@override
	void initState() {
		super.initState();
		_loadProfile();
	}

	Future<void> _loadProfile() async {
		setState(() => _loading = true);
		try {
			final profile = await _authRepository.getProfile();
			_usernameController.text = profile['username']?.toString() ?? '';
			_emailController.text = profile['email']?.toString() ?? '';
			_displayNameController.text = profile['display_name']?.toString() ?? profile['full_name']?.toString() ?? '';
			_phoneController.text = profile['phone']?.toString() ?? (context.read<AuthBloc>().state is AuthAuthenticated ? (context.read<AuthBloc>().state as AuthAuthenticated).phone : '');
		} catch (e) {
			CustomSnackbar.showError(context, 'Failed to load profile: ${e.toString()}');
		} finally {
			setState(() => _loading = false);
		}
	}

	Future<void> _saveProfile() async {
		if (!_formKey.currentState!.validate()) return;
		setState(() => _loading = true);
		try {
			final api = GetIt.I<ApiClient>();
			final payload = {
				'username': _usernameController.text.trim(),
				'email': _emailController.text.trim(),
				'display_name': _displayNameController.text.trim(),
			};
			await api.dio.patch(kProfileEndpoint, data: payload);
			CustomSnackbar.showSuccess(context, 'Profile updated');
			context.read<AuthBloc>().add(CheckAuthStatusEvent());
		} catch (e) {
			CustomSnackbar.showError(context, 'Update failed: ${e.toString()}');
		} finally {
			setState(() => _loading = false);
		}
	}

	@override
	void dispose() {
		_usernameController.dispose();
		_emailController.dispose();
		_displayNameController.dispose();
		_phoneController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: const CustomAppBar(title: 'Profile'),
			drawer: const AppDrawer(),
			bottomNavigationBar: const AppBottomNavigationBar(),
			body: _loading
					? const Center(child: CircularProgressIndicator())
					: SingleChildScrollView(
							padding: const EdgeInsets.all(16),
							child: Form(
								key: _formKey,
								child: Column(
									children: [
										CustomTextField(
											controller: _displayNameController,
											label: 'Full name',
											textInputAction: TextInputAction.next,
											validator: (v) => v == null || v.isEmpty ? 'Required' : null,
										),
										const SizedBox(height: 12),
										CustomTextField(
											controller: _usernameController,
											label: 'Username',
											textInputAction: TextInputAction.next,
											validator: (v) => v == null || v.isEmpty ? 'Required' : null,
										),
										const SizedBox(height: 12),
										CustomTextField(
											controller: _emailController,
											label: 'Email',
											keyboardType: TextInputType.emailAddress,
											textInputAction: TextInputAction.next,
											validator: (v) {
												if (v == null || v.isEmpty) return null;
												return v.contains('@') ? null : 'Enter valid email';
											},
										),
										const SizedBox(height: 12),
										CustomTextField(
											controller: _phoneController,
											label: 'Phone',
											keyboardType: TextInputType.phone,
											enabled: false,
										),
										const SizedBox(height: 20),
										CustomButton(onPressed: _saveProfile, isLoading: _loading, label: 'Save Changes'),
										const SizedBox(height: 12),
										CustomButton(
											onPressed: () => _confirmLogout(),
											label: 'Log out',
											color: Colors.redAccent,
										),
									],
								),
							),
						),
		);
	}

	void _confirmLogout() {
		showDialog(
			context: context,
			builder: (ctx) => AlertDialog(
				title: const Text('Log out'),
				content: const Text('Are you sure you want to log out?'),
				actions: [
					TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
					TextButton(
						onPressed: () {
							Navigator.of(ctx).pop();
							context.read<AuthBloc>().add(LogoutEvent());
						},
						child: const Text('Log out'),
					),
				],
			),
		);
	}

}


