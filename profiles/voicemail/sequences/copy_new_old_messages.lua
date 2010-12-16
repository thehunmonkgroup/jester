return
{
  -- We already have the message data loaded, so just copy it where we need,
  -- saves another hit to the data_load action.
  {
    action = "copy_storage",
    storage_area = args(1),
    copy_to = "message",
  },
}
