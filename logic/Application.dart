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
    //canvas.on[STREAM_LINE_REMOVE].listen(removeLine);
    canvas.onDragOver.listen(_onDragOver);
    canvas.onDrop.listen(_onDrop);

    // Add new operator
    // Dragging and dropping operators
    var units = html.document.querySelectorAll('ul.units li');
    units.onDragStart.listen(_onDragStart);
    units.onDragEnd.listen(_onDragEnd);

    // Refresh down stream when output specification changes
    //closeButton.onClick.listen((e) => canvas.dispatchEvent(new html.CustomEvent(OPERATOR_OUTPUT_REFRESH, detail: currentOperatorId)));
    js.context['jQuery']('#$OPERATOR_MODAL_ID').on('hidden.bs.modal', js.context['dartCallback'] = (x) =>
        canvas.dispatchEvent(new html.CustomEvent(OPERATOR_OUTPUT_REFRESH, detail: currentOperatorId)));
    initialize();
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

  /*
  void removeLine(html.CustomEvent e) {
    operators[e.detail[0]].removeNext(e.detail[1]);
    operators[e.detail[1]].removePrevious(e.detail[0]);
  }*/

  void _onDragStart(html.MouseEvent e) {
    html.Element dragTarget = e.target;
    dragTarget.classes.add('moving');
    _dragSource = dragTarget;
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('unit-type', dragTarget.attributes['data-unit-type']);

    js.context['jQuery']('ul.units li').tooltip('hide');
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
    e.stopImmediatePropagation(); // .stopPropagation();
    html.Element dropTarget = e.target;
    if (_dragSource != dropTarget) {
      String operatorId = 'operator_$opNumber';
      operators['operator_$opNumber'] = new Operator(operatorId, e.dataTransfer.getData('unit-type'), e.offset.x, e.offset.y);
      opNumber += 1;
    }

  }

  void initialize() {
    js.context['jQuery']('ul.units li').tooltip();
  }
}