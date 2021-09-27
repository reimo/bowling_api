defmodule Game.Repo.Migrations.CreateBowling do
  use Ecto.Migration

  def change do
    create table(:bowling) do
      add :state, :string
      add :frames, :map
      add :username, :string
      timestamps()
    end
  end
end
