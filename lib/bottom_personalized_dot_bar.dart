library bottom_personalized_dot_bar;

import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

/// [BottomPersonalizedDotBar] Parent class to create a custom navigation bar
class BottomPersonalizedDotBar extends StatefulWidget {
  /// List of items to be displayed in the navigation bar
  final List<BottomPersonalizedDotBarItem> items;

  /// List of items that will be hidden
  final List<BottomPersonalizedDotBarItem> hiddenItems;

  /// Item key that is selected
  final String keyItemSelected;

  /// Navigation bar width
  final double width;

  /// Navigation bar height
  final double height;

  /// Navigation bar radius
  final BorderRadius borderRadius;

  /// Selected Icon color
  final Color selectedColorIcon;

  /// Unselected Icon color
  final Color unSelectedColorIcon;

  /// Navigator Container Background color
  final Color navigatorBackground;

  /// Setting Container Background color (Hidden items)
  final Color settingBackground;

  /// Settings button icon
  final IconData iconSetting;

  /// Settings button icon color
  final Color iconSettingColor;

  /// Setting Title Text
  final String settingTitleText;

  /// Setting Title color
  final Color settingTitleColor;

  /// Setting Sub-Title Text
  final String settingSubTitleText;

  /// Setting Sub-Title color
  final Color settingSubTitleColor;

  /// Done button Text
  final String doneText;

  /// Text Done Color
  final Color textDoneColor;

  /// Button done color
  final Color buttonDoneColor;

  /// Background of hidden item
  final Color hiddenItemBackground;

  /// Icon Hidden Color
  final Color iconHiddenColor;

  /// Text Hidden Color
  final Color textHiddenColor;

  /// Selection Indicator Color (Dot|Point)
  final Color dotColor;

  /// Shadow of container
  final List<BoxShadow> boxShadow;

  /// Event when you sort the hidden options, this has as parameter the list of hidden options with the new order.
  final Function(List<BottomPersonalizedDotBarItem> hiddenItems)
      onOrderHideItems;

  /// Event when ordering browser options, this has as parameter the list of options with the new order.
  final Function(List<BottomPersonalizedDotBarItem> items) onOrderItems;

  /// Event when you add a new option to the navigation bar, this has as parameters the item you add and the list of options.
  final Function(BottomPersonalizedDotBarItem itemAdd,
      List<BottomPersonalizedDotBarItem> items) onAddItem;

  /// Event when you delete an option from the navigation bar, this has as parameters the element to delete and the list of hidden options.
  final Function(BottomPersonalizedDotBarItem itemRemove,
      List<BottomPersonalizedDotBarItem> hiddenItems) onRemoveItem;

  /// Constructor
  const BottomPersonalizedDotBar(
      {@required this.items,
      @required this.hiddenItems,
      Key key,
      this.width,
      this.height = 110.0,
      this.borderRadius =
          const BorderRadius.vertical(top: const Radius.circular(60.0)),
      this.selectedColorIcon = const Color(0xBB000000),
      this.unSelectedColorIcon = Colors.black38,
      this.boxShadow,
      this.navigatorBackground = Colors.white,
      this.settingBackground = Colors.black,
      this.iconSettingColor = Colors.yellow,
      this.iconSetting = Icons.content_copy,
      this.settingTitleText = 'Your Menu',
      this.settingSubTitleText = 'Drag and drop options',
      this.doneText = 'Done',
      this.buttonDoneColor = Colors.yellow,
      this.settingTitleColor = Colors.white,
      this.settingSubTitleColor = Colors.yellow,
      this.onOrderHideItems,
      this.onOrderItems,
      this.onAddItem,
      this.onRemoveItem,
      this.keyItemSelected,
      this.hiddenItemBackground = Colors.white,
      this.iconHiddenColor = Colors.black,
      this.textHiddenColor = Colors.black,
      this.textDoneColor = Colors.black,
      this.dotColor = const Color(0xBB000000)})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BottomPersonalizedDotBarState();
}

class _BottomPersonalizedDotBarState extends State<BottomPersonalizedDotBar> {
  StreamController<_DragItemUpdate> _dragItemUpdateStream;
  ScrollController _scrollController;
  double _positionIndicatorDot;
  double _widthBase;
  double _navContainerTranslate = .0;
  bool _activeLimitScroll = false;
  bool _isRightDirection;
  bool _settingVisible = false;
  bool _buttonSettingVisible = false;
  Offset _positionDrag = Offset.zero;
  Offset _initPositionItem = Offset.zero;
  List<double> _translateItemList = [];
  List<double> _translateHiddenItemList = [];
  BottomPersonalizedDotBarItem _draggedItem;
  bool _blockAnimationHiddenMenuOption = true;
  bool _animationItemNavigator = false;
  List<BottomPersonalizedDotBarItem> _internalItems;
  List<BottomPersonalizedDotBarItem> _internalHiddenItems;

  @override
  void initState() {
    _internalItems = widget.items;
    _internalHiddenItems = widget.hiddenItems;
    _dragItemUpdateStream = StreamController<_DragItemUpdate>();
    _scrollController = ScrollController();
    _dragItemUpdateStream.stream.listen((event) {
      setState(() {
        if (event.eventDragEnum == _EventDragEnum.START) {
          _draggedItem = event.item;
          _animationItemNavigator = true;
          _initPositionItem = event.typeMenuOption == _TypeMenuOption.NAVIGATION
              ? Offset(event.position.dx - .5, event.position.dy + 7.0)
              : event.position;
          _positionDrag = event.typeMenuOption == _TypeMenuOption.NAVIGATION
              ? Offset(event.position.dx, event.position.dy - 15.0)
              : event.position;
          if (event.typeMenuOption == _TypeMenuOption.NAVIGATION)
            _translateItemList = getTranslateItemListFromBottom(
                _positionXNavigator(_positionDrag.dx), .0, .0);
          else
            _translateHiddenItemList = getTranslateHiddenItemListFromTop(
                _positionXNavigator(_initPositionItem.dx), .0, .0);
        } else if (event.eventDragEnum == _EventDragEnum.UPDATE) {
          _blockAnimationHiddenMenuOption = false;
          _positionDrag = Offset(_positionDrag.dx + event.position.dx,
              _positionDrag.dy + event.position.dy);
          final initXPositionDrag = _positionDrag.dx - _initPositionItem.dx;
          final initYPositionDrag = _positionDrag.dy - _initPositionItem.dy;
          if (event.typeMenuOption == _TypeMenuOption.NAVIGATION) {
            _translateHiddenItemList = getTranslateHiddenItemListFromBottom(
                _positionXNavigator(_positionDrag.dx), initYPositionDrag);
            _translateItemList = getTranslateItemListFromBottom(
                _positionXNavigator(_positionDrag.dx),
                initXPositionDrag,
                initYPositionDrag);
          } else {
            _translateHiddenItemList = getTranslateHiddenItemListFromTop(
                _positionXNavigator(_positionDrag.dx),
                initXPositionDrag,
                initYPositionDrag);
            _translateItemList = getTranslateItemListFromTop(
                _positionXNavigator(_positionDrag.dx), initYPositionDrag);
          }
        } else if (event.eventDragEnum == _EventDragEnum.END) {
          final initXPositionDrag = _positionDrag.dx - _initPositionItem.dx;
          final initYPositionDrag = _positionDrag.dy - _initPositionItem.dy;
          final xPosition = _positionXNavigator(_positionDrag.dx);
          if (event.typeMenuOption == _TypeMenuOption.NAVIGATION) {
            if (initYPositionDrag >= -60.0 &&
                ((xPosition + 110.0) >= -25.0 &&
                    (xPosition + 110.0) <= (_widthBase - 55))) {
              if (_translateItemList.any((value) => value != .0)) {
                final oldIndex = _internalItems.indexOf(_draggedItem);
                final newIndex = initXPositionDrag.isNegative
                    ? _translateItemList.indexWhere((value) => value != .0)
                    : _translateItemList.lastIndexWhere((value) => value != .0);
                final double positionX =
                    (_widthBase / (_internalItems.length) * 0.5) *
                        (newIndex + (newIndex + 1));
                double differenceWidth = _differenceWidthContainer() - 110.0;
                _positionDrag = Offset(
                    differenceWidth + positionX - 42.5, _initPositionItem.dy);
                _translateHiddenItemList = [];
                _animationItemNavigator = false;
                _executeAfterAnimation(() {
                  _reorderItemList(oldIndex, newIndex);
                  _translateItemList = [];
                  _resetOperators();
                });
              } else {
                _positionDrag = _initPositionItem;
                _translateItemList = [];
                _translateHiddenItemList = [];
                _executeAfterAnimation(_resetOperators);
              }
            } else if ((initYPositionDrag >= -250.0 &&
                    initYPositionDrag <= -40.0) &&
                (xPosition >= -80.0 && xPosition <= (_widthBase - 20))) {
              final indexItemRemove = _internalItems.indexOf(_draggedItem);
              final indexPositionHidden =
                  _translateHiddenItemList.indexWhere((value) => value != .0);
              _translateHiddenItemList = _translateHiddenItemList
                  .map((value) => value == .0 ? .0 : 105.0)
                  .toList();
              final heightYPosition =
                  MediaQuery.of(context).size.height - widget.height;
              _positionDrag = Offset(
                  (indexPositionHidden != -1
                              ? indexPositionHidden
                              : _translateHiddenItemList.length) *
                          105.0 +
                      _differenceWidthContainer() +
                      35.0 -
                      _scrollController.offset,
                  heightYPosition - 122.0);
              _animationItemNavigator = false;
              _executeAfterAnimation(() {
                _removeItemList(
                    indexItemRemove,
                    indexPositionHidden != -1
                        ? indexPositionHidden
                        : _translateHiddenItemList.length);
                _translateItemList = [];
                _resetOperators();
              });
            } else {
              _positionDrag = _initPositionItem;
              _translateItemList = [];
              _translateHiddenItemList = [];
              _executeAfterAnimation(_resetOperators);
            }
          } else if (event.typeMenuOption == _TypeMenuOption.HIDDEN) {
            if (initYPositionDrag >= 80.0 &&
                (xPosition >= -135.0 && xPosition <= (_widthBase - 165))) {
              final indexItem = _internalHiddenItems.indexOf(_draggedItem);
              _translateHiddenItemList =
                  _translateHiddenItemList.map((value) => .0).toList();
              final indexNavigator = _translateItemList
                          .indexWhere((value) => !value.isNegative) !=
                      -1
                  ? _translateItemList.indexWhere((value) => !value.isNegative)
                  : _translateItemList.length;
              final yPosition =
                  MediaQuery.of(context).size.height - (widget.height * 0.5);
              double differenceWidth = _differenceWidthContainer() - 110.0;
              final double positionX =
                  (_widthBase / (_internalItems.length + 1) * 0.5) *
                      (indexNavigator + (indexNavigator + 1));
              _positionDrag =
                  Offset(differenceWidth + positionX - 42.5, yPosition - 34);
              _animationItemNavigator = false;
              _executeAfterAnimation(() {
                _insertItemToNavigator(indexItem, indexNavigator);
                _translateItemList = [];
                _resetOperators();
              });
            } else if ((initYPositionDrag >= -105.0 &&
                    initYPositionDrag <= 105.0) &&
                (xPosition >= -80.0 && xPosition <= (_widthBase - 20))) {
              final oldIndex = _internalHiddenItems.indexOf(_draggedItem);
              final previewValue =
                  oldIndex != 0 ? _translateHiddenItemList[oldIndex - 1] : .0;
              final nextValue = (oldIndex + 1) != _internalHiddenItems.length
                  ? _translateHiddenItemList[oldIndex + 1]
                  : -1.0;
              if (previewValue != .0 || nextValue == .0) {
                _translateHiddenItemList = _translateHiddenItemList
                    .map((value) => value == .0 ? .0 : 105.0)
                    .toList();
                final newIndex = _translateHiddenItemList
                        .lastIndexWhere((value) => value == .0) +
                    (initXPositionDrag.isNegative ? 1 : 0);
                _positionDrag = Offset(
                    newIndex * 105.0 +
                        _differenceWidthContainer() +
                        35.0 -
                        _scrollController.offset,
                    _initPositionItem.dy);
                _executeAfterAnimation(() {
                  _reorderHiddenItemList(oldIndex, newIndex);
                  _resetOperators();
                });
              } else {
                _translateHiddenItemList = getTranslateHiddenItemListFromTop(
                    _positionXNavigator(_initPositionItem.dx), .0, .0);
                _positionDrag = _initPositionItem;
                _translateItemList = [];
                _executeAfterAnimation(_resetOperators);
              }
            } else {
              _translateHiddenItemList = getTranslateHiddenItemListFromTop(
                  _positionXNavigator(_initPositionItem.dx), .0, .0);
              _positionDrag = _initPositionItem;
              _translateItemList = [];
              _executeAfterAnimation(_resetOperators);
            }
          }
        }
      });
    });
    super.initState();
  }

  _executeAfterAnimation(Function() function) {
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        function();
      });
    });
  }

  _reorderHiddenItemList(int oldIndex, int newIndex) {
    final item = _internalHiddenItems.removeAt(oldIndex);
    _internalHiddenItems.insert(newIndex, item);
    if (widget.onOrderHideItems != null)
      widget.onOrderHideItems(_internalHiddenItems);
  }

  _reorderItemList(int oldIndex, int newIndex) {
    final item = _internalItems.removeAt(oldIndex);
    _internalItems.insert(newIndex, item);
    if (widget.onOrderItems != null) widget.onOrderItems(_internalItems);
  }

  _insertItemToNavigator(int indexItem, int indexNavigator) {
    final item = _internalHiddenItems.removeAt(indexItem);
    _internalItems.insert(indexNavigator, item);
    if (widget.onAddItem != null) widget.onAddItem(item, _internalItems);
  }

  _removeItemList(int indexRemove, int indexHiddenPosition) {
    final item = _internalItems.removeAt(indexRemove);
    _internalHiddenItems.insert(indexHiddenPosition, item);
    if (widget.onRemoveItem != null)
      widget.onRemoveItem(item, _internalHiddenItems);
  }

  void _resetOperators() {
    _draggedItem = null;
    _positionDrag = Offset.zero;
    _translateHiddenItemList = [];
    _blockAnimationHiddenMenuOption = true;
  }

  List<double> getTranslateHiddenItemListFromTop(double dragContainerXPosition,
      double initXPositionDrag, double initYPositionDrag) {
    return (initYPositionDrag >= -105.0 && initYPositionDrag <= 105.0) &&
            (dragContainerXPosition >= -80.0 &&
                dragContainerXPosition <= (_widthBase - 20))
        ? Iterable<double>.generate(
            _internalHiddenItems.length,
            (index) => (dragContainerXPosition + _scrollController.offset) <=
                    (index * 105.0) +
                        (initXPositionDrag.isNegative ? 90.0 : -18.0)
                ? 105.0 - initYPositionDrag.abs().clamp(.0, 105)
                : .0).toList()
        : Iterable<double>.generate(_internalHiddenItems.length, (index) => .0)
            .toList();
  }

  List<double> getTranslateHiddenItemListFromBottom(
      double dragContainerXPosition, double initYPositionDrag) {
    return (initYPositionDrag >= -250.0 && initYPositionDrag <= -40.0) &&
            (dragContainerXPosition >= -80.0 &&
                dragContainerXPosition <= (_widthBase - 20))
        ? Iterable<double>.generate(
            _internalHiddenItems.length,
            (index) =>
                (dragContainerXPosition - 110) + _scrollController.offset <=
                        (index * 105.0) - 21.0
                    ? 105.0 - (initYPositionDrag + 134.0).abs().clamp(.0, 105)
                    : .0).toList()
        : Iterable<double>.generate(_internalHiddenItems.length, (index) => .0)
            .toList();
  }

  List<double> getTranslateItemListFromTop(
      double dragContainerXPosition, double initYPositionDrag) {
    final navDragContainerXPosition = dragContainerXPosition + 110.0;
    if (initYPositionDrag >= 80.0 &&
        (navDragContainerXPosition >= -25.0 &&
            navDragContainerXPosition <= (_widthBase - 55))) {
      final sizeList = _internalItems.length;
      final baseDifference = ((_widthBase / sizeList) * 0.5) -
          ((_widthBase / (sizeList + 1)) * 0.5);
      return Iterable<int>.generate(_internalItems.length, (i) {
        final limitSize = ((_widthBase / (sizeList + 1)) * (i + 1)) - 42.0;
        if (navDragContainerXPosition <= limitSize) {
          final index = sizeList - 1 - i;
          return index + index + 1;
        } else {
          return -(i + (i + 1));
        }
      }).map((multiply) => baseDifference * multiply).toList();
    } else {
      return [];
    }
  }

  List<double> getTranslateItemListFromBottom(double dragContainerXPosition,
      double initXPositionDrag, double initYPositionDrag) {
    final navDragContainerXPosition = dragContainerXPosition + 110.0;
    final lengthList = _internalItems.length;
    if (initYPositionDrag >= -60.0 &&
        (navDragContainerXPosition >= -25.0 &&
            navDragContainerXPosition <= (_widthBase - 55))) {
      final indexSelected = _internalItems.indexOf(_draggedItem);
      final fractionWidth = _widthBase / lengthList;
      return Iterable<int>.generate(lengthList, (i) {
        final limitSize =
            fractionWidth * (i + (i <= indexSelected ? 1 : 0)) - 42.0;
        return (navDragContainerXPosition <= limitSize)
            ? i < indexSelected ? 2 : 0
            : i < indexSelected ? 0 : -2;
      }).map((multiply) => (fractionWidth * 0.5) * multiply).toList();
    } else {
      final baseDifference = ((_widthBase / lengthList) * 0.5) -
          ((_widthBase / (lengthList - 1)) * 0.5);
      final limitWidth = (_internalItems.indexOf(_draggedItem)) *
          (_widthBase / (lengthList - 1));
      return Iterable<int>.generate(lengthList, (i) {
        final limitSize = _widthBase / (lengthList + 1) * (i + 1);
        if (limitWidth <= limitSize) {
          final index = lengthList - 1 - i;
          return index + index + 1;
        } else {
          return -(i + (i + 1));
        }
      }).map((multiply) => baseDifference * multiply).toList();
    }
  }

  double _positionXNavigator(double translateX) =>
      translateX - _differenceWidthContainer();

  double _differenceWidthContainer() {
    final withNavigator = MediaQuery.of(context).size.width;
    return (_widthBase != withNavigator)
        ? ((withNavigator - _widthBase) / 2)
        : .0;
  }

  @override
  void dispose() {
    _dragItemUpdateStream.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _widthBase = widget.width ?? MediaQuery.of(context).size.width;
    _positionIndicatorDot =
        positionItem(_widthBase, widget.keyItemSelected, _draggedItem?.keyItem);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _buildSettingContainer(),
        Container(
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            onHorizontalDragStart: _settingVisible
                ? null
                : (dragStart) {
                    _activeLimitScroll = _buttonSettingVisible ||
                        (dragStart.localPosition.dx -
                                _differenceWidthContainer()) >=
                            (_widthBase * 0.75);
                  },
            onHorizontalDragEnd: _settingVisible
                ? null
                : (dragEnd) {
                    setState(() {
                      if (_isRightDirection && _navContainerTranslate > -50.0) {
                        _buttonSettingVisible = false;
                        _navContainerTranslate = .0;
                      } else if (!_isRightDirection &&
                          _navContainerTranslate < -50.0) {
                        _buttonSettingVisible = true;
                        _navContainerTranslate = -110.0;
                      } else {
                        _navContainerTranslate = _isRightDirection ? -110 : .0;
                        _buttonSettingVisible = _isRightDirection;
                      }
                    });
                  },
            onHorizontalDragUpdate: _settingVisible
                ? null
                : (dragUpdate) {
                    _isRightDirection = dragUpdate.delta.dx > 0;
                    if (!_settingVisible &&
                        (_activeLimitScroll || _isRightDirection) &&
                        _navContainerTranslate <= .0 &&
                        _navContainerTranslate >= -110.0) {
                      setState(() {
                        final result =
                            _navContainerTranslate + (dragUpdate.delta.dx / 1);
                        _navContainerTranslate =
                            result > 0 ? .0 : result < -110.0 ? -110 : result;
                      });
                    }
                  },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                Positioned(
                    right: (MediaQuery.of(context).size.width / 2) -
                        (_widthBase * 0.5),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                      width: _widthBase - _navContainerTranslate,
                      height: widget.height,
                      decoration: BoxDecoration(
                          borderRadius: widget.borderRadius,
                          boxShadow: widget.boxShadow),
                      child: _buildNavigator(),
                    )),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.topLeft,
          child: _buildItemDragged(),
        )
      ],
    );
  }

  Widget _buildNavigator() {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        children: <Widget>[
          Positioned(right: 0, child: _buildButtonSetting()),
          _buildNavOptionsMenu()
        ],
      ),
    );
  }

  Widget _buildNavOptionsMenu() {
    return Container(
      width: _widthBase,
      height: widget.height,
      decoration: BoxDecoration(
          color: widget.navigatorBackground,
          borderRadius: widget.borderRadius,
          boxShadow: widget.boxShadow),
      child: Container(
        padding: const EdgeInsets.only(bottom: 35.0, top: 30.0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _buildNavigationItemList(_internalItems)),
            AnimatedPositioned(
                child: Opacity(
                    opacity: _visiblePointNavigator ? 1.0 : .0,
                    child: Container(
                      transform: Matrix4.translationValues(.0, 25.0, .0),
                      child: CircleAvatar(
                          radius: 2.5, backgroundColor: widget.dotColor),
                    )),
                duration: Duration(milliseconds: _settingVisible ? 200 : 400),
                curve: Curves.ease,
                left: _positionIndicatorDot,
                top: 0,
                bottom: 0),
          ],
        ),
      ),
    );
  }

  bool get _visiblePointNavigator {
    return widget.keyItemSelected != _draggedItem?.keyItem &&
        _internalItems.indexWhere((navigationItem) =>
                navigationItem.keyItem == widget.keyItemSelected) !=
            -1;
  }

  Widget _buildButtonSetting() {
    return Container(
      height: widget.height,
      width: 220.0,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 35.0, bottom: 15.0),
      decoration: BoxDecoration(
        color: widget.settingBackground,
        borderRadius: widget.borderRadius,
      ),
      transform: Matrix4.translationValues(-.5, .5, .0),
      child: _ButtonScale(
        onTap: () => setState(() {
          if (!_settingVisible) _scrollController.jumpTo(.0);
          _settingVisible = !_settingVisible;
        }),
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(widget.iconSetting,
              size: 30.0, color: widget.iconSettingColor),
        ),
      ),
    );
  }

  Widget _buildSettingContainer() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.ease,
      width: _widthBase,
      height: widget.height + 275.0,
      transform: Matrix4.translationValues(
          .0, _settingVisible ? .0 : 275.0 + widget.height, .0),
      decoration: BoxDecoration(
          color: widget.settingBackground,
          borderRadius: widget.borderRadius,
          boxShadow: widget.boxShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 50.0, left: 35.0, right: 35.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.settingTitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: widget.settingTitleColor, fontSize: 35.0),
                      ),
                      Text(widget.settingSubTitleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: widget.settingSubTitleColor,
                              fontSize: 22.0)),
                    ],
                  ),
                ),
                _ButtonScale(
                    onTap: () => setState(() => _settingVisible = false),
                    color: widget.buttonDoneColor,
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 130.0),
                      padding: EdgeInsets.all(20.0),
                      child: Text(widget.doneText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: widget.textDoneColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700)),
                    ))
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: _draggedItem != null
                  ? const NeverScrollableScrollPhysics()
                  : null,
              padding: EdgeInsets.only(
                  bottom: 110.0,
                  left: 35.0,
                  right: _draggedItem != null ? 120.0 : 15.0),
              child: Row(children: _buildHiddenItemList(_internalHiddenItems)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItemDragged() {
    return Visibility(
        visible: _positionDrag != Offset.zero,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(
                _positionDrag.dx, _positionDrag.dy, .0),
            child: _HiddenMenuOption(
                iconData: _draggedItem?.icon,
                name: _draggedItem?.name,
                backgroundColor: widget.hiddenItemBackground,
                colorIcon: widget.iconHiddenColor,
                colorText: widget.textHiddenColor)));
  }

  List<_DraggedMenuOption> _buildNavigationItemList(
      List<BottomPersonalizedDotBarItem> bottomPersonalizedDotBarItemList) {
    List<_DraggedMenuOption> childrenList = List<_DraggedMenuOption>();
    bottomPersonalizedDotBarItemList.asMap().forEach((index, item) {
      childrenList.add(_DraggedMenuOption(
        iconData: item.icon,
        colorIcon: (item.keyItem == widget.keyItemSelected)
            ? widget.selectedColorIcon
            : widget.unSelectedColorIcon,
        onTap: () => item?.onTap(item.keyItem),
        translate:
            _translateItemList.isNotEmpty ? _translateItemList[index] : .0,
        statusDragged: _draggedItem == null
            ? _StatusDragged.NONE
            : item.keyItem == _draggedItem.keyItem
                ? _StatusDragged.DRAGGED
                : _StatusDragged.UN_DRAGGED,
        bottomItem: item,
        dragItemUpdateStream: _dragItemUpdateStream,
        settingVisible: _settingVisible,
        animationItemNavigator: _animationItemNavigator,
      ));
    });
    return childrenList;
  }

  List<_DraggedHiddenMenuOption> _buildHiddenItemList(
      List<BottomPersonalizedDotBarItem> bottomPersonalizedDotBarItemList) {
    List<_DraggedHiddenMenuOption> children = List<_DraggedHiddenMenuOption>();
    bottomPersonalizedDotBarItemList.asMap().forEach((index, item) {
      children.add(_DraggedHiddenMenuOption(
          bottomItem: item,
          iconData: item.icon,
          name: item.name,
          dragItemUpdateStream: _dragItemUpdateStream,
          statusDragged: _draggedItem == null
              ? _StatusDragged.NONE
              : item.keyItem == _draggedItem.keyItem
                  ? _StatusDragged.DRAGGED
                  : _StatusDragged.UN_DRAGGED,
          translateData: _translateHiddenItemList.isNotEmpty
              ? _translateHiddenItemList[index]
              : .0,
          blockAnimationHiddenMenuOption: _blockAnimationHiddenMenuOption,
          backgroundColor: widget.hiddenItemBackground,
          colorIcon: widget.iconHiddenColor,
          colorText: widget.textHiddenColor));
    });
    return children;
  }

  double positionItem(
      double width, String keyItemSelected, String keyItemDragged) {
    final indexItemSelected = _internalItems.indexWhere(
        (navigationItem) => navigationItem.keyItem == keyItemSelected);
    if (indexItemSelected != -1) {
      final translate = (keyItemSelected != keyItemDragged)
          ? (_translateItemList.isNotEmpty
              ? _translateItemList[indexItemSelected]
              : .0)
          : .0;
      final numPositionBase = width / _internalItems.length;
      final numDifferenceBase = (numPositionBase - (numPositionBase / 2) + 2.3);
      return (numPositionBase * (indexItemSelected + 1) -
          numDifferenceBase +
          translate);
    } else {
      return .0;
    }
  }
}

class _DraggedMenuOption extends StatefulWidget {
  final IconData iconData;
  final Color colorIcon;
  final GestureTapCallback onTap;
  final double translate;
  final _StatusDragged statusDragged;
  final BottomPersonalizedDotBarItem bottomItem;
  final StreamController<_DragItemUpdate> dragItemUpdateStream;
  final bool settingVisible;
  final bool animationItemNavigator;

  const _DraggedMenuOption(
      {Key key,
      this.iconData,
      this.colorIcon,
      this.onTap,
      this.translate,
      @required this.statusDragged,
      @required this.bottomItem,
      @required this.dragItemUpdateStream,
      @required this.settingVisible,
      @required this.animationItemNavigator})
      : super(key: key);

  @override
  _DraggedMenuOptionState createState() => _DraggedMenuOptionState();
}

class _DraggedMenuOptionState extends State<_DraggedMenuOption> {
  GlobalKey _keyItem = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final activeDrag = widget.statusDragged != _StatusDragged.UN_DRAGGED &&
        widget.settingVisible;
    return GestureDetector(
      key: _keyItem,
      onPanStart: activeDrag
          ? (details) {
              final RenderBox renderBox =
                  _keyItem.currentContext.findRenderObject();
              final position = renderBox.localToGlobal(Offset.zero);
              widget.dragItemUpdateStream.add(_DragItemUpdate(
                  widget.bottomItem,
                  Offset(position.dx - 27, position.dy - 16),
                  _EventDragEnum.START,
                  _TypeMenuOption.NAVIGATION));
            }
          : null,
      onPanUpdate: activeDrag
          ? (details) {
              widget.dragItemUpdateStream.add(_DragItemUpdate(
                  widget.bottomItem,
                  details.delta,
                  _EventDragEnum.UPDATE,
                  _TypeMenuOption.NAVIGATION));
            }
          : null,
      onPanEnd: activeDrag
          ? (details) {
              widget.dragItemUpdateStream.add(_DragItemUpdate(widget.bottomItem,
                  null, _EventDragEnum.END, _TypeMenuOption.NAVIGATION));
            }
          : null,
      child: widget.statusDragged != _StatusDragged.DRAGGED
          ? (widget.animationItemNavigator
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.ease,
                  transform:
                      Matrix4.translationValues(widget.translate, .0, .0),
                  child: _MenuOption(widget.iconData, widget.colorIcon,
                      widget.onTap, !widget.settingVisible),
                )
              : Container(
                  transform:
                      Matrix4.translationValues(widget.translate, .0, .0),
                  child: _MenuOption(widget.iconData, widget.colorIcon,
                      widget.onTap, !widget.settingVisible),
                ))
          : Container(
              width: 30.0,
            ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData _iconData;
  final Color _colorIcon;
  final GestureTapCallback _onTap;
  final bool _enable;

  const _MenuOption(this._iconData, this._colorIcon, this._onTap, this._enable);

  @override
  Widget build(BuildContext context) {
    return _ButtonScale(
        activeOpacity: true,
        onTap: _enable
            ? () {
                _onTap();
              }
            : null,
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Icon(_iconData, color: _colorIcon, size: 30.0),
        ));
  }
}

class _DraggedHiddenMenuOption extends StatefulWidget {
  final IconData iconData;
  final String name;
  final StreamController<_DragItemUpdate> dragItemUpdateStream;
  final BottomPersonalizedDotBarItem bottomItem;
  final _StatusDragged statusDragged;
  final double translateData;
  final bool blockAnimationHiddenMenuOption;
  final Color backgroundColor;
  final Color colorIcon;
  final Color colorText;

  const _DraggedHiddenMenuOption(
      {Key key,
      this.iconData,
      @required this.dragItemUpdateStream,
      this.name,
      this.bottomItem,
      @required this.statusDragged,
      @required this.translateData,
      @required this.blockAnimationHiddenMenuOption,
      @required this.backgroundColor,
      @required this.colorIcon,
      @required this.colorText})
      : super(key: key);

  @override
  _DraggedHiddenMenuOptionState createState() =>
      _DraggedHiddenMenuOptionState();
}

class _DraggedHiddenMenuOptionState extends State<_DraggedHiddenMenuOption> {
  GlobalKey _keyItem = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: _keyItem,
        onPanStart: (widget.statusDragged != _StatusDragged.UN_DRAGGED)
            ? (details) {
                final RenderBox renderBox =
                    _keyItem.currentContext.findRenderObject();
                final position = renderBox.localToGlobal(Offset.zero);
                widget.dragItemUpdateStream.add(_DragItemUpdate(
                    widget.bottomItem,
                    position,
                    _EventDragEnum.START,
                    _TypeMenuOption.HIDDEN));
              }
            : null,
        onPanUpdate: (widget.statusDragged != _StatusDragged.UN_DRAGGED)
            ? (details) {
                widget.dragItemUpdateStream.add(_DragItemUpdate(
                    widget.bottomItem,
                    details.delta,
                    _EventDragEnum.UPDATE,
                    _TypeMenuOption.HIDDEN));
              }
            : null,
        onPanEnd: (widget.statusDragged != _StatusDragged.UN_DRAGGED)
            ? (details) {
                widget.dragItemUpdateStream.add(_DragItemUpdate(
                    widget.bottomItem,
                    null,
                    _EventDragEnum.END,
                    _TypeMenuOption.HIDDEN));
              }
            : null,
        child: widget.statusDragged != _StatusDragged.DRAGGED
            ? (widget.blockAnimationHiddenMenuOption
                ? Transform(
                    transform: Matrix4.translationValues(
                        widget.statusDragged == _StatusDragged.DRAGGED
                            ? .0
                            : widget.translateData,
                        .0,
                        .0),
                    child: _HiddenMenuOption(
                        iconData: widget.iconData,
                        name: widget.name,
                        backgroundColor: widget.backgroundColor,
                        colorIcon: widget.colorIcon,
                        colorText: widget.colorText))
                : AnimatedContainer(
                    curve: Curves.ease,
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(
                        widget.statusDragged == _StatusDragged.DRAGGED
                            ? .0
                            : widget.translateData,
                        .0,
                        .0),
                    child: _HiddenMenuOption(
                        iconData: widget.iconData,
                        name: widget.name,
                        backgroundColor: widget.backgroundColor,
                        colorIcon: widget.colorIcon,
                        colorText: widget.colorText)))
            : Container());
  }
}

class _HiddenMenuOption extends StatelessWidget {
  final IconData iconData;
  final String name;
  final Color backgroundColor;
  final Color colorIcon;
  final Color colorText;

  const _HiddenMenuOption(
      {Key key,
      @required this.iconData,
      @required this.name,
      @required this.backgroundColor,
      @required this.colorIcon,
      @required this.colorText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.0,
      height: 85.0,
      margin: EdgeInsets.only(right: 20.0),
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(20.0)),
      child: DottedBorder(
        color: const Color(0x44000000),
        radius: Radius.circular(20.0),
        strokeWidth: 1,
        dashPattern: [3, 2],
        borderType: BorderType.RRect,
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, size: 30.0, color: colorIcon),
              SizedBox(height: 5.0),
              Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: colorText,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700))
            ],
          ),
        ),
      ),
    );
  }
}

/// [BottomPersonalizedDotBarItem] Represents an item, it can be hidden or in the navigation bar
class BottomPersonalizedDotBarItem {
  /// Unique key
  final String keyItem;

  /// Item icon
  final IconData icon;

  /// Item name
  final Function(String) onTap;

  /// Event with you press the item.
  final String name;

  /// Constructor
  const BottomPersonalizedDotBarItem(this.keyItem,
      {this.name, this.icon, this.onTap});
}

class _DragItemUpdate {
  final BottomPersonalizedDotBarItem item;
  final Offset position;
  final _EventDragEnum eventDragEnum;
  final _TypeMenuOption typeMenuOption;

  _DragItemUpdate(
      this.item, this.position, this.eventDragEnum, this.typeMenuOption);
}

class _ButtonScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final Color color;
  final double minScale;
  final bool activeOpacity;

  const _ButtonScale(
      {Key key,
      @required this.onTap,
      this.child,
      this.borderRadius,
      this.color,
      this.minScale = 0.90,
      this.activeOpacity = false})
      : super(key: key);

  @override
  _ButtonScaleState createState() => _ButtonScaleState();
}

class _ButtonScaleState extends State<_ButtonScale>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _scaleAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _scaleAnimation =
        Tween(begin: 1.0, end: widget.minScale).animate(_animationController);
    _opacityAnimation =
        Tween(begin: 1.0, end: 0.7).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              alignment: FractionalOffset.center,
              child: widget.activeOpacity
                  ? Opacity(
                      opacity: _opacityAnimation.value,
                      child: _buildContent(child))
                  : _buildContent(child),
            );
          },
          child: widget.child),
      onTapDown: (_) {
        _animationController.forward();
      },
      onTapUp: (_) {
        _animationController.reverse();
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      onTap: widget.onTap,
    );
  }

  Widget _buildContent(Widget child) {
    return Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: widget.borderRadius,
        ),
        child: child);
  }
}

enum _EventDragEnum { START, UPDATE, END }
enum _StatusDragged { DRAGGED, UN_DRAGGED, NONE }
enum _TypeMenuOption { NAVIGATION, HIDDEN }
