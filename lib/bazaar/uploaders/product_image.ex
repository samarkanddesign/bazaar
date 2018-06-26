defmodule Bazaar.Uploaders.ProductImage do
  use Arc.Definition
  use Arc.Ecto.Definition

  def __storage, do: Arc.Storage.Local

  def storage_dir(_version, {_file, scope}) do
    IO.inspect({"SCOPYSCOPE", scope})
    "uploads/products/#{scope.product_id}"
  end

  # @acl :public_read
  # @versions [:original, :show, :thumb]

  # @heights %{
  #   show: 315,
  #   thumb: 30
  # }

  # def validate({file, _}) do
  #   ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  # end

  # def transform(:thumb, _file) do
  #   {:convert, "-thumbnail x#{@heights[:thumb]} -gravity center -format jpg"}
  # end

  # def transform(:show, _file) do
  #   {:convert, "-strip -resize x#{@heights[:show]} -gravity center -format png"}
  # end

  # def storage_dir(version, {_, image}) do
  #   "uploads/products/#{image.product_id}/images/#{image.id}/#{version}"
  # end

  # def filename(_version, {file, _}) do
  #   Path.rootname(file.file_name)
  # end
end
