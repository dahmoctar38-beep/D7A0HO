class AppRoutes {
  AppRoutes._();
  static const home = '/';
  static const scanner = '/scanner';
  static const productDetails = '/product/:barcode';
  static const aiAnalysis = '/analysis/:barcode';
  static const history = '/history';
  static const favorites = '/favorites';
  static const profile = '/profile';
  static const login = '/login';

  static String productDetailsPath(String barcode) => '/product/$barcode';
  static String aiAnalysisPath(String barcode) => '/analysis/$barcode';
}

class AppStrings {
  AppStrings._();
  static const appName = 'NutriScan AI';
  static const scannerTitle = 'Scan Product';
  static const productDetailsTitle = 'Product Details';
  static const aiAnalysisTitle = 'AI Analysis';

  static const disclaimerText =
      'This app is not a substitute for a doctor or nutritionist, '
      'especially for diabetic, hypertensive, or allergy patients. '
      'Always consult a healthcare professional before making dietary decisions.';

  static const errorGeneric = 'Something went wrong. Please try again.';
  static const errorProductNotFound = 'Product not found. Try scanning again.';
  static const emptyNoScans = 'No scans yet. Tap the button below to start!';
}
