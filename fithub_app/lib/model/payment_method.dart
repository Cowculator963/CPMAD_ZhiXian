class PaymentMethod {
  final String email; // Add the id property
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String cvv;

  PaymentMethod({
    this.email, // Include the id property in the constructor
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.cvv,
  });

  // Convert PaymentMethod object to a Map
  Map<String, dynamic> toMap() {
    return {
      'email': email, // Include the id property in the Map
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'cvv': cvv,
    };
  }
}
