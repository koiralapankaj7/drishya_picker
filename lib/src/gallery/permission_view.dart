import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

///
class PermissionRequest extends StatelessWidget {
  ///
  const PermissionRequest({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          // Heading
          Text(
            'Access Your Album',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
            ),
          ),

          SizedBox(height: 8.0),

          // Description
          Text(
            'Allow Drishya picker to access your album for picking media.',
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.0),

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
