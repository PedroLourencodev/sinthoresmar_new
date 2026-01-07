import 'package:flutter/material.dart';
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});
  @override
  Widget build(BuildContext context) => const _Stub(title: 'FAQ (Perguntas Frequentes)');
}
class _Stub extends StatelessWidget {
  final String title; const _Stub({required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: Center(child: Text(title)));
}
