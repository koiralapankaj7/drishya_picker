import 'dart:math' as math;

import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
class StickerPicker extends StatelessWidget {
  ///
  const StickerPicker({
    Key? key,
    required this.controller,
    required this.initialIndex,
    required this.onStickerSelected,
    required this.onTabChanged,
    required this.bucket,
    required this.background,
    required this.onBackground,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  ///
  final int initialIndex;

  ///
  final ValueSetter<Sticker> onStickerSelected;

  ///
  final ValueSetter<int> onTabChanged;

  ///
  final PageStorageBucket bucket;

  ///
  final Color background;

  ///
  final Color onBackground;

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: bucket,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            GestureDetector(
              onTap: Navigator.of(context).pop,
              child: Container(
                height: 70,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: StickersTabs(
                controller: controller,
                initialIndex: initialIndex,
                onTabChanged: onTabChanged,
                onStickerSelected: onStickerSelected,
                background: background,
                onBackground: onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///
class StickersTabs extends StatefulWidget {
  ///
  const StickersTabs({
    Key? key,
    required this.controller,
    required this.onStickerSelected,
    required this.onTabChanged,
    required this.background,
    required this.onBackground,
    this.initialIndex = 0,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  ///
  final ValueSetter<Sticker> onStickerSelected;

  ///
  final ValueSetter<int> onTabChanged;

  ///
  final int initialIndex;

  ///
  final Color background;

  ///
  final Color onBackground;

  @override
  State<StickersTabs> createState() => _StickersTabsState();
}

class _StickersTabsState extends State<StickersTabs>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final Map<String, Set<Sticker>> _stickers;

  @override
  void initState() {
    super.initState();
    _stickers = widget.controller.setting.stickers ?? {};
    _tabController = TabController(
      length: _stickers.length,
      initialIndex: math.min(widget.initialIndex, _stickers.length - 1),
      vsync: this,
    );
    _tabController.addListener(() {
      // False when swipe
      if (!_tabController.indexIsChanging) {
        widget.onTabChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stickers.isEmpty) return const SizedBox();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _stickers.keys.map((key) {
                final stickers = _stickers[key] ?? {};
                return StickersTabBarView(
                  key: Key('stickersTabs_${key}TabBarView'),
                  controller: widget.controller,
                  color: widget.onBackground,
                  stickers: stickers,
                  onStickerSelected: widget.onStickerSelected,
                );
              }).toList(),
            ),
          ),
          TabBar(
            onTap: widget.onTabChanged,
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: const EdgeInsets.symmetric(vertical: 10),
            indicator: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            isScrollable:
                _stickers.length > widget.controller.setting.fixedTabSize,
            tabs: _stickers.keys.map((key) {
              return StickersTab(
                key: Key('stickersTabs_${key}Tab'),
                label: key,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

///
class StickersTab extends StatefulWidget {
  ///
  const StickersTab({
    Key? key,
    required this.label,
    this.active = true,
  }) : super(key: key);

  ///
  final String label;

  ///
  final bool active;

  @override
  State<StickersTab> createState() => _StickersTabState();
}

class _StickersTabState extends State<StickersTab>
    with AutomaticKeepAliveClientMixin<StickersTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Text(
          widget.label,
          style: Theme.of(context).textTheme.button?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

///
@visibleForTesting
class StickersTabBarView extends StatelessWidget {
  ///
  const StickersTabBarView({
    Key? key,
    required this.controller,
    required this.stickers,
    required this.onStickerSelected,
    required this.color,
    this.maxCrossAxisExtent = 80.0,
  }) : super(key: key);

  ///
  final DrishyaEditingController controller;

  ///
  final Set<Sticker> stickers;

  ///
  final ValueSetter<Sticker> onStickerSelected;

  ///
  final double maxCrossAxisExtent;

  ///
  final Color color;

  @override
  Widget build(BuildContext context) {
    final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: maxCrossAxisExtent,
      mainAxisSpacing: 24,
      crossAxisSpacing: 24,
    );
    return GridView.builder(
      key: PageStorageKey<String>('$key'),
      gridDelegate: gridDelegate,
      padding: const EdgeInsets.all(24),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers.elementAt(index);
        final updatedSticker =
            sticker is IconSticker ? sticker.copyWith(color: color) : sticker;
        return updatedSticker.build(
          context,
          controller,
          () => onStickerSelected(sticker),
          null,
        );
      },
    );
  }
}
