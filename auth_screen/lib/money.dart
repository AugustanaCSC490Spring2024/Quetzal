class Money{
  double starting_amount = 1000000;

  Money(this.starting_amount);

  bool hasEnough(double money){
    return starting_amount >= money;
  }

}