defmodule Bazaar.ProductImage do
  # use BazaarWeb, :model
  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  schema "product_images" do
    field(:image, Bazaar.Uploaders.ProductImage.Type)
    # field(:upload, :any, virtual: true)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast_attachments(params, [:image])
    |> validate_required([:image])

    # |> put_name
  end

  def put_name(changeset) do
    case changeset do
      %Ecto.Changeset{
        valid?: true,
        changes: %{upload: %Plug.Upload{content_type: "image/" <> _, filename: name}}
      } ->
        put_change(changeset, :image, name)

      _ ->
        changeset
    end
  end

  def store(%Plug.Upload{} = upload, image) do
    Bazaar.Uploaders.ProductImage.store({upload, image})
  end

  def url(image, version) do
    Bazaar.Uploaders.ProductImage.url({image.name, image}, version)
  end
end
