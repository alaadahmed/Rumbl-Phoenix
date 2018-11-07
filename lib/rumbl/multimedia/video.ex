defmodule Rumbl.Multimedia.Video do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rumbl.Accounts.User
  alias Rumbl.Multimedia.Category
  alias Rumbl.Multimedia.Annotation

  @primary_key {:id, Rumbl.Multimedia.Permalink, autogenerate: true}

  schema "videos" do
    field(:description, :string)
    field(:title, :string)
    field(:url, :string)
    field(:slug, :string)

    belongs_to(:user, User)
    belongs_to(:category, Category)
    has_many(:annotations, Annotation)

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:url, :title, :description, :category_id])
    |> validate_required([:url, :title, :description])
    |> assoc_constraint(:category)
    |> slugify_title()
  end

  defp slugify_title(changeset) do
    case fetch_change(changeset, :title) do
      {:ok, new_title} -> put_change(changeset, :slug, slugify(new_title))
      :error -> changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end

  defimpl Phoenix.Param, for: Rumbl.Multimedia.Video do
    def to_param(%{slug: slug, id: id}) do
      "#{id}-#{slug}"
    end
  end
end
