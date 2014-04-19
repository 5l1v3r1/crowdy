part of crowdy;

class Operator {

  String id, type;
  BaseOperatorBody body;
  BaseDetails uiDetails;
  Map<String, bool> next, prev;
  Map details;

  Operator(String this.id, String this.type, num mouseX, num mouseY) {
    this.next = new Map<String, bool>();
    this.prev = new Map<String, bool>();
    this.details = new Map();
    this.details['rules'] = new List<String>();
  }

  void initialize() {
    this.body.initialize();
    this.body.group.onDoubleClick.listen(_onDoubleClick);

    this.uiDetails.initialize();

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
    log.info("${previousOperatorId} connected to ${this.id}.");
  }

  Map getDetails() {
    this.details['output'] = this.uiDetails.listOutputs();
    List<String> prevOperators = new List<String>();
    List<String> nextOperators = new List<String>();
    this.prev.forEach((identifier, connected) => prevOperators.add(identifier));
    this.next.forEach((identifier, connected) => nextOperators.add(identifier));
    this.details['prev'] = prevOperators;
    this.details['next'] = nextOperators;
    return this.details;
  }

  void removeNext(String nextOperatorId) {
    this.next.remove(nextOperatorId);
  }

  void removePrevious(String previousOperatorId) {
    this.prev.remove(previousOperatorId);
    this.clearDownFlow();
    log.info("Connection from ${previousOperatorId} to ${this.id} is removed.");
  }

  void _onDoubleClick(html.MouseEvent e) {
    currentOperatorId = this.id;

    modalBody.children.add(this.uiDetails.view);
    modal.classes.add('in');
    modal.style.display = 'block';

    log.info("Operator modal for ${currentOperatorId} is opened.");
  }

  void _refresh(html.CustomEvent e) {
    String operatorId = e.detail as String;
    if (this.prev.containsKey(operatorId)) {
      this.updateDownFlow(operatorId);
    }

    if (this.id == operatorId) {
      this.uiDetails.updateOperatorDetails();
    }
  }

  void updateDetail(String identifier, html.Element input) {
    if (input is html.InputElement) {
      this.details[identifier] = input.value;
    }
    else if (input is html.TextAreaElement) {
      this.details[identifier] = input.value;
    }
    else if (input is html.SelectElement) {
      this.details[identifier] = input.value;
    }
    else if (input is html.DivElement) {
      this.details[identifier] = input.innerHtml;
    }
  }

  void cleanRules() {
    this.details['rules'].clear();
  }

  void addRule(String value) {
    (this.details['rules'] as List<String>).add(value);
  }

  bool updateDownFlow(String prevId) {
    bool updated = this.uiDetails.refresh(operators[prevId].uiDetails.output);
    if (updated && this.next.length > 0) {
      this.next.forEach((nextId, connected) => operators[nextId].type != 'union' && operators[nextId].updateDownFlow(prevId));
    }
    return true;
  }

  void clearDownFlow() {
    this.uiDetails.clear();
    this.next.forEach((nextId, connected) => operators[nextId].clearDownFlow());
  }

  void validate() {
    this.uiDetails.validate();
  }
}

class EnrichOperator extends Operator {
  EnrichOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new EnrichOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
    this.uiDetails = new EnrichDetails(this.id, this.type, this.prev, this.next);
  }
}

class SourceFileOperator extends Operator {
  SourceFileOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new SourceOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.uiDetails = new SourceFileDetails(this.id, this.type, this.prev, this.next);
  }
}

class SourceHumanOperator extends Operator {
  SourceHumanOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new SourceOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.uiDetails = new HumanDetails(this.id, this.type, this.prev, this.next);
  }
}

class SourceManualOperator extends Operator {
  SourceManualOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new SourceOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.uiDetails = new SourceManualDetails(this.id, this.type, this.prev, this.next);
  }
}

class SourceRSSOperator extends Operator {
  SourceRSSOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new SourceOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.uiDetails = new SourceRSSDetails(this.id, this.type, this.prev, this.next);
  }
}

class SinkFileOperator extends Operator {
  SinkFileOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new SinkOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.uiDetails = new SinkFileDetails(this.id, this.type, this.prev, this.next);
  }
}

class SinkEmailOperator extends Operator {
  SinkEmailOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new SinkOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.uiDetails = new SinkEmailDetails(this.id, this.type, this.prev, this.next);
  }
}

class HumanProcessingOperator extends Operator {
  HumanProcessingOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new ProcessingOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH, OPERATOR_HEIGHT);
    this.uiDetails = new HumanDetails(this.id, this.type, this.prev, this.next);
  }
}

class SelectionOperator extends Operator {
  SelectionOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new SelectionOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH/3, OPERATOR_HEIGHT);
    this.uiDetails = new SelectionDetails(this.id, this.type, this.prev, this.next);
  }
}

class SortOperator extends Operator {
  SortOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new SortOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
    this.uiDetails = new SortDetails(this.id, this.type, this.prev, this.next);
  }
}

class SplitOperator extends Operator {

  SplitOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new SplitOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
    this.uiDetails = new SplitDetails(this.id, this.type, this.prev, this.next);
  }

  void connectTo(String nextOperatorId) {
    super.connectTo(nextOperatorId);
    (this.uiDetails.output as SplitOutputSpecification).refreshOutput();
  }

  void removeNext(String nextOperatorId) {
    super.removeNext(nextOperatorId);
    (this.uiDetails.output as SplitOutputSpecification).refreshOutput();
  }
}

class UnionOperator extends Operator {

  UnionOperator(String id, String type, num mouseX, num mouseY) : super(id, type, mouseX, mouseY) {
    this.body = new UnionOperatorBody(this.id, mouseX, mouseY, OPERATOR_WIDTH/2, OPERATOR_HEIGHT);
    this.uiDetails = new UnionDetails(this.id, this.type, this.prev, this.next);
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

  bool updateDownFlow(String prevId) {
    bool isConsistent = this.isConsistent(prevId, 1);

    if (isConsistent) {
      bool updated = this.uiDetails.refresh(operators[prevId].uiDetails.output);
      if (updated && this.next.length > 0) {
        this.next.forEach((nextId, connected) => operators[nextId].updateDownFlow(prevId));
      }
    }
    else {
      log.warning(WARNING_LINE_INCONSISTENT_SPECIFICATION);
      (this.body as UnionOperatorBody).inputPort.body.dispatchEvent(new html.CustomEvent(OPERATOR_PORT_REMOVED));
      if (this.next.length > 0) {
        this.clearDownFlow();
      }
    }
    return true;
  }

  bool isConsistent(String previousOperatorId, [int updating = 0]) {
    bool isConsistent = true;
    if (this.prev.length > (0 + updating)) {
      Map<String, OutputSegment> existingOutputSpec = this.uiDetails.output.elements;
      Map<String, OutputSegment> newOutputSpec = operators[previousOperatorId].uiDetails.output.elements;
      existingOutputSpec.forEach((id, segment) => isConsistent = isConsistent && newOutputSpec.containsKey(id));
      newOutputSpec.forEach((id, segment) => isConsistent = isConsistent && existingOutputSpec.containsKey(id));
    }
    return isConsistent;
  }

  void validate() {
    super.validate();

    if (this.prev.length < 2) {
      validation.error("${this.id} of ${this.type} type has less than 2 flow coming to itself.");
    }
  }
}