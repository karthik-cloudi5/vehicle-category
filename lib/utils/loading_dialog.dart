import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String? message;

  const LoadingDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 12),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(
                Colors.amber,
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Text(message! + ", \nPlease wait...."),
        ],
      ),
    );
  }
}