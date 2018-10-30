defmodule Vimond.Client do
  require Logger
  alias TimeConverter
  alias Vimond.{Order, Property, Session, User}

  @unexpected_error {:error, %{type: :generic, source_errors: ["Unexpected error"]}}

  @callback add_order_signed(user_id :: String.t(), order :: Order.t()) ::
              {:ok, integer()} | {:error, :failed_to_add_order}
  def add_order_signed(user_id, order = %Order{}, http_client \\ nil) do
    url = vimond_url("order/#{user_id}/create")
    path = URI.parse(url).path

    body =
      build_order(order)
      |> Jason.encode!()

    request("add_order", fn ->
      http_client(http_client).post(url, body, headers(signed_headers("POST", path)))
    end)
    |> case do
      %HTTPotion.Response{body: body, status_code: 200} ->
        case Jason.decode(body) do
          {:ok, %{"id" => order_id}} -> {:ok, order_id}
        end

      error ->
        Logger.error("Error adding order: #{inspect(error)}")
        {:error, :failed_to_add_order}
    end
  end

  @callback authenticate(username :: String.t(), password :: String.t()) :: {:ok | :error, map}
  def authenticate(username, password, http_client \\ nil) do
    body = Jason.encode!(%{username: username, password: password, rememberMe: true})

    request("authenticate", fn ->
      http_client(http_client).post(
        vimond_url("/api/authentication/user/login"),
        body,
        headers("Content-Type": "application/json; v=2; charset=UTF-8")
      )
    end)
    |> handle_response(&extract_authenticate/2)
  end

  @callback create(user :: Vimond.User.t()) :: {:ok | :error, map}
  def create(user = %User{}, http_client \\ nil) do
    body =
      %{
        userName: user.username,
        password: user.password,
        email: user.username,
        firstName: user.first_name,
        lastName: user.last_name,
        zip: user.zip_code,
        country: user.country_code,
        dateOfBirth: TimeConverter.year_to_iso8601(user.year_of_birth),
        properties: properties_payload(user)
      }
      |> Jason.encode!()

    request("create", fn ->
      http_client(http_client).post(vimond_url("user"), body, headers())
    end)
    |> handle_response(&extract_create_user/2)
  end

  @callback delete(user_id :: String.t(), vimond_authorization_token :: String.t()) ::
              {:ok | :error, map}
  def delete(user_id, vimond_authorization_token, http_client \\ nil) do
    request("delete", fn ->
      http_client(http_client).delete(
        vimond_url("user/#{user_id}"),
        headers(Authorization: "Bearer #{vimond_authorization_token}")
      )
    end)
    |> handle_delete_response()
  end

  def delete_signed(user_id, http_client \\ nil) do
    url = vimond_url("user/#{user_id}")
    path = URI.parse(url).path

    request("delete_signed", fn ->
      http_client(http_client).delete(url, headers(signed_headers("DELETE", path)))
    end)
    |> handle_delete_response()
  end

  @callback forgot_password(email :: String.t()) :: {:ok | :error, map}
  def forgot_password(email, http_client \\ nil) do
    request("forgot_password", fn ->
      http_client(http_client).delete(vimond_url("user/#{email}/password"), headers())
    end)
    |> handle_forgot_password_response
  end

  @callback logout(vimond_authorization_token :: String.t(), remember_me :: String.t()) ::
              {:ok | :error, map}
  def logout(vimond_authorization_token, remember_me, http_client \\ nil) do
    request("logout", fn ->
      http_client(http_client).delete(
        vimond_url("/api/authentication/user/logout"),
        headers_with_tokens(vimond_authorization_token, remember_me)
      )
    end)
    |> handle_response(&extract_logout/2)
  end

  @callback reauthenticate(remember_me :: String.t()) :: {:ok | :error, map}
  def reauthenticate(remember_me, http_client \\ nil) do
    request("reauthenticate", fn ->
      http_client(http_client).get(
        vimond_url("/api/authentication/user"),
        headers(Cookie: "rememberMe=#{remember_me}")
      )
    end)
    |> handle_response(&extract_reauthenticate/2)
  end

  @callback update_password(
              user_id :: String.t(),
              vimond_authorization_token :: String.t(),
              remember_me :: String.t(),
              old_password :: String.t(),
              new_password :: String.t()
            ) :: {:ok | :error, map}
  def update_password(
        user_id,
        vimond_authorization_token,
        remember_me,
        old_password,
        new_password,
        http_client \\ nil
      ) do
    headers = headers_with_tokens(vimond_authorization_token, remember_me)

    body =
      Jason.encode!(%{
        userId: String.to_integer(user_id),
        oldPassword: old_password,
        newPassword: new_password
      })

    request("update_password", fn ->
      http_client(http_client).put(vimond_url("user/password"), body, headers)
    end)
    |> case do
      %HTTPotion.Response{status_code: 204} -> {:ok, %{}}
      response -> handle_response(response, &extract_update_password/2)
    end
  end

  @callback update_password_with_token(password_token :: String.t(), new_password :: String.t()) ::
              {:ok | :error, map}
  def update_password_with_token(password_token, new_password, http_client \\ nil) do
    body = Plug.Conn.Query.encode(%{token: password_token, password: new_password})

    request("update_password_with_token", fn ->
      http_client(http_client).post(
        vimond_url("user/password"),
        body,
        headers("Content-Type": "application/x-www-form-urlencoded; charset=UTF-8")
      )
    end)
    |> case do
      %HTTPotion.Response{status_code: 204} -> {:ok, %{}}
      response -> handle_response(response, &extract_update_password/2)
    end
  end

  @callback current_orders(
              user_id :: String.t(),
              vimond_authorization_token :: String.t(),
              remember_me :: String.t()
            ) :: {:ok | :error, map}
  def current_orders(user_id, vimond_authorization_token, remember_me, http_client \\ nil) do
    request("current_orders", fn ->
      http_client(http_client).get(
        vimond_url("user/#{user_id}/orders/current"),
        headers_with_tokens(vimond_authorization_token, remember_me)
      )
    end)
    |> handle_response(&extract_orders/2)
  end

  def current_orders_signed(user_id, http_client \\ nil) do
    url = vimond_url("user/#{user_id}/orders/current")
    path = URI.parse(url).path

    request("current_orders", fn ->
      http_client(http_client).get(url, headers(signed_headers("GET", path)))
    end)
    |> handle_response(&extract_orders/2)
  end

  @callback product(product_group_id :: String.t(), product_id :: String.t()) ::
              {:ok, map} | {:error, String.t()}
  def product(product_group_id, product_id, http_client \\ nil) do
    request("product", fn ->
      http_client(http_client).get(
        vimond_url("productgroup/#{product_group_id}/products/#{product_id}"),
        headers()
      )
    end)
    |> handle_product_response
  end

  @callback product_group(product_group_id :: String.t()) :: {:ok | :error, map}
  def product_group(product_group_id, http_client \\ nil) do
    request("product_group", fn ->
      http_client(http_client).get(
        vimond_url("productgroup/#{product_group_id}"),
        headers()
      )
    end)
    |> handle_product_group_response
  end

  @callback exists_signed(username :: String.t()) :: {:ok, boolean}
  def exists_signed(username, http_client \\ nil) do
    url = vimond_url("user/username/#{username}")
    path = URI.parse(url).path

    request("exists", fn ->
      http_client(http_client).get(url, headers(signed_headers("GET", path)))
    end)
    |> handle_exists_response
  end

  @callback user_information(vimond_authorization_token :: String.t(), remember_me :: String.t()) ::
              {:ok | :error, map}
  def user_information(vimond_authorization_token, remember_me, http_client \\ nil) do
    with {:ok, data} <-
           fetch_user_information(
             vimond_authorization_token,
             remember_me,
             http_client,
             &extract_user_information/1
           ) do
      case Map.pop(data, :vimond_authorization_token) do
        {nil, data} ->
          {:ok, Map.put(data, :session, %Vimond.Session{})}

        {token, data} ->
          {:ok, Map.put(data, :session, %Vimond.Session{vimond_authorization_token: token})}
      end
    end
  end

  @callback user_information_signed(user_id :: String.t()) :: {:ok | :error, map}
  def user_information_signed(user_id, http_client \\ nil) do
    url = vimond_url("user/#{user_id}")
    path = URI.parse(url).path

    request("user_info", fn ->
      http_client(http_client).get(url, headers(signed_headers("GET", path)))
    end)
    |> handle_response(fn json, headers ->
      case json do
        %{"userName" => _} ->
          with {:ok, data} <- extract_user_information({:ok, reject_nil_values(json)}) do
            {:ok, Map.merge(data, updated_tokens(headers))}
          end

        %{"error" => %{"code" => "SESSION_NOT_AUTHENTICATED", "description" => reason}} ->
          error(:invalid_session, reason)

        _ ->
          @unexpected_error
      end
    end)
  end

  @callback update(
              vimond_authorization_token :: String.t(),
              remember_me :: String.t(),
              user_id :: String.t(),
              updated_user :: Vimond.User.t()
            ) :: {:ok | :error, map}
  def update(
        vimond_authorization_token,
        remember_me,
        user_id,
        updated_user = %User{},
        http_client \\ nil
      ) do
    with {:ok, user_data} <-
           fetch_user_information(
             vimond_authorization_token,
             remember_me,
             http_client,
             fn result ->
               with {:ok, json} <- result do
                 user_data =
                   json
                   |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
                   |> Map.new()

                 {:ok, user_data}
               end
             end
           ) do
      # Keep updated tokens and append to result of this function
      new_vimond_authorization_token =
        Map.get(user_data, :vimond_authorization_token, vimond_authorization_token)

      user_data =
        Map.put(user_data, :properties, updated_properties_payload(user_data, updated_user))

      # Remove user keys that should not be sent to Vimond in the update request
      old_user = Map.drop(user_data, [:uri, :vimond_authorization_token])

      # Merge existing keys in Vimond with updated user values
      merged_user =
        Map.merge(old_user, update_user_payload(user_id, updated_user), fn
          _, left, nil -> left
          _, _, right -> right
        end)

      headers = headers_with_tokens(new_vimond_authorization_token, remember_me)

      request("update", fn ->
        http_client(http_client).put(
          vimond_url("user"),
          Jason.encode!(merged_user),
          headers
        )
      end)
      |> handle_response(&extract_update_user/2)
      |> case do
        # Put back updated vimond tokens into result if changed
        {:ok, data} ->
          if new_vimond_authorization_token &&
               new_vimond_authorization_token != vimond_authorization_token do
            {:ok,
             Map.put(data, :session, %Vimond.Session{
               vimond_authorization_token: new_vimond_authorization_token
             })}
          else
            {:ok, Map.put(data, :session, %Vimond.Session{})}
          end

        response ->
          response
      end
    end
  end

  @callback terminate_order_signed(String.t()) :: {:ok | :error, order_id :: String.t()}
  def terminate_order_signed(order_id, http_client \\ nil) do
    {:ok, order} = get_order_signed(order_id, http_client)
    end_date = DateTime.to_unix(datetime().utc_now(), :milliseconds)

    body =
      order
      |> Enum.filter(fn {_key, value} -> !is_map(value) end)
      |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
      |> Map.new()
      |> Map.put("accessEndDate", end_date)
      |> Map.put("endDate", end_date)
      |> Jason.encode!()

    url = vimond_url("order/#{order_id}")
    path = URI.parse(url).path
    headers = headers(signed_headers("PUT", path))

    request("terminate_order", fn ->
      http_client(http_client).put(url, body, headers)
    end)
    |> case do
      %HTTPotion.Response{status_code: 200} -> {:ok, order_id}
      _ -> {:error, order_id}
    end
  end

  defp get_order_signed(order_id, http_client) do
    url = vimond_url("order/#{order_id}")
    path = URI.parse(url).path
    headers = signed_headers("GET", path) |> headers()

    request("get_order", fn ->
      http_client(http_client).get(url, headers)
    end)
    |> case do
      %HTTPotion.Response{body: body, status_code: 200} -> Jason.decode(body)
    end
  end

  defp updated_properties_payload(user_data, updated_user) do
    {:ok, properties} =
      Map.get(user_data, :properties)
      |> extract_properties()

    new_properties = properties_payload(updated_user)

    updated_properties =
      Enum.map(new_properties, fn property ->
        if old_property = Enum.find(properties, &(&1.name == property.name)) do
          Map.put(old_property, :value, property.value)
        else
          property
        end
      end)

    Enum.reduce(properties, updated_properties, fn property, acc ->
      if Enum.find(acc, &(&1.name == property.name)) do
        acc
      else
        [property | acc]
      end
    end)
  end

  @remapper %{
    year_of_birth: {:dateOfBirth, &TimeConverter.year_to_iso8601/1},
    first_name: :firstName,
    last_name: :lastName,
    zip_code: :zip,
    country_code: :country
  }

  defp update_user_payload(user_id, user) do
    mandatory = %{
      id: String.to_integer(user_id),
      userName: user.username,
      # Handle users with different username and email (The lodakai scenario)
      email: user.email || user.username
    }

    user
    |> Map.take(Map.keys(@remapper))
    |> Enum.reject(fn {_, value} -> missing?(value) end)
    |> Enum.map(fn {key, value} ->
      case Map.get(@remapper, key) do
        {remapped_key, remap_function} -> {remapped_key, remap_function.(value)}
        remapped_key -> {remapped_key, value}
      end
    end)
    |> Map.new()
    |> Map.merge(mandatory)
  end

  defp extract_update_user(json, _headers) do
    case json do
      %{"id" => _, "userName" => _} ->
        {:ok, extract_user(json)}

      %{"error" => %{"code" => "UNAUTHORIZED", "description" => reason}} ->
        error(:invalid_session, reason)

      %{"error" => %{"code" => "USER_INVALID_EMAIL", "description" => reason}} ->
        error(:email_already_in_use, reason)

      %{"error" => %{"code" => "USER_INVALID_USERNAME", "description" => reason}} ->
        error(:username_already_in_use, reason)

      _ ->
        @unexpected_error
    end
  end

  defp extract_properties(nil), do: {:ok, []}

  defp extract_properties(properties) do
    Enum.reduce(properties, %{}, &latest_property/2)
    |> Map.values()
    |> case do
      [%Property{id: nil, name: nil, value: nil}] ->
        {:error,
         %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}

      properties ->
        {:ok, properties}
    end
  end

  defp latest_property(property, result) do
    property_name = property["name"]

    if result[property_name] == nil || result[property_name].id < property["id"] do
      Map.put(result, property_name, %Property{
        id: property["id"],
        name: property_name,
        value: property["value"]
      })
    else
      result
    end
  end

  defp missing?(nil), do: true
  defp missing?(""), do: true
  defp missing?(_), do: false

  defp extract_user_information({:ok, json}) do
    {:ok, extract_user(json)}
  end

  defp extract_user_information(error = {:error, _}), do: error

  defp fetch_user_information(
         vimond_authorization_token,
         remember_me,
         http_client,
         extraction_function
       ) do
    request("user_information", fn ->
      http_client(http_client).get(
        vimond_url("user"),
        headers_with_tokens(vimond_authorization_token, remember_me)
      )
    end)
    |> handle_response(fn json, headers ->
      case json do
        %{"userName" => _} ->
          with {:ok, data} <- extraction_function.({:ok, reject_nil_values(json)}) do
            {:ok, Map.merge(data, updated_tokens(headers))}
          end

        %{"error" => %{"code" => "SESSION_NOT_AUTHENTICATED", "description" => reason}} ->
          error(:invalid_session, reason)

        _ ->
          @unexpected_error
      end
    end)
  end

  defp handle_product_response(%HTTPotion.Response{status_code: 200, body: body}) do
    case json = Jason.decode(body) do
      {:ok, json} ->
        {:ok, %{description: json["description"]}}

      {:error, _} ->
        Logger.error("handle_product_response: Unexpected json: '#{inspect(json)}'")
        {:error, "Failed to parse product description"}
    end
  end

  defp handle_product_response(response) do
    Logger.error("handle_product_response: Unexpected response: '#{inspect(response)}'")
    {:error, "Failed to fetch product description"}
  end

  defp handle_product_group_response(%HTTPotion.Response{status_code: 200, body: body}) do
    case json = Jason.decode(body) do
      {:ok, json} ->
        {:ok, %{name: json["name"]}}

      _ ->
        Logger.error("handle_product_group_response: Unexpected json: '#{inspect(json)}'")
        {:error, %{name: nil}}
    end
  end

  defp handle_product_group_response(response) do
    Logger.error("handle_product_group_response: Unexpected response: '#{inspect(response)}'")

    {:ok, %{name: nil}}
  end

  defp request(log_message, request_function) do
    Logger.info("count#outgoing.vimond.#{log_message}.start=1")
    {time, vimond_response} = :timer.tc(request_function)
    Logger.debug("Vimond response for #{log_message}: #{inspect(vimond_response)}")

    Logger.info(
      "Vimond request time: measure#vimond.#{log_message}=#{div(time, 1000)}ms count#outgoing.vimond.#{
        log_message
      }.end=1"
    )

    vimond_response
  end

  @doc """
  Only made public for ease of testing.
  """
  def handle_response(
        %HTTPotion.Response{body: body, headers: %HTTPotion.Headers{hdrs: headers}},
        extraction_function
      ) do
    case Jason.decode(body) do
      {:ok, json} ->
        extraction_function.(json, headers)

      _ ->
        {:error,
         %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
    end
  end

  def handle_response(%HTTPotion.ErrorResponse{message: reason}, _) do
    {:error, %{type: :http_error, source_errors: [reason]}}
  end

  defp handle_delete_response(%HTTPotion.Response{status_code: 204}) do
    {:ok, %{message: "User has been deleted"}}
  end

  defp handle_delete_response(%HTTPotion.Response{body: body}) do
    %{"error" => %{"description" => reason, "code" => code}} = Jason.decode!(body)
    error(:invalid_session, reason || code)
  end

  defp handle_delete_response(_), do: @unexpected_error

  defp handle_exists_response(%HTTPotion.Response{status_code: 200}), do: {:ok, %{exists: true}}

  defp handle_exists_response(%HTTPotion.ErrorResponse{message: reason}),
    do: {:error, %{type: :http_error, source_errors: [reason]}}

  defp handle_exists_response(_), do: {:ok, %{exists: false}}

  defp handle_forgot_password_response(%HTTPotion.Response{status_code: 204}) do
    {:ok, %{message: "Reset password email sent"}}
  end

  defp handle_forgot_password_response(%HTTPotion.Response{body: body, status_code: 404}) do
    case Jason.decode(body) do
      {:ok, %{"error" => %{"code" => "USER_NOT_FOUND", "description" => reason}}} ->
        {:error, %{type: :user_not_found, source_errors: [reason]}}

      _ ->
        {:error,
         %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
    end
  end

  defp handle_forgot_password_response(_), do: @unexpected_error

  defp extract_authorization_token(%{"authorization" => authorization}) do
    extract_header_value(~r/Bearer (.*)/, authorization)
  end

  defp extract_authorization_token(_), do: nil

  defp extract_header_value(_regex, []), do: nil

  defp extract_header_value(regex, [header_value | tail]) do
    Regex.run(regex, header_value, capture: :all_but_first)
    |> case do
      [token] when is_binary(token) -> token
      _ -> extract_header_value(regex, tail)
    end
  end

  defp extract_header_value(regex, header_value) when is_binary(header_value) do
    extract_header_value(regex, [header_value])
  end

  defp extract_header_value(_regex, _), do: nil

  defp handle_multiple_validation_errors(errors) do
    error_codes = Enum.map(errors, &Kernel.get_in(&1, ["code"]))
    error_messages = Enum.map(errors, &Kernel.get_in(&1, ["description"]))

    cond do
      Enum.member?(error_codes, "USER_INVALID_USERNAME") ->
        error(:username_already_in_use, error_messages)

      Enum.member?(error_codes, "USER_INVALID_EMAIL") ->
        if Enum.member?(error_messages, "Email address is already registered") do
          error(:email_already_in_use, error_messages)
        else
          error(:email_invalid, error_messages)
        end

      true ->
        error(:user_creation_failed, error_messages)
    end
  end

  defp extract_user(json) do
    %{
      user: %User{
        user_id: to_string(json["id"]),
        username: json["userName"],
        email: json["email"],
        first_name: json["firstName"],
        last_name: json["lastName"],
        zip_code: json["zip"],
        country_code: json["country"],
        year_of_birth: TimeConverter.iso8601_to_year(json["dateOfBirth"]),
        properties: extract_properties(json["properties"]) |> elem(1)
      }
    }
  end

  defp vimond_url(path) do
    Application.get_env(:vimond_client, :vimond_base_url)
    |> URI.merge(path)
    |> to_string
  end

  defp headers(headers \\ []) do
    Keyword.merge(
      [
        Accept: "application/json; v=3; charset=UTF-8",
        "Content-Type": "application/json; v=3; charset=UTF-8"
      ],
      headers
    )
  end

  defp headers_with_tokens(vimond_authorization_token, remember_me) do
    headers(
      Authorization: "Bearer #{vimond_authorization_token}",
      Cookie: "rememberMe=#{remember_me}"
    )
  end

  defp reject_nil_values(map) do
    map
    |> Enum.reject(fn {_, value} -> is_nil(value) end)
    |> Map.new()
  end

  defp error(type, source_errors) when is_list(source_errors) do
    {:error, %{type: type, source_errors: source_errors}}
  end

  defp error(type, source_error), do: error(type, [source_error])

  defp signed_headers(method, path) do
    timestamp = Timex.format!(datetime().utc_now(), "{RFC1123}")

    [
      Authorization: "SUMO #{api_key()}:#{vimond_signature(method, path, timestamp)}",
      Date: timestamp
    ]
  end

  def vimond_signature(method, path, timestamp) do
    :crypto.hmac(:sha, api_secret(), "#{method}\n#{path}\n#{timestamp}")
    |> Base.encode64()
  end

  defp api_key, do: Application.get_env(:vimond_client, :vimond_api_key)
  defp api_secret, do: Application.get_env(:vimond_client, :vimond_api_secret)
  defp http_client(client), do: client || Application.get_env(:vimond_client, :http_client)
  defp datetime, do: Application.get_env(:vimond_client, :datetime, DateTime)

  defp build_order(%Order{referrer: referrer, product_payment_id: product_payment_id})
       when not is_nil(referrer) and not is_nil(product_payment_id) do
    %{
      startDate: DateTime.to_unix(datetime().utc_now(), :milliseconds),
      productPaymentId: product_payment_id,
      referrer: referrer
    }
  end

  defp extract_authenticate(json, headers) do
    case json do
      %{"code" => "AUTHENTICATION_OK"} ->
        {
          :ok,
          %{
            session: %Session{
              expires: extract_remember_me_expiry(headers),
              vimond_remember_me: extract_remember_me(headers),
              vimond_authorization_token: extract_authorization_token(headers)
            },
            user: %User{
              user_id: to_string(json["userId"])
            }
          }
        }

      %{"code" => "AUTHENTICATION_FAILED", "description" => reason} ->
        error(:invalid_credentials, reason)

      _ ->
        @unexpected_error
    end
  end

  defp extract_remember_me(%{"set-cookie" => cookies}) do
    extract_header_value(~r/rememberMe=(?!deleteMe)([^;]*)/, cookies)
  end

  defp extract_remember_me_expiry(%{"set-cookie" => cookies}) do
    extract_header_value(~r/rememberMe=(?!deleteMe).*Expires=([^;]*)/, cookies)
    |> TimeConverter.format_expires_timestamp()
  end

  defp properties_payload(user) do
    user.properties
  end

  defp extract_create_user(json, _headers) do
    case json do
      %{"id" => _, "userName" => _} ->
        {:ok, extract_user(json)}

      %{"error" => %{"code" => "USER_MULTIPLE_VALIDATION_ERRORS", "errors" => errors}}
      when is_list(errors) ->
        handle_multiple_validation_errors(errors)

      %{"error" => %{"code" => code}} ->
        error(:user_creation_failed, code)

      _ ->
        @unexpected_error
    end
  end

  defp extract_logout(%{"code" => "SESSION_AUTHENTICATED"}, _),
    do: {:ok, %{vimond_session: :valid}}

  defp extract_logout(%{"code" => "SESSION_INVALIDATED"}, _),
    do: {:ok, %{message: "User logged out"}}

  defp extract_logout(_, _), do: {:ok, %{vimond_session: :invalid}}

  defp extract_reauthenticate(json, headers) do
    case json do
      %{"code" => "SESSION_AUTHENTICATED"} ->
        {:ok, %{session: struct(Vimond.Session, updated_tokens(headers))}}

      %{"code" => "SESSION_NOT_AUTHENTICATED", "description" => reason} ->
        error(:invalid_session, reason)

      _ ->
        @unexpected_error
    end
  end

  defp updated_tokens(headers) do
    %{vimond_authorization_token: extract_authorization_token(headers)}
    |> reject_nil_values
  end

  defp extract_update_password(json, _headers) do
    case json do
      %{"error" => %{"code" => "INVALID_TOKEN", "description" => reason}} ->
        error(:generic, reason)

      %{"error" => %{"code" => "USER_INVALID_PASSWORD", "description" => reason}} ->
        error(:generic, reason)

      %{"error" => %{"code" => "UNAUTHORIZED", "description" => reason}} ->
        error(:invalid_session, reason)

      _ ->
        @unexpected_error
    end
  end

  defp extract_orders(json, _) do
    case json do
      %{"error" => %{"code" => "UNAUTHORIZED", "description" => reason}} ->
        error(:invalid_credentials, reason)

      json when is_list(json) ->
        {:ok, %{orders: Enum.map(json, &transform_order/1)}}

      _ ->
        @unexpected_error
    end
  end

  defp transform_order(order) do
    %Vimond.Order{
      order_id: order["id"],
      product_id: order["productId"],
      product_group_id: order["productGroupId"],
      asset_id: order["progId"],
      referrer: order["referrer"],
      product_payment_id: order["productPaymentId"]
    }
  end
end
