import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PermissionRequest extends StatelessWidget {
  const PermissionRequest();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Heading
          Text(
            'Access Your Album',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
            ),
          ),

          const SizedBox(height: 8.0),

          // Description
          Text(
            'Allow Drishya picker to access your album for picking media.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8.0),

          // Allow access button
          TextButton(
            onPressed: PhotoManager.openSetting,
            child: Text('Allow Access'),
          ),
        ],
      ),
    );
  }
}
