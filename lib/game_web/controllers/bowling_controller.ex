defmodule GameWeb.BowlingController do
  use GameWeb, :controller

  alias Game.PinBowling
  alias Game.PinBowling.Bowling

  action_fallback(GameWeb.FallbackController)

  def index(conn, _params) do
    bowling = PinBowling.list_bowling()
    render(conn, "index.json", bowling: bowling)
  end

  def create(conn, %{"bowling" => bowling_params}) do
    with {:ok, %Bowling{} = bowling} <- PinBowling.start_game(bowling_params) do
      conn
      |> put_status(:created)
      |> render("show.json", bowling: bowling)
    end
  end

  def roll(conn, %{"id" => id, "roll" => roll}) do
    bowling = PinBowling.get_bowling!(id)

    with {:ok, %Bowling{} = bowling} <- PinBowling.roll(bowling, roll) do
      render(conn, "show.json", bowling: bowling)
    end
  end

  def score(conn, %{"id" => id}) do
    bowling = PinBowling.get_bowling!(id)

    json(conn, %{"score" => PinBowling.score(bowling)})
  end

  def show(conn, %{"id" => id}) do
    bowling = PinBowling.get_bowling!(id)
    render(conn, "show.json", bowling: bowling)
  end

  def update(conn, %{"id" => id, "bowling" => bowling_params}) do
    bowling = PinBowling.get_bowling!(id)

    with {:ok, %Bowling{} = bowling} <- PinBowling.update_bowling(bowling, bowling_params) do
      render(conn, "show.json", bowling: bowling)
    end
  end

  def delete(conn, %{"id" => id}) do
    bowling = PinBowling.get_bowling!(id)

    with {:ok, %Bowling{}} <- PinBowling.delete_bowling(bowling) do
      send_resp(conn, :no_content, "")
    end
  end
end
