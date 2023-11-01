class Config {
  static const String apiUrl = 'http://192.168.30.18:3060/';
  // static const String apiUrl = 'http://192.168.50.42:3060/';
  // static const String apiUrl = 'https://sois.5lsolutions.com/';

  static const String getActiveCategoryAPI = 'mastercategory/getactive';
  static const String getProductAPI = 'product/load';
  static const String getPaymentAPI = 'masterpayment/load';
  static const String sendTransactionAPI = 'salesdetails/save';
  static const String getDetailIDAPI = 'salesdetails/getdetailid';
  static const String registrationAPI = 'customer/save';
  static const String loginCustomerAPI = 'customer/login';
}
