
import 'package:flutter/material.dart';

class FieldRequiredTag extends StatelessWidget{
  const FieldRequiredTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 3.5),
      child: const Text('*', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),),
    );
  }

}
