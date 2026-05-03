import 'package:flutter/material.dart';

class FoodSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;

  const FoodSearchBar({
    Key? key,
    required this.onSearch,
    this.hintText = 'Search restaurants...',
  }) : super(key: key);

  @override
  State<FoodSearchBar> createState() => _FoodSearchBarState();
}

class _FoodSearchBarState extends State<FoodSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onSearch,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onSearch('');
                },
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
