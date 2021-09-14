class SiteCustomization::Image < ApplicationRecord
  include HasAttachment

  VALID_IMAGES = {
    "logo_header" => [260, 80],
    "social_media_icon" => [470, 246],
    "social_media_icon_twitter" => [246, 246],
    "apple-touch-icon-200" => [200, 200],
    "budget_execution_no_image" => [800, 600],
    "map" => [420, 500],
    "logo_email" => [400, 80]
  }.freeze

  has_attachment :image

  validates :name, presence: true, uniqueness: true, inclusion: { in: VALID_IMAGES.keys }
  do_not_validate_attachment_file_type :image
  validates :image, file_content_type: { allow: ["image/png", "image/jpeg"] }

  validate :check_image

  def self.all_images
    VALID_IMAGES.keys.map do |image_name|
      find_by(name: image_name) || create!(name: image_name.to_s)
    end
  end

  def self.image_path_for(filename)
    image_name = filename.split(".").first

    find_by(name: image_name)&.path
  end

  def required_width
    VALID_IMAGES[name]&.first
  end

  def required_height
    VALID_IMAGES[name]&.second
  end

  def path
    storage_image if storage_image.attachment&.persisted?
  end

  private

    def check_image
      return unless image?

      storage_image.analyze unless storage_image.analyzed?
      width = storage_image.metadata[:width]
      height = storage_image.metadata[:height]

      if name == "logo_header"
        errors.add(:image, :image_width, required_width: required_width) unless width <= required_width
      else
        errors.add(:image, :image_width, required_width: required_width) unless width == required_width
      end

      errors.add(:image, :image_height, required_height: required_height) unless height == required_height
    end
end
