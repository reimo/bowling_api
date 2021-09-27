defmodule GameWeb.BowlingView do
  use GameWeb, :view
  alias GameWeb.BowlingView
  alias GameWeb.FrameView

  def render("index.json", %{bowling: bowling}) do
    %{data: render_many(bowling, BowlingView, "bowling.json")}
  end

  def render("show.json", %{bowling: bowling}) do
    %{data: render_one(bowling, BowlingView, "bowling.json")}
  end

  def render("bowling.json", %{bowling: bowling}) do
    %{
      id: bowling.id,
      state: bowling.state,
      username: bowling.username,
      frames: render_many(bowling.frames, FrameView, "frame.json")
    }
  end
end
