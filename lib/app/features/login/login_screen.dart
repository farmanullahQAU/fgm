import 'package:flutter/material.dart';
import 'package:fmac/services/auth_service.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.put(AuthService());
    final emailController = TextEditingController(text: "ali@gmail.com");
    final passwordController = TextEditingController(text: "pakistan");

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'user@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Obx(
              () => authService.isAuthenticated.value
                  ? const Text('Already logged in!')
                  : ElevatedButton(
                      onPressed: () async {
                        final email = emailController.text.trim();
                        final password = passwordController.text;
                        if (email.isEmpty || password.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please enter email and password',
                          );
                          return;
                        }
                        final success = await authService.login(
                          email,
                          password,
                        );
                        if (success) {
                          Get.offNamed('/home');
                        }
                      },
                      child: const Text('Login'),
                    ),
            ),
            TextButton(
              onPressed: () {
                Get.to(() => const RegisterScreen());
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();
    final emailController = TextEditingController(text: "ali@gmail.com");
    final passwordController = TextEditingController(text: "pakistan");
    final firstNameController = TextEditingController(text: "ali");
    final lastNameController = TextEditingController(text: "ahmed");
    final phoneController = TextEditingController(text: "43453545");

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'user@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone (Optional)'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text;
                final firstName = firstNameController.text.trim();
                final lastName = lastNameController.text.trim();
                final phone = phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim();

                if (email.isEmpty ||
                    password.isEmpty ||
                    firstName.isEmpty ||
                    lastName.isEmpty) {
                  Get.snackbar('Error', 'Please fill in all required fields');
                  return;
                }

                final success = await authService.register(
                  email: email,
                  password: password,
                  firstName: firstName,
                  lastName: lastName,
                  phone: phone,
                );
                if (success) {
                  Get.offNamed('/home');
                }
              },
              child: const Text('Register'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
