part of crowdy;

FlowLine selectedFlow;

class FlowLine {

  svg.PathElement path;
  Port from, to;

  FlowLine(Port this.from, Port this.to) {
    this.path = new svg.PathElement();
    this.path
    ..pathSegList.appendItem(this.path.createSvgPathSegMovetoAbs(from.point.x, from.point.y))
    ..pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs((from.point.x + to.point.x)/2, (from.point.y + to.point.y)/2))
    ..pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs(to.point.x, to.point.y))
    ..setAttribute('from', '${this.from.hashCode}')
    ..setAttribute('to', '${this.to.hashCode}')
    ..setAttribute('stroke-width', '1.5')
    ..onMouseDown.listen(_onClick);

    canvas.append(this.path);

    this.from.body.on[OPERATOR_PORT_MOVING].listen(_move);
    this.to.body.on[OPERATOR_PORT_MOVING].listen(_move);
    this.from.body.on[OPERATOR_PORT_REMOVED].listen((e) => this.remove());
    this.to.body.on[OPERATOR_PORT_REMOVED].listen((e) => this.remove());
  }

  void remove() {
    String from = this.from.group.attributes['id'];
    String to = this.to.group.attributes['id'];
    operators[from].removeNext(to);
    operators[to].removePrevious(from);

    canvas.children.remove(this.path);
    operators[this.to.group.id].clearDownFlow();
  }

  void _onClick(html.MouseEvent e) {
    bool alreadySelected = this == selectedFlow;

    if (selectedFlow != null) {
      selectedFlow.path.setAttribute('class', '');
    }

    if (!alreadySelected) {
      selectedFlow = this;
      selectedFlow.path.setAttribute('class', 'selected');
    }
    else {
      selectedFlow = null;
    }
  }

  void _move(html.CustomEvent e) {
    this.path.pathSegList.clear();
    this.path.pathSegList.appendItem(this.path.createSvgPathSegMovetoAbs(from.point.x, from.point.y));
    this.path.pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs((from.point.x + to.point.x)/2, (from.point.y + to.point.y)/2));
    this.path.pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs(to.point.x, to.point.y));
  }
}