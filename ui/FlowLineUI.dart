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
    
    html.window.onKeyDown.listen(keyPressed);
    
    this.from.body.on[STREAM_PORT_MOVING].listen(move);
    this.to.body.on[STREAM_PORT_MOVING].listen(move);
    this.from.body.on[STREAM_PORT_REMOVED].listen(remove);
    this.to.body.on[STREAM_PORT_REMOVED].listen(remove);
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
  
  void keyPressed(html.KeyboardEvent e) {
    if (this.selected && e.keyCode == 8) {
      e.preventDefault();
      canvas.dispatchEvent(new html.CustomEvent(STREAM_LINE_REMOVE, detail: [this.from.group.attributes['id'], this.to.group.attributes['id']]));
      canvas.children.remove(this.path);
    }
  }
  
  void move(html.CustomEvent e) {
    this.path.pathSegList.clear()
    ..pathSegList.appendItem(this.path.createSvgPathSegMovetoAbs(from.point.x, from.point.y))
    ..pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs((from.point.x + to.point.x)/2, (from.point.y + to.point.y)/2))
    ..pathSegList.appendItem(this.path.createSvgPathSegLinetoAbs(to.point.x, to.point.y));
  }
  
  void remove(html.CustomEvent e) {
    canvas.children.remove(this.path);
  }
}