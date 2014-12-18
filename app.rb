require 'json'
require_relative 'game'

# The collection of games and players
GAMES = Hash.new { |h, k| h[k] = Game.new }

# config
set :content_type, :json
set :public_folder, 'public'

def game_for(game, player)
  {
    deck_size: game.cards.count,
    hand: {
      cards: player.cards.map { |c| { type: c.type, token: c.token, lost: c.lost } },
      money: player.money
    },
    players: game.players.values.reject { |p| p == player }.map do |p|
      {
        token: p.token,
        money: p.money,
        card_types: p.cards.select(&:lost).map(&:type)
      }
    end
  }
end

get '/' do
  redirect '/index.html'
end

# Reset the game
post '/games/:game_id/players/:player_id/reset' do
  game = GAMES[params[:game_id]]
  player = game.players[params[:player_id]]
  game.reset!
  game_for(game, player).to_json
end

# Draw a card
post '/games/:game_id/players/:player_id/draw' do
  game = GAMES[params[:game_id]]
  player = game.players[params[:player_id]]
  params[:cards].to_i.times.each { game.draw_for(player) }
  game_for(game, player).to_json
end

# Return a card
post '/games/:game_id/players/:player_id/return/:card_token' do
  game = GAMES[params[:game_id]]
  player = game.players[params[:player_id]]
  game.return_from(player, params[:card_token])
  game_for(game, player).to_json
end

# Refresh game
get '/games/:game_id/players/:player_id' do
  game = GAMES[params[:game_id]]
  player = game.players[params[:player_id]]
  game_for(game, player).to_json
end

# Adjust money
post '/games/:game_id/players/:player_id/adjust_money/:amount' do
  game = GAMES[params[:game_id]]
  player = game.players[params[:player_id]]
  player.adjust_money(params[:amount].to_i)
  game_for(game, player).to_json
end

# Lose influence
post '/games/:game_id/players/:player_id/lose/:card_token' do
  game = GAMES[params[:game_id]]
  player = game.players[params[:player_id]]
  player.lose_influence(params[:card_token])
  game_for(game, player).to_json
end
