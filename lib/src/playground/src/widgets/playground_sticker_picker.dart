import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/sticker_booth/sticker_booth.dart';
import 'package:flutter/material.dart';

import '../../playground.dart';

///
class StickerPicker extends StatelessWidget {
  ///
  const StickerPicker({
    Key? key,
    required this.initialIndex,
    required this.onStickerSelected,
    required this.onTabChanged,
    required this.bucket,
    this.background,
  }) : super(key: key);

  ///
  final int initialIndex;

  ///
  final ValueSetter<Sticker> onStickerSelected;

  ///
  final ValueSetter<int> onTabChanged;

  ///
  final PageStorageBucket bucket;

  ///
  final GradientBackground? background;

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
                height: 70.0,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: StickersTabs(
                initialIndex: initialIndex,
                onTabChanged: onTabChanged,
                onStickerSelected: onStickerSelected,
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
    required this.onStickerSelected,
    required this.onTabChanged,
    this.initialIndex = 0,
  }) : super(key: key);

  ///
  final ValueSetter<Sticker> onStickerSelected;

  ///
  final ValueSetter<int> onTabChanged;

  ///
  final int initialIndex;

  @override
  State<StickersTabs> createState() => _StickersTabsState();
}

class _StickersTabsState extends State<StickersTabs>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex,
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
      decoration: const BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                StickersTabBarView(
                  key: const Key('stickersTabs_artsTabBarView'),
                  stickers: arts,
                  onStickerSelected: widget.onStickerSelected,
                ),
                StickersTabBarView(
                  key: const Key('stickersTabs_emojisTabBarView'),
                  stickers: gifs,
                  onStickerSelected: widget.onStickerSelected,
                ),
                StickersTabBarView(
                  key: const Key('stickersTabs_shapesTabBarView'),
                  stickers: gifs,
                  onStickerSelected: widget.onStickerSelected,
                ),
              ],
            ),
          ),
          TabBar(
            onTap: widget.onTabChanged,
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorPadding: const EdgeInsets.symmetric(vertical: 10.0),
            indicator: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16.0),
            ),
            tabs: const [
              StickersTab(
                key: Key('stickersTabs_artsTab'),
                assetPath: 'assets/icons/google_icon.png',
                label: 'ARTS',
              ),
              StickersTab(
                key: Key('stickersTabs_emojisTab'),
                assetPath: 'assets/icons/hats_icon.png',
                label: 'EMOJIS',
              ),
              StickersTab(
                key: Key('stickersTabs_shapesTab'),
                assetPath: 'assets/icons/hats_icon.png',
                label: 'SHAPES',
              ),
            ],
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
    required this.assetPath,
    required this.label,
    this.active = true,
  }) : super(key: key);

  ///
  final String assetPath;

  ///
  final String label;

  ///
  final bool active;

  @override
  _StickersTabState createState() => _StickersTabState();
}

class _StickersTabState extends State<StickersTab>
    with AutomaticKeepAliveClientMixin<StickersTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16.0),
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
  }) : super(key: key);

  ///
  final Set<Sticker> stickers;

  ///
  final ValueSetter<Sticker> onStickerSelected;

  static const _smallGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 100,
    childAspectRatio: 1,
    mainAxisSpacing: 48,
    crossAxisSpacing: 24,
  );

  @override
  Widget build(BuildContext context) {
    const gridDelegate = _smallGridDelegate;
    return GridView.builder(
      key: PageStorageKey<String>('$key'),
      gridDelegate: gridDelegate,
      padding: const EdgeInsets.all(32),
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
      switch (s.pathType) {
        case PathType.networkImg:
          return _Network(
            url: s.path,
            onPressed: onPressed,
          );
        default:
          return const SizedBox();
      }
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
