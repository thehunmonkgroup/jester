jester.help_map.record = {}
jester.help_map.record.description_short = [[Record sound from a channel.]]
jester.help_map.record.description_long = [[This module provides actions which deal with recording sound from a channel.]]

jester.help_map.record.actions = {}

jester.help_map.record.actions.record = {}
jester.help_map.record.actions.record.description_short = [[Records sound from a channel.]]
jester.help_map.record.actions.record.description_long = [[This action records sound from a channel and stores it.

The recording is in .wav format.

The following variables/values related to the recording are put into Jester storage upon completion of the recording:

  last_recording_name:  
    The name of the recording.
  last_recording_path:  
    A full path to the recording.
  last_recording_timestamp:  
    The timestamp of the recording (when it began).
  last_recording_duration:  
    The duration of the recording in seconds.
]]
jester.help_map.record.actions.record.params = {
  filename = [[(Optional) The name of the recorded file.  Defaults to %Y-%m-%d_%H:%M:%S-${uuid}.wav]],
  location = [[(Optional) Where to store the file.  Default is /tmp.]],
  append = [[(Optional) Append the recording to an existing file.  Requires that the 'name' parameter be set.  If the named file does not exist, then it will be created.  Default is false.]],
  pre_record_sound = [[(Optional) Set to a file or phrase to play prior to beginning the recording, or to 'tone' to play a typical 'wait for the beep' tone.  Default is to do nothing.]],
  pre_record_delay = [[(Optional) Set to the number of milliseconds to delay just prior to beginning the recording.  This happens after the pre_record_sound is played.  This can be useful to tweak if trailing channel sounds are being recording at the beginning of the recording.  Set to 0 for no delay.  Default is 200 milliseconds.]],
  max_length = [[(Optional) Maximum allowed length of the recording in seconds.  Default is 180.]],
  silence_threshold = [[(Optional) A number indicating the threshhold for what is considered silence.  Higher numbers mean more noise will be tolerated.  Default is 20.  TODO: need to find doc on this.]],
  silence_secs = [[(Optional) The number of consecutive seconds of silence to wait before considering the recording finished.  Default is 5.]],
  storage_area = [[(Optional) If set the 'last_recording' storage values are also stored this storage area with the 'last_recording_' prefix stripped, eg. 'storage_area = "message"' would store 'name' in the 'message' storage area with the same value as 'last_recording_name'.]],
  keys = [[(Optional) See 'help sequences keys'.]],
}

