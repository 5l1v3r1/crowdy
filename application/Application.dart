part of crowdy;

svg.SvgSvgElement canvas;
svg.LineElement tempLine;

html.Element _dragSource;
int opNumber = 1;

String currentOperatorId;

Map<String, Operator> operators;

class Application extends Object {

  Application(String canvas_id) {
    // Create canvas
    canvas = html.document.querySelector(canvas_id);

    // Create temporary line for line animation while adding
    tempLine = new svg.LineElement()
    ..attributes['stroke'] = '#ddd'
    ..attributes['strokeLength'] = '1';
    canvas.append(tempLine);

    // Create operator map
    operators = new Map<String, Operator>();

    // Operator functions
    canvas.onClick.listen(_deselect);
    canvas.on[STREAM_LINE_DRAW].listen(_drawLine);
    canvas.onDragOver.listen(_onDragOver);
    canvas.onDrop.listen(_onDrop);

    // Add new operator
    // Dragging and dropping operators
    var units = html.document.querySelectorAll('ul.units li');
    units.onDragStart.listen(_onDragStart);
    units.onDragEnd.listen(_onDragEnd);

    // Handle operator removal
    canvas.on[OPERATOR_UNIT_REMOVE].listen(removeOperator);

    // Refresh down stream when output specification changes
    modal.onClick.listen(_closeModalConditional);
    closeButton.onClick.listen((e) => _closeModal());
    modalAlert.querySelector('.close').onClick.listen((e) => modalAlert.style.display = 'none');

    log.info("Application is created.");
  }

  void _deselect(html.MouseEvent e) {
    if (e.target is svg.SvgSvgElement && selectedOperator != null) {
      selectedOperator.group.setAttribute('class', '');
      selectedOperator = null;
    }
  }

  void _drawLine(html.CustomEvent e) {
    String fromId = e.detail[0].group.attributes['id'];
    String toId = e.detail[1].group.attributes['id'];

    if (operators[fromId].canConnectTo(toId) && operators[toId].canConnectFrom(fromId)) {
      operators[fromId].connectTo(toId);
      operators[toId].connectFrom(fromId);
      FlowLine newLine = new FlowLine(e.detail[0], e.detail[1]);
    }
  }

  void _onDragStart(html.MouseEvent e) {
    _dragSource = e.target as html.LIElement;
    _dragSource.classes.add('moving');
    e.dataTransfer.effectAllowed = 'move';

    if (isFirefox || isIE) {
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
    if (dropTarget == canvas && _dragSource != null && _dragSource.classes.contains('moving')) {
      String operatorId = 'operator_${opNumber}';
      var mouseCoordinates = getRelativeMouseCoordinates(e);
      operators[operatorId] = addOperator(operatorId, _dragSource.dataset['unit-type'], mouseCoordinates['x'], mouseCoordinates['y']);
      opNumber += 1;
    }
  }

  void _closeModalConditional(html.MouseEvent e) {
    if(e.target == modal) {
      this._closeModal();
    }
  }

  void _closeModal() {
    modalBody.children.clear();
    modalAlert.style.display = 'none';
    modal.style.display = 'none';
    canvas.dispatchEvent(new html.CustomEvent(OPERATOR_OUTPUT_REFRESH, detail: currentOperatorId));

    log.info("Operator modal for ${currentOperatorId} is closed.");
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

    newOperator.initialize();

    log.info("An operator with type ${type} and id ${id} is added.");

    return newOperator;
  }

  void removeOperator(html.CustomEvent e) {
    String operatorId = e.detail;
    operators.remove(operatorId);

    log.info("${operatorId} is removed.");
  }
}