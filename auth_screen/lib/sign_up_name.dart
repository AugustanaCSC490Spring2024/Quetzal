bool isFirstNameValid(String name) {

  final RegExp nameRegExp = RegExp(r'^[a-zA-Z]{2,}$');
  return nameRegExp.hasMatch(name);
}

bool isLastNameValid(String name) {

  final RegExp nameRegExp = RegExp(r'^[a-zA-Z]{2,}$');
  return nameRegExp.hasMatch(name);
}
