part of crowdy;

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
  }

  void initialize() {
    this.ui.initialize();
    this.ui.group.onDoubleClick.listen(_onDoubleClick);

    this.details.initialize();

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

class EnrichOperator extends Operator {
  EnrichOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new EnrichOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
    this.details = new EnrichDetailsUI(this.id, this.type, this.prev, this.next);
  }
}

class SourceFileOperator extends Operator {
  SourceFileOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new SourceOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.details = new SourceFileDetailsUI(this.id, this.type, this.prev, this.next);
  }
}

class SourceHumanOperator extends Operator {
  SourceHumanOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new SourceOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.details = new SourceHumanDetailsUI(this.id, this.type, this.prev, this.next);
  }
}

class SourceManualOperator extends Operator {
  SourceManualOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new SourceOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.details = new SourceManualDetailsUI(this.id, this.type, this.prev, this.next);
  }
}

class SourceRSSOperator extends Operator {
  SourceRSSOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new SourceOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.details = new SourceRSSDetailsUI(this.id, this.type, this.prev, this.next);
  }
}

class SinkFileOperator extends Operator {
  SinkFileOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new SinkOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.details = new SinkFileDetailsUI(this.id, this.type, this.prev, this.next);
  }
}

class SinkEmailOperator extends Operator {
  SinkEmailOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new SinkOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.details = new SinkEmailDetailsUI(this.id, this.type, this.prev, this.next);
  }
}

class HumanProcessingOperator extends Operator {
  HumanProcessingOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new ProcessingOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.details = new SourceHumanDetailsUI(this.id, this.type, this.prev, this.next);
  }
}

class SelectionOperator extends Operator {
  SelectionOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new SelectionOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH/3, OPERATOR_HEIGHT);
    this.details = new SelectionDetailsUI(this.id, this.type, this.prev, this.next);
  }
}

class SortOperator extends Operator {
  SortOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new SortOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
    this.details = new SortDetailsUI(this.id, this.type, this.prev, this.next);
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