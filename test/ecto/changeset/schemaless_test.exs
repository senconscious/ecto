defmodule Ecto.Changeset.SchemalessTest do
  use ExUnit.Case, async: true

  defmodule Author do
    import Ecto.Changeset

    @types %{
      name: :string,
      age: :integer,
      book: {:embed, Ecto.Embedded.init(cardinality: :one, field: :book)}
    }

    @keys Map.keys(@types) -- [:book]

    @book_types %{
      id: :integer,
      name: :string
    }

    @book_keys Map.keys(@book_types)

    def build(entity, attrs) do
      entity
      |> changeset(attrs)
      |> apply_action(:validate)
    end

    def changeset(entity, attrs) do
      {entity, @types}
      |> cast(attrs, @keys)
      |> cast_embed(:book, with: &book_changeset/2)
    end

    def book_changeset(entity, attrs) do
      {entity, @book_types}
      |> cast(attrs, @book_keys)
    end
  end

  test "successfully casts schemaless embed" do
    {:ok, data} = Author.build(%{}, %{name: "Jane", book: %{id: 1, name: "title 1"}})
    assert %{name: "Jane", book: %{id: 1, name: "title 1"}} = data
  end
end
