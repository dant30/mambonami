class RoutePaths {
  static const login = '/login';
  static const register = '/register';
  static const registerVerify = '/register/verify';
  static const forgotPassword = '/forgot-password';

  static const buyerDashboard = '/buyer';
  static const farmerDashboard = '/farmer';
  static const transportProviderDashboard = '/transport_provider';
  static const availableOrders = '/transport_provider/available-orders';
  static const myTrips = '/transport_provider/my-trips';
  static const tripDetail = '/transport_provider/trip/:uuid';
  static String tripDetailPath(String uuid) => '/transport_provider/trip/$uuid';
  static const pickup = '/transport_provider/pickup/:uuid';
  static String pickupPath(String uuid) => '/transport_provider/pickup/$uuid';
  static const delivery = '/transport_provider/delivery/:uuid';
  static String deliveryPath(String uuid) => '/transport_provider/delivery/$uuid';
  static const transportEarnings = '/transport_provider/earnings';

  static const farmerProducts = '/farmer/products';
  static const farmerProductCreate = '/farmer/products/create';
  static const farmerProductEdit = '/farmer/products/:uuid/edit';
  static String farmerProductEditPath(String uuid) => '/farmer/products/$uuid/edit';

  static const farmerOrderRequests = '/farmer/order-requests';
  static const farmerOrderRequestDetail = '/farmer/order-requests/:id';
  static String farmerOrderRequestDetailPath(int id) => '/farmer/order-requests/$id';

  static const farmerEarnings = '/farmer/earnings';

  static const notifications = '/notifications';
  static const orders = '/orders';
  static const products = '/products';
  static const productDetail = '/product/:uuid';
  static String productDetailPath(String uuid) => '/product/$uuid';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const dispute = '/dispute';
  static const profile = '/profile';
  static const settings = '/settings';
  static const support = '/support';
  static const orderTracking = '/order/:uuid';
  static String orderTrackingPath(String uuid) => '/order/$uuid';
}
