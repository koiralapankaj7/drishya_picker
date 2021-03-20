part of '../drishya_picker.dart';

///
class GalleryView extends StatefulWidget {
  ///
  const GalleryView({
    Key? key,
    required this.mediaController,
    this.headerBackground,
    this.panelBackground,
  }) : super(key: key);

  ///
  final Color? headerBackground;

  ///
  final Color? panelBackground;

  ///
  final CustomMediaController? mediaController;

  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late PanelController _panelController;

  @override
  void initState() {
    super.initState();

    _panelController = widget.mediaController!.panelController;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.0,
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.decelerate,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toogleAlbumList() {
    final gState = context.read<GalleryCubit>().state;

    if (!gState.hasPermission || gState.items.isEmpty) return;

    if (_animationController.isAnimating) return;
    _panelController.isGestureEnabled = _animationController.value == 1.0;
    if (_animationController.value == 1.0) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  void _onClosePressed() {
    if (_animationController.isAnimating) return;
    if (_animationController.value == 1.0) {
      _animationController.reverse();
      _panelController.isGestureEnabled = true;
    } else {
      _panelController.minimizePanel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final albumListHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        _panelController.headerMaxHeight!;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Header
        Header(
          background: widget.headerBackground,
          toogleAlbumList: _toogleAlbumList,
          onClosePressed: _onClosePressed,
          headerSubtitle: widget.mediaController!.setting!.albumSubtitle,
        ),

        // Gallery
        Column(
          children: [
            // Space for header
            ValueListenableBuilder<SliderValue>(
              valueListenable: _panelController,
              builder: (context, SliderValue value, child) {
                final num height = (_panelController.headerMinHeight! +
                        (_panelController.headerMaxHeight! -
                                _panelController.headerMinHeight!) *
                            value.factor *
                            1.2)
                    .clamp(
                  _panelController.headerMinHeight!,
                  _panelController.headerMaxHeight!,
                );

                return SizedBox(height: height as double?);
              },
            ),

            // Gallery view
            Expanded(
              child: Container(
                color: widget.panelBackground ?? Colors.black,
                child: BlocConsumer<GalleryCubit, GalleryState>(
                  listener: (context, state) {
                    // PhotoManager.requestPermission();
                    // if (s.paginationFailure != null) {
                    //   ScaffoldMessenger.of(context)
                    //.showSnackBar(SnackBar(
                    //       content: Text(s.paginationFailure.message)));
                    // }
                  },
                  builder: (context, state) {
                    // Loading state
                    if (state.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state.hasError) {
                      if (!state.hasPermission) {
                        return const _PermissionRequest();
                      }
                    }

                    if (state.items.isEmpty) {
                      return const Center(
                        child: Text(
                          'No media available',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      controller: _panelController.scrollController,
                      padding: const EdgeInsets.all(0.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 1.0,
                        mainAxisSpacing: 1.0,
                      ),
                      itemCount: state.count,
                      itemBuilder: (context, index) {
                        final entity = state.items[index];
                        return _ImageView(entity: entity);
                      },
                    );
                  },
                ),
              ),
            ),

            //
          ],
        ),

        // Send and edit button
        Positioned(
          bottom: 0.0,
          child: _SelectSelection(
            mediaController: widget.mediaController,
          ),
        ),

        // Album List
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Positioned(
              bottom: albumListHeight * (_animation.value - 1),
              left: 0.0,
              right: 0.0,
              child: child!,
            );
          },
          child: _AlbumList(
            height: albumListHeight,
            onPressed: (album) {
              context.read<CurrentAlbumCubit>().changeAlbum(album);
              _toogleAlbumList();
            },
          ),
        ),

        //
      ],
    );
  }
}

class _AlbumList extends StatelessWidget {
  const _AlbumList({
    Key? key,
    required this.height,
    this.onPressed,
  }) : super(key: key);

  final double height;
  final Function(AssetPathEntity album)? onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumCollectionCubit, AlbumCollectionState>(
      builder: (context, state) {
        // Loading
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (state.hasError) {
          if (!state.hasPermission) {
            return const _PermissionRequest();
          }
          return Center(
            child: Text(
              state.error ?? 'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        // Album list
        return Container(
          height: height,
          color: Colors.black,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16.0),
            itemCount: state.count,
            itemBuilder: (context, index) {
              final entity = state.albums[index];
              return _Album(
                entity: entity,
                onPressed: onPressed,
              );
            },
          ),
        );
      },
    );
  }
}

class _Album extends StatelessWidget {
  const _Album({
    Key? key,
    required this.entity,
    this.onPressed,
  }) : super(key: key);

  final AssetPathEntity entity;
  final imageSize = 48;
  final Function(AssetPathEntity album)? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed?.call(entity);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, bottom: 20.0, right: 16.0),
        color: Colors.black,
        child: Row(
          children: [
            // Image
            Container(
              height: imageSize.toDouble(),
              width: imageSize.toDouble(),
              color: Colors.grey,
              child: FutureBuilder<List<AssetEntity>>(
                future: entity.getAssetListPaged(0, 1),
                builder: (context, listSnapshot) {
                  if (listSnapshot.connectionState == ConnectionState.done &&
                      (listSnapshot.data?.isNotEmpty ?? false)) {
                    return FutureBuilder<Uint8List?>(
                      future: listSnapshot.data!.first
                          .thumbDataWithSize(imageSize * 5, imageSize * 5),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        }

                        return const SizedBox();
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),

            const SizedBox(width: 16.0),

            // Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Album name
                  Text(
                    entity.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  // Total photos
                  Text(
                    entity.assetCount.toString(),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            ),

            //
          ],
        ),
      ),
    );
  }
}

class _ImageView extends StatefulWidget {
  const _ImageView({
    Key? key,
    required this.entity,
  }) : super(key: key);

  final AssetEntity entity;

  @override
  __ImageViewState createState() => __ImageViewState();
}

class __ImageViewState extends State<_ImageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaController = context.mediaController;

    return GestureDetector(
      onTap: () {
        mediaController!._select(widget.entity, context);
      },
      child: Container(
        color: Colors.grey.shade700,
        child: FutureBuilder<Uint8List?>(
          future: widget.entity.thumbDataWithSize(
            400,
            400,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _animation,
                    child: child,
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),

                    // Duration
                    if (widget.entity.type == AssetType.video)
                      Positioned(
                        right: 4.0,
                        bottom: 4.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            color: Colors.black.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.0, vertical: 2.0),
                            child: Text(
                              widget.entity.duration.formatedDuration,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Image selection overlay
                    ValueListenableBuilder<CustomMediaValue>(
                      valueListenable: mediaController!,
                      builder: (context, value, child) {
                        final isSelected =
                            value.entities.contains(widget.entity);

                        if (!isSelected) return const SizedBox();

                        return Container(
                          color: Colors.white54,
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              radius: 14.0,
                              child: Text(
                                '${value.entities.indexOf(widget.entity) + 1}',
                                style: const TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    //
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _SelectSelection extends StatefulWidget {
  const _SelectSelection({
    Key? key,
    required this.mediaController,
  }) : super(key: key);

  final CustomMediaController? mediaController;

  @override
  __SelectSelectionState createState() => __SelectSelectionState();
}

class __SelectSelectionState extends State<_SelectSelection>
    with TickerProviderStateMixin {
  late AnimationController _editOpaController;
  late AnimationController _selectOpaController;
  late AnimationController _selectSizeController;
  late Animation<double> _editOpa;
  late Animation<double> _selectOpa;
  late Animation<double> _selectSize;

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 300);
    _editOpaController = AnimationController(vsync: this, duration: duration);
    _selectOpaController = AnimationController(vsync: this, duration: duration);
    _selectSizeController =
        AnimationController(vsync: this, duration: duration);

    final tween = Tween(begin: 0.0, end: 1.0);

    _editOpa = tween.animate(CurvedAnimation(
      parent: _editOpaController,
      curve: Curves.easeIn,
    ));

    _selectOpa = tween.animate(CurvedAnimation(
      parent: _selectOpaController,
      curve: Curves.easeIn,
    ));

    _selectSize = tween.animate(CurvedAnimation(
      parent: _selectSizeController,
      curve: Curves.easeIn,
    ));

    widget.mediaController!.addListener(() {
      if (mounted) {
        final entities = widget.mediaController!.value.entities;

        if (!widget.mediaController!.reachedMaximumLimit) {
          if (entities.isEmpty && _selectOpaController.value == 1.0) {
            _editOpaController.reverse();
            _selectOpaController.reverse();
          }

          if (entities.isNotEmpty) {
            if (entities.length == 1) {
              _editOpaController.forward();
              _selectOpaController.forward();
              _selectSizeController.reverse();
            } else {
              _editOpaController.reverse();
              _selectSizeController.forward();
              if (_selectOpaController.value == 0.0) {
                _selectOpaController.forward();
              }
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _editOpaController.dispose();
    _selectOpaController.dispose();
    _selectSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const padding = 20.0 + 16.0 + 20.0;
    final buttonWidth = (size.width - padding) / 2;
    final mediaController = widget.mediaController!;

    return ValueListenableBuilder<CustomMediaValue>(
      valueListenable: mediaController,
      builder: (context, value, child) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          width: size.width,
          child: Stack(
            children: [
              // Edit button
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedBuilder(
                  animation: _editOpa,
                  builder: (context, child) {
                    final hide = (value.entities.isEmpty &&
                            !_editOpaController.isAnimating) ||
                        _editOpa.value == 0.0;
                    return hide
                        ? const SizedBox()
                        : Opacity(
                            opacity: _editOpa.value,
                            child: child,
                          );
                  },
                  child: SizedBox(
                    width: buttonWidth,
                    child: _TextButton(
                      onPressed: () {
                        log('Edit photo');
                      },
                      label: 'EDIT',
                      background: Colors.white,
                      labelColor: Colors.black,
                    ),
                  ),
                ),
              ),

              // Margin
              const SizedBox(width: 16.0),

              // Select
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedBuilder(
                  animation: _selectOpa,
                  builder: (context, child) {
                    final hide = (value.entities.isEmpty &&
                            !_selectOpaController.isAnimating) ||
                        _selectOpa.value == 0.0;

                    return hide
                        ? const SizedBox()
                        : Opacity(
                            opacity: _selectOpa.value,
                            child: child,
                          );
                  },
                  child: AnimatedBuilder(
                    animation: _selectSize,
                    builder: (context, child) {
                      return SizedBox(
                        width: buttonWidth +
                            _selectSize.value * (buttonWidth + 20.0),
                        child: child,
                      );
                    },
                    child: _TextButton(
                      onPressed: mediaController._submit,
                      label: 'SELECT',
                    ),
                  ),
                ),
              ),

              // Send Button
            ],
          ),
        );
      },
    );
  }
}

class _TextButton extends StatelessWidget {
  const _TextButton({
    Key? key,
    this.label,
    this.background,
    this.labelColor,
    this.onPressed,
  }) : super(key: key);

  final String? label;
  final Color? background;
  final Color? labelColor;
  final Function? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed as void Function()?,
      child: Text(
        label ?? '',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: labelColor ?? Colors.white,
            ),
      ),
      style: TextButton.styleFrom(
        primary: Colors.black,
        backgroundColor: background ?? Colors.lightBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14.0),
      ),
    );
  }
}

class _PermissionRequest extends StatelessWidget {
  const _PermissionRequest();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Heading
          Text(
            'Access Your Album',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.0,
            ),
          ),

          const SizedBox(height: 8.0),

          // Description
          Text(
            'Allow Drishya picker to access your album for picking media.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8.0),

          // Allow access button
          TextButton(
            onPressed: PhotoManager.openSetting,
            child: Text('Allow Access'),
          ),
        ],
      ),
    );
  }
}

extension on int {
  String get formatedDuration {
    final duration = Duration(seconds: this);
    final min = duration.inMinutes.remainder(60).toString();
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }
}
