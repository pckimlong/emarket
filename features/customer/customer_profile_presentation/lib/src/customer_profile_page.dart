import 'package:material_ui/material_ui.dart';

class CustomerProfilePage extends StatelessWidget {
  const CustomerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Profile'),
      ),
      body: const SizedBox.expand(),
    );
  }
}
