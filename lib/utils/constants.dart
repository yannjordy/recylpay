class Constants {
  static const String appName = 'RecycPay';
  static const String baseUrl = 'https://api.recylpay.com';
  static const String wsUrl = 'wss://api.recylpay.com/ws';
  static const String openRouterKey = '';
  static const double cameroonLat = 7.3697;
  static const double cameroonLng = 12.3547;

  static const List<String> wasteCategories = [
    'PET (Plastique)',
    'PEHD (Plastique dur)',
    'Aluminium',
    'Carton',
    'Verre',
    'Papier',
    'Fer/Métal',
    'Électronique',
    'Pneu',
    'Huile usagée',
  ];

  static const Map<String, double> defaultPrices = {
    'PET (Plastique)': 150,
    'PEHD (Plastique dur)': 200,
    'Aluminium': 500,
    'Carton': 100,
    'Verre': 80,
    'Papier': 75,
    'Fer/Métal': 250,
    'Électronique': 300,
    'Pneu': 400,
    'Huile usagée': 350,
  };

  static const List<String> userRoles = [
    'collecteur',
    'trieur',
    'livreur',
  ];

  static const double platformCommission = 0.10;
}
