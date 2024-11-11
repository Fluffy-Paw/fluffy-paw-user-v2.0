class DepositLinkResponse {
  final String checkoutUrl;
  final int orderCode;

  DepositLinkResponse({
    required this.checkoutUrl,
    required this.orderCode,
  });

  factory DepositLinkResponse.fromMap(Map<String, dynamic> map) {
    return DepositLinkResponse(
      checkoutUrl: map['checkoutUrl'] ?? '',
      orderCode: map['orderCode'] ?? 0,
    );
  }
}