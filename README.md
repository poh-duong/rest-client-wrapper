# Rest-Client-Wrapper

REST client wrapper around the rest-client gem: https://github.com/rest-client/rest-client

Features:

- Retries for response codes: 401 & 429; additional response codes can be added through configuration
- Authentication for: Basic, OAuth, Token; plus a Custom authenticator
- Re-authentication for: OAuth
- URI segment construction
- Pagination for: Header links and Echo

---
## Table of contents
1. [ Get Started ](#get-started)
2. [ Rest-Client ](#rest-client)
3. [ Authentication ](#authentication)
4. [ Paginator ](#paginator)
5. [ Request ](#request)
6. [ Response ](#response)
7. [ Examples ](#examples)

<a name="get-started"></a>
# Get Started

## Create a rest_client

A `rest_client` must be created to make requests (if the rest_client requires authentication, an authenticator can be set - see _Authentication_):

```ruby
require "rest_client_wrapper"

# Create a rest_client
rest_client = RestClientWrapper::RestClient.new(host: "https://www.host.com")
```

## Basic Usage: `make_request`

The `rest_client` can make HTTP requests using `make_request`:

```ruby
# Make a request
response = rest_client.make_request(http_method: :get, uri: "https://www.host.com")
```
<a name="get_started"></a>
## Basic Usage: `execute`

The `rest_client` can also make HTTP requests using `execute`, which accepts a _Request_ object. The advantage of this approach is that the URI with the _segment parameters_ is automatically built.

_Segment parameters_ can be added to an existing `request`:

```ruby
# Create an HTTP request with a segmented uri
request = Request.new(http_method: :get, uri: "/%<segment_1>s/%<segment_2>s")

# Add the segment parameter(s) to the request ('%<segment_x>s' in the uri will be replaced with the matching segment param when the request is executed)
request.segment_params = { segment_1: "user_id_0001", segment_2: "course_id_0001" }

# Execute a request
response = rest_client.execute(request: request)
```

_Segment parameters_ can be created with the `request`:

```ruby
# Segment parameters can be created with the request
request = Request.new(http_method: :post, uri: "/%<segment_1>s", segment_params: { segment_1: "user_id_0001" }, payload: { first_name: "name" }, headers: { content_type: "application/json" })

# Execute a request
response = rest_client.execute(request: request)
```
<a name="authentication"></a>
## Authentication

The `rest_client` can make authenticated HTTP requests using an `authenticator`.

### Basic

```ruby
# Add a Basic authenticator to the rest_client
rest_client.authenticator = Authenticator::Basic.new(username: "username", password: "password")

# Make a request
response = rest_client.make_request(http_method: :get, uri: "https://www.host.com/api/v1/resource")
```

### Custom

`new` accepts the following parameters:
- type
- custom_auth_param

```ruby
# Add a Custom authenticator using query_param
# The custom auth parameter will be added as a query parameter
rest_client.authenticator = Authenticator::Custom.new(type: :query_param, auth_param: { custom_auth_param: "auth_value" })

# Make a request
response = rest_client.make_request(http_method: :get, uri: "https://www.host.com/api/v1/resource")
```

```ruby
# Add a Custom authenticator using header
# The custom auth parameter will be added to the request header
rest_client.authenticator = Authenticator::Custom.new(type: :header, auth_param: { custom_auth_param: "auth_value" })

# Make a request
response = rest_client.make_request(http_method: :get, uri: "https://www.host.com/api/v1/resource")
```

### OAuth

```ruby
# Add an OAuth authenticator to the rest_client
rest_client.authenticator = Authenticator::Oauth.new(site: "https://www.host.com", token_url_path: "token_url_path", client_id: "client_id", client_secret: "secret")

# Make a request
response = rest_client.make_request(http_method: :get, uri: "/api/v1/user")
```

### Token

```ruby
# Add a Token authenticator to the rest_client
rest_client.authenticator = Authenticator::Token.new(access_token: "access_token")

# Make a request
response = rest_client.make_request(http_method: :get, uri: "/api/v1/user")
```

## Pagination

The `rest_client` can make paginated HTTP requests using a `paginator`.

### Header links

```ruby
# Add a Header links paginator to the rest_client
rest_client.paginator = Paginator::HeaderLink.new

# Make a request for paginated data
rest_client.make_request_for_pages(http_method: :get, uri: "/api/v1/user")
```

### Echo360

```ruby
# Add an Echo paginator to the rest_client
rest_client.paginator = Paginator::Echo.new

rest_client.make_request_for_pages(http_method: :get, uri: "/api/v1/user")
```

---

<a name="rest-client"></a>
# `rest_client`

`rest_client` has the following accessors:

- authenticator
- paginator

`rest_client` has the following methods:

## new

`new` accepts the following parameters:

- host
- config (optional)

`new` returns a _Client_ object.

### Configuration

_Client_ provides the following default configuration:

```ruby
config = {
  retries: {
    401 => { max_retry: 1, wait: 0 }, # Unauthorized
    429 => { max_retry: 3, wait: 3 }  # Too Many Requests
  }
}

rest_client = RestClientWrapper::RestClient.new(host: "host")
```

If the caller wishes for additional HTTP codes to be handled, they can be specified in the `config`:

```ruby
config = {
  retries: {
    431 => { max_retry: 2, wait: 1 }, # Request Header Fields Too Large
    500 => { max_retry: 2, wait: 1 }  # Internal Server Error
  }
}

rest_client = RestClientWrapper::RestClient.new(host: "host", config: config)
```

## make_request

`make_request` accepts the following parameters:

- http_method
- uri
- payload (optional)
- query_params (optional)
- headers (optional)

`make_request` returns a _Response_ object.

## make_request_for_pages

`make_request_for_pages` accepts the following parameters:

- http_method
- uri
- query_params (optional)
- headers (optional)
- data (optional)

`make_request_for_pages` returns:

- an array where each element is a _Response_ object for each page (ie header and the body), if data is false.
- an array where each element is one entity from every `response.body` for each page (ie the data), if data is true.

## execute

`execute` accepts the following parameters:

- request

`execute` returns a _Response_ object.

# `Authenticator`

`authenticator` has the following methods:

## generate_auth

`generate_auth` returns a hash that is suitable for use in a _Request_.

## `Basic`

## new

`new` accepts the following parameters:

- username
- password

`new` returns a _Basic_ (_Authenticator_) object.

## `Custom`

## new

`new` accepts the following parameters:

- type
- auth_param

`new` returns a _Custom_ (_Authenticator_) object.

## `Oauth`

## new

`new` accepts the following parameters:

- site
- token_url_path
- client_id
- client_secret

`new` returns an _Oauth_ (_Authenticator_) object.

## `Token`

## new

`new` accepts the following parameters:

- access_token

`new` returns a _Token_ (_Authenticator_) object.

## tokens

`tokens` returns all of the token(s) for the `authenticator`.

## access_token

`access_token` returns the access token for the `client_id` of the `authenticator`.

## Oauth.authenticate

`authenticate` accepts the following parameters:

- client_id
- access_token

`authenticate` authenticates the rest_client using the `client_id` and `access_token` and updates the `tokens` for the rest_client.

<a name="paginator"></a>
# `Paginator`

`paginator` has the following accessors:

- rest_client

`paginator` has the following methods:

## paginate

`paginate` accepts the following parameters:

- http_method
- uri
- payload (optional)
- headers (optional)
- data (optional)

`paginate` returns:

- an array where each element is a _Response_ object for each page (ie header and the body), if data is false.
- an array where each element is one entity from every `response.body` for each page (ie the data), if data is true.

## `HeaderLink`

`new` accepts the following parameters:

- per_page (optional)

`new` returns a _HeaderLink_ (_Paginator_) object.

## `Echo`

`new` accepts the following parameters:

- limit (optional)

`new` returns an _Echo_ (_Paginator_) object.

<a name="request"></a>
# `Request`

`request` has the following accessors:

- uri
- headers
- http_method
- payload
- query_params
- segment_params

`request` has the following methods:

## new

`new` accepts the following parameters:

- http_method
- uri
- segment_params (optional)
- payload (optional)
- query_params (optional)
- headers (optional)

`new` returns a _Request_ object.

<a name="reponse"></a>
# `Response`

_Response_ objects have the following methods:

- `code`: The HTTP response code
- `body`: The response body will be returned as a hash if the content-type of the response is a string otherwise it will return a string
- `headers`: A hash of HTTP response header objects

## Exceptions

- `RestClientError`: Exceptions that are raised by the rest-client GEM will be captured in this exception
- `RestClientNotSuccessful` : Unsuccessful requests (i.e. a `response` with a status that is not between 200 and 207)
- Get server response by calling .response on the exception

```ruby
begin
  request = Request.new(http_method: :get, uri: "https://www.host.com/public/api/v1/resource")
  response = rest_client.execute(request: request)
rescue RestClientError => e
  e.response
end
```


---

<a name="examples"></a>
# Examples

### REST API call

```ruby
host_url = "https://www.host.com"
username = "api_user_name"
password = "password"
client = Client.new(host: host_url)
client.authenticator = Authenticator::Basic.new(username: username, password: password)
client.paginator = Paginator::HeaderLink.new(per_page: 10)

response = client.make_request(http_method: :get, uri: "/api/v1/resource")

# paginated request
data = client.make_request_for_pages(http_method: :get, uri: "/api/v1/resource", data: true)

```

### Canvas

```ruby
canvas_host = "https://host.instructure.com"
canvas_access_token = "access_token"
canvas_client = Client.new(host: canvas_host)
canvas_client.authenticator = Authenticator::Token.new(access_token: canvas_access_token)
canvas_client.paginator = Paginator::HeaderLink.new(per_page: 10)

canvas_response = canvas_client.make_request(http_method: :get, uri: "/api/v1/accounts/1/terms")

# paginated request
canvas_data = canvas_client.make_request_for_pages(http_method: :get, uri: "/api/v1/accounts/1/terms", data: true)
```

### Echo

```ruby
echo_host = "https://echo360.net.au"
echo_client_id = "client_id"
echo_client_secret = "client_secret"
echo_client = Client.new(host: echo_host)
echo_client.authenticator = Authenticator::Oauth.new(site: echo_host, token_url_path: "/oauth2/access_token", client_id: echo_client_id, client_secret: echo_client_secret)
echo_client.paginator = Paginator::Echo.new(limit: 10)

echo_response = echo_client.make_request(http_method: :get, uri: "/public/api/v1/terms")
echo_data = echo_client.make_request_for_pages(http_method: :get, uri: "/public/api/v1/terms", data: true)
```

## Create a request object

Create a `rest_client`.

```ruby
rest_client = RestClientWrapper::RestClient.new(host: "https://www.host.com")
```

## Request with a segmented absolute URI

```ruby
request = Request.new(http_method: :get, uri: "https://www.host.com/public/api/v1/users/%<user_id>s")
request.segment_params = { user_id: "user_id" }
response = rest_client.execute(request: request)
```

## Request with a segmented resource path

```ruby
rest_client = RestClientWrapper::RestClient.new(host: "https://www.host.com")
request = Request.new(http_method: :get, uri: "/public/api/v1/users/%<user_id>s")
request.segment_params = { user_id: "user_id" }
response = rest_client.execute(request: request)
```

## Query Parameters

```ruby
rest_client = RestClientWrapper::RestClient.new(host: "https://www.host.com")
request = Request.new(http_method: :put, uri: "/api/v1/resource/")
request.payload = { user_id: "user_id" }
request.query_params = { id: "value" }
response = rest_client.execute(request: request)
```
