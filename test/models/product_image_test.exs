defmodule Bazaar.ProductImageTest do
  use Bazaar.DataCase

  alias Bazaar.ProductImage

  @invalid_attrs %{}

  # test "changeset with valid attributes" do
  #   changeset = ProductImage.changeset(%ProductImage{}, @valid_attrs)
  #   assert changeset.valid?
  # end

  test "changeset with invalid attributes" do
    changeset = ProductImage.changeset(%ProductImage{}, @invalid_attrs)
    refute changeset.valid?
  end
end
