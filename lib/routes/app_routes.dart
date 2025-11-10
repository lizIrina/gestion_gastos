import '../presentation/pages/login/login_page.dart';
import '../presentation/pages/register/register_page.dart';
import '../presentation/pages/reportes/reportes_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String reportes = '/reportes';

  static final routes = {
    login: (context) => const LoginPage(),
    register: (context) => const RegisterPage(),
    reportes: (context) => const ReportesPage(),
  };
}
