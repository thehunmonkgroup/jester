--- This table represents Jester actions as extracted from Jester using ldoc.
--
-- It is a simple map of all actions, their parameters (minus the action
-- itself), and what value type the parameter accepts.
--
-- @script action_map.lua
-- @author Chad Phillips
-- @copyright 2011-2015 Chad Phillips

return {
  api_command = {
    command = "string",
    storage_key = "string",
  },
  call_sequence = {
    sequence = "string",
  },
  clear_storage = {
    data_keys = "tab",
    storage_area = "string",
  },
  conditional = {
    compare_to = "string",
    comparison = "string",
    if_false = "string",
    if_true = "string",
    value = "string",
  },
  copy_storage = {
    copy_to = "string",
    move = "bool",
    storage_area = "string",
  },
  exit_sequence = {
    sequence = "string",
  },
  load_profile = {
    profile = "string",
    sequence = "string",
  },
  none = {
  },
  set_storage = {
    data = "tab",
    storage_area = "string",
  },
  set_variable = {
    data = "tab",
  },
  wait = {
    keys = "tab",
    milliseconds = "int",
  },
  couchdb_add_attachment = {
    attachment_name = "string",
    content_type = "string",
    database = "string",
    document_id = "string",
    document_rev = "string",
    file_path = "string",
    server = "tab",
    storage_area = "string",
  },
  couchdb_create_document = {
    database = "string",
    document = "tab",
    document_id = "string",
    server = "tab",
    storage_area = "string",
  },
  couchdb_delete_attachment = {
    attachment_name = "string",
    database = "string",
    document_id = "string",
    document_rev = "string",
    server = "tab",
    storage_area = "string",
  },
  couchdb_delete_document = {
    database = "string",
    document_id = "string",
    document_rev = "string",
    server = "tab",
    storage_area = "string",
  },
  couchdb_retrieve = {
    database = "string",
    path = "string",
    query_parameters = "tab",
    server = "tab",
    storage_area = "string",
  },
  couchdb_retrieve_attachment = {
    attachment_name = "string",
    database = "string",
    document_id = "string",
    file_path = "string",
    server = "tab",
    storage_area = "string",
  },
  couchdb_retrieve_document = {
    database = "string",
    document_id = "string",
    query_parameters = "tab",
    server = "tab",
    storage_area = "string",
  },
  couchdb_update_document = {
    database = "string",
    document = "tab",
    document_id = "string",
    document_rev = "string",
    server = "tab",
    storage_area = "string",
  },
  data_delete = {
    config = "tab",
    filters = "tab",
  },
  data_load = {
    config = "tab",
    fields = "tab",
    filters = "tab",
    multiple = "bool",
    sort = "string",
    sort_order = "string",
    storage_area = "string",
  },
  data_load_count = {
    config = "tab",
    count_field = "string",
    filters = "tab",
    storage_area = "string",
    storage_key = "string",
  },
  data_query = {
    config = "tab",
    query = "string",
    return_fields = "bool",
    storage_area = "string",
    tokens = "tab",
  },
  data_update = {
    config = "tab",
    fields = "tab",
    filters = "tab",
    update_type = "string",
  },
  bridge = {
    channel = "string",
    extension = "string",
    hangup_after_bridge = "bool",
    multichannel_type = "string",
    variables = "tab",
  },
  execute = {
    application = "string",
    data = "string",
  },
  transfer = {
    context = "string",
    dialplan = "string",
    extension = "string",
  },
  email = {
    attachments = "tab",
    email_templates = "tab",
    from = "string",
    headers = "tab",
    port = "int",
    server = "string",
    template = "tab",
    to = "tab",
    tokens = "tab",
  },
  fire_event = {
    body = "string",
    event_type = "string",
    header_prefix = "string",
    headers = "tab",
    subclass = "string",
  },
  create_directory = {
    directory = "string",
  },
  delete_file = {
    file = "string",
  },
  file_exists = {
    file = "string",
    if_false = "string",
    if_true = "string",
  },
  file_size = {
    file = "string",
  },
  move_file = {
    binary = "bool",
    copy = "bool",
    destination = "string",
    source = "string",
  },
  remove_directory = {
    directory = "string",
  },
  format_date = {
    format = "string",
    storage_key = "string",
    timestamp = "int",
    timezone = "string",
  },
  format_string = {
    mask = "string",
    string = "string",
    storage_key = "string",
  },
  flush_digits = {
  },
  get_digits = {
    audio_files = "tab",
    bad_input = "string",
    digits_regex = "string",
    max_digits = "int",
    max_tries = "int",
    min_digits = "int",
    storage_key = "string",
    terminators = "string",
    timeout = "int",
  },
  hangup = {
    play = "string",
  },
  hangup_sequence = {
    sequence = "string",
  },
  log = {
    file = "string",
    level = "string",
    message = "string",
  },
  navigation_add = {
    sequence = "string",
  },
  navigation_beginning = {
  },
  navigation_clear = {
  },
  navigation_previous = {
  },
  navigation_reset = {
  },
  play = {
    file = "tab",
    keys = "tab",
    repetitions = "int",
    wait = "int",
  },
  play_keys = {
    key_announcements = "tab",
    keys = "tab",
    order = "tab",
    repetitions = "int",
    wait = "int",
  },
  play_phrase = {
    keys = "tab",
    language = "string",
    phrase = "string",
    phrase_arguments = "string",
    repetitions = "int",
    wait = "int",
  },
  play_valid_file = {
    files = "tab",
    keys = "tab",
    repetitions = "int",
    wait = "int",
  },
  record = {
    append = "bool",
    filename = "string",
    keys = "tab",
    location = "string",
    max_length = "int",
    pre_record_delay = "int",
    pre_record_sound = "string",
    silence_secs = "int",
    silence_threshold = "int",
    storage_area = "string",
  },
  record_merge = {
    base_file = "string",
    merge_file = "string",
    merge_type = "string",
  },
  http_request = {
    fragment = "string",
    password = "string",
    path = "string",
    port = "int",
    query = "tab",
    response = "string",
    server = "string",
    storage_area = "string",
    user = "string",
  },
  speech_to_text_from_file = {
    app_key = "string",
    app_secret = "string",
    filepath = "string",
    storage_area = "string",
  },
  shell_command = {
    command = "string",
    storage_area = "string",
  },
  shell_command_with_output = {
    command = "string",
    storage_area = "string",
  },
  counter = {
    compare_to = "int",
    if_equal = "string",
    if_greater = "string",
    if_less = "string",
    increment = "int",
    reset = "bool",
    storage_key = "string",
  },
}
