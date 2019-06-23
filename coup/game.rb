# frozen_string_literal: true

require_relative "card"
require_relative "player"

CARD_TYPES = ['ambassador', 'assassin', 'duke', 'captain', 'contessa']

class Game
  attr_reader :players, :cards

  def initialize
    reset!
  end

  # Draw a card (shuffle first)
  def draw_for(player)
    @cards.shuffle!
    player.cards << @cards.pop
  end

  def return_from(player, card_token)
    idx = player.cards.index { |c| c.token == card_token }
    card = player.cards.delete_at(idx)
    @cards << card
  end

  def reset!
    @cards = (CARD_TYPES * 3).map { |c| Card.new(c) }
    @players = Hash.new { |h, k| h[k] = Player.new(self, k) }
  end
end
