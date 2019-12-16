class Item {
  final int imageId;
  final String name;

  Item(this.imageId, this.name);

  imageUrl(size) {
    return 'https://picsum.photos/$size?image=$imageId';
  }
}

final items = [
  Item(1, 'One'),
  Item(2, 'Two'),
  Item(3, 'Three'),
  Item(4, 'Four'),
];
