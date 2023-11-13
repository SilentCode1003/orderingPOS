class Config {
  static const String apiUrl = 'http://192.168.30.18:3060/';
  // static const String apiUrl = 'http://192.168.50.16:3060/';
  // static const String apiUrl = 'https://sois.5lsolutions.com/';
  // static const String apiUrl = 'https://salesinventory.5lsolutions.com/';

  static const String getActiveCategoryAPI = 'mastercategory/getactive';
  static const String getProductAPI = 'product/getactive';
  static const String getPaymentAPI = 'masterpayment/load';
  static const String sendTransactionAPI = 'salesdetails/save';
  static const String getDetailIDAPI = 'salesdetails/getdetailid';
  static const String registrationAPI = 'customer/save';
  static const String loginCustomerAPI = 'customer/login';
  static const String customerOrderAPI = 'customerorder/save';
  static const String customerCreditAPI = 'customercredit/getcredit';
  static const String paymentAPI = 'masterpayment/getorderingpayment';
  static const String orderhistoryAPI = 'customerorder/getorderhistory';
  static const String activeOrederAPI = 'customerorder/getactiveorder';
  static const String getOrderDetailAPI = 'customerorder/getorderdetail';
  static const String updateCustomerAPI = 'customer/update';
}
