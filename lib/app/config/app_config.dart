class AppConfig {
  static const String appName = "Evolve Home";

  // static const String environment = "local";
  static const String environment =
      String.fromEnvironment("ENV", defaultValue: "dev");

  static String get baseUrl {
    switch (environment) {
      case "local":
        return "http://192.168.31.71:8080/evolv";
      case "dev":
        return "https://evolv-spring.onrender.com/evolv";
      case "prod":
        return "https://api.yourproductiondomain.com/evolv";
      default:
        return "http://192.168.31.71:8080/evolv";
    }
  }

  // API Endpoints
  static String get apiUrl => baseUrl;
  static String get loginUrl => "$baseUrl/api/auth/login";
  static String get userProfileUrl => "$baseUrl/api/users";
  static String get familyUrl => "$baseUrl/api/family";
  static String get prescriptionsUrl => "$baseUrl/api/prescriptions";
}