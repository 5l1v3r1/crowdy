part of crowdy;

final html.DivElement modal = html.document.querySelector('#$OPERATOR_MODAL_ID');
final html.DivElement modalBody = html.document.querySelector('#$OPERATOR_MODAL_ID .modal-dialog .modal-content .modal-body');
final closeButton = html.document.querySelector('#$OPERATOR_MODAL_ID .modal-footer #close_operator_modal');

String currentOperatorId;

class Operator {

  final Logger log = new Logger('Operator');

  String id, type;
  BaseOperatorUI ui;
  BaseDetailsUI details;
  Map<String, bool> next, prev;

  Operator(String this.id, String this.type, num mouseX, num mouseY) {
    next = new Map<String, bool>();
    prev = new Map<String, bool>();

    switch(this.type) {
      case 'enrich':
        this.ui = new EnrichOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
        this.details = new EnrichDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'source.file':
        this.ui = new SourceOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SourceFileDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'source.human':
        this.ui = new SourceOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SourceHumanDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'source.manual':
        this.ui = new SourceOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SourceManualDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'source.rss':
        this.ui = new SourceOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SourceRSSDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'sink.file':
        this.ui = new SinkOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SinkFileDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'sink.email':
        this.ui = new SinkOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new SinkEmailDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'processing':
        this.ui = new ProcessingOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
        this.details = new ProcessingDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'selection':
        this.ui = new SelectionOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH/3, OPERATOR_HEIGHT);
        this.details = new SelectionDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'split':
        this.ui = new SplitOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
        this.details = new SplitDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      case 'sort':
        this.ui = new SortOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
        this.details = new SortDetailsUI(this.id, this.type, this.prev, this.next);
        break;
      default:
        this.ui = new BaseOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
        this.details = new BaseDetailsUI(this.id, this.type, this.prev, this.next);
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
    this.updateDownFlow(previousOperatorId);
  }

  void removeNext(String nextOperatorId) {
    this.next.remove(nextOperatorId);
  }

  void removePrevious(String previousOperatorId) {
    this.prev.remove(previousOperatorId);
    this.clearDownFlow();
  }

  void _onDoubleClick(html.MouseEvent e) {
    currentOperatorId = this.id;

    modalBody.children.add(this.details.view);
    modal.classes.add('in');
    modal.style.display = 'block';
  }

  void _refresh(html.CustomEvent e) {
    String prevId = e.detail as String;
    if (this.prev.containsKey(prevId)) {
      this.updateDownFlow(prevId);
    }
  }

  void updateDownFlow(String prevId) {
    bool updated = this.details.refresh(operators[prevId].details.output);

    if (updated && this.next.length > 0) {
      this.next.forEach((nextId, connected) => operators[nextId].updateDownFlow(prevId));
    }
  }

  void clearDownFlow() {
    this.details.clear();
    this.next.forEach((nextId, connected) => operators[nextId].clearDownFlow());
  }
}

class SplitOperator extends Operator {

  SplitOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new SplitOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
    this.details = new SplitDetailsUI(this.id, this.type, this.prev, this.next);
  }

  bool connectNext(String nextOperatorId) {
    bool result = super.connectNext(nextOperatorId);
    if (result) {
      (this.details.output as SplitOutputSpecification).refreshOutput();
    }
    return result;
  }

  void removeNext(String nextOperatorId) {
    super.removeNext(nextOperatorId);
    (this.details.output as SplitOutputSpecification).refreshOutput();
  }
}