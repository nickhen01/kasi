# frozen_string_literal: true

class FlashComponent < ViewComponent::Base
  FLASH_TO_MODIFIER = {
    'notice' => {
      icon: "outline/check-circle.svg",
      bg: "flash_bg__notice",
      text: "flash_text__notice"
    },
    'alert' => {
      icon: "outline/exclamation-circle.svg",
      bg: "flash_bg__alert",
      text: "flash_text__alert"
    }
  }.freeze

  delegate :keys, to: :flash

  def initialize(flash:)
    @flash = flash
  end

  def render?
    flash.any?
  end

  def message(key)
    flash[key]
  end

  def icon(key)
    FLASH_TO_MODIFIER.dig(key, :icon)
  end

  def background_modifier(key)
    FLASH_TO_MODIFIER.dig(key, :bg)
  end

  def text_modifier(key)
    FLASH_TO_MODIFIER.dig(key, :text)
  end

  private

  attr_reader :flash
end
