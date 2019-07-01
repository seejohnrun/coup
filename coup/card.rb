# frozen_string_literal: true

require "securerandom"

class Card
  attr_reader :token, :type
  attr_accessor :lost, :active

  def initialize(type)
    @token = SecureRandom.uuid
    @type = type
    @lost = false
    @active = true
  end
end
