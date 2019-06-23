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
    count.times do
      break if player.cards.size >= 4
      new_card = @cards.pop
      new_card.active = false if player.cards.size >= 2
      player.cards << new_card
    end
  end

  def return_from(player, card_token)
    idx = player.cards.index { |c| c.token == card_token }
    card = player.cards.delete_at(idx)
    card.active = false
    player.cards.each { |c| c.active = true } if player.cards.size == 2
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
        cards: list_player_cards(player),
        money: player.money
      },
      players: list_other_players(player)
    }.to_json
  end

  private

  def list_player_cards(player)
    player.cards.map do |c|
      {
        type: c.type,
        token: c.token,
        lost: c.lost,
        active: c.active
      }
    end
  end

  def list_other_players(player)
    players.values.reject { |p| p == player || p.cards.empty? }.map do |p|
      {
        token: p.token,
        game_over: p.game_over?,
        money: p.money,
        card_types: p.cards.select(&:lost).map(&:type)
      }
    end
  end
end
