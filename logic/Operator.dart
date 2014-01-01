part of crowdy;

final modal = html.document.querySelector('#$OPERATOR_MODAL_ID .modal-dialog .modal-content .modal-body');
final closeButton = html.document.querySelector('#close_operator_modal');
String currentOperatorId;

class Operator {
  String id, type;
  BaseOperatorUI ui;
  BaseDetailsUI details;
  Map<String, bool> next, prev;

  Operator(String this.id, String this.type, svg.SvgSvgElement canvas, num mouseX, num mouseY) {
    next = new Map<String, bool>();
    prev = new Map<String, bool>();

    switch(this.type) {
      case 'enrich':
        this.ui = new EnrichOperatorUI(canvas, this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
        this.details = new EnrichDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'source.file':
        this.ui = new SourceOperatorUI(canvas, this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SourceFileDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'source.human':
        this.ui = new SourceOperatorUI(canvas, this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SourceHumanDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'source.manual':
        this.ui = new SourceOperatorUI(canvas, this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SourceManualDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'source.rss':
        this.ui = new SourceOperatorUI(canvas, this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SourceRSSDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'sink.file':
        this.ui = new SinkOperatorUI(canvas, this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SinkFileDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'sink.email':
        this.ui = new SinkOperatorUI(canvas, this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SinkEmailDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'processing':
        this.ui = new ProcessingOperatorUI(canvas, this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new ProcessingDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'selection':
        this.ui = new SelectionOperatorUI(canvas, this.id, mouseX, mouseY, OPERATOR_WIDTH/3, OPERATOR_HEIGHT);
        this.details = new SelectionDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'split':
        this.ui = new SplitOperatorUI(canvas, this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
        this.details = new BaseDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'sort':
        this.ui = new SortOperatorUI(canvas, this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
        this.details = new SortDetailsUI(this.id, this.type, this.prev, this.next);
        break;
    }

    if (this.ui != null) {
      canvas.append(this.ui.group);
    }

    this.ui.group.onDoubleClick.listen(_onDoubleClick);

    // Refresh the output specification according to changes made on previous operator
    canvas.on[OPERATOR_OUTPUT_REFRESH].listen(_refresh);
  }

  bool alreadyConnected() {
    return this.prev.length > 0;
  }

  bool connectNext(String nextOperatorId) {
    if (this.next.containsKey(nextOperatorId)) {
      return false;
    }
    this.next[nextOperatorId] = true;
    return this.next[nextOperatorId];
  }

  void connectPrevious(String previousOperatorId) {
    this.prev[previousOperatorId] = true;
    canvas.dispatchEvent(new html.CustomEvent(OPERATOR_OUTPUT_REFRESH, detail: previousOperatorId));
  }

  void removeNext(String nextOperatorId) {
    this.next.remove(nextOperatorId);
  }

  void removePrevious(String previousOperatorId) {
    this.prev.remove(previousOperatorId);
    this.details.outputSpecification.outputUI.clear();
  }

  void _onDoubleClick(html.MouseEvent e) {
    currentOperatorId = this.id;

    modal.children.add(this.details.view);
    //modal.children.add(this.flow.getFlow('input'));
    //modal.children.add(this.flow.getFlow('output'));
    js.context['jQuery']('#$OPERATOR_MODAL_ID').modal('show');
    js.context['jQuery']('#$OPERATOR_MODAL_ID').on('hidden.bs.modal', js.context['dartCallback'] = (x) => modal.children.clear());
  }

  void _refresh(html.CustomEvent e) {
    String prevId = e.detail as String;
    if (this.prev.containsKey(prevId)) {
      this.details.refresh(operators[prevId].details.outputSpecification);

      if (this.next.length > 0) {
        operators[prevId].details.refresh(this.details.outputSpecification);
      }
    }
  }
}