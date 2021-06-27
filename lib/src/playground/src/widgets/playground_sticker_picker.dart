import 'package:drishya_picker/src/animations/animations.dart';
import 'package:drishya_picker/src/sticker_booth/sticker_booth.dart';
import 'package:flutter/material.dart';

///
class StickerPicker extends StatelessWidget {
  ///
  const StickerPicker({
    Key? key,
    required this.initialIndex,
    required this.onStickerSelected,
    required this.onTabChanged,
    required this.bucket,
  }) : super(key: key);

  ///
  final int initialIndex;

  ///
  final ValueSetter<Sticker> onStickerSelected;

  ///
  final ValueSetter<int> onTabChanged;

  ///
  final PageStorageBucket bucket;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return PageStorage(
      bucket: bucket,
      child: Container(
        height: screenHeight * 0.90,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Text(
                      'Add sticker',
                      style: Theme.of(context)
                          .textTheme
                          .headline3
                          ?.copyWith(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: StickersTabs(
                    initialIndex: initialIndex,
                    onTabChanged: onTabChanged,
                    onStickerSelected: onStickerSelected,
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              top: 8,
              child: IconButton(
                key: const Key('stickersDrawer_close_iconButton'),
                icon: const Icon(
                  Icons.clear,
                  color: Colors.black54,
                ),
                onPressed: () => Navigator.of(context).pop(),
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
      length: 2,
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
    return Column(
      children: [
        TabBar(
          onTap: widget.onTabChanged,
          controller: _tabController,
          tabs: const [
            StickersTab(
              key: Key('stickersTabs_googleTab'),
              assetPath: 'assets/icons/google_icon.png',
            ),
            StickersTab(
              key: Key('stickersTabs_hatsTab'),
              assetPath: 'assets/icons/hats_icon.png',
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              StickersTabBarView(
                key: const Key('stickersTabs_googleTabBarView'),
                stickers: arts,
                onStickerSelected: widget.onStickerSelected,
              ),
              StickersTabBarView(
                key: const Key('stickersTabs_hatsTabBarView'),
                stickers: gifs,
                onStickerSelected: widget.onStickerSelected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

///
@visibleForTesting
class StickersTab extends StatefulWidget {
  ///
  const StickersTab({
    Key? key,
    required this.assetPath,
  }) : super(key: key);

  ///
  final String assetPath;

  @override
  _StickersTabState createState() => _StickersTabState();
}

class _StickersTabState extends State<StickersTab>
    with AutomaticKeepAliveClientMixin<StickersTab> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const Tab(
      iconMargin: EdgeInsets.only(bottom: 24),
      icon: Icon(
        Icons.emoji_emotions,
        color: Colors.black,
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

  // static const _defaultGridDelegate =
  // SliverGridDelegateWithMaxCrossAxisExtent(
  //   maxCrossAxisExtent: 150,
  //   childAspectRatio: 1,
  //   mainAxisSpacing: 64,
  //   crossAxisSpacing: 42,
  // );

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
          asset: sticker,
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
    required this.asset,
    required this.onPressed,
  }) : super(key: key);

  ///
  final Sticker asset;

  ///
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    switch (asset.pathType) {
      case StickerPathType.networkImg:
        return _Network(
          url: asset.path!,
          onPressed: onPressed,
        );
      default:
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
