require 'securerandom'

CARD_TYPES = ['ambassador', 'assassin', 'duke', 'captain', 'contessa']

class Player

  attr_reader :cards, :money, :token

  def initialize(game, token)
    @game = game
    @cards = []
    @token = token

    @money = 2
    2.times { game.draw_for(self) }
  end

  def adjust_money(amount)
    @money += amount
  end

  def lose_influence(card_token)
    card = cards.detect { |c| c.token == card_token }
    card.lost = true
  end

end

class Card

  attr_reader :token, :type
  attr_accessor :lost

  def initialize(type)
    @token = SecureRandom.uuid
    @type = type
    @lost = false
  end

end

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
