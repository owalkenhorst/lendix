import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../asciimoji_shrug.dart';
import 'entity_search_cubit.dart';

class EntitySearchDelegate<T> extends SearchDelegate<T?> {
  EntitySearchDelegate({
    required this.buildListTile,
    required this.emptyLabel,
    TextInputType keyboardType = TextInputType.name,
    this.onCreate,
    String? searchFieldLabel,
    TextInputAction textInputAction = TextInputAction.search,
  }) : super(
          keyboardType: keyboardType,
          searchFieldLabel: searchFieldLabel,
          textInputAction: textInputAction,
        );

  final Widget Function(T value, VoidCallback? onTap) buildListTile;
  final String emptyLabel;
  final void Function(String)? onCreate;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
      ),
      if (onCreate != null)
        IconButton(
          onPressed: () {
            close(context, null);
            onCreate!(query);
          },
          icon: const Icon(Icons.create),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const BackButtonIcon(),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Should never be called, since `showResults` is overridden
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    context.read<EntitySearchCubit<T>>().query(query);
    return BlocBuilder<EntitySearchCubit<T>, List<T>?>(
        builder: (context, state) {
      if (state == null) {
        return const LinearProgressIndicator();
      }
      if (state.isEmpty) {
        return Center(
          child: AsciimojiShrug(label: emptyLabel),
        );
      }
      return ListView.builder(
        itemCount: state.length,
        itemBuilder: (context, index) {
          final value = state.elementAt(index);
          return buildListTile(
            value,
            () => close(context, value),
          );
        },
      );
    });
  }

  @override
  void showResults(BuildContext context) {
    final state = context.read<EntitySearchCubit<T>>().state;
    if (state?.length == 1) {
      close(context, state!.first);
    } else {
      close(context, null);
    }
  }
}
