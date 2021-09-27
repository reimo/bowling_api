defmodule Game.PinBowlingTest do
  use Game.DataCase

  alias Game.PinBowling

  describe "bowling" do
    alias Game.PinBowling.Bowling

    @valid_attrs %{
      "username" => "user1"
    }
    @update_attrs %{"username" => "user2"}
    @invalid_attrs %{"username" => nil}

    def bowling_fixture(attrs \\ %{}) do
      {:ok, bowling} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PinBowling.start_game()

      bowling
    end

    test "list_bowling/0 returns all bowling" do
      bowling = bowling_fixture()
      assert PinBowling.list_bowling() == [bowling]
    end

    test "get_bowling!/1 returns the bowling with given id" do
      bowling = bowling_fixture()
      assert PinBowling.get_bowling!(bowling.id) == bowling
    end

    test "create_bowling/1 with valid data creates a bowling" do
      assert {:ok, %Bowling{} = bowling} = PinBowling.start_game(@valid_attrs)
      assert bowling.username == "user1"
    end

    test "create_bowling/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PinBowling.start_game(@invalid_attrs)
    end

    test "update_bowling/2 with valid data updates the bowling" do
      bowling = bowling_fixture()
      assert {:ok, %Bowling{} = bowling} = PinBowling.update_bowling(bowling, @update_attrs)
      assert bowling.username == "user2"
    end

    test "update_bowling/2 with invalid data returns error changeset" do
      bowling = bowling_fixture()
      assert {:error, %Ecto.Changeset{}} = PinBowling.update_bowling(bowling, @invalid_attrs)
      assert bowling == PinBowling.get_bowling!(bowling.id)
    end

    test "roll/2 roll a game" do
      bowling = bowling_fixture()

      roll = PinBowling.roll(bowling, 10)

      assert {:ok,
              %Game.PinBowling.Bowling{
                id: _,
                frames: [
                  %Game.PinBowling.Bowling.Frame{
                    fill1: nil,
                    fill2: nil,
                    kind: "strike",
                    roll1: 10,
                    roll2: nil,
                    score: 10,
                    state: "started"
                  }
                ]
              }} = roll
    end

    test "score/2 return game score" do
      bowling = bowling_fixture()

      PinBowling.roll(bowling, 10)
      # get game
      bowling = PinBowling.get_bowling!(bowling.id)
      assert 10 = PinBowling.score(bowling)
    end

    test "delete_bowling/1 deletes the bowling" do
      bowling = bowling_fixture()
      assert {:ok, %Bowling{}} = PinBowling.delete_bowling(bowling)
      assert_raise Ecto.NoResultsError, fn -> PinBowling.get_bowling!(bowling.id) end
    end

    test "change_bowling/1 returns a bowling changeset" do
      bowling = bowling_fixture()
      assert %Ecto.Changeset{} = PinBowling.change_bowling(bowling)
    end
  end
end
