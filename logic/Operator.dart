part of crowdy;

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

  bool canConnectTo(String nextOperatorId) {
    bool canConnect = !this.next.containsKey(nextOperatorId);
    if (!canConnect) {
      log.warning(WARNING_LINE_DUPLICATE);
    }
    return canConnect;
  }

  void connectTo(String nextOperatorId) {
    this.next[nextOperatorId] = true;
  }

  bool canConnectFrom(String previousOperatorId) {
    bool canConnect = this.prev.length == 0;
    if (!canConnect) {
      log.warning(WARNING_LINE_ALREADY_CONNECTED);
    }
    return canConnect;
  }

  void connectFrom(String previousOperatorId) {
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
      this.next.forEach((nextId, connected) => operators[nextId].type != 'union' && operators[nextId].updateDownFlow(prevId));
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

  void connectTo(String nextOperatorId) {
    super.connectTo(nextOperatorId);
    (this.details.output as SplitOutputSpecification).refreshOutput();
  }

  void removeNext(String nextOperatorId) {
    super.removeNext(nextOperatorId);
    (this.details.output as SplitOutputSpecification).refreshOutput();
  }
}

class UnionOperator extends Operator {

  UnionOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.ui = new UnionOperatorUI(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
    this.details = new UnionDetailsUI(this.id, this.type, this.prev, this.next);
  }

  bool alreadyConnected() {
    return false;
  }

  bool canConnectFrom(String previousOperatorId) {
    if (this.prev.length > 0) {
      bool isConsistent = this.isConsistent(previousOperatorId);
      if (!isConsistent) {
        log.warning(WARNING_LINE_DIFFERENT_SPECIFICATION);
      }
      return isConsistent;
    }
    else {
      return true;
    }
  }

  void updateDownFlow(String prevId) {
    bool isConsistent = this.isConsistent(prevId, 1);

    if (isConsistent) {
      bool updated = this.details.refresh(operators[prevId].details.output);
      if (updated && this.next.length > 0) {
        this.next.forEach((nextId, connected) => operators[nextId].updateDownFlow(prevId));
      }
    }
    else {
      log.warning(WARNING_LINE_INCONSISTENT_SPECIFICATION);
      (this.ui as UnionOperatorUI).inputPort.body.dispatchEvent(new html.CustomEvent(OPERATOR_PORT_REMOVED));
      if (this.next.length > 0) {
        this.clearDownFlow();
      }
    }
  }

  bool isConsistent(String previousOperatorId, [int updating = 0]) {
    bool isConsistent = true;
    if (this.prev.length > (0 + updating)) {
      Map<String, OutputSegmentUI> existingOutputSpec = this.details.output.elements;
      Map<String, OutputSegmentUI> newOutputSpec = operators[previousOperatorId].details.output.elements;
      existingOutputSpec.forEach((id, segment) => isConsistent = isConsistent && newOutputSpec.containsKey(id));
      newOutputSpec.forEach((id, segment) => isConsistent = isConsistent && existingOutputSpec.containsKey(id));
    }
    return isConsistent;
  }
}