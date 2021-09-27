defmodule Game.PinBowling.Bowling do
  use Ecto.Schema
  import Ecto.Changeset
  alias Game.PinBowling.Bowling.Frame

  schema "bowling" do
    field :state, :string
    field :username, :string

    embeds_many :frames, Frame

    timestamps()
  end

  @doc false
  def new_changeset(bowling, attrs) do
    bowling
    |> cast(attrs, [:state, :username])
    |> validate_required([:state, :username])
  end

  def changeset(bowling, attrs) do
    bowling
    |> cast(attrs, [:state, :username])
    |> validate_required([:state, :username])
    |> cast_embed(:frames)
  end
end

defmodule Game.PinBowling.Bowling.Frame do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :roll1, :integer
    field :roll2, :integer
    field :fill1, :integer
    field :fill2, :integer
    field :score, :integer
    field :kind, :string
    field :state, :string
  end

  def changeset(schema, params) do
    schema
    |> cast(params, [:roll1, :roll2, :fill1, :fill2, :score, :kind, :state])
  end
end
