part of crowdy;

Port selectedPort;

class Port {

  svg.GElement group;
  svg.RectElement body;
  svg.Point point;

  num size, width, height, initX, initY;
  bool input;

  Port(svg.GElement this.group, num x, num y, num this.width, num this.height, num this.size, {bool this.input : true}) {
    num xCoor = x - this.size/2 + (this.input ? (-1) * this.width/2 : this.width/2);
    num yCoor = y - this.size/2;

    this.body = new svg.RectElement()
    ..setAttribute('x', '$xCoor')
    ..setAttribute('y', '$yCoor')
    ..setAttribute('width', '$size')
    ..setAttribute('height', '$size')
    ..classes.add('port')
    ..onMouseDown.listen(_onMouseDown)
    ..onMouseEnter.listen(_onMouseEnter)
    ..onMouseUp.listen(_onMouseUpPort);

    html.document.onMouseUp.listen(_onMouseUp);
    html.document.onMouseMove.listen(_onMouseMove).cancel();

    this.point = canvas.createSvgPoint()
    ..x = xCoor + (this.input ? 0 : size)
    ..y = yCoor + size/2;

    this.initX = this.point.x;
    this.initY = this.point.y;

    this.group.append(this.body);
    this.body.parent.on[STREAM_UNIT_MOVING].listen(move);
    //this.body.parent.on[OPERATOR_UNIT_REMOVE].listen(remove);
  }

  void _onMouseDown(html.MouseEvent e) {
    e.preventDefault();

    if (selectedPort != null) {
      selectedPort.body.setAttribute('class', CSS_PORT_CLASS);
    }

    selectedPort = this;
    selectedPort.body.setAttribute('class', CSS_PORT_CLASS_SELECTED);

    tempLine.attributes['x1'] = '${selectedPort.point.x}';
    tempLine.attributes['y1'] = '${selectedPort.point.y}';
    tempLine.attributes['x2'] = '${selectedPort.point.x}';
    tempLine.attributes['y2'] = '${selectedPort.point.y}';
    html.document.onMouseMove.listen(_onMouseMove).resume();
  }

  void _onMouseEnter(html.MouseEvent e) {
    this.body.style.cursor = 'pointer';
  }

  void _onMouseMove(html.MouseEvent e) {
    if (selectedPort != null) {
      var mouseCoordinates = getMouseCoordinatesRelativeToCanvas(e);
      tempLine.attributes['x2'] = '${mouseCoordinates['x']}';
      tempLine.attributes['y2'] = '${mouseCoordinates['y']}';
    }
  }

  void _onMouseUp(html.MouseEvent e) {
    if (selectedPort != null) {
      selectedPort.body.setAttribute('class', CSS_PORT_CLASS);
      selectedPort = null;
    }
    tempLine.attributes['x1'] = '0';
    tempLine.attributes['y1'] = '0';
    tempLine.attributes['x2'] = '0';
    tempLine.attributes['y2'] = '0';
    html.document.onMouseMove.listen(_onMouseMove).cancel();
  }

  void _onMouseUpPort(html.MouseEvent e) {
    this._draw(e);
  }

  void _draw(html.MouseEvent e) {
    if (selectedPort != null && this != selectedPort) {
      if (selectedPort.group.hashCode == this.group.hashCode) {
        log.warning(WARNING_LINE_SAME_UNIT);
      }
      else if (!selectedPort.input && this.input) {
        canvas.dispatchEvent(new html.CustomEvent(STREAM_LINE_DRAW, detail: [selectedPort, this]));
      }
      else {
        log.warning(WARNING_LINE_DIRECTION);
      }

      selectedPort.body.setAttribute('class', CSS_PORT_CLASS);
      selectedPort = null;
    }
  }

  void move(html.CustomEvent e) {
    this.point.x = this.initX + e.detail[0];
    this.point.y = this.initY + e.detail[1];
    this.body.dispatchEvent(new html.CustomEvent(OPERATOR_PORT_MOVING));
  }

  void remove() {
    this.body.dispatchEvent(new html.CustomEvent(OPERATOR_PORT_REMOVED));

    if (selectedPort == this) {
      selectedPort = null;
    }
  }
}