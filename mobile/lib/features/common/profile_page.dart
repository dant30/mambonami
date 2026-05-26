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
import '../../shared/widgets/avatar.dart';
import '../../shared/widgets/section_header.dart';
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
	final _firstNameController = TextEditingController();
	final _secondNameController = TextEditingController();
	final _lastNameController = TextEditingController();
	final _phoneController = TextEditingController();
	final _formKey = GlobalKey<FormState>();
	bool _loading = true;
	String? _profileImageUrl;
	String? _firstName;
	String? _secondName;
	String? _lastName;
	String? _username;

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
			_firstNameController.text = profile['first_name']?.toString() ?? '';
			_secondNameController.text = profile['second_name']?.toString() ?? '';
			_lastNameController.text = profile['last_name']?.toString() ?? '';
			_phoneController.text = profile['phone']?.toString() ?? (context.read<AuthBloc>().state is AuthAuthenticated ? (context.read<AuthBloc>().state as AuthAuthenticated).phone : '');
			setState(() {
				_profileImageUrl = profile['profile_image']?.toString();
				_firstName = profile['first_name']?.toString();
				_secondName = profile['second_name']?.toString();
				_lastName = profile['last_name']?.toString();
				_username = profile['username']?.toString();
			});
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
				'first_name': _firstNameController.text.trim(),
				'second_name': _secondNameController.text.trim(),
				'last_name': _lastNameController.text.trim(),
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
		_firstNameController.dispose();
		_secondNameController.dispose();
		_lastNameController.dispose();
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
										Center(
											child: Avatar(
												imageUrl: _profileImageUrl,
												firstName: _firstName,
												secondName: _secondName,
												lastName: _lastName,
												username: _username,
												size: 80,
											),
										),
										const SizedBox(height: 24),
										SectionHeader(
											title: 'Personal Information',
											padding: EdgeInsets.zero,
										),
										const SizedBox(height: 16),
										CustomTextField(
											controller: _firstNameController,
											label: 'First Name',
											textInputAction: TextInputAction.next,
											validator: (v) => v == null || v.isEmpty ? 'Required' : null,
										),
										const SizedBox(height: 12),
										CustomTextField(
											controller: _secondNameController,
											label: 'Second Name (Middle Name)',
											textInputAction: TextInputAction.next,
										),
										const SizedBox(height: 12),
										CustomTextField(
											controller: _lastNameController,
											label: 'Last Name',
											textInputAction: TextInputAction.next,
											validator: (v) => v == null || v.isEmpty ? 'Required' : null,
										),
										const SizedBox(height: 20),
										SectionHeader(
											title: 'Account Settings',
											padding: EdgeInsets.zero,
										),
										const SizedBox(height: 16),

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
										const SizedBox(height: 24),
										SectionHeader(
											title: 'Actions',
											padding: EdgeInsets.zero,
										),
										const SizedBox(height: 16),

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


