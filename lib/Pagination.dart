class Pagination<T> {
  final int page;
  final int perPage;
  final int numbersOfPages;
  final List<T> items;

  Pagination({
    required this.page,
    required this.perPage,
    required this.numbersOfPages,
    required this.items,
  });
}

class Filter {
  Filter(this.subject, this.value);

  String subject;
  String value;
}

class Sort {
  Sort(this.subject, this.direction);

  String subject;
  SortDirection direction;
}

enum SortDirection { asc, desc, none }
