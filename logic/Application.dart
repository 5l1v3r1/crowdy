part of crowdy;

Map<String, Operator> operators;
html.Element _dragSource;
int opNumber = 1;

class Application {

  final Logger log = new Logger('Application');

  ApplicationUI ui;

  Application(String canvas_id) {
    this.ui = new ApplicationUI(canvas_id);

    operators = new Map<String, Operator>();

    canvas.onClick.listen(deselect);
    canvas.on[STREAM_LINE_DRAW].listen(drawLine);
    canvas.onDragOver.listen(_onDragOver);
    canvas.onDragEnter.listen(_onDragOver);
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
    if (operators[toId].alreadyConnected()) {
      log.warning(WARNING_LINE_ALREADY_CONNECTED);
    }
    else if (operators[fromId].connectNext(toId)) {
      operators[toId].connectPrevious(fromId);
      FlowLineUI newLine = new FlowLineUI(e.detail[0], e.detail[1]);
    }
    else {
      log.warning(WARNING_LINE_DUPLICATE);
    }
  }

  void _onDragStart(html.MouseEvent e) {
    html.Element dragTarget = e.target;
    dragTarget.classes.add('moving');
    _dragSource = dragTarget;
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('unit-type', dragTarget.attributes['data-unit-type']);
  }

  void _onDragEnd(html.MouseEvent e) {
    html.Element dragTarget = e.target;
    dragTarget.classes.remove('moving');
  }

  void _onDragOver(html.MouseEvent e) {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  }

  void _onDrop(html.MouseEvent e) {
    //e.stopImmediatePropagation(); // .stopPropagation();
    html.Element dropTarget = e.target;
    if (_dragSource != dropTarget) {
      String operatorId = 'operator_$opNumber';
      operators['operator_$opNumber'] = addOperator(operatorId, e.dataTransfer.getData('unit-type'), e.offset.x, e.offset.y);
      operators['operator_$opNumber'].initialize();
      opNumber += 1;
    }
  }

  Operator addOperator(String id, String type, int x, int y) {
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
      case 'processing':
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
      default:
        newOperator = new Operator(id, type, x, y);
        break;
    }

    return newOperator;
  }
}