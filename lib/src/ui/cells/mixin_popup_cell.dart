import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class AbstractMixinPopupCell extends StatefulWidget {
  final PlutoGridStateManager? stateManager;
  final PlutoCell? cell;
  final PlutoColumn? column;

  AbstractMixinPopupCell({
    this.stateManager,
    this.cell,
    this.column,
  });
}

abstract class AbstractPopup {
  List<PlutoColumn>? popupColumns;

  List<PlutoRow>? popupRows;

  Icon? icon;
}

mixin MixinPopupCell<T extends AbstractMixinPopupCell> on State<T>
    implements AbstractPopup {
  TextEditingController? _textController;

  late FocusNode _keyboardFocus;

  FocusNode? _textFocus;

  bool isOpenedPopup = false;

  /// If a column field name is specified,
  /// the value of the field is returned even if another cell is selected.
  ///
  /// If the column field name is not specified,
  /// the value of the selected cell is returned.
  String? fieldOnSelected;

  double? popupHeight;

  int offsetOfScrollRowIdx = 0;

  /// Callback function that returns Header to be inserted at the top of the popup
  /// Implement a callback function that takes [PlutoGridStateManager] as a parameter.
  CreateHeaderCallBack? createHeader;

  /// Callback function that returns Footer to be inserted at the bottom of the popup
  /// Implement a callback function that takes [PlutoGridStateManager] as a parameter.
  CreateFooterCallBack? createFooter;

  @override
  void dispose() {
    widget.stateManager!.resetKeyPressed();

    _textController!.dispose();

    _keyboardFocus.dispose();

    _textFocus!.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController()
      ..text =
          widget.column!.formattedValueForDisplayInEditing(widget.cell!.value);

    _keyboardFocus = FocusNode(onKey: _handleKeyboardFocusOnKey);

    _textFocus = FocusNode();
  }

  void openPopup() {
    if (widget.column!.type!.readOnly!) {
      return;
    }

    isOpenedPopup = true;

    PlutoGridPopup(
      context: context,
      mode: PlutoGridMode.select,
      onLoaded: onLoaded,
      onSelected: onSelected,
      columns: popupColumns,
      rows: popupRows,
      width: popupColumns!.fold<double>(0, (previous, column) {
            return previous + column.width;
          }) +
          1,
      height: popupHeight,
      createHeader: createHeader,
      createFooter: createFooter,
      configuration: widget.column!.type.isSelect
          ? widget.stateManager!.configuration
          : widget.stateManager!.configuration!.copyWith(
              rowHeight: PlutoGridSettings.rowHeight,
            ),
    );
  }

  KeyEventResult _handleKeyboardFocusOnKey(
      FocusNode focusNode, RawKeyEvent event) {
    PlutoKeyManagerEvent keyManagerEvent = PlutoKeyManagerEvent(
      focusNode: focusNode,
      event: event,
    );

    if (keyManagerEvent.isKeyDownEvent) {
      if (keyManagerEvent.isF2 || keyManagerEvent.isCharacter) {
        if (isOpenedPopup != true) {
          openPopup();
          return KeyEventResult.handled;
        }
      }
    }

    return KeyEventResult.ignored;
  }

  void onLoaded(PlutoGridOnLoadedEvent event) {
    for (var i = 0; i < popupRows!.length; i += 1) {
      if (fieldOnSelected == null) {
        for (var entry in popupRows![i].cells.entries) {
          if (popupRows![i].cells[entry.key]!.value == widget.cell!.value) {
            event.stateManager!.setCurrentCell(
                event.stateManager!.refRows![i]!.cells[entry.key], i);
            break;
          }
        }
      } else {
        if (popupRows![i].cells[fieldOnSelected!]!.value ==
            widget.cell!.value) {
          event.stateManager!.setCurrentCell(
              event.stateManager!.refRows![i]!.cells[fieldOnSelected!], i);
          break;
        }
      }
    }

    if (event.stateManager!.currentRowIdx != null) {
      final rowIdxToMove =
          event.stateManager!.currentRowIdx! + 1 + offsetOfScrollRowIdx;

      if (rowIdxToMove < event.stateManager!.refRows!.length) {
        event.stateManager!
            .moveScrollByRow(PlutoMoveDirection.up, rowIdxToMove);
      } else {
        event.stateManager!.moveScrollByRow(
            PlutoMoveDirection.up, event.stateManager!.refRows!.length);
      }
    }
  }

  void onSelected(PlutoGridOnSelectedEvent event) {
    isOpenedPopup = false;

    dynamic selectedValue;

    if (event.row != null &&
        fieldOnSelected != null &&
        event.row!.cells.containsKey(fieldOnSelected)) {
      selectedValue = event.row!.cells[fieldOnSelected!]!.value;
    } else if (event.cell != null) {
      selectedValue = event.cell!.value;
    } else {
      return;
    }

    handleSelected(selectedValue);
  }

  void handleSelected(dynamic value) {
    widget.stateManager!.handleAfterSelectingRow(widget.cell!, value);

    try {
      _textController!.text = widget.column!.formattedValueForDisplayInEditing(
        widget.stateManager!.currentCell!.value,
      );
    } catch (e) {
      /**
       * When the Popup is opened, the TextField is closed
       * _textController is dispose
       * When calling _handleSelected in Popup
       * _textController error.
       *
       * TODO : Change widget structure...
       */
      PlutoLog(
        'popup_base_mixin',
        type: PlutoLogType.todo,
        error: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateManager!.keepFocus) {
      _textFocus!.requestFocus();
    }

    return RawKeyboardListener(
      focusNode: _keyboardFocus,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TextField(
            controller: _textController,
            focusNode: _textFocus,
            readOnly: true,
            textInputAction: TextInputAction.none,
            onTap: openPopup,
            style: widget.stateManager!.configuration!.cellTextStyle,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(0),
              isDense: true,
            ),
            maxLines: 1,
            textAlign: widget.column!.textAlign.value,
          ),
          Positioned(
            top: -14,
            right: widget.column!.textAlign.isLeft ? -10 : null,
            left: widget.column!.textAlign.isRight ? -10 : null,
            child: IconButton(
              icon: icon!,
              color: widget.stateManager!.configuration!.iconColor,
              iconSize: widget.stateManager!.configuration!.iconSize,
              onPressed: openPopup,
            ),
          ),
        ],
      ),
    );
  }
}
