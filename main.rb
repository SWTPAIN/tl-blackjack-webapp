require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_HIT_MIN = 17


helpers do

  def valid_bet? (amount)
    if amount.is_a?(Numeric) && amount<=session[:player_money]
      true
    else
      @error = "Your bet amount must be positive or larger than your held money"
      false
    end
  end

  def calculate_total(cards)
    arr = cards.map{|element| element[1]}

    total = 0
    arr.each do |v|
      if v == "A"
        total += 11
      else
        total += v.to_i == 0 ? 10 : v.to_i
      end
    end

    arr.select{|element| element =="A"}.count.times do
      total -=10 if total > BLACKJACK_AMOUNT
    end
    total
  end

  def card_img(card)
    suit = case card[0]
      when 'H' then'hearts'
      when 'D' then 'diamonds'
      when 'C' then 'clubs'
      when 'S' then 'spades'
      end
    face_value = case card[1]
      when 'J' then 'jack'
      when 'Q' then 'queen'
      when 'K' then 'king'
      when 'A' then 'ace'
      else
        card[1]
      end
    "<img src='/images/cards/#{suit}_#{face_value}.jpg' />"
  end

  def winner!(msg)
    session[:player_money]+=session[:bet_amount]
    @success = "Congratulations! #{msg} #{session[:player_name]} now has $#{session[:player_money]}"
    @show_hit_or_stay_buttons = false
    @gameover = true

  end

  def losser!(msg)
    session[:player_money]-=session[:bet_amount]
    @error = "Sorry, #{msg} #{session[:player_name]} now has $#{session[:player_money]}"
    @show_hit_or_stay_buttons = false
    @gameover = true
    session[:player_money]-=session[:bet_amount]
  end

  def tier!(msg)
    @error = "#{msg} #{session[:player_name]} now has $#{session[:player_money]}"
    @show_hit_or_stay_buttons = false
    @gameover = true
  end
end

before do
  @show_hit_or_stay_buttons = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  session[:player_money] = 500
  erb :new_player
end

post '/new_player' do

  if params[:player_name].empty?
    @error = "Name is required"
    halt erb :new_player
  end

  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/bet' do
  erb :bet
end

post '/bet' do
  if valid_bet? params[:bet_amount]
    session[:bet_amount]=params[:bet_amount].to_i
    redirect '/game'
  else
    erb :bet
  end
end

get '/game' do
  session[:turn] = session[:player_name]
  suits =['H', 'D', 'C', 'S']
  values = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  session[:deck] = suits.product(values).shuffle!

  session[:dealer_cards] = []
  session[:player_cards] = []
  2.times do
    session[:dealer_cards] << session[:deck].pop
    session[:player_cards] << session[:deck].pop
  end

  player_total = calculate_total(session[:player_cards])
  if  player_total == BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit blackjack.")
  end

  erb :game
end


post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  player_total = calculate_total(session[:player_cards])
  if  player_total == BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit blackjack.")
  elsif player_total > BLACKJACK_AMOUNT
    losser!("it look like #{session[:player_name]} are busted")
  end
  erb :game
end

post '/game/player/stay' do
  @success = "#{session[:player_name]} chose to stay. "
  @show_hit_or_stay_buttons = false
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_hit_or_stay_buttons = false

  dealer_total = calculate_total session[:dealer_cards]

  if dealer_total == BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit blackjack.")
  elsif dealer_total > BLACKJACK_AMOUNT
    losser!("it look like #{session[:player_name]} are busted.")
  elsif dealer_total >= DEALER_HIT_MIN
    redirect "/game/compare"
  else
    @dealer_hit = true
  end

  erb :game
end

get '/game/dealer/hit' do
  @show_hit_or_stay_buttons = false
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'

end

get '/game/compare' do
  @show_hit_or_stay_buttons = false
  player_total = calculate_total(session[:player_cards])
  dealer_total = calculate_total(session[:dealer_cards])
  result = "#{session[:player_name]} stay at #{player_total} and the dealer stay at #{dealer_total}.  "
  if dealer_total > player_total
    losser!("#{result} #{session[:player_name]} lose. " )
  elsif dealer_total < player_total
    winner!("#{result} #{session[:player_name]} win.")

  else
    tier!("#{result} It is a tie. " )
  end

  erb :game
end



get '/game_over' do
  erb :game_over
end