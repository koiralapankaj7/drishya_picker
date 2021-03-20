part of '../drishya_picker.dart';

///
class Header extends StatelessWidget {
  ///
  const Header({
    Key? key,
    this.background,
    this.headerSubtitle,
    this.toogleAlbumList,
    this.onClosePressed,
  }) : super(key: key);

  ///
  final Color? background;

  ///
  final String? headerSubtitle;

  ///
  final Function? toogleAlbumList;

  ///
  final Function? onClosePressed;

  void _showAlert(BuildContext context) {
    final cancel = TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        'CANCEL',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.lightBlue,
            ),
      ),
    );
    final unselectItems = TextButton(
      onPressed: () {
        context.mediaController!._clearSelection();
        Navigator.of(context).pop();
      },
      child: Text(
        'USELECT ITEMS',
        style: Theme.of(context).textTheme.button!.copyWith(
              color: Colors.blue,
            ),
      ),
    );

    final alertDialog = AlertDialog(
      title: Text(
        'Unselect these items?',
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Colors.white70,
            ),
      ),
      content: Text(
        'Going back will undo the selections you made.',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(
              color: Colors.grey.shade600,
            ),
      ),
      actions: [
        cancel,
        unselectItems,
      ],
      backgroundColor: Colors.grey.shade900,
      // contentPadding: EdgeInsets.all(16.0),
      actionsPadding: const EdgeInsets.all(0.0),
      titlePadding: const EdgeInsets.all(16.0),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 2.0,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => alertDialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaController = context.mediaController!;

    return Container(
      color: background ?? Colors.black,
      constraints: BoxConstraints(
        minHeight: mediaController.panelController.headerMinHeight!,
        maxHeight: mediaController.panelController.headerMaxHeight!,
      ),
      child: Column(
        children: [
          // Handler
          _Handler(height: mediaController.panelController.headerMinHeight),

          // Details and controls
          Expanded(
            child: Row(
              children: [
                // Close icon
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ValueListenableBuilder<DrishyaValue>(
                      valueListenable: mediaController,
                      builder: (context, value, child) {
                        return _IconButton(
                          iconData: Icons.close,
                          onPressed: value.entities.isEmpty
                              ? onClosePressed
                              : () {
                                  _showAlert(context);
                                },
                        );
                      },
                    ),
                  ),
                ),

                // Album name and media receiver name
                _AlbumDetail(subtitle: headerSubtitle),

                // Dropdown
                Expanded(
                  child: Container(
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ValueListenableBuilder<DrishyaValue>(
                      valueListenable: mediaController,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value.entities.isEmpty ? 1.0 : 0.0,
                          child: _AnimatedDropdown(onPressed: toogleAlbumList),
                        );
                      },
                    ),
                  ),
                ),

                //
              ],
            ),
          ),

          //
        ],
      ),
    );
  }
}

class _AnimatedDropdown extends StatefulWidget {
  const _AnimatedDropdown({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  final Function? onPressed;

  @override
  __AnimatedDropdownState createState() => __AnimatedDropdownState();
}

class __AnimatedDropdownState extends State<_AnimatedDropdown> {
  bool isDown = true;
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: isDown ? 1.0 : 0.0, end: isDown ? 0.0 : 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, double value, child) {
        return Transform.rotate(
          angle: pi * value,
          child: child,
        );
      },
      child: _IconButton(
        iconData: Icons.keyboard_arrow_down,
        onPressed: () {
          widget.onPressed?.call();
          setState(() {
            isDown = !isDown;
          });
        },
        size: 34.0,
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    Key? key,
    this.iconData,
    this.onPressed,
    this.size,
  }) : super(key: key);

  final IconData? iconData;
  final Function? onPressed;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(40.0),
      elevation: 0.0,
      child: IconButton(
        padding: const EdgeInsets.all(0.0),
        icon: Icon(
          iconData ?? Icons.close,
          color: Colors.lightBlue.shade300,
          size: size ?? 26.0,
        ),
        onPressed: onPressed as void Function()?,
      ),
    );
  }
}

class _AlbumDetail extends StatelessWidget {
  const _AlbumDetail({
    Key? key,
    this.subtitle,
  }) : super(key: key);

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Album name

        BlocBuilder<CurrentAlbumCubit, CurrentAlbumState>(
          builder: (context, state) {
            return Text(
              state.name,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            );
          },
        ),

        const SizedBox(height: 2.0),

        // Receiver name
        Text(
          subtitle ?? 'Select',
          style: Theme.of(context)
              .textTheme
              .caption!
              .copyWith(color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _Handler extends StatelessWidget {
  const _Handler({
    Key? key,
    this.height,
  }) : super(key: key);

  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            width: 40.0,
            height: 5.0,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
