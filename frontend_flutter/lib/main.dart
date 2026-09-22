import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/auth/auth_cubit.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/job_list/job_list_cubit.dart';
import 'bloc/new_job/new_job_cubit.dart';
import 'core/api_client.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const RepairmateApp());
}

class RepairmateApp extends StatelessWidget {
  const RepairmateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient();

    return RepositoryProvider<ApiClient>.value(
      value: api,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(api: api)..checkAuthStatus()),
          BlocProvider(create: (_) => JobListCubit(api: api)),
          BlocProvider(create: (_) => NewJobCubit(api: api)),
        ],
        child: MaterialApp(
          title: 'Repairmate',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF315C55),
            scaffoldBackgroundColor: const Color(0xFFF4F7F5),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD9E3DE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF315C55), width: 2),
              ),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
            ),
          ),
          home: const AppAuthGate(),
        ),
      ),
    );
  }
}

class AppAuthGate extends StatelessWidget {
  const AppAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const DashboardScreen();
        }
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF315C55)),
                  SizedBox(height: 16),
                  Text(
                    'Loading Repairmate...',
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const LoginScreen();
      },
    );
  }
}
