// ignore_for_file: non_constant_identifier_names

class Money{
  double starting_amount = 100000;

  Money(this.starting_amount);

  bool hasEnough(double money){
    return starting_amount >= money;
  }
  void add(double amount) {
    starting_amount += amount;
  }

  void deduct(double amount) {
    starting_amount -= amount;
  }

}