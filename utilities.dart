part of crowdy;

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