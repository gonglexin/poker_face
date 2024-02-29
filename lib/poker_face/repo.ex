defmodule PokerFace.Repo do
  use Ecto.Repo,
    otp_app: :poker_face,
    adapter: Ecto.Adapters.Postgres
end
