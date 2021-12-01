import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/editor/editor.dart';
import 'package:flutter/material.dart';

///
class StickerPicker extends StatelessWidget {
  ///
  const StickerPicker({
    Key? key,
    required this.setting,
    required this.initialIndex,
    required this.onStickerSelected,
    required this.onTabChanged,
    required this.bucket,
    required this.imageBackground,
  }) : super(key: key);

  ///
  final EditorSetting setting;

  ///
  final int initialIndex;

  ///
  final ValueSetter<Sticker> onStickerSelected;

  ///
  final ValueSetter<int> onTabChanged;

  ///
  final PageStorageBucket bucket;

  ///
  final bool imageBackground;

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
                setting: setting,
                initialIndex: initialIndex,
                onTabChanged: onTabChanged,
                onStickerSelected: onStickerSelected,
                imageBackground: imageBackground,
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
    required this.setting,
    required this.onStickerSelected,
    required this.onTabChanged,
    required this.imageBackground,
    this.initialIndex = 0,
  }) : super(key: key);

  ///
  final EditorSetting setting;

  ///
  final ValueSetter<Sticker> onStickerSelected;

  ///
  final ValueSetter<int> onTabChanged;

  ///
  final int initialIndex;

  ///
  final bool imageBackground;

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
    _stickers = widget.setting.stickers ?? stickers;
    _tabController = TabController(
      length: _stickers.length,
      initialIndex: widget.initialIndex,
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.imageBackground ? Colors.black54 : Colors.white54,
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
                  stickers: stickers,
                  onStickerSelected: widget.onStickerSelected,
                  maxCrossAxisExtent: 100,
                );
              }).toList(),
              // [
              //   StickersTabBarView(
              //     key: const Key('stickersTabs_artsTabBarView'),
              //     stickers: arts,
              //     onStickerSelected: widget.onStickerSelected,
              //     maxCrossAxisExtent: 100,
              //   ),
              //   StickersTabBarView(
              //     key: const Key('stickersTabs_emojisTabBarView'),
              //     stickers: gifs,
              //     onStickerSelected: widget.onStickerSelected,
              //     maxCrossAxisExtent: 70,
              //   ),
              //   StickersTabBarView(
              //     key: const Key('stickersTabs_shapesTabBarView'),
              //     stickers: shapes,
              //     onStickerSelected: widget.onStickerSelected,
              //   ),
              // ],
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
            isScrollable: _stickers.length > widget.setting.fixedTabSize,
            tabs: _stickers.keys.map((key) {
              return StickersTab(
                key: Key('stickersTabs_${key}Tab'),
                label: key,
              );
            }).toList(),

            // const [
            //   StickersTab(
            //     key: Key('stickersTabs_artsTab'),
            //     label: 'ARTS',
            //   ),
            //   StickersTab(
            //     key: Key('stickersTabs_emojisTab'),
            //     label: 'EMOJIS',
            //   ),
            //   StickersTab(
            //     key: Key('stickersTabs_shapesTab'),
            //     label: 'SHAPES',
            //   ),
            // ],
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
    required this.stickers,
    required this.onStickerSelected,
    this.maxCrossAxisExtent = 50.0,
  }) : super(key: key);

  ///
  final Set<Sticker> stickers;

  ///
  final ValueSetter<Sticker> onStickerSelected;

  ///
  final double maxCrossAxisExtent;

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
        return StickerChoice(
          sticker: sticker,
          onPressed: () => onStickerSelected(sticker),
        );
      },
    );
  }
}

///
@visibleForTesting
class StickerChoice extends StatelessWidget {
  ///
  const StickerChoice({
    Key? key,
    required this.sticker,
    required this.onPressed,
  }) : super(key: key);

  ///
  final Sticker sticker;

  ///
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (sticker is ImageSticker) {
      final s = sticker as ImageSticker;
      if (s.isNetworkImage) {
        return _Network(
          url: s.path,
          onPressed: onPressed,
        );
      }
      return const SizedBox();
    } else if (sticker is IconSticker) {
      return InkWell(
        onTap: onPressed,
        child: FittedBox(
          child: Icon(
            (sticker as IconSticker).iconData,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class _Network extends StatelessWidget {
  const _Network({
    Key? key,
    required this.url,
    this.onPressed,
  }) : super(key: key);

  final String url;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        return AppAnimatedCrossFade(
          firstChild: SizedBox.fromSize(
            size: const Size(20, 20),
            child: const AppCircularProgressIndicator(strokeWidth: 2),
          ),
          secondChild: InkWell(
            onTap: onPressed,
            child: child,
          ),
          crossFadeState: frame == null
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        );
      },
    );
  }
}
