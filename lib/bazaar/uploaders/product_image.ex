defmodule Bazaar.Uploaders.ProductImage do
  use Arc.Definition
  use Arc.Ecto.Definition

  def __storage, do: Arc.Storage.Local

  def storage_dir(version, {_file, scope}) do
    "uploads/products/#{scope.product_id}/#{version}"
  end

  # @acl :public_read
  @versions [:original, :show, :thumb]

  @heights %{
    thumb: "415x415",
    show: "1300x900"
  }

  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name) |> String.downcase())
  end

  def transform(:thumb, _file) do
    {:convert, "-strip -resize #{@heights[:thumb]}^ -gravity center -extent #{@heights[:thumb]}"}
  end

  def transform(:show, _file) do
    {:convert, "-strip -resize #{@heights[:show]}^ -gravity center -extent #{@heights[:show]}"}
  end

  # def storage_dir(version, {_, image}) do
  #   "uploads/products/#{image.product_id}/images/#{image.id}/#{version}"
  # end

  def filename(_version, {file, _}) do
    Path.rootname(file.file_name)
  end
end
