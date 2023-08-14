module Telegram
  include TelegramHelper

  def self.start(bd, bot, message)
    if TelegramHelper.check_status(bd, message.chat.id, 'start') == 1
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}!", reply_markup: kb)
      mess = "This is Tic-tac-toe.\n\nLet`s play\n\n"
      bot.api.send_message(chat_id: message.chat.id, text: mess, reply_markup: kb)
      TelegramHelper.change_status(bd, message.chat.id, 'game')
      setup(bd, bot, message)
    else
      bot.api.send_message(chat_id: message.chat.id, text: 'You are not on the start layer to write /start.')
    end
  end

  def self.the_end(bot, message, i, bd)
    TelegramHelper.change_status(bd, message.chat.id, 'start')
    iter = TelegramHelper.get_iter(bd, message.chat.id)
    bd[iter][2] = 0
    kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    mess =  case i
            when 0
              "End of the game, #{message.from.first_name}!\nIt's a draw!"
            when 1
              "End of the game, #{message.from.first_name}!\nCrosses won!"
            when 2
              "End of the game, #{message.from.first_name}!\nNoughts won!\n"
            end
    bot.api.send_message(chat_id: message.chat.id, text: mess, reply_markup: kb)
    mess = 'Do you want to play again?'
    kb2 = [[
      Telegram::Bot::Types::KeyboardButton.new(text: 'Yes'),
      Telegram::Bot::Types::KeyboardButton.new(text: 'No')
    ]]
    answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb2)
    bot.api.send_message(chat_id: message.chat.id, text: mess, reply_markup: answers)
  end

  def self.check_end(bot, message, map, bd)
    res = map.check_game_status
    if res == 'Crosses won!'
      TelegramHelper.show_game_field(bot, message, map)
      the_end(bot, message, 1, bd)
      return 1
    elsif res == 'Noughts won!'
      TelegramHelper.show_game_field(bot, message, map)
      the_end(bot, message, 2, bd)
      return 1
    elsif res == 'No space'
      TelegramHelper.show_game_field(bot, message, map)
      the_end(bot, message, 0, bd)
      return 1
    end
    0
  end

  def self.restart(bot, bd, message, maps)
    TelegramHelper.change_status(bd, message.chat.id, 'game')
    TelegramHelper.del_map(maps, message.chat.id)
    i = TelegramHelper.get_iter(bd, message.chat.id)
    bd[i][2] = 0
    mess = "This is Tic-tac-toe.\n\nLet`s play\n\n"
    kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    bot.api.send_message(chat_id: message.chat.id, text: mess, reply_markup: kb)
    TelegramHelper.change_status(bd, message.chat.id, 'game')
    setup(bd, bot, message)
  end

  def self.stop(bot, bd, message, maps)
    TelegramHelper.del_map(maps, message.chat.id)
    i = TelegramHelper.get_iter(bd, message.chat.id)
    bd.delete_at(i)
    kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    mess = "Okay, #{message.from.first_name}, see you later! Write /start when you will be ready to play again."
    bot.api.send_message(chat_id: message.chat.id, text: mess, reply_markup: kb)
  end

  def self.set_crosses(bd, bot, message, maps, play_bot)
    if TelegramHelper.check_status(bd, message.chat.id, 'cr_or_no') == 1
      play_bot.figure = 2
      i = TelegramHelper.get_iter(bd, message.chat.id)
      bd[i][2] = 1
      TelegramHelper.change_status(bd, message.chat.id, "game")
      map = Map.new(message.chat.id)
      maps << map
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: "Great!\nYou will play for crosses!", reply_markup: kb)
      TelegramHelper.show_game_field(bot, message, map)
    else
      bot.api.send_message(chat_id: message.chat.id, text: 'You are not choosing how to play.')
    end
  end

  def self.set_noughts(bd, bot, message, maps, play_bot)
    if TelegramHelper.check_status(bd, message.chat.id, 'cr_or_no') == 1
      i = TelegramHelper.get_iter(bd, message.chat.id)
      bd[i][2] = 2
      TelegramHelper.change_status(bd, message.chat.id, "game")
      map = Map.new(message.chat.id)
      maps << map
      play_bot.figure = 1
      play_bot.hard_move(map)
      kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      bot.api.send_message(chat_id: message.chat.id, text: "Great!\nYou will play for noughts!", reply_markup: kb)
      TelegramHelper.show_game_field(bot, message, map)
    else
      bot.api.send_message(chat_id: message.chat.id, text: 'You are not choosing how to play.')
    end
  end

  def self.setup(bd, bot, message)
    if TelegramHelper.check_status(bd, message.chat.id, 'game') == 1
      TelegramHelper.change_status(bd, message.chat.id, 'cr_or_no')
      mess = 'Do you want to play for crosses or noughts?'
      kb = [[
        Telegram::Bot::Types::KeyboardButton.new(text: 'Crosses'),
        Telegram::Bot::Types::KeyboardButton.new(text: 'Noughts')
      ]]
      ans = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb)

      bot.api.send_message(chat_id: message.chat.id, text: mess, reply_markup: ans)
    else
      bot.api.send_message(chat_id: message.chat.id, text: 'The game needs to start')
    end
  end

  def self.game(bd, bot, message, maps, play_bot)
    i = TelegramHelper.get_map(maps, message.chat.id)
    iter = TelegramHelper.get_iter(bd, message.chat. id)
    if maps[i].dot_empty?(message.text)
      TelegramHelper.make_move(maps[i], message.text, bd[iter][2])

      if check_end(bot, message, maps[i], bd) == 1 ## check if user didn't win
        TelegramHelper.del_map(maps, message.chat.id)
        return 0
      end

      play_bot.figure = bd[iter][2] == 1 ? 2 : 1
      play_bot.hard_move(maps[i])

      if check_end(bot, message, maps[i], bd) == 1
        TelegramHelper.del_map(maps, message.chat.id)
        return 0
      end
      TelegramHelper.show_game_field(bot, message, maps[i])
    end
  end
end
