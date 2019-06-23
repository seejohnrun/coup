# frozen_string_literal: true

require_relative "card"
require_relative "player"

CARD_TYPES = ['ambassador', 'assassin', 'duke', 'captain', 'contessa']

class Game
  attr_reader :players, :cards, :activity_logs

  def initialize
    reset!
  end

  def log_action(player, message)
    @activity_logs << {
      player_token: player.token,
      message: message
    }
  end

  # Draw a card (shuffle first)
  def draw_for(player, count = 1)
    @cards.shuffle!
    log_action(player, "Shuffled the cards.")

    taken = 0
    count.times do
      break if player.cards.size >= 4 || @cards.size == 0
      new_card = @cards.pop
      new_card.active = false if player.cards.size >= 2
      player.cards << new_card
      taken += 1
    end

    log_action(player, "Took #{taken} cards.")
  end

  def return_from(player, card_token)
    idx = player.cards.index { |c| c.token == card_token }
    card = player.cards.delete_at(idx)
    card.active = false
    player.cards.each { |c| c.active = true } if player.cards.size == 2
    @cards << card

    log_action(player, "Returned 1 card.")
  end

  def reset!(player = nil)
    @activity_logs = []
    @cards = (CARD_TYPES * 3).map { |c| Card.new(c) }
    @players = Hash.new { |h, k| h[k] = Player.new(self, k) }
  
    log_action(player, "Reset the game.") if player
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
      players: list_other_players(player),
      activity_logs: activity_logs
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
