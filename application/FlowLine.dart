part of crowdy;

class FlowLine {

  svg.PathElement path;
  Port from, to;
  bool selected;

  FlowLine(Port this.from, Port this.to) {
    this.selected = false;

    this.path = new svg.PathElement();
    this.path
    ..pathSegList.appendItem(this.path.createSvgPathSegMovetoAbs(from.point.x, from.point.y))
    ..pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs((from.point.x + to.point.x)/2, (from.point.y + to.point.y)/2))
    ..pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs(to.point.x, to.point.y))
    ..setAttribute('from', '${this.from.hashCode}')
    ..setAttribute('to', '${this.to.hashCode}')
    ..setAttribute('stroke-width', '1.5')
    ..onMouseDown.listen(_select);

    canvas.append(this.path);

    html.window.onKeyDown.listen(_keyPressed);

    this.from.body.on[OPERATOR_PORT_MOVING].listen(_move);
    this.to.body.on[OPERATOR_PORT_MOVING].listen(_move);
    this.from.body.on[OPERATOR_PORT_REMOVED].listen(_remove);
    this.to.body.on[OPERATOR_PORT_REMOVED].listen(_remove);
  }

  void remove() {
    String from = this.from.group.attributes['id'];
    String to = this.to.group.attributes['id'];
    operators[from].removeNext(to);
    operators[to].removePrevious(from);

    canvas.children.remove(this.path);
    operators[this.to.group.id].clearDownFlow();
  }

  void _select(html.MouseEvent e) {
    this.selected = !this.selected;
    if (this.selected) {
      this.path.parentNode.append(this.path);
      this.path.setAttribute('class', 'selected');
    }
    else {
      this.path.setAttribute('class', '');
    }
  }

  void _keyPressed(html.KeyboardEvent e) {
    if (this.selected && e.keyCode == 8) {
      e.preventDefault();
      this.remove();
    }
  }

  void _move(html.CustomEvent e) {
    this.path.pathSegList.clear();
    this.path.pathSegList.appendItem(this.path.createSvgPathSegMovetoAbs(from.point.x, from.point.y));
    this.path.pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs((from.point.x + to.point.x)/2, (from.point.y + to.point.y)/2));
    this.path.pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs(to.point.x, to.point.y));
  }

  void _remove(html.CustomEvent e) {
    this.remove();
  }
}