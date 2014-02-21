part of crowdy;

class Application {

  final Logger log = new Logger('Application');

  Application(String canvas_id) {
    canvas = html.document.querySelector(canvas_id);

    tempLine = new svg.LineElement()
    ..attributes['stroke'] = '#ddd'
    ..attributes['strokeLength'] = '1';
    canvas.append(tempLine);

    operators = new Map<String, Operator>();

    canvas.onClick.listen(deselect);
    canvas.on[STREAM_LINE_DRAW].listen(drawLine);
    canvas.onDragOver.listen(_onDragOver);
    canvas.onDrop.listen(_onDrop);

    // Add new operator
    // Dragging and dropping operators
    var units = html.document.querySelectorAll('ul.units li');
    units.onDragStart.listen(_onDragStart);
    units.onDragEnd.listen(_onDragEnd);

    // Refresh down stream when output specification changes
    closeButton.onClick.listen(_modalClosed);
    modalAlert.querySelector('.close').onClick.listen((e) => modalAlert.style.display = 'none');
  }

  void _modalClosed(html.MouseEvent e) {
    modalBody.children.clear();
    modalAlert.style.display = 'none';
    modal.style.display = 'none';
    canvas.dispatchEvent(new html.CustomEvent(OPERATOR_OUTPUT_REFRESH, detail: currentOperatorId));
  }

  void deselect(html.MouseEvent e) {
    if (e.target is svg.SvgSvgElement && selectedOperator != null) {
      selectedOperator.group.setAttribute('class', '');
      selectedOperator = null;
    }
  }

  void drawLine(html.CustomEvent e) {
    String fromId = e.detail[0].group.attributes['id'];
    String toId = e.detail[1].group.attributes['id'];

    if (operators[fromId].canConnectTo(toId) && operators[toId].canConnectFrom(fromId)) {
      operators[fromId].connectTo(toId);
      operators[toId].connectFrom(fromId);
      FlowLineUI newLine = new FlowLineUI(e.detail[0], e.detail[1]);
    }
  }

  void _onDragStart(html.MouseEvent e) {
    _dragSource = e.target as html.LIElement;
    _dragSource.classes.add('moving');
    e.dataTransfer.effectAllowed = 'move';

    if (isFirefox) {
      e.dataTransfer.setData('text/plain', 'God damn Firefox!');
    }
  }

  void _onDragEnd(html.MouseEvent e) {
    _dragSource.classes.remove('moving');
  }

  void _onDragOver(html.MouseEvent e) {
    e.preventDefault();
  }

  void _onDrop(html.MouseEvent e) {
    e.preventDefault();
    html.Element dropTarget = e.target;
    if (dropTarget == canvas) {
      String operatorId = 'operator_$opNumber';
      var mouseCoordinates = getRelativeMouseCoordinates(e);
      operators[operatorId] = addOperator(operatorId, _dragSource.dataset['unit-type'], mouseCoordinates['x'], mouseCoordinates['y']);
      operators[operatorId].initialize();
      opNumber += 1;
    }
  }

  Operator addOperator(String id, String type, num x, num y) {
    Operator newOperator;
    switch(type) {
      case 'enrich':
        newOperator = new EnrichOperator(id, type, x, y);
        break;
      case 'source.file':
        newOperator = new SourceFileOperator(id, type, x, y);
        break;
      case 'source.human':
        newOperator = new SourceHumanOperator(id, type, x, y);
        break;
      case 'source.manual':
        newOperator = new SourceManualOperator(id, type, x, y);
        break;
      case 'source.rss':
        newOperator = new SourceRSSOperator(id, type, x, y);
        break;
      case 'sink.file':
        newOperator = new SinkFileOperator(id, type, x, y);
        break;
      case 'sink.email':
        newOperator = new SinkEmailOperator(id, type, x, y);
        break;
      case 'processing.human':
        newOperator = new HumanProcessingOperator(id, type, x, y);
        break;
      case 'selection':
        newOperator = new SelectionOperator(id, type, x, y);
        break;
      case 'sort':
        newOperator = new SortOperator(id, type, x, y);
        break;
      case 'split':
        newOperator = new SplitOperator(id, type, x, y);
        break;
      case 'union':
        newOperator = new UnionOperator(id, type, x, y);
        break;
      default:
        newOperator = new Operator(id, type, x, y);
        break;
    }

    return newOperator;
  }
}