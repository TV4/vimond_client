defmodule Vimond.Session do
  defstruct ~w(expires vimond_authorization_token vimond_remember_me)a
  defdelegate get_and_update(session, key, fun), to: Map
end
