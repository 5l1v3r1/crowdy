part of crowdy;

class ElementUI {
  String id, type;
  html.LabelElement label;
  html.HtmlElement input;

  ElementUI(String this.id, String this.type, String description,
      {Map<String, String> attributes: null, List<String> options: null}) {
    this.label = new html.LabelElement()
    ..text = description
    ..htmlFor = this.id
    ..className = 'col-sm-3 control-label';

    switch (this.type) {
      case 'select':
        this.input = new html.SelectElement();
        for(int i = 0; i < options.length; i++) {
          html.OptionElement newOption = new html.OptionElement(data: options[i], value: '$i');
          this.input.append(newOption);
        }
        break;
      case 'textarea':
        this.input = new html.TextAreaElement();
        this.input.onKeyDown.listen(_tabPressed);
        break;
      default:
        this.input = new html.InputElement(type: this.type);
        break;
    }

    if (attributes != null) {
      attributes.forEach((property, value) => this.input.attributes[property] = value);
    }

    this.input.id = this.id;
    this.input.className = 'form-control';
  }

  html.DivElement getFormElement() {
    html.DivElement inputDiv = new html.DivElement();
    inputDiv.className = 'col-sm-9';
    inputDiv.append(this.input);

    html.DivElement outerDiv = new html.DivElement();
    outerDiv.className = 'row';
    outerDiv.append(this.label);
    outerDiv.append(inputDiv);
    return outerDiv;
  }

  void _tabPressed(html.KeyboardEvent e) {
    if (e.keyCode == 9) {
      e.preventDefault();

      html.TextAreaElement textArea = this.input as html.TextAreaElement;
      String currentValue = textArea.value;
      int start = textArea.selectionStart;
      int end = textArea.selectionEnd;

      textArea.value = currentValue.substring(0, start) + "\t" + currentValue.substring(end);
    }
  }

}

class BaseDetailsUI {

  final Logger log = new Logger('OperatorDetails');

  static int count = 1;

  String id, type;
  Map<String, bool> prevConn, nextConn;
  BaseSpecification output;

  Map<String, ElementUI> base;
  Map<String, ElementUI> elements;
  html.DivElement view;
  html.DivElement detailsView;
  html.DivElement parametersView;

  BaseDetailsUI(String this.id, String this.type, Map<String, bool> this.prevConn, Map<String, bool> this.nextConn) {
    this.output = new OutputSpecification(this.id);

    this.base = new Map<String, ElementUI>();
    this.elements = new Map<String, ElementUI>();

    this.detailsView = new html.DivElement()..id = '${this.id}-details'..className = 'operator-details';
    this.parametersView = new html.DivElement()..id = '${this.id}-parameters'..className = 'operator-parameters';
    this.view = new html.DivElement()..append(this.detailsView)..append(this.parametersView);
  }

  void initialize() {
    this.addTitles();
    this.addElement('id', 'text', 'ID', this.base, features: {'disabled': 'true', 'value': this.id});
    this.addElement('type', 'text', 'Type', this.base, features: {'disabled': 'true', 'value': this.type});
    this.addElement('name', 'text', 'Name', this.base);
    this.addElement('description', 'textarea', 'Description', this.base, features: {'rows': '3'});
  }

  void addElement(String identifier, String type, String description, Map<String, ElementUI> list,
                  { Map<String, String> features: null, List<String> options: null }) {
    ElementUI newElement = new ElementUI('${this.id}_${count}', type, description, options: options, attributes: features);
    list[identifier] = newElement;
    count += 1;

    if (list == this.base) {
      this.detailsView.append(newElement.getFormElement());
    }
    else {
      this.parametersView.append(newElement.getFormElement());
    }
  }

  void addTitles() {
    this.detailsView.append(new html.HeadingElement.h4()
    ..id = 'details'
    ..text = 'Details'
    ..appendHtml('<small>for bookkeeping purposes</small>'));
    this.detailsView.append(new html.HRElement());

    this.parametersView.append(new html.HeadingElement.h4()
    ..id = 'parameters'
    ..text = 'Parameters'
    ..appendHtml('<small>specific to this operator</small>'));
    this.parametersView.append(new html.HRElement());
  }

  bool refresh(OutputSpecification specification) {
    return false;
  }

  void clear() {
    this.output.clear();
  }
}

class OutputDetailsUI extends BaseDetailsUI {

  OutputDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {
    this.output = new OutputSpecification(this.id);
  }

  bool refresh(OutputSpecification specification) {
    return (this.output as OutputSpecification).refresh(specification.elements);
  }
}

class RuleDetailsUI extends OutputDetailsUI {

  html.DivElement rulesDiv;
  html.ButtonElement addRuleButton;

  RuleDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {
  }

  void initialize() {
    super.initialize();

    this.rulesDiv = new html.DivElement()
    ..className = 'rules';
    this.parametersView.append(this.rulesDiv);

    this.addRuleButton = new html.ButtonElement()
    ..className = 'btn btn-default btn-xs'
    ..text = 'add new rule'
    ..onClick.listen(_addRule);

    this.parametersView.querySelector('#parameters').append(this.addRuleButton);
  }

  void clear() {
    super.clear();
    this.rulesDiv.children.clear();
  }

  bool refresh(OutputSpecification specification) {
    bool updated = super.refresh(specification);
    if (specification.elements.length == 0) {
      this.clear();
      return true;
    }
    return updated;
  }

  void _addRule(html.MouseEvent e) { }

  void _deleteRule(html.MouseEvent e, String ruleId) {
    this.rulesDiv.querySelector('#${ruleId}').remove();
  }
}

class EnrichDetailsUI extends OutputDetailsUI {

  EnrichDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {
    this.view.append(this.output.view);
  }

  void initialize() {
    super.initialize();
    this.addElement('copy', 'number', 'Iterations', this.elements, features: {'min': '1', 'max': '5', 'value': '1'});
  }
}

class SourceFileDetailsUI extends BaseDetailsUI {

  SourceFileDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {

  }

  void initialize() {
    super.initialize();
    this.addElement('input', 'file', 'File', this.elements);
    this.addElement('delimiter', 'text', 'Delimiter', this.elements);
  }
}

class SourceHumanDetailsUI extends BaseDetailsUI {

  static int count = 1;
  html.ButtonElement addInput;
  html.SelectElement availableInputs;
  html.DivElement elementsDiv;
  html.DivElement rulesDiv;

  SourceHumanDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {
    this.output = new InputHumanOutputSpecification(this.id);
    this.view.append(this.output.view);
  }

  void initialize() {
    super.initialize();
    this.addElement('input', 'textarea', 'Instructions for human workers', this.elements, features: {'rows': '5'});
    this.addElement('question', 'text', 'Question', this.elements);
    this.configureHumanTasks();
  }

  void configureHumanTasks() {
    this.addInput = new html.ButtonElement();
    this.addInput.text = 'Add';
    this.addInput.className = 'btn btn-default btn-xs';
    this.addInput.onClick.listen(_addNewInput);

    this.availableInputs = new html.SelectElement();
    this.availableInputs.className = 'form-control input-xs';
    SOURCE_OPTIONS_HUMAN_INPUTS.forEach((name, value) => this.availableInputs.append(new html.OptionElement(data: name, value: value)));

    html.DivElement buttonDiv = new html.DivElement();
    buttonDiv.className = 'col-sm-3';
    buttonDiv.append(this.addInput);
    buttonDiv.appendText(' ');
    buttonDiv.append(this.availableInputs);

    this.elementsDiv = new html.DivElement();
    this.elementsDiv.className = 'col-sm-9';

    html.DivElement outerDiv = new html.DivElement();
    outerDiv.className = 'row';
    outerDiv.append(buttonDiv);
    outerDiv.append(this.elementsDiv);
    this.parametersView.append(outerDiv);
  }

  void _addNewInput(html.MouseEvent e) {
    html.DivElement elementRow = new html.DivElement();
    elementRow.className = 'row rule';
    elementRow.id = 'segment-${elementRow.hashCode}';

    String inputType = this.availableInputs.value;
    this.output.addElement('segment-${elementRow.hashCode}', example: '${inputType} from human workers');

    html.DivElement elementRowDefinition = new html.DivElement();
    elementRowDefinition.className = 'col-sm-2';
    elementRowDefinition.append(new html.SpanElement()..text = inputType);
    elementRow.append(elementRowDefinition);

    html.DivElement elementRowConfig = new html.DivElement();
    elementRowConfig.className = 'col-sm-9';
    elementRow.append(elementRowConfig);

    elementRow.append(new html.ButtonElement()
                        ..text = '-'
                        ..className = 'btn btn-danger btn-sm'
                        ..onClick.listen((e) => _deleteInput(e, elementRow.id)));

    switch (inputType) {
      case 'text':
        elementRowConfig.append(new html.InputElement(type: 'number')
                                  ..className = 'form-control input-xs col-xs-12'
                                  ..placeholder = 'max. character length'
                                  ..attributes['min'] = '1'
                                  ..attributes['max'] = '255');
        break;
      case 'number':
        elementRowConfig.append(new html.InputElement(type: 'number')
                                  ..placeholder = 'min. value'
                                  ..className = 'form-control input-xs');
        elementRowConfig.append(new html.InputElement(type: 'number')
                                  ..placeholder = 'max. value'
                                  ..className = 'form-control input-xs');
        break;
      case 'single':
        elementRowConfig.append(new html.TextAreaElement()
                                  ..className = 'form-control input-sm'
                                  ..placeholder = 'Enter options line by line');
        break;
      case 'multiple':
        elementRowConfig.append(new html.TextAreaElement()
                                  ..className = 'form-control input-sm'
                                  ..placeholder = 'Enter options line by line');
        break;
    }

    count += 1;
    this.elementsDiv.append(elementRow);
  }

  void _deleteInput(html.MouseEvent e, String rowId) {
    this.elementsDiv.querySelector('#${rowId}').remove();
    this.output.removeElement(rowId);
  }
}

class SourceManualDetailsUI extends BaseDetailsUI {

  SourceManualDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {
    this.output = new InputManualOutputSpecification(this.id);
    this.output.title.append(new html.ButtonElement()
    ..text = '(re)generate'
    ..className = 'btn btn-default btn-xs'
    ..onClick.listen(_onRefresh));
    this.view.append(this.output.view);
  }

  void initialize() {
    super.initialize();
    this.addElement('input', 'textarea', 'Manual entry', this.elements, features: {'rows': '5'});
    this.addElement('delimiter', 'select', 'Delimiter', this.elements, options: SOURCE_OPTIONS_NAMES);
  }

  void _onRefresh(html.MouseEvent e) {
    String text = (this.elements['input'].input as html.TextAreaElement).value;
    String delimiter = SOURCE_OPTIONS_VALUES[int.parse((this.elements['delimiter'].input as html.SelectElement).value)];

    if (text.contains('\n')) {
      text = text.substring(0, text.indexOf('\n'));
    }

    this.output.clear();
    List<String> delimitedString;
    if (text.isNotEmpty && delimiter.isNotEmpty) {
      delimitedString = text.trim().split(delimiter);
    }
    else {
      delimitedString = new List<String>();
      delimitedString.add('');
    }

    for (String segment in delimitedString) {
      html.SpanElement dumpSpan = new html.SpanElement();
      this.output.addElement('segment-${dumpSpan.hashCode}', example: segment);
      dumpSpan.remove();
    }
  }
}

class SourceRSSDetailsUI extends BaseDetailsUI {

  SourceRSSDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {

  }

  void initialize() {
    super.initialize();
    this.addElement('webpage', 'url', 'Feed URL', this.elements);
  }
}

class SinkFileDetailsUI extends BaseDetailsUI {

  SinkFileDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {

  }

  void initialize() {
    super.initialize();
    this.addElement('output', 'text', 'File name', this.elements);
  }
}

class SinkEmailDetailsUI extends BaseDetailsUI {

  SinkEmailDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {

  }

  void initialize() {
    super.initialize();
    this.addElement('email', 'email', 'email address', this.elements);
  }
}

class ProcessingDetailsUI extends OutputDetailsUI {

  ProcessingDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {
    this.view.append(this.output.view);
  }

  void initialize() {
    super.initialize();
    this.addElement('input', 'textarea', 'Instructions', this.elements, features: {'rows': '5'});
  }
}

class SelectionDetailsUI extends RuleDetailsUI {

  static int count = 1;

  SelectionDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {
    this.output = new SelectionOutputSpecification(this, this.id);
    this.view.append(this.output.view);
  }

  void initialize() {
    super.initialize();
  }

  void _addRule(html.MouseEvent e) {
    if (this.prevConn.length < 1) {
      log.warning('Please first make sure there is an input flow to this operator.');
      return;
    }

    html.DivElement parameter = new html.DivElement()
    ..className = 'row rule'
    ..id = '${this.id}-rule-${count}';

    html.DivElement conditionDiv = new html.DivElement()
    ..className = 'col-sm-3'
    ..appendText('Filter ')
    ..append(new html.SelectElement()
      ..append(new html.OptionElement(data: 'in', value: 'in'))
      ..append(new html.OptionElement(data: 'out', value: 'out')));

    html.DivElement configDiv = new html.DivElement()
    ..className = 'col-sm-9'
    ..append(this.output.select(this.prevConn))
    ..append(new html.SelectElement()
      ..append(new html.OptionElement(data: 'equals', value: 'equals'))
      ..append(new html.OptionElement(data: 'not equals', value: 'not equals'))
      ..append(new html.OptionElement(data: 'contains', value: 'contains')))
    ..append(new html.InputElement(type: 'text')..className = 'form-control input-sm')
    ..append(new html.ButtonElement()
      ..text = '-'
      ..className = 'btn btn-danger btn-sm'
      ..onClick.listen((e) => _deleteRule(e, parameter.id)));;

    count += 1;
    parameter.append(conditionDiv);
    parameter.append(configDiv);
    this.rulesDiv.append(parameter);
  }
}

class SortDetailsUI extends RuleDetailsUI {

  static int count = 1;

  SortDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {
    this.output = new SortOutputSpecification(this, this.id);
    this.view.append(this.output.view);
  }

  void initialize() {
    this.addElement('size', 'number', 'Window size', this.elements, features: {'min': '1', 'max': '100', 'value': '1'});
    super.initialize();
  }

  void _addRule(html.MouseEvent e) {
    if (this.prevConn.length < 1) {
      log.warning('Please first make sure there is an input flow to this operator.');
      return;
    }

    html.DivElement parameter = new html.DivElement()
    ..className = 'row'
    ..id = '${this.id}-rule-${count}';

    html.DivElement conditionDiv = new html.DivElement()
    ..className = 'col-sm-3'
    ..appendText('Sort using');

    html.DivElement configDiv = new html.DivElement()
    ..className = 'col-sm-9'
    ..append(this.output.select(this.prevConn))
    ..appendText('in')
    ..append(new html.SelectElement()
      ..append(new html.OptionElement(data: 'ascending', value: 'ascending'))
      ..append(new html.OptionElement(data: 'descending', value: 'descending')))
    ..appendText('order')
    ..append(new html.ButtonElement()
      ..text = '-'
      ..className = 'btn btn-danger btn-sm'
      ..onClick.listen((e) => _deleteRule(e, parameter.id)));

    count += 1;
    parameter.append(conditionDiv);
    parameter.append(configDiv);
    this.rulesDiv.append(parameter);
  }
}

class SplitDetailsUI extends RuleDetailsUI {

  static int count = 1;

  SplitDetailsUI(String id, String type, Map<String, bool> prevConn, Map<String, bool> nextConn) : super(id, type, prevConn, nextConn) {
    this.output = new SplitOutputSpecification(this, this.id);
    this.view.append(this.output.view);
  }

  html.SelectElement outputSelectElement() {
    html.SelectElement selectElement = new html.SelectElement();
    selectElement.className = 'output-flows';
    this.nextConn.forEach((identifier, connected) => selectElement.append(new html.OptionElement(data: identifier, value: identifier)));
    return selectElement;
  }

  void _addRule(html.MouseEvent e) {
    if (this.nextConn.length < 1) {
      log.warning('Please first make sure there is an output flow from this operator.');
      return;
    }

    if (this.prevConn.length < 1) {
      log.warning('Please first make sure there is an input flow to this operator.');
      return;
    }

    html.DivElement parameter = new html.DivElement()
    ..className = 'row rule'
    ..id = '${this.id}-rule-${count}';

    html.DivElement conditionDiv = new html.DivElement()
    ..className = 'col-sm-3'
    ..appendText('Send to ')
    ..append(this.outputSelectElement());

    html.DivElement configDiv = new html.DivElement()
    ..className = 'col-sm-9'
    ..appendText('when ')
    ..append(this.output.select(this.prevConn))
    ..append(new html.SelectElement()
      ..append(new html.OptionElement(data: 'equals', value: 'equals'))
      ..append(new html.OptionElement(data: 'not equals', value: 'not equals'))
      ..append(new html.OptionElement(data: 'contains', value: 'contains')))
    ..append(new html.InputElement(type: 'text')..className = 'form-control input-sm')
    ..append(new html.ButtonElement()
      ..text = '-'
      ..className = 'btn btn-danger btn-sm'
      ..onClick.listen((e) => _deleteRule(e, parameter.id)));;

    count += 1;
    parameter.append(conditionDiv);
    parameter.append(configDiv);
    this.rulesDiv.append(parameter);
  }
}