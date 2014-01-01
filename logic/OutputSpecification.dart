part of crowdy;

class OutputSegmentUI {

  bool removable;
  html.LIElement segment;
  html.SpanElement name;
  html.SpanElement value;
  html.ButtonElement deleteButton;

  OutputSegmentUI(String defaultName, bool this.removable, bool editable) {
    if (this.removable) {
      this.deleteButton = new html.ButtonElement()
      ..text = 'Delete'
      ..className = 'btn btn-danger'
      ..onClick.listen((e) => this._remove());
    }

    this.segment = new html.LIElement();

    this.name = new html.SpanElement()
    ..text = defaultName.isNotEmpty ? defaultName : 'segment-name'
    ..contentEditable = editable.toString()
    ..attributes['onKeyPress'] = editable ? 'return (this.innerText.length <= 32)' : 'return';

    this.value = new html.SpanElement();
    this.value.className = 'example';
  }

  html.LIElement getFormElement(String exampleValue) {
    this.segment.appendHtml('<span>"</span>');
    this.segment.append(this.name);
    this.segment.appendHtml('<span>"</span>');

    if (exampleValue.isNotEmpty) {
      this.value.text = 'e.g. ${exampleValue}';
      this.segment.append(this.value);
    }

    if (this.removable) {
      html.DivElement buttonDiv = new html.DivElement();
      buttonDiv.className = 'col-sm-2';
      buttonDiv.append(this.deleteButton);
      this.segment.append(buttonDiv);
    }

    return this.segment;
  }

  void _remove() {
    this.segment.remove();
  }
}

class OutputSpecificationUI {

  String id;
  Map<String, OutputSegmentUI> elements;
  html.HeadingElement title;
  html.DivElement view;
  html.DivElement innerView;
  html.UListElement elementList;

  OutputSpecificationUI(String this.id) {
    this.elements = new Map<String, OutputSegmentUI>();
    this.view = new html.DivElement();
    this.innerView = new html.DivElement();
    this.elementList = new html.UListElement();
    this.initialize();
  }

  void initialize() {
    this.view.id = '${this.id}-specification';
    this.view.className = 'output-specification';
    this.elementList.className = 'segment-list';

    this.title = new html.HeadingElement.h4();
    this.title.text = 'Output Specification ';
    this.title.className = 'margin-top';
    this.view.append(this.title);
    this.view.append(new html.HRElement());

    this.innerView.append(new html.ParagraphElement()..text = '{');
    this.innerView.append(this.elementList);
    this.innerView.append(new html.ParagraphElement()..text = '}');
    this.view.append(this.innerView);
  }


  void addElement(String identifier,
                  {String defaultName: '', String example: '', bool editable: true,
                    bool removable: false, Map<String, String> additional: null}) {
    OutputSegmentUI newElement = new OutputSegmentUI(defaultName, removable, editable);
    newElement.name.id = identifier;
    this.elements[identifier] = newElement;
    this.elementList.append(newElement.getFormElement(example));
  }

  void editElement(String identifier, String newText) {
    this.elements[identifier].name.text = newText;
  }

  void removeElement(String identifier) {
    this.elements[identifier]._remove();
    this.elements.remove(identifier);
  }

  void clear() {
    this.elementList.innerHtml = '';
    this.elements.clear();
  }

  html.SelectElement select(Map<String, bool> previousConnections) {
    html.SelectElement selectElement = new html.SelectElement();
    if (previousConnections.length > 0) {
      Map<String, OutputSegmentUI> segmentList = operators[previousConnections.keys.first].details.outputSpecification.outputUI.elements;
      segmentList.forEach((identifier, segment) => selectElement.append(new html.OptionElement(data: segment.name.text)));
    }
    return selectElement;
  }

  void refresh (Map<String, OutputSegmentUI> elements) { }
}

class OutputSpecification {

  String id, type;
  OutputSpecificationUI outputUI;

  OutputSpecification(String this.id, String this.type) {
  }
}

class InputHumanOutputSpecificationUI extends OutputSpecificationUI {

  InputHumanOutputSpecificationUI(String id) : super(id) {

  }
}

class InputManualOutputSpecificationUI extends OutputSpecificationUI {

  Map<String, ElementUI> details;

  InputManualOutputSpecificationUI(Map<String, ElementUI> this.details, String id) : super(id) {
    html.ButtonElement button = new html.ButtonElement();
    button.text = '(re)generate';
    button.className = 'btn btn-default btn-xs';
    button.onClick.listen(_onRefresh);
    this.title.append(button);
  }

  void _onRefresh(html.MouseEvent e) {
    String text = (this.details['input'].input as html.TextAreaElement).value;
    String delimiter = SOURCE_OPTIONS_VALUES[int.parse((this.details['delimiter'].input as html.SelectElement).value)];

    if (text.contains('\n')) {
      text = text.substring(0, text.indexOf('\n'));
    }

    this.clear();
    int length = 0;

    if (delimiter.isEmpty) {
      length = 1;
      this.addElement('output-1', example: text.trim());
      return;
    }

    List<String> delimitedString;
    if (text.isNotEmpty) {
      delimitedString = text.trim().split(delimiter);
      length = delimitedString.length;
    }

    for (int i = 0; i < length; i++) {
      this.addElement('output-$i', example: delimitedString[i]);
    }
  }
}

class SelectionOutputSpecificationUI extends OutputSpecificationUI {

  SelectionOutputSpecificationUI(String id) : super(id) {

  }

  void refresh (Map<String, OutputSegmentUI> previousElements) {
    previousElements.forEach((id, segment) => updateSegment(id, segment));
    this.elements.forEach((id, segment) => assureSegment(id, segment, previousElements));
  }

  void updateSegment(String id, OutputSegmentUI segment) {
    if (this.elements.containsKey(id)) {
      this.editElement(id, segment.name.text);
    }
    else {
      this.addElement(segment.name.id, defaultName: segment.name.text, editable: false);
    }
  }

  void assureSegment(String id, OutputSegmentUI segment, Map<String, OutputSegmentUI> previousElements) {
    if (!previousElements.containsKey(id)) {
      this.removeElement(segment.name.id);
    }
  }
}