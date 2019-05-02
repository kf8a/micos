defmodule MicosUi.SamplesTest do
  use MicosUi.DataCase

  alias MicosUi.Samples

  describe "samples" do
    alias MicosUi.Samples.Sample

    @valid_attrs %{finished_at: ~N[2010-04-17 14:00:00], plot_id: 42, started_at: ~N[2010-04-17 14:00:00]}
    @update_attrs %{finished_at: ~N[2011-05-18 15:01:01], plot_id: 43, started_at: ~N[2011-05-18 15:01:01]}
    @invalid_attrs %{finished_at: nil, plot_id: nil, started_at: nil}

    def sample_fixture(attrs \\ %{}) do
      {:ok, sample} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Samples.create_sample()

      sample
    end

    test "list_samples/0 returns all samples" do
      sample = sample_fixture()
      assert Samples.list_samples() == [sample]
    end

    test "get_sample!/1 returns the sample with given id" do
      sample = sample_fixture()
      assert Samples.get_sample!(sample.id) == sample
    end

    test "create_sample/1 with valid data creates a sample" do
      assert {:ok, %Sample{} = sample} = Samples.create_sample(@valid_attrs)
      assert sample.finished_at == ~N[2010-04-17 14:00:00]
      assert sample.plot_id == 42
      assert sample.started_at == ~N[2010-04-17 14:00:00]
    end

    test "create_sample/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Samples.create_sample(@invalid_attrs)
    end

    test "update_sample/2 with valid data updates the sample" do
      sample = sample_fixture()
      assert {:ok, %Sample{} = sample} = Samples.update_sample(sample, @update_attrs)
      assert sample.finished_at == ~N[2011-05-18 15:01:01]
      assert sample.plot_id == 43
      assert sample.started_at == ~N[2011-05-18 15:01:01]
    end

    test "update_sample/2 with invalid data returns error changeset" do
      sample = sample_fixture()
      assert {:error, %Ecto.Changeset{}} = Samples.update_sample(sample, @invalid_attrs)
      assert sample == Samples.get_sample!(sample.id)
    end

    test "delete_sample/1 deletes the sample" do
      sample = sample_fixture()
      assert {:ok, %Sample{}} = Samples.delete_sample(sample)
      assert_raise Ecto.NoResultsError, fn -> Samples.get_sample!(sample.id) end
    end

    test "change_sample/1 returns a sample changeset" do
      sample = sample_fixture()
      assert %Ecto.Changeset{} = Samples.change_sample(sample)
    end
  end
end
