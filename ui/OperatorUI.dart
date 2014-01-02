part of crowdy;

class BaseOperatorUI {

  svg.GElement group;
  svg.RectElement body;
  String id;
  bool dragging;
  num x, y, dragOffsetX, dragOffsetY, width, height;

  BaseOperatorUI(String this.id, num mouseX, num mouseY, num this.width, num this.height) {
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

    html.window.onKeyDown.listen(_onKeyDown);
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

    var mouseCoordinates = this.getMouseCoordinates(e);
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
      var mouseCoordinates = this.getMouseCoordinates(e);
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
    if (selectedOperator == this && e.keyCode == 8 && html.document.querySelector('.modal.fade.in') == null) {
      e.preventDefault();
      //canvas.dispatchEvent(new html.CustomEvent(STREAM_LINE_REMOVE, detail: [this.group.attributes['id'], 'ALL']));
      this.group.dispatchEvent(new html.CustomEvent(STREAM_UNIT_REMOVED));
      canvas.children.remove(this.group);
    }
  }

  dynamic getMouseCoordinates(e) {
    return {'x': (e.offset.x - canvas.currentTranslate.x)/canvas.currentScale,
            'y': (e.offset.y - canvas.currentTranslate.y)/canvas.currentScale};
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

class SourceOperatorUI extends BaseOperatorUI {

  PortUI port;

  SourceOperatorUI(svg.SvgSvgElement canvas, String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.port = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: false);
    this.addBackgroundImage(OPERATOR_ICON_INPUT);
  }
}

class SinkOperatorUI extends BaseOperatorUI {

  PortUI port;

  SinkOperatorUI(svg.SvgSvgElement canvas, String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.port = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: true);
    this.addBackgroundImage(OPERATOR_ICON_OUTPUT);
  }
}

class ProcessingOperatorUI extends BaseOperatorUI {

  PortUI inputPort;
  PortUI outputPort;

  ProcessingOperatorUI(svg.SvgSvgElement canvas, String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.inputPort = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: true);
    this.outputPort = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: false);
    this.addBackgroundImage(OPERATOR_ICON_PROCESSING);
  }
}

class SelectionOperatorUI extends BaseOperatorUI {

  PortUI inputPort;
  PortUI outputPort;

  SelectionOperatorUI(svg.SvgSvgElement canvas, String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.inputPort = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: true);
    this.outputPort = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: false);
    this.addBackgroundImage(OPERATOR_ICON_SELECTION);
  }
}

class SplitOperatorUI extends BaseOperatorUI {

  PortUI inputPort;
  PortUI outputPort;

  SplitOperatorUI(svg.SvgSvgElement canvas, String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.inputPort = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: true);
    this.outputPort = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: false);
    this.addBackgroundImage(OPERATOR_ICON_SPLIT);
  }
}

class SortOperatorUI extends BaseOperatorUI {

  PortUI inputPort;
  PortUI outputPort;

  SortOperatorUI(svg.SvgSvgElement canvas, String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.inputPort = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: true);
    this.outputPort = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: false);
    this.addBackgroundImage(OPERATOR_ICON_SORT);
  }
}

class EnrichOperatorUI extends BaseOperatorUI {

  PortUI inputPort;
  PortUI outputPort;

  EnrichOperatorUI(svg.SvgSvgElement canvas, String id, num x, num y, num width, num height) : super(id, x, y, width, height) {
    this.inputPort = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: true);
    this.outputPort = new PortUI(this.group, x, y, width, height, PORT_SIZE, input: false);
    this.addBackgroundImage(OPERATOR_ICON_ENRICH);
  }
}