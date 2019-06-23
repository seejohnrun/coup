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
  def draw_for(player, count = 1)
    @cards.shuffle!
    count.times { player.cards << @cards.pop }
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

  def to_json(player)
    {
      me: player.token,
      game_over: player.game_over?,
      deck_size: cards.count,
      hand: {
        cards: player.cards.map { |c| { type: c.type, token: c.token, lost: c.lost } },
        money: player.money
      },
      players: players.values.reject { |p| p == player || p.cards.empty? }.map do |p|
        {
          token: p.token,
          game_over: p.game_over?,
          money: p.money,
          card_types: p.cards.select(&:lost).map(&:type)
        }
      end
    }.to_json
  end
end
