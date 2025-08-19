import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/database_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart'; // 确保这个文件存在

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DatabaseProvider(),
      child: MaterialApp(
        title: 'ChronoWise',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const AppInitializer(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    await provider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在加载...'),
                ],
              ),
            ),
          );
        }

        // 如果没有用户，显示欢迎页面
        if (!provider.hasUser) {
          return const WelcomeScreen();
        }

        // 有用户，显示主界面
        return const MainScreen();
      },
    );
  }
}
