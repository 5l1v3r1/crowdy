part of crowdy;

dynamic getMouseCoordinates(html.MouseEvent e) {
  //return [e.offset.x, e.offset.y];
  print('${e.client}');
  print('${e.offset}');
  print('${e.layer}');
  //print('${e.movement}');
  //print('${e.screen}');
  return {
    'x': (e.client.x - canvas.currentTranslate.x)/canvas.currentScale,
    'y': (e.client.y - canvas.currentTranslate.y)/canvas.currentScale
  };
}

void _editableKeyPressed(html.KeyboardEvent e, bool editable) {
  html.SpanElement target = e.target;
  if (e.keyCode == 13 || target.text.length > 32) {
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