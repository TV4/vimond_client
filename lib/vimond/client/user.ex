defmodule Vimond.Client.User do
  alias Vimond.{Property, Session, User}

  @unexpected_error {:error, %{type: :generic, source_errors: ["Unexpected error"]}}

  @remapper %{
    year_of_birth: {:dateOfBirth, &TimeConverter.year_to_iso8601/1},
    first_name: :firstName,
    last_name: :lastName,
    zip_code: :zip,
    country_code: :country,
    email_status: :emailStatus,
    gender: :gender,
    mobile_status: :mobileStatus,
    postal_address: :address,
    mobile_number: :mobileNumber
  }

  defmacro __using__(_) do
    quote do
      import Vimond.Client.User
      alias Vimond.Config

      # User
      @callback create(User.t(), Config.t()) :: {:ok | :error, map}
      def create(user = %User{}, config = %Config{}) do
        body =
          %{
            userName: user.username,
            password: user.password,
            email: user.email,
            firstName: user.first_name,
            lastName: user.last_name,
            zip: user.zip_code,
            country: user.country_code,
            dateOfBirth: TimeConverter.year_to_iso8601(user.year_of_birth),
            properties: properties_payload(user),
            gender: user.gender,
            address: user.postal_address,
            mobileNumber: user.mobile_number
          }
          |> Jason.encode!()

        request("create", fn ->
          @http_client.post("user", body, headers(), config)
        end)
        |> handle_response(&extract_create_user/2)
      end

      @callback delete(binary, Vimond.Session.t(), Config.t()) :: {:ok | :error, map}
      def delete(
            user_id,
            %Vimond.Session{vimond_authorization_token: token, vimond_jsessionid: jsessionid},
            config = %Config{}
          ) do
        headers = headers(Authorization: "Bearer #{token}", Cookie: "JSESSIONID=#{jsessionid}")

        request("delete", fn ->
          @http_client.delete("user/#{user_id}", headers, config)
        end)
        |> handle_delete_response()
      end

      @callback delete(binary, binary, Config.t()) :: {:ok | :error, map}
      def delete(user_id, vimond_authorization_token, config = %Config{}) when is_binary(vimond_authorization_token) do
        headers = headers(Authorization: "Bearer #{vimond_authorization_token}")

        request("delete", fn ->
          @http_client.delete("user/#{user_id}", headers, config)
        end)
        |> handle_delete_response()
      end

      @callback delete_signed(binary, Config.t()) :: {:ok | :error, map}
      def delete_signed(user_id, config = %Config{}) do
        request("delete_signed", fn ->
          @http_client.delete_signed("user/#{user_id}", headers(), config)
        end)
        |> handle_delete_response()
      end

      @callback exists_signed(binary, Config.t()) :: {:ok, %{exists: boolean}}
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

      @callback user_information(Session.t(), Config.t()) :: {:ok | :error, map}
      def user_information(
            %Session{
              vimond_authorization_token: authorization_token,
              vimond_remember_me: remember_me,
              vimond_jsessionid: jsessionid
            },
            config = %Config{}
          ) do
        user_information(authorization_token, remember_me, jsessionid, config)
      end

      @callback user_information(binary, binary, Config.t()) :: {:ok | :error, map}
      @callback user_information(binary, binary, binary | atom, Config.t()) :: {:ok | :error, map}
      @deprecated "Use user_information/2 instead."
      def user_information(vimond_authorization_token, remember_me, jsessionid \\ :no_jsessionid, config = %Config{}) do
        with {:ok, data} <-
               fetch_user_information(
                 vimond_authorization_token,
                 remember_me,
                 jsessionid,
                 &extract_user_information/1,
                 config
               ) do
          put_in_updated_session(data)
        end
      end

      defp put_in_updated_session(data) do
        data
        |> Map.put(:session, %Vimond.Session{})
        |> Map.pop(:vimond_authorization_token)
        |> case do
          {nil, data} ->
            data

          {token, data} ->
            Map.put(data, :session, %Vimond.Session{vimond_authorization_token: token})
        end
        |> Map.pop(:vimond_jsessionid)
        |> case do
          {nil, data} ->
            data

          {token, data} ->
            put_in(data, [:session, :vimond_jsessionid], token)
        end
        |> (fn data -> {:ok, data} end).()
      end

      @callback user_information_signed(binary, Config.t()) :: {:ok | :error, map}
      def user_information_signed(user_id, config = %Config{}) do
        fetch_user_information_signed(user_id, &extract_user_information/1, config)
      end

      @callback update(Session.t(), binary, User.t(), Config.t()) :: {:ok | :error, map}
      def update(
            %Session{
              vimond_authorization_token: authorization_token,
              vimond_remember_me: remember_me,
              vimond_jsessionid: jsessionid
            },
            user_id,
            updated_user = %User{},
            config = %Config{}
          ) do
        update(authorization_token, remember_me, user_id, updated_user, jsessionid, config)
      end

      @callback update(binary, binary, binary, User.t(), Config.t()) :: {:ok | :error, map}
      @callback update(binary, binary, binary, User.t(), binary | atom, Config.t()) :: {:ok | :error, map}
      @deprecated "Use update/3 instead."
      def update(
            vimond_authorization_token,
            remember_me,
            user_id,
            updated_user = %User{},
            jsessionid \\ :no_jsessionid,
            config = %Config{}
          ) do
        with {:ok, user_data} <-
               fetch_user_information(vimond_authorization_token, remember_me, jsessionid, &to_atom_keys/1, config) do
          # Keep updated tokens and append to result of this functio
          new_vimond_authorization_token = Map.get(user_data, :vimond_authorization_token, vimond_authorization_token)

          new_jsessionid = Map.get(user_data, :vimond_jsessionid, jsessionid)

          user_data = Map.put(user_data, :properties, updated_properties_payload(user_data, updated_user))

          # Remove user keys that should not be sent to Vimond in the update request
          old_user = Map.drop(user_data, [:uri, :vimond_authorization_token])

          # Merge existing keys in Vimond with updated user values
          merged_user =
            Map.merge(old_user, update_user_payload(user_id, updated_user), fn
              _, left, nil -> left
              _, _, right -> right
            end)

          headers = headers_with_tokens(new_vimond_authorization_token, remember_me, new_jsessionid)

          response =
            request("update", fn ->
              @http_client.put("user", Jason.encode!(merged_user), headers, config)
            end)

          response
          |> handle_response(&extract_update_user/2)
          |> case do
            # Put back updated vimond tokens into result if changed
            # add jsessionid
            {:ok, data} ->
              data =
                if new_vimond_authorization_token && new_vimond_authorization_token != vimond_authorization_token do
                  Map.put(data, :session, %Vimond.Session{vimond_authorization_token: new_vimond_authorization_token})
                else
                  Map.put(data, :session, %Vimond.Session{})
                end

              data = put_in(data, [:session, :vimond_jsessionid], extract_jsessionid(response.headers))

              {:ok, data}

            response ->
              response
          end
        end
      end

      @callback update_signed(binary, User.t(), Config.t()) :: {:ok | :error, map}
      def update_signed(user_id, updated_user = %User{}, config = %Config{}) do
        with {:ok, user_data} <- fetch_user_information_signed(user_id, &to_atom_keys/1, config) do
          user_data = Map.put(user_data, :properties, updated_properties_payload(user_data, updated_user))

          # Remove user keys that should not be sent to Vimond in the update request
          old_user = Map.delete(user_data, :uri)

          # Merge existing keys in Vimond with updated user values
          merged_user =
            Map.merge(old_user, update_user_payload(user_id, updated_user), fn
              _, left, nil -> left
              _, _, right -> right
            end)

          request("update_signed", fn ->
            @http_client.put_signed("user", Jason.encode!(merged_user), headers(), config)
          end)
          |> handle_response(&extract_update_user/2)
        end
      end

      # Session
      @callback authenticate(binary, binary, Config.t()) :: {:ok | :error, map}
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

      @callback reauthenticate(Session.t(), Config.t()) :: {:ok | :error, map}
      def reauthenticate(
            %Session{
              vimond_authorization_token: vimond_authorization_token,
              vimond_remember_me: remember_me,
              vimond_jsessionid: jsessionid
            },
            config
          ) do
        reauthenticate(vimond_authorization_token, remember_me, jsessionid, config)
      end

      @callback reauthenticate(binary, binary, Config.t()) :: {:ok | :error, map}
      @callback reauthenticate(binary, binary, binary | atom, Config.t()) :: {:ok | :error, map}
      @deprecated "Use reauthenticate/2 instead."
      def reauthenticate(vimond_authorization_token, remember_me, jsessionid \\ :no_jsessionid, config = %Config{}) do
        request("reauthenticate", fn ->
          headers = headers_with_tokens(vimond_authorization_token, remember_me, jsessionid)
          @http_client.get("/api/authentication/user", headers, config)
        end)
        |> handle_response(&extract_reauthenticate/2)
      end

      @callback logout(Vimond.Session.t(), Config.t()) :: {:ok | :error, map}
      def logout(
            %Vimond.Session{
              vimond_authorization_token: token,
              vimond_remember_me: remember_me,
              vimond_jsessionid: jsessionid
            },
            config
          ) do
        logout(token, remember_me, jsessionid, config)
      end

      @callback logout(binary, binary, Config.t()) :: {:ok | :error, map}
      @deprecated "Use logout/2 instead."
      def logout(vimond_authorization_token, remember_me, jsessionid \\ :no_jsessionid, config = %Config{}) do
        request("logout", fn ->
          @http_client.delete(
            "/api/authentication/user/logout",
            headers_with_tokens(vimond_authorization_token, remember_me, jsessionid),
            config
          )
        end)
        |> handle_response(&extract_logout/2)
      end

      # Password
      @callback forgot_password(binary, Config.t()) :: {:ok | :error, map}
      def forgot_password(email, %Config{} = config) do
        request("forgot_password", fn ->
          @http_client.delete("user/#{email}/password", headers(), config)
        end)
        |> handle_forgot_password_response
      end

      @callback update_password(binary, Vimond.Session.t(), binary, binary, Config.t()) ::
                  {:ok | :error, map}
      def update_password(
            user_id,
            %Vimond.Session{
              vimond_authorization_token: vimond_authorization_token,
              vimond_remember_me: remember_me,
              vimond_jsessionid: jsession_id
            },
            old_password,
            new_password,
            config = %Config{}
          ) do
        update_password(
          user_id,
          vimond_authorization_token,
          remember_me,
          jsession_id,
          old_password,
          new_password,
          config
        )
      end

      @callback update_password(binary, binary, binary, binary, binary, Config.t()) ::
                  {:ok | :error, map}
      @callback update_password(binary, binary, binary, binary | atom, binary, binary, Config.t()) ::
                  {:ok | :error, map}
      @deprecated "Use update_password/5 instead"
      def update_password(
            user_id,
            vimond_authorization_token,
            remember_me,
            jsessionid \\ :no_jsessionid,
            old_password,
            new_password,
            config = %Config{}
          ) do
        headers = headers_with_tokens(vimond_authorization_token, remember_me, jsessionid)

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
          %Vimond.Response{status_code: 204} -> {:ok, %{}}
          response -> handle_response(response, &extract_update_password/2)
        end
      end

      @callback update_password_with_token(binary, binary, Config.t()) :: {:ok | :error, map}
      def update_password_with_token(password_token, new_password, config = %Config{}) do
        body = Plug.Conn.Query.encode(%{token: password_token, password: new_password})
        headers = headers("Content-Type": "application/x-www-form-urlencoded; charset=UTF-8")

        request("update_password_with_token", fn ->
          @http_client.post("user/password", body, headers, config)
        end)
        |> case do
          %Vimond.Response{status_code: 204} -> {:ok, %{}}
          response -> handle_response(response, &extract_update_password/2)
        end
      end

      # User properties
      @callback set_property_signed(binary, Property.t(), Config.t()) :: :ok
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

        with %Vimond.Response{body: body, status_code: 200} <- response,
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
          %Vimond.Response{status_code: 200} -> :ok
        end
      end

      def update_property_signed(user_id, %Property{} = property, config = %Config{}) do
        body = Jason.encode!(property)

        request("update_property_signed", fn ->
          @http_client.put_signed("user/#{user_id}/property/#{property.id}", body, headers(), config)
        end)
        |> case do
          %Vimond.Response{status_code: 200} -> :ok
        end
      end

      defp fetch_user_information(
             vimond_authorization_token,
             remember_me,
             jsessionid \\ :no_jsessionid,
             extraction_function,
             config = %Config{}
           ) do
        headers = headers_with_tokens(vimond_authorization_token, remember_me, jsessionid)

        request("user_information", fn ->
          @http_client.get("user", headers, config)
        end)
        |> handle_response(fn json, headers ->
          extract_fetch_user_information(json, headers, extraction_function)
        end)
      end

      defp fetch_user_information_signed(user_id, extraction_function, config = %Config{}) do
        get_properties_task =
          Task.async(fn ->
            request("get_properties_signed", fn ->
              @http_client.get_signed("user/#{user_id}/properties", headers(), config)
              |> handle_response(fn json, _headers -> json end)
            end)
          end)

        request("user_information_signed", fn -> @http_client.get_signed("user/#{user_id}", headers(), config) end)
        |> handle_response(fn user_data, _headers ->
          extract_fetch_user_information_signed(user_data, extraction_function, get_properties_task)
        end)
      end

      defp parse_exists_vimond_response(request_fun) do
        case request("exists", request_fun) do
          %Vimond.Response{status_code: 200} ->
            {:ok, %{exists: true}}

          # When using the username lookup endpoint in Vimond, it can return the following things:
          #
          # For a username that looks like a username and exists -> 200, exists
          # For a username that looks like an email address and exists -> 200, exists
          # For a username that looks like an email address and doesn't exist as username -> 400, Invalid username
          # For a username that looks like a username and doesn't exist -> 400, unhandled Java error "UserNotFoundException"
          #
          # 😱
          %Vimond.Response{status_code: _} ->
            :maybe

          %Vimond.Error{message: message} ->
            {:error, %{type: :http_error, source_errors: [message]}}
        end
      end

      defp to_atom_keys(result) do
        with {:ok, json} <- result do
          user_data =
            json
            |> Enum.map(fn {key, value} -> {String.to_atom(key), value} end)
            |> Map.new()

          {:ok, user_data}
        end
      end
    end
  end

  def extract_fetch_user_information(json, headers, extraction_function) do
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
  end

  def extract_fetch_user_information_signed(user_data, extraction_function, get_properties_task) do
    case user_data do
      %{"userName" => _} ->
        properties = Task.await(get_properties_task)
        user_data = Map.put(user_data, "properties", properties)
        extraction_function.({:ok, reject_nil_values(user_data)})

      %{"error" => %{"code" => "USER_NOT_FOUND", "description" => reason}} ->
        error(:user_not_found, reason)

      _ ->
        @unexpected_error
    end
  end

  def extract_create_user(json, headers) do
    case json do
      %{"id" => _, "userName" => _} ->
        {:ok, extract_user(json, headers)}

      %{"error" => %{"code" => "USER_MULTIPLE_VALIDATION_ERRORS", "errors" => errors}}
      when is_list(errors) ->
        handle_multiple_validation_errors(errors)

      %{"error" => %{"code" => code}} ->
        error(:user_creation_failed, code)

      _ ->
        @unexpected_error
    end
  end

  def updated_properties_payload(user_data, updated_user) do
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

  def update_user_payload(user_id, user) do
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

  def extract_update_user(json, headers) do
    case json do
      %{"id" => _, "userName" => _} ->
        {:ok, extract_user(json, headers)}

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

  def extract_properties(nil), do: {:ok, []}

  def extract_properties(properties) do
    Enum.reduce(properties, %{}, &latest_property/2)
    |> Map.values()
    |> case do
      [%Property{id: nil, name: nil, value: nil}] ->
        {:error, %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}

      properties ->
        {:ok, properties}
    end
  end

  def extract_user_information({:ok, json}) do
    {:ok, extract_user(json, [])}
  end

  def extract_user_information(error = {:error, _}), do: error

  def handle_delete_response(%Vimond.Response{status_code: 204}) do
    {:ok, %{message: "User has been deleted"}}
  end

  def handle_delete_response(%Vimond.Response{body: body}) do
    %{"error" => %{"description" => reason, "code" => code}} = Jason.decode!(body)

    case code do
      "USER_NOT_FOUND" -> error(:user_not_found, code)
      _ -> error(:invalid_session, reason || code)
    end
  end

  def handle_delete_response(_), do: @unexpected_error

  def handle_forgot_password_response(%Vimond.Response{status_code: 204}) do
    {:ok, %{message: "Reset password email sent"}}
  end

  def handle_forgot_password_response(%Vimond.Response{body: body, status_code: 404}) do
    case Jason.decode(body) do
      {:ok, %{"error" => %{"code" => "USER_NOT_FOUND", "description" => reason}}} ->
        {:error, %{type: :user_not_found, source_errors: [reason]}}

      _ ->
        {:error, %{type: :bad_vimond_response, source_errors: ["Could not parse Vimond response"]}}
    end
  end

  def handle_forgot_password_response(_), do: @unexpected_error

  def extract_authenticate(json, headers) do
    case json do
      %{"code" => "AUTHENTICATION_OK"} ->
        {
          :ok,
          %{
            session: %Session{
              expires: extract_remember_me_expiry(headers),
              vimond_remember_me: extract_remember_me(headers),
              vimond_authorization_token: extract_authorization_token(headers),
              vimond_jsessionid: extract_jsessionid(headers)
            }
          }
          |> Map.merge(extract_user(json["user"], headers))
        }

      %{"code" => "AUTHENTICATION_FAILED", "description" => reason} ->
        error(:invalid_credentials, reason)

      _ ->
        @unexpected_error
    end
  end

  def extract_reauthenticate(json, headers) do
    case json do
      %{"code" => "SESSION_AUTHENTICATED"} ->
        {:ok, %{session: struct(Vimond.Session, updated_tokens(headers))}}

      %{"code" => "SESSION_NOT_AUTHENTICATED", "description" => reason} ->
        error(:invalid_session, reason)

      _ ->
        @unexpected_error
    end
  end

  def properties_payload(user) do
    user.properties
  end

  def extract_logout(%{"code" => "SESSION_AUTHENTICATED"}, _),
    do: {:ok, %{vimond_session: :valid}}

  def extract_logout(%{"code" => "SESSION_INVALIDATED"}, _),
    do: {:ok, %{message: "User logged out"}}

  def extract_logout(_, _), do: {:ok, %{vimond_session: :invalid}}

  def extract_update_password(json, _headers) do
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

  defp latest_property(property = %Property{}, result) do
    property_name = property.name

    if result[property_name] == nil || result[property_name].id < property.id do
      Map.put(result, property_name, property)
    else
      result
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

  defp updated_tokens(headers) do
    %{vimond_authorization_token: extract_authorization_token(headers), vimond_jsessionid: extract_jsessionid(headers)}
    |> reject_nil_values
  end

  defp extract_authorization_token(%{"authorization" => authorization}) do
    extract_header_value(~r/Bearer (.*)/, authorization)
  end

  defp extract_authorization_token(_), do: nil

  defp extract_remember_me(%{"set-cookie" => cookies}) do
    extract_header_value(~r/rememberMe=(?!deleteMe)([^;]*)/, cookies)
  end

  def extract_jsessionid(%{"set-cookie" => cookies}) do
    extract_header_value(~r/JSESSIONID=([^;]*)/, cookies)
  end

  def extract_jsessionid(_), do: nil

  defp extract_remember_me_expiry(%{"set-cookie" => cookies}) do
    extract_header_value(~r/rememberMe=(?!deleteMe).*Expires=([^;]*)/, cookies)
    |> TimeConverter.parse_vimond_expires_timestamp()
  end

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

  defp extract_user(json, _headers) do
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
        properties: extract_properties(json["properties"]) |> elem(1),
        postal_address: json["address"],
        gender: json["gender"],
        email_status: json["emailStatus"],
        mobile_status: json["mobileStatus"],
        mobile_number: json["mobileNumber"]
      }
    }
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
end
