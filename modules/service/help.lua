jester.help_map.service = {}
jester.help_map.service.description_short = [[Access external services.]]
jester.help_map.service.description_long = [[This module provides actions for accessing external services, such as webservices.]]

jester.help_map.service.actions = {}

jester.help_map.service.actions.http_request = {}
jester.help_map.service.actions.http_request.description_short = [[Make an HTTP request to a external server.]]
jester.help_map.service.actions.http_request.description_long = [[Make an HTTP request to an external server.

Only the http:// protocol is supported.  The resulting status of the request is stored in the 'last_http_request' storage area, with the following keys:

  code:
    An HTTP/1.1 return code, or 'error' if the request fails.
  description:
    A human-readable description of the code.

If the request returns a '200' code, then the body of the response will be stored according to the parameter settings.]]
jester.help_map.service.actions.http_request.params = {
  server = [[(Optional) The server to send the request to, eg. 'www.example.com'. Default is 'localhost'.]],
  port = [[(Optional) The port to send the request to.  Default is 80.]],
  path = [[(Optional) The server path to send the request to, no leading or trailing slash, eg. 'path/to/resource'.]],
  query = [[(Optional) A table of query parameters to append to the URL.  Keys must be only numbers, letters, and underscores, values can be any string and will be properly URL escaped before sending, eg. '{foo = "bar", baz = "two words"}'.]],
  fragment = [[(Optional) A fragment to append to the URL.  It will be properly escaped before sending.]],
  user = [[(Optional) A user name to use for basic authentication.]],
  password = [[(Optional) A password to use for basic authentication.  'user' parameter must also be provided.]],
  response = [[(Optional) The format to expect the response in:
  lua:
    A string that represents a Lua table, of the following format:
      return {
        foo = 'bar',
      }
      The table data will be loaded into the specified storage area. Table values cannot contain a table.
  raw:
    A string of raw data.  This will be stored in the specified storage area under the 'raw' storage key.
Default is 'raw'.]],
  storage_area = [[(Optional) The storage area to store the response in.  Defaults to 'service'.]],
}

