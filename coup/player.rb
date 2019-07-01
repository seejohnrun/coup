# frozen_string_literal: true

class Player
  attr_reader :cards, :money, :token

  def initialize(game, token)
    @lost = false
    @game = game
    @cards = []
    @token = token

    @money = 2
  end

  def game_over?
    @lost
  end

  def adjust_money(amount)
    @money += amount
  end

  def lose_influence(card_token)
    card = cards.detect { |c| c.token == card_token }
    card.lost = true
    @lost = true if cards.all?(&:lost)
  end
end
