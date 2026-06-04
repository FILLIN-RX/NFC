import 'package:flutter/material.dart';
import '../widgets/action_buttons.dart';
import '../widgets/balance_card.dart';
import '../widgets/home_header.dart';
import '../widgets/transaction_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            HomeHeader(),
            SizedBox(height: 8),
            BalanceCard(),
            SizedBox(height: 8),
            ActionButtons(),
            TransactionList(),
          ],
        ),
      ),
    );
  }
}
