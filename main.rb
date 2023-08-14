require './lib/lib.rb'

bd = []
maps = []
play_bot = BotPlayer.new

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if message.is_a?(Telegram::Bot::Types::Message)
      bd.push([message.chat.id, 'start', 0]) if TelegramHelper.check_all(bd, message.chat.id).zero?
      case message.text
      when '/start'
        Telegram.start(bd, bot, message)
      when 'Crosses', 'Noughts'
        Telegram.set_crosses(bd, bot, message, maps, play_bot) if message.text == 'Crosses'
        Telegram.set_noughts(bd, bot, message, maps, play_bot) if message.text == 'Noughts'
      when '/stop', 'No'
        Telegram.stop(bot, bd, message, maps)
      when '/restart', 'Yes'
        Telegram.restart(bot, bd, message, maps)
      when '1', '2', '3', '4', '5', '6', '7', '8', '9'
        if TelegramHelper.check_status(bd, message.chat.id, 'game') == 1
          Telegram.game(bd, bot, message, maps, play_bot)
        end
      else
        bot.api.send_message(chat_id: message.chat.id, text: 'Unknown command')
      end
    elsif message.is_a?(Telegram::Bot::Types::CallbackQuery)
      chat_id = message.message.chat.id
      bd.push([chat_id, 'start', 0]) if check_all(bd, chat_id).zero?
    end
  end
end
