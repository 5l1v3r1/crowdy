part of crowdy;

BaseOperatorBody selectedOperator;

class BaseOperatorBody {

  svg.GElement group;
  svg.RectElement body;
  String id;
  bool dragging;
  num x, y, dragOffsetX, dragOffsetY, width, height;

  BaseOperatorBody(String this.id, num mouseX, num mouseY, num this.width, num this.height) {
    this.x = mouseX - this.width/2;
    this.y = mouseY - this.height/2;

    this.body = new svg.RectElement()
    ..setAttribute('x', '${this.x}')
    ..setAttribute('y', '${this.y}')
    ..setAttribute('width', '$width')
    ..setAttribute('height', '$height')
    ..classes.add('processing_body')
    ..onMouseDown.listen(_onMouseDown)
    ..onMouseEnter.listen(_onMouseEnter);

    this.group = new svg.GElement()
    ..setAttribute('id', '${id}')
    ..append(this.body);

    this.dragging = false;

    html.document.onKeyDown.listen(_onKeyDown);
  }

  void initialize() {
    canvas.append(this.group);
  }

  void _onClick(html.MouseEvent e) {
    bool alreadySelected = this == selectedOperator;

    if (selectedOperator != null) {
      selectedOperator.group.setAttribute('class', '');
    }

    if (!alreadySelected) {
      selectedOperator = this;
      selectedOperator.group.setAttribute('class', 'selected');
    }
    else {
      selectedOperator = null;
    }
  }

  void _onMouseDown(html.MouseEvent e) {
    e.preventDefault();

    this._onClick(e);

    this.dragging = true;
    this.group.parentNode.append(this.group);

    var mouseCoordinates = getMouseCoordinatesProportinalToCanvas(e);
    this.dragOffsetX = mouseCoordinates['x'] - this.group.getCtm().e;
    this.dragOffsetY = mouseCoordinates['y'] - this.group.getCtm().f;

    canvas.onMouseMove.listen(_moveStarted).resume();
    canvas.onMouseUp.listen(_moveCompleted).resume();
  }

  void _onMouseEnter(html.MouseEvent e) {
    this.body.style.cursor = 'move';
  }

  void _moveStarted(html.MouseEvent e) {
    if (this.dragging) {
      var mouseCoordinates = getMouseCoordinatesProportinalToCanvas(e);
      num newX = mouseCoordinates['x'] - this.dragOffsetX;
      num newY = mouseCoordinates['y'] - this.dragOffsetY;
      this.group.setAttribute('transform', 'translate($newX, $newY)');

      this.group.dispatchEvent(new html.CustomEvent(STREAM_UNIT_MOVING, detail: [newX, newY]));
    }
  }

  void _moveCompleted(html.MouseEvent e) {
    this.dragging = false;

    canvas.onMouseMove.listen(_moveStarted).cancel();
    canvas.onMouseUp.listen(_moveCompleted).cancel();
  }

  void _onKeyDown(html.KeyboardEvent e) {
    if (e.keyCode == 8 && modal.style.display != 'block') {
      e.preventDefault();

      if (selectedOperator == this) {
        this.remove();
      }
    }
  }

  void remove() {
    this.group.dispatchEvent(new html.CustomEvent(OPERATOR_UNIT_REMOVE));
    canvas.children.remove(this.group);
    operators[this.id].remove();
    operators.remove(this.id);
    log.info("${selectedOperator.id} is removed.");
  }

  void addBackgroundImage(String image) {
    this.group.append(new svg.ImageElement()
    ..setAttribute('x', '${this.x + this.width - OPERATOR_ICON_WIDTH - 3}')
    ..setAttribute('y', '${this.y + this.height - OPERATOR_ICON_HEIGHT - 3}')
    ..setAttribute('width', '$OPERATOR_ICON_WIDTH')
    ..setAttribute('height', '$OPERATOR_ICON_HEIGHT')
    ..setAttributeNS('http://www.w3.org/1999/xlink', 'href', '$STATIC_IMG_FOLDER$image')
    ..onMouseDown.listen(_onMouseDown));
  }
}

class SourceOperatorBody extends BaseOperatorBody {

  Port outputPort;

  SourceOperatorBody(String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.outputPort = new Port(this.group, x, y, width, height, PORT_SIZE, input: false);
    this.addBackgroundImage(OPERATOR_ICON_INPUT);
  }
}

class SinkOperatorBody extends BaseOperatorBody {

  Port inputPort;

  SinkOperatorBody(String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.inputPort = new Port(this.group, x, y, width, height, PORT_SIZE, input: true);
    this.addBackgroundImage(OPERATOR_ICON_OUTPUT);
  }
}

class ProcessingBaseOperatorBody extends BaseOperatorBody {

  Port inputPort;
  Port outputPort;

  ProcessingBaseOperatorBody(String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.inputPort = new Port(this.group, x, y, width, height, PORT_SIZE, input: true);
    this.outputPort = new Port(this.group, x, y, width, height, PORT_SIZE, input: false);
  }
}

class ProcessingOperatorBody extends ProcessingBaseOperatorBody {

  ProcessingOperatorBody(String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.addBackgroundImage(OPERATOR_ICON_PROCESSING);
  }
}

class SelectionOperatorBody extends ProcessingBaseOperatorBody {

  SelectionOperatorBody(String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.addBackgroundImage(OPERATOR_ICON_SELECTION);
  }
}

class SplitOperatorBody extends ProcessingBaseOperatorBody {

  SplitOperatorBody(String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.addBackgroundImage(OPERATOR_ICON_SPLIT);
  }
}

class UnionOperatorBody extends ProcessingBaseOperatorBody {

  UnionOperatorBody(String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.addBackgroundImage(OPERATOR_ICON_UNION);
  }
}

class SortOperatorBody extends ProcessingBaseOperatorBody {

  SortOperatorBody(String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.addBackgroundImage(OPERATOR_ICON_SORT);
  }
}

class EnrichOperatorBody extends ProcessingBaseOperatorBody {

  EnrichOperatorBody(String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.addBackgroundImage(OPERATOR_ICON_ENRICH);
  }
}