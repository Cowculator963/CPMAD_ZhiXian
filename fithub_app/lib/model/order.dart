// This model class provides a structured way to define and organize your data. It encapsulates related data fields into a single object, making it easier to manage and work with the data.

class Order {
  final String orderId;
  final String userId;
  final DateTime timestamp;
  final List<OrderItem> items;

  Order({
    this.orderId,
    this.userId,
    this.timestamp,
    this.items,
  });
}

class OrderItem {
  final String itemName;
  final String itemPrice;
  final int quantity;
  final String imagePath; // Add this property

  OrderItem({
    this.itemName,
    this.itemPrice,
    this.quantity,
    this.imagePath, // Initialize it when creating an OrderItem instance
  });
}
