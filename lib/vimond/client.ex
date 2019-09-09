defmodule Vimond.Client do
  require Logger
  alias TimeConverter
  alias Vimond.{Config, Order, Property, Session, Subtitle, User}

  @http_client Application.get_env(:vimond_client, :vimond_http_client, Vimond.HTTPClient)
  @unexpected_error {:error, %{type: :generic, source_errors: ["Unexpected error"]}}

  @callback add_order_signed(String.t(), Order.t(), Config.t()) :: {:ok, integer} | {:error, :failed_to_add_order}
  def add_order_signed(user_id, order = %Order{}, config = %Config{}) do
    body =
      build_order(order)
      |> Jason.encode!()

    request("add_order_signed", fn ->
      @http_client.post_signed("order/#{user_id}/create", body, headers(), config)
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

  @callback authenticate(String.t(), String.t(), Config.t()) :: {:ok | :error, map}
  @doc """
  Authenticates the user and returns session and user information.
  """
  def authenticate(username, password, config = %Config{}) do
    body =
      Jason.encode!(%{
        username: username,
        password: password,
        rememberMe: true,
        expand: "user",
        platform: "all"
      })

    headers = headers("Content-Type": "application/json; v=2; charset=UTF-8")

    request("authenticate", fn ->
      @http_client.post("/api/authentication/user/login", body, headers, config)
    end)
    |> handle_response(&extract_authenticate/2)
  end

  @callback create(Vimond.User.t(), Config.t()) :: {:ok | :error, map}
  def create(user = %User{}, config = %Config{}) do
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
      @http_client.post("user", body, headers(), config)
    end)
    |> handle_response(&extract_create_user/2)
  end

  @callback delete(String.t(), String.t(), Config.t()) :: {:ok | :error, map}
  def delete(user_id, vimond_authorization_token, config = %Config{}) do
    headers = headers(Authorization: "Bearer #{vimond_authorization_token}")

    request("delete", fn ->
      @http_client.delete("user/#{user_id}", headers, config)
    end)
    |> handle_delete_response()
  end

  def delete_signed(user_id, config = %Config{}) do
    request("delete_signed", fn ->
      @http_client.delete_signed("user/#{user_id}", headers(), config)
    end)
    |> handle_delete_response()
  end

  @callback forgot_password(String.t(), Config.t()) :: {:ok | :error, map}
  def forgot_password(email, %Config{} = config) do
    request("forgot_password", fn ->
      @http_client.delete("user/#{email}/password", headers(), config)
    end)
    |> handle_forgot_password_response
  end

  @callback logout(String.t(), String.t(), Config.t()) :: {:ok | :error, map}
  def logout(vimond_authorization_token, remember_me, config = %Config{}) do
    request("logout", fn ->
      @http_client.delete(
        "/api/authentication/user/logout",
        headers_with_tokens(vimond_authorization_token, remember_me),
        config
      )
    end)
    |> handle_response(&extract_logout/2)
  end

  @callback reauthenticate(String.t(), Config.t()) :: {:ok | :error, map}
  def reauthenticate(remember_me, config = %Config{}) do
    headers = headers(Cookie: "rememberMe=#{remember_me}")

    request("reauthenticate", fn ->
      @http_client.get("/api/authentication/user", headers, config)
    end)
    |> handle_response(&extract_reauthenticate/2)
  end

  @callback update_password(String.t(), String.t(), String.t(), String.t(), String.t(), Config.t()) ::
              {:ok | :error, map}
  def update_password(
        user_id,
        vimond_authorization_token,
        remember_me,
        old_password,
        new_password,
        config = %Config{}
      ) do
    headers = headers_with_tokens(vimond_authorization_token, remember_me)

    body =
      Jason.encode!(%{
        userId: String.to_integer(user_id),
        oldPassword: old_password,
        newPassword: new_password
      })

    request("update_password", fn ->
      @http_client.put("user/password", body, headers, config)
    end)
    |> case do
      %HTTPotion.Response{status_code: 204} -> {:ok, %{}}
      response -> handle_response(response, &extract_update_password/2)
    end
  end

  @callback update_password_with_token(String.t(), String.t(), Config.t()) :: {:ok | :error, map}
  def update_password_with_token(password_token, new_password, config = %Config{}) do
    body = Plug.Conn.Query.encode(%{token: password_token, password: new_password})
    headers = headers("Content-Type": "application/x-www-form-urlencoded; charset=UTF-8")

    request("update_password_with_token", fn ->
      @http_client.post("user/password", body, headers, config)
    end)
    |> case do
      %HTTPotion.Response{status_code: 204} -> {:ok, %{}}
      response -> handle_response(response, &extract_update_password/2)
    end
  end

  @callback current_orders(String.t(), String.t(), String.t(), Config.t()) :: {:ok | :error, map}
  def current_orders(user_id, vimond_authorization_token, remember_me, config = %Config{}) do
    headers = headers_with_tokens(vimond_authorization_token, remember_me)

    request("current_orders", fn ->
      @http_client.get("user/#{user_id}/orders/current", headers, config)
    end)
    |> handle_response(&extract_orders/2)
  end

  def current_orders_signed(user_id, config = %Config{}) do
    request("current_orders", fn ->
      @http_client.get_signed("user/#{user_id}/orders/current", headers(), config)
    end)
    |> handle_response(&extract_orders/2)
  end

  @callback product(String.t(), String.t(), Config.t()) :: {:ok, map} | {:error, String.t()}
  @deprecated "Use product/2 instead. Vimond ignores the product group id."
  def product(product_group_id, product_id, config = %Config{}) do
    request("product", fn ->
      @http_client.get(
        "productgroup/#{product_group_id}/products/#{product_id}",
        headers(),
        config
      )
    end)
    |> handle_product_response
  end

  @callback product(String.t(), Config.t()) :: {:ok, map} | {:error, String.t()}
  def product(product_id, config = %Config{}) do
    product("0", product_id, config)
  end

  @callback products(String.t(), Config.t()) :: {:ok, map} | {:error, String.t()}
  def products(product_group_id, config = %Config{}) do
    request("products", fn ->
      @http_client.get(
        "productgroup/#{product_group_id}/products",
        headers(),
        config
      )
    end)
    |> handle_products_response
  end

  @callback product_groups(Config.t()) :: {:ok | :error, map}
  def product_groups(config = %Config{}) do
    request("product_groups", fn ->
      @http_client.get("productgroup", headers(), config)
    end)
    |> handle_product_groups_response
  end

  @callback product_group(String.t(), Config.t()) :: {:ok | :error, map}
  def product_group(product_group_id, config = %Config{}) do
    request("product_group", fn ->
      @http_client.get("productgroup/#{product_group_id}", headers(), config)
    end)
    |> handle_product_group_response
  end

  @callback payment_methods(String.t(), Config.t()) :: {:ok | :error, map}
  def payment_methods(product_id, config = %Config{}) do
    request("payment_methods", fn ->
      @http_client.get("productgroup/0/products/#{product_id}/productPayments", headers(), config)
    end)
    |> handle_payment_methods_response
  end

  @callback payment(String.t(), Config.t()) :: {:ok | :error, map}
  def payment(payment_method_id, config = %Config{}) do
    request("payment", fn ->
      @http_client.get(
        "productgroup/0/products/0/productPayments/#{payment_method_id}/payment",
        headers(),
        config
      )
    end)
    |> handle_payment_response(String.to_integer(payment_method_id))
  end

  @callback exists_signed(String.t(), Config.t()) :: {:ok, boolean}
  def exists_signed(username, config = %Config{}) do
    username_exists = fn ->
      @http_client.get_signed("user/username/#{username}", headers(), config)
    end

    email_exists = fn ->
      @http_client.get_signed("user/#{username}", headers(), config)
    end

    with :maybe <- parse_exists_vimond_response(username_exists),
         :maybe <- parse_exists_vimond_response(email_exists) do
      {:ok, %{exists: false}}
    end
  end

  defp parse_exists_vimond_response(request_fun) do
    case request("exists", request_fun) do
      %HTTPotion.Response{status_code: 200} ->
        {:ok, %{exists: true}}

      # When using the username lookup endpoint in Vimond, it can return the following things:
      #
      # For a username that looks like a username and exists -> 200, exists
      # For a username that looks like an email address and exists -> 200, exists
      # For a username that looks like an email address and doesn't exist as username -> 400, Invalid username
      # For a username that looks like a username and doesn't exist -> 400, unhandled Java error "UserNotFoundException"
      #
      # 😱
      %HTTPotion.Response{status_code: _} ->
        :maybe

      %HTTPotion.ErrorResponse{message: message} ->
        {:error, %{type: :http_error, source_errors: [message]}}
    end
  end

  @callback user_information(String.t(), String.t(), Config.t()) :: {:ok | :error, map}
  def user_information(vimond_authorization_token, remember_me, config = %Config{}) do
    with {:ok, data} <-
           fetch_user_information(
             vimond_authorization_token,
             remember_me,
             &extract_user_information/1,
             config
           ) do
      case Map.pop(data, :vimond_authorization_token) do
        {nil, data} ->
          {:ok, Map.put(data, :session, %Vimond.Session{})}

        {token, data} ->
          {:ok, Map.put(data, :session, %Vimond.Session{vimond_authorization_token: token})}
      end
    end
  end

  @callback user_information_signed(String.t(), Config.t()) :: {:ok | :error, map}
  def user_information_signed(user_id, config = %Config{}) do
    request("user_info", fn ->
      @http_client.get_signed("user/#{user_id}", headers(), config)
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

  @callback update(String.t(), String.t(), String.t(), Vimond.User.t(), Config.t()) :: {:ok | :error, map}
  def update(
        vimond_authorization_token,
        remember_me,
        user_id,
        updated_user = %User{},
        config = %Config{}
      ) do
    with {:ok, user_data} <-
           fetch_user_information(
             vimond_authorization_token,
             remember_me,
             fn result ->
               with {:ok, json} <- result do
                 user_data =
                   json
                   |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
                   |> Map.new()

                 {:ok, user_data}
               end
             end,
             config
           ) do
      # Keep updated tokens and append to result of this function
      new_vimond_authorization_token = Map.get(user_data, :vimond_authorization_token, vimond_authorization_token)

      user_data = Map.put(user_data, :properties, updated_properties_payload(user_data, updated_user))

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
        @http_client.put("user", Jason.encode!(merged_user), headers, config)
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

  @callback terminate_order_signed(String.t(), Config.t()) :: {:ok | :error, order_id :: String.t()}
  def terminate_order_signed(order_id, config = %Config{}) do
    {:ok, order} = get_order_signed(order_id, config)
    end_date = DateTime.to_unix(datetime().utc_now(), :millisecond)

    body =
      order
      |> Enum.filter(fn {_key, value} -> !is_map(value) end)
      |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
      |> Map.new()
      |> Map.put("accessEndDate", end_date)
      |> Map.put("endDate", end_date)
      |> Jason.encode!()

    request("terminate_order", fn ->
      @http_client.put_signed("order/#{order_id}", body, headers(), config)
    end)
    |> case do
      %HTTPotion.Response{status_code: 200} -> {:ok, order_id}
      _ -> {:error, order_id}
    end
  end

  @callback update_order_signed(Order.t(), Config.t()) :: {:ok | :error, order_id :: String.t()}
  def update_order_signed(order = %Order{order_id: order_id}, config = %Config{}) do
    request("updated order", fn ->
      @http_client.put_signed(
        "order/#{order_id}",
        Jason.encode!(update_order_payload(order, config)),
        headers(),
        config
      )
    end)
    |> handle_response(&extract_order/2)
  end

  defp update_order_payload(order, config) do
    {:ok, old_order} = get_order_signed(order.order_id, config)

    old_order =
      old_order
      |> Enum.filter(fn {_key, value} -> !is_map(value) end)
      |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
      |> Map.new()

    order =
      order
      |> Map.from_struct()
      |> Enum.reject(&(elem(&1, 1) == nil))
      |> Enum.flat_map(fn
        {:end_date, value} ->
          [
            {"endDate", value |> DateTime.from_unix!() |> DateTime.to_iso8601()},
            {"accessEndDate", value |> DateTime.from_unix!() |> DateTime.to_iso8601()}
          ]

        {:order_id, value} ->
          [{"id", value}]

        {key, value} ->
          [{key |> Atom.to_string() |> camelize(), value}]
      end)
      |> Map.new()

    Map.merge(old_order, order)
  end

  def get_order_signed(order_id, config = %Config{}) do
    request("get_order", fn ->
      @http_client.get_signed("order/#{order_id}", headers(), config)
    end)
    |> case do
      %HTTPotion.Response{body: body, status_code: 200} -> Jason.decode(body)
    end
  end

  @callback subtitles(String.t(), String.t(), Config.t()) ::
              {:ok, list(Subtitle.t())} | {:error, map()}
  def subtitles(asset_id, platform, config) do
    request("subtitles", fn ->
      @http_client.get("/api/#{platform}/asset/#{asset_id}/subtitles", headers(), config)
    end)
    |> handle_response(fn json, _headers ->
      subtitles =
        json
        |> Enum.map(fn subtitle ->
          %Subtitle{
            asset_id: Map.get(subtitle, "assetId"),
            content_type: Map.get(subtitle, "contentType"),
            id: Map.get(subtitle, "id"),
            locale: Map.get(subtitle, "locale"),
            name: Map.get(subtitle, "name"),
            type: Map.get(subtitle, "type"),
            uri: Map.get(subtitle, "uri")
          }
        end)

      {:ok, subtitles}
    end)
  end

  @callback set_property_signed(String.t(), Property.t(), Config.t()) :: :ok
  def set_property_signed(user_id, %Property{} = property, config = %Config{}) do
    get_properties_signed(user_id, config)
    |> case do
      {:ok, properties} ->
        Enum.find(properties, fn %Property{name: name} -> name == property.name end)
        |> case do
          %Property{id: id} ->
            update_property_signed(user_id, %Property{property | id: id}, config)

          nil ->
            create_property_signed(user_id, property, config)
        end
    end
  end

  def get_properties_signed(user_id, config = %Config{}) do
    response =
      request("get_properties_signed", fn ->
        @http_client.get_signed("user/#{user_id}/properties", headers(), config)
      end)

    with %HTTPotion.Response{body: body, status_code: 200} <- response,
         {:ok, properties} <- Jason.decode(body) do
      extract_properties(properties)
    end
  end

  def create_property_signed(user_id, %Property{} = property, config = %Config{}) do
    body = Jason.encode!(property)

    request("create_property_signed", fn ->
      @http_client.post_signed("user/#{user_id}/property", body, headers(), config)
    end)
    |> case do
      %HTTPotion.Response{status_code: 200} -> :ok
    end
  end

  def update_property_signed(user_id, %Property{} = property, config = %Config{}) do
    body = Jason.encode!(property)

    request("update_property_signed", fn ->
      @http_client.put_signed("user/#{user_id}/property/#{property.id}", body, headers(), config)
    end)
    |> case do
      %HTTPotion.Response{status_code: 200} -> :ok
    end
  end

  defp updated_properties_payload(user_data, updated_user) do
    {:ok, properties} =
      Map.get(user_data, :properties)
      |> extract_properties()

    properties =
      Enum.reject(properties, fn property ->
        property.allow_user_to_update == false
      end)

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
        if reason == "Email address is already registered" do
          error(:email_already_in_use, reason)
        else
          error(:email_invalid, reason)
        end

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
        {:error, %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}

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
        value: property["value"],
        allow_user_to_update: property["allowUserToUpdate"]
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
         extraction_function,
         config = %Config{}
       ) do
    headers = headers_with_tokens(vimond_authorization_token, remember_me)

    request("user_information", fn ->
      @http_client.get("user", headers, config)
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
        {:ok,
         %{
           id: json["id"],
           currency: json["currency"],
           description: json["description"],
           enabled: json["enabled"],
           minimum_periods: json["minimumPeriods"],
           payment_plan: %{
             name: get_in(json, ["paymentPlan", "name"]),
             payment_type: get_in(json, ["paymentPlan", "paymentType"]),
             period: get_in(json, ["paymentPlan", "period"])
           },
           price: json["price"],
           product_group_id: json["productGroupId"],
           product_payments_uri: json["productPaymentsUri"]["uri"],
           product_status: json["productStatus"]
         }}

      {:error, _} ->
        Logger.error("handle_product_response: Unexpected json: '#{inspect(json)}'")
        {:error, "Failed to parse product"}
    end
  end

  defp handle_product_response(response) do
    Logger.error("handle_product_response: Unexpected response: '#{inspect(response)}'")
    {:error, "Failed to fetch product"}
  end

  defp handle_products_response(%HTTPotion.Response{status_code: 200, body: body}) do
    case json = Jason.decode(body) do
      {:ok, %{"products" => products}} ->
        {:ok,
         %{
           products:
             Enum.map(products, fn product ->
               %{
                 id: product["id"],
                 currency: product["currency"],
                 description: product["description"],
                 enabled: product["enabled"],
                 minimum_periods: product["minimumPeriods"],
                 payment_plan: %{
                   name: get_in(product, ["paymentPlan", "name"]),
                   payment_type: get_in(product, ["paymentPlan", "paymentType"]),
                   period: get_in(product, ["paymentPlan", "period"])
                 },
                 price: product["price"],
                 product_group_id: product["productGroupId"],
                 product_payments_uri: product["productPaymentsUri"]["uri"],
                 product_status: product["productStatus"]
               }
             end)
         }}

      _ ->
        Logger.error("handle_products_response: Unexpected json: '#{inspect(json)}'")
        {:error, "Failed to parse products"}
    end
  end

  defp handle_products_response(response) do
    Logger.error("handle_products_response: Unexpected response: '#{inspect(response)}'")
    {:error, "Failed to fetch products"}
  end

  defp handle_product_groups_response(%HTTPotion.Response{status_code: 200, body: body}) do
    case json = Jason.decode(body) do
      {:ok, json} ->
        {:ok,
         Enum.map(json["productGroups"], fn productGroup ->
           %Vimond.ProductGroup{
             name: productGroup["name"],
             description: productGroup["description"],
             sale_status: productGroup["saleStatus"]
           }
         end)}

      _ ->
        Logger.error("handle_product_group_response: Unexpected json: '#{inspect(json)}'")
        {:error, %{name: nil, description: nil, sale_status: nil}}
    end
  end

  defp handle_product_groups_response(response) do
    Logger.error("handle_product_groups_response: Unexpected response: '#{inspect(response)}'")

    {:error, "Failed to fetch product groups"}
  end

  defp handle_product_group_response(%HTTPotion.Response{status_code: 200, body: body}) do
    case json = Jason.decode(body) do
      {:ok, json} ->
        {:ok,
         %Vimond.ProductGroup{
           id: json["id"],
           name: json["name"],
           description: json["description"],
           sale_status: json["saleStatus"]
         }}

      _ ->
        Logger.error("handle_product_group_response: Unexpected json: '#{inspect(json)}'")
        {:error, "Failed to parse product group"}
    end
  end

  defp handle_product_group_response(response) do
    Logger.error("handle_product_group_response: Unexpected response: '#{inspect(response)}'")

    {:error, "Failed to fetch product group"}
  end

  defp handle_payment_methods_response(%HTTPotion.Response{status_code: 200, body: body}) do
    case json = Jason.decode(body) do
      {:ok, json} ->
        {:ok,
         Enum.map(json["productPaymentList"], fn payment_method ->
           %Vimond.PaymentMethod{
             auto_renew_warning_enabled: payment_method["autoRenewWarningEnabled"],
             autorenew_warning_channel: payment_method["autorenewWarningChannel"],
             description: payment_method["description"],
             discounted_price: payment_method["discountedPrice"],
             enabled: payment_method["enabled"],
             id: payment_method["id"],
             init_period: payment_method["initPeriod"],
             init_price: payment_method["initPrice"],
             payment_object_uri: get_in(payment_method, ["paymentObjectUri", "uri"]),
             payment_provider_id: payment_method["paymentProviderId"],
             product_id: payment_method["productId"],
             product_payment_status: payment_method["productPaymentStatus"],
             recurring_discounted_price: payment_method["recurringDiscountedPrice"],
             recurring_price: payment_method["recurringPrice"],
             sort_index: payment_method["sortIndex"],
             uri: payment_method["uri"]
           }
         end)}

      {:error, _} ->
        Logger.error("handle_payment_methods_response: Unexpected json: '#{inspect(json)}'")
        {:error, "Failed to parse payment methods"}
    end
  end

  defp handle_payment_methods_response(response) do
    Logger.error("handle_payment_methods_response: Unexpected response: '#{inspect(response)}'")

    {:error, "Failed to fetch payment methods"}
  end

  defp handle_payment_response(%HTTPotion.Response{status_code: 200, body: body}, id) do
    case json = Jason.decode(body) do
      {:ok, json} ->
        {:ok, %Vimond.Payment{id: id, name: json["name"], payment_method: json["paymentMethod"], url: json["url"]}}

      {:error, _} ->
        Logger.error("handle_payment_response: Unexpected json: '#{inspect(json)}'")
        {:error, "Failed to parse payment"}
    end
  end

  defp handle_payment_response(response, _) do
    Logger.error("handle_payment_response: Unexpected response: '#{inspect(response)}'")

    {:error, "Failed to fetch payment"}
  end

  defp request(log_message, request_function) do
    Logger.info("count#outgoing.vimond.#{log_message}.start=1")
    {time, vimond_response} = :timer.tc(request_function)
    Logger.debug("Vimond response for #{log_message}: #{inspect(vimond_response)}")

    Logger.info(
      "Vimond request time: measure#vimond.#{log_message}=#{div(time, 1000)}ms count#outgoing.vimond.#{log_message}.end=1"
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
        {:error, %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
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

  defp handle_forgot_password_response(%HTTPotion.Response{status_code: 204}) do
    {:ok, %{message: "Reset password email sent"}}
  end

  defp handle_forgot_password_response(%HTTPotion.Response{body: body, status_code: 404}) do
    case Jason.decode(body) do
      {:ok, %{"error" => %{"code" => "USER_NOT_FOUND", "description" => reason}}} ->
        {:error, %{type: :user_not_found, source_errors: [reason]}}

      _ ->
        {:error, %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
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

  defp datetime, do: Application.get_env(:vimond_client, :datetime, DateTime)

  defp build_order(%Order{referrer: referrer, product_payment_id: product_payment_id})
       when not is_nil(referrer) and not is_nil(product_payment_id) do
    %{
      startDate: DateTime.to_unix(datetime().utc_now(), :millisecond),
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
            }
          }
          |> Map.merge(extract_user(json["user"]))
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
        error(:invalid_credentials, reason)

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

  defp extract_order(json, _) do
    {:ok, transform_order(json)}
  end

  defp transform_order(order) do
    {:ok, end_date, _offset} = DateTime.from_iso8601(order["endDate"])

    end_date = DateTime.to_unix(end_date)

    %Vimond.Order{
      order_id: order["id"],
      product_id: order["productId"],
      product_group_id: order["productGroupId"],
      asset_id: order["progId"],
      referrer: order["referrer"],
      product_payment_id: order["productPaymentId"],
      end_date: end_date
    }
  end

  defp camelize(snake) do
    [first | rest] =
      snake
      |> Macro.camelize()
      |> String.codepoints()

    [String.downcase(first) | rest] |> Enum.join()
  end
end
