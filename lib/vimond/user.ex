defmodule Vimond.User do
  defstruct user_id: nil,
            username: nil,
            password: nil,
            email: nil,
            first_name: nil,
            last_name: nil,
            zip_code: nil,
            country_code: nil,
            year_of_birth: nil,
            properties: []

  defdelegate fetch(user, key), to: Map
  defdelegate get_and_update(user_output, key, fun), to: Map
end
