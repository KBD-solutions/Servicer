class _Drink{
  final String name;
  int amount;
  _Drink(this.name, {this.amount = 0});
}

final List<_Drink> drinks = [
  _Drink('Sprite'),
  _Drink('Fanta'),
  _Drink('CocaCola')
];