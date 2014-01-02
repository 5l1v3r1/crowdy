part of crowdy;

const STATIC_IMG_FOLDER = 'static/img/';

const OPERATOR_WIDTH = 80;
const OPERATOR_HEIGHT = 60;

const OPERATOR_ICON_WIDTH = 20;
const OPERATOR_ICON_HEIGHT = 14;
const OPERATOR_ICON_ENRICH = 'enrich.png';
const OPERATOR_ICON_INPUT = 'input.png';
const OPERATOR_ICON_PROCESSING = 'processing.png';
const OPERATOR_ICON_SELECTION = 'selection.png';
const OPERATOR_ICON_SPLIT = 'split.png';
const OPERATOR_ICON_SORT = 'sort.png';
const OPERATOR_ICON_OUTPUT = 'output.png';

const OPERATOR_MODAL_ID = 'operator_modal';

const OPERATOR_OUTPUT_REFRESH = 'operator_output_refresh';
//const OPERATOR_OUTPUT_CLEAR = 'operator_output_clear';

List<String> SOURCE_OPTIONS_VALUES = ['', ' ', '\t', ',', ':'];
List<String> SOURCE_OPTIONS_NAMES = ['None', 'White space', 'Tab', 'Comma', 'Column'];

Map<String, String> SOURCE_OPTIONS_HUMAN_INPUTS = {
    'text input': 'text',
    'number input': 'number',
    'single choice': 'single',
    'multiple choice': 'multiple'
};

const STREAM_UNIT_MOVING = 'stream_unit_moving';
const STREAM_UNIT_REMOVED = 'stream_unit_removed';

const PORT_SIZE = 6;

const CSS_PORT_CLASS = 'port';
const CSS_PORT_CLASS_SELECTED = 'port selected';

const STREAM_PORT_MOVING = 'stream_port_moving';
const STREAM_PORT_REMOVED = 'stream_port_removed';

const LINE_SIZE = 4;

const STREAM_LINE_DRAW = 'stream_draw_line';
//const STREAM_LINE_REMOVE = 'stream_remove_line';

const WARNING_LINE_SAME_UNIT = 'You cannot add a flow within the same unit.';
const WARNING_LINE_DUPLICATE = 'You already have a flow line between those units.';
const WARNING_LINE_DIRECTION = 'You can only direct flow from an input port to outpot port.';
const WARNING_LINE_ALREADY_CONNECTED = 'You can connect only one flow to an operator.';
