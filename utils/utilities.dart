part of crowdy;

dynamic getMouseCoordinatesRelativeToCanvas(html.MouseEvent e) {
  return {
    'x': (e.client.x - canvas.getScreenCtm().e),
    'y': (e.client.y - canvas.getScreenCtm().f)
  };
}

dynamic getRelativeMouseCoordinates(html.MouseEvent e) {
  return {
    'x': (e.offset.x),
    'y': (e.offset.y)
  };
}

dynamic getMouseCoordinatesProportinalToCanvas(html.MouseEvent e) {
  return {
    'x': (e.client.x - canvas.currentTranslate.x)/canvas.currentScale,
    'y': (e.client.y - canvas.currentTranslate.y)/canvas.currentScale
  };
}

void _editableKeyPressed(html.KeyboardEvent e, bool editable) {
  html.SpanElement target = e.target;
  int charCode = e.charCode > 0 ? e.charCode : e.keyCode > 0 ? e.keyCode : e.which > 0 ? e.which : 0;
  bool isAlphaNumeric = charCode > 31 &&
      ((charCode >= 48 && charCode <= 57) ||
          (charCode >= 65 && charCode <= 90) ||
          (charCode >= 97 && charCode <= 122));
  bool isMinus = charCode == 45;
  if(!(isAlphaNumeric || isMinus) || target.text.length > 31) {
    e.preventDefault();
  }
}

void _tabbableTextAreaKeyPressed(html.KeyboardEvent e) {
  if (e.keyCode == 9) {
    e.preventDefault();

    html.TextAreaElement textArea = e.target as html.TextAreaElement;
    String currentValue = textArea.value;
    int start = textArea.selectionStart;
    int end = textArea.selectionEnd;

    textArea.value = currentValue.substring(0, start) + "\t" + currentValue.substring(end);
  }
}

void _triggerDetails(html.DivElement div) {
  if (div.className.contains('hide')) {
    div.className = 'inner';
  }
  else {
    div.className = 'inner hide';
  }
}

bool isFirefox = html.window.navigator.userAgent.contains("Firefox");