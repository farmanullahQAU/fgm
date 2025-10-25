import 'package:flutter/material.dart';
import 'package:fmac/app/routes/app_routes.dart';
import 'package:fmac/core/values/app_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controller.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header with User Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.branding.withOpacity(0.9),
                  AppColors.branding,
                ],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,

                  // child: user?.image != null && user!.image!.isNotEmpty
                  //     ? ClipOval(
                  //         child: Image.network(
                  //           user.image!,
                  //           width: 90,
                  //           height: 90,
                  //           fit: BoxFit.cover,
                  //           errorBuilder: (context, error, stackTrace) =>
                  //               Icon(Icons.person, size: 50, color: Colors.grey[600]),
                  //         ),
                  //       )
                  //     :
                  child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                ),

                Obx(
                  () => Column(
                    children: [
                      Text(
                        controller.userDisplayName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.userEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {
                    Get.back(); // Close drawer
                    // TODO: Navigate to profile settings screen
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.groups_outlined,
                  title: 'Teams & Athletes',
                  onTap: () {
                    Get.back();
                    Get.toNamed(AppRoutes.teams);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Get.back();
                    // TODO: Navigate to settings screen
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Get.back();
                    // TODO: Navigate to help screen
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Get.back();
                    // TODO: Navigate to privacy policy
                  },
                ),
                const Divider(height: 1),
                _buildDrawerItem(
                  icon: Icons.logout_outlined,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () => controller.logout(),
                ),
              ],
            ),
          ),

          // App Version
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'FMAC App v1.0.0',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 FMAC',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red.shade400 : Colors.blue.shade600,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 0.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      dense: true,
      onTap: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}
