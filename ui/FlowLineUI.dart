part of crowdy;

class FlowLineUI {

  svg.PathElement path;
  PortUI from, to;
  bool selected;

  FlowLineUI(PortUI this.from, PortUI this.to) {
    this.selected = false;

    this.path = new svg.PathElement();
    this.path.pathSegList.appendItem(this.path.createSvgPathSegMovetoAbs(from.point.x, from.point.y));
    this.path.pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs((from.point.x + to.point.x)/2, (from.point.y + to.point.y)/2));
    this.path.pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs(to.point.x, to.point.y));
    this.path.setAttribute('from', '${this.from.hashCode}');
    this.path.setAttribute('to', '${this.to.hashCode}');
    this.path.setAttribute('stroke-width', '1.5');
    this.path.onMouseDown.listen(select);

    canvas.append(this.path);

    html.window.onKeyDown.listen(_keyPressed);

    this.from.body.on[OPERATOR_PORT_MOVING].listen(_move);
    this.to.body.on[OPERATOR_PORT_MOVING].listen(_move);
    this.from.body.on[OPERATOR_PORT_REMOVED].listen(_remove);
    this.to.body.on[OPERATOR_PORT_REMOVED].listen(_remove);
  }

  void select(html.MouseEvent e) {
    this.selected = !this.selected;
    if (this.selected) {
      this.path.parentNode.append(this.path);
      this.path.setAttribute('class', 'selected');
    }
    else {
      this.path.setAttribute('class', '');
    }
  }

  void remove() {
    String from = this.from.group.attributes['id'];
    String to = this.to.group.attributes['id'];
    operators[from].removeNext(to);
    operators[to].removePrevious(from);
    canvas.children.remove(this.path);
    operators[this.to.group.id].clearDownFlow();
  }

  void _keyPressed(html.KeyboardEvent e) {
    if (this.selected && e.keyCode == 8) {
      e.preventDefault();
      this.remove();
      //canvas.dispatchEvent(new html.CustomEvent(STREAM_LINE_REMOVE, detail: [this.from.group.attributes['id'], this.to.group.attributes['id']]));
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