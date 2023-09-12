import 'package:flutter/material.dart';
import 'package:jukebox/Album.dart';
import 'package:jukebox/Pagination.dart';
import 'package:jukebox/api.dart';
import 'dart:async';

class AlbumsIndex extends StatefulWidget {
  const AlbumsIndex({super.key});

  @override
  State<AlbumsIndex> createState() => _AlbumsIndexState();
}

class _AlbumsIndexState extends State<AlbumsIndex> {
  late Future<Pagination<AlbumSummary>> paginationResult;

  var paginationParams = AlbumsPaginationParams(
      nameFilter: Filter('name', ''),
      nameSort: Sort('name', SortDirection.asc));

  @override
  void initState() {
    super.initState();
    paginationResult = fetchAlbums(paginationParams);
  }

  void changeNameSortDirection(SortDirection direction) {
    setState(() {
      paginationParams.nameSort.direction = direction;
      paginationResult = fetchAlbums(paginationParams);
    });
  }

  void changeNameFilter(String name) {
    setState(() {
      paginationParams.nameFilter.value = name;
      paginationResult = fetchAlbums(paginationParams);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Albums"),
      ),
      body: WidgetStateProvider(
        state: this,
        child: Column(
          children: [
            PaginationControls(),
            FutureBuilder<Pagination<AlbumSummary>>(
              future: paginationResult,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        alignment: Alignment.center,
                        child: Wrap(
                            spacing: 5,
                            runSpacing: 10,
                            direction: Axis.horizontal,
                            children: [
                              for (var album in snapshot.data!.items)
                                AlbumSummaryCard(album: album)
                            ]),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Column(children: []);
                }

                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumSummaryCard extends StatelessWidget {
  final AlbumSummary album;

  const AlbumSummaryCard({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Card(
          shape: const ContinuousRectangleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (album.hasCover)
                Image.network(
                  'http://127.0.0.1:8000/api/albums/${album.uid}/cover',
                  width: 180,
                ),
              Container(
                  padding: const EdgeInsets.all(10), child: Text(album.name))
            ],
          )),
    );
  }
}

class PaginationControls extends StatelessWidget {
  final AlbumsPaginationParams paginationParams = AlbumsPaginationParams(
      nameFilter: Filter('name', ''),
      nameSort: Sort('name', SortDirection.none));

  @override
  Widget build(BuildContext context) {
    Timer? timer;

    var albumsIndexState = WidgetStateProvider.of<_AlbumsIndexState>(context);

    return Padding(
      padding: EdgeInsets.all(8.0).copyWith(bottom: 25),
      child: Container(
        child: Row(
          children: [
            Flexible(
              child: TextField(
                onChanged: (String value) {
                  if (timer?.isActive ?? false) timer?.cancel();
                  timer = Timer(const Duration(milliseconds: 500), () {
                    albumsIndexState.changeNameFilter(value);
                  });
                },
                decoration:
                    InputDecoration(hintText: 'Please enter a search term'),
              ),
            ),
            SortDirectionSelector(
                sort: albumsIndexState.paginationParams.nameSort),
          ],
        ),
      ),
    );
  }
}

class WidgetStateProvider extends InheritedWidget {
  final State state;

  const WidgetStateProvider(
      {super.key, required this.state, required Widget child})
      : super(child: child);

  static S of<S extends State>(BuildContext context) {
    final WidgetStateProvider? stateProvider =
        context.dependOnInheritedWidgetOfExactType<WidgetStateProvider>();
    assert(stateProvider != null, 'No State found in context');

    return stateProvider!.state as S;
  }

  @override
  bool updateShouldNotify(WidgetStateProvider oldWidget) => true;
}

class SortDirectionSelector extends StatelessWidget {
  final Sort sort;
  final bool noneValue;

  const SortDirectionSelector(
      {super.key, required this.sort, this.noneValue = false});

  SortDirection nextSortDirection() {
    return switch (sort.direction) {
      SortDirection.asc => SortDirection.desc,
      SortDirection.desc => noneValue ? SortDirection.none : SortDirection.asc,
      _ => SortDirection.asc,
    };
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => WidgetStateProvider.of<_AlbumsIndexState>(context)
            .changeNameSortDirection(nextSortDirection()),
        icon: Icon(
          sort.direction == SortDirection.asc
              ? Icons.arrow_upward
              : sort.direction == SortDirection.desc
                  ? Icons.arrow_downward
                  : Icons.remove,
          size: 22,
        ));
  }
}
