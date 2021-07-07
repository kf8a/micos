defmodule MicosUi.Samples do
  @moduledoc """
  The Samples context.
  """

  import Ecto.Query, warn: false
  alias MicosUi.Repo

  alias MicosUi.Samples.Sample
  alias MicosUi.Samples.Plot

  @doc """
  Returns the list of samples.

  ## Examples

      iex> list_samples()
      [%Sample{}, ...]

  """
  def list_samples do
    Repo.all(Sample)
  end

  def list_samples_to_upload() do
    query = from s in MicosUi.Samples.Sample, where: s.uploaded == false
    Repo.all(query)
  end

  def get_plots() do
    Repo.all(Plot)
  end

  def get_plots_for_select(study_id) do
    query = from p in MicosUi.Samples.Plot,
      select: {p.name, p.id},
      where: p.study_id == ^study_id
    Repo.all(query)
    # |> Enum.map(fn [name,key] -> %{key: key, option: name} end)
  end

  def get_studies_for_select() do
    query = from p in MicosUi.Samples.Study, select: {p.name, p.id}
    Repo.all(query)
    # |> Enum.map(fn [name,key] -> %{key: key, option: name} end)
  end

  @doc """
  Gets a single sample.

  Raises `Ecto.NoResultsError` if the Sample does not exist.

  ## Examples

      iex> get_sample!(123)
      %Sample{}

      iex> get_sample!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sample!(id), do: Repo.get!(Sample, id)

  @doc """
  Creates a sample.

  ## Examples

      iex> create_sample(%{field: value})
      {:ok, %Sample{}}

      iex> create_sample(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sample(attrs \\ %{}) do
    %Sample{}
    |> Sample.changeset(attrs)
    |> Repo.insert()
  end

  def insert_or_update(%Sample{} = sample, attrs \\ %{}) do
    sample
    |> Sample.changeset(attrs)
    |> Repo.insert_or_update
  end

  @doc """
  Updates a sample.

  ## Examples

      iex> update_sample(sample, %{field: new_value})
      {:ok, %Sample{}}

      iex> update_sample(sample, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sample(%Sample{} = sample, attrs) do
    sample
    |> Sample.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Sample.

  ## Examples

      iex> delete_sample(sample)
      {:ok, %Sample{}}

      iex> delete_sample(sample)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sample(%Sample{} = sample) do
    Repo.delete(sample)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sample changes.

  ## Examples

      iex> change_sample(sample)
      %Ecto.Changeset{source: %Sample{}}

  """
  def change_sample(%Sample{} = sample) do
    Sample.changeset(sample, %{})
  end

end
