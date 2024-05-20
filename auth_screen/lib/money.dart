class Money {
  double amount;

  Money(this.amount);

  bool hasEnough(double cost) {
    return amount >= cost;
  }

  void deduct(double cost) {
    amount -= cost;
  }

  void add(double earnings) {
    amount += earnings;
  }
}
