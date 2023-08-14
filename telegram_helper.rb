module TelegramHelper
  def self.make_move(map, mess, figure)
    cell = mess.to_i - 1

    if map[cell/3, cell%3].zero?
      map[cell/3, cell%3] = figure
    else
      bot.api.send_message(chat_id: message.chat.id, text: 'This cell is already taken. Try again')
    end
  end

  def self.build_map_str(map)
    str = " "
    (0..2).each do |i|
      (0..2).each do |j|
        str += case map[i, j]
               when 0
                 "◻  "
               when 1
                 "❌  "
               when 2
                 "🟢  "
               else
                 'something went really wrong'
               end
        str += '|  ' if j != 2
      end
      str += "\n"
      str += "---➕---➕---\n" if i != 2
    end
    str
  end

  def self.show_game_field(bot, message, map)
    button_labels = %w[1 2 3 4 5 6 7 8 9]
    rows = button_labels.each_slice(3).map do |row_labels|
      row_labels.map do |label|
        Telegram::Bot::Types::InlineKeyboardButton.new(text: label, callback_data: label)
      end
    end

    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: rows)
    mess_map = build_map_str(map)
    bot.api.send_message(chat_id: message.chat.id, text: mess_map, reply_markup: markup)
  end

  def self.get_map(maps, id)
    iterator = 0
    maps.each do |i|
      return iterator if i.id == id

      iterator += 1
    end
    -1
  end

  def self.del_map(maps, id)
    iterator = 0
    maps.each do |i|
      maps.delete_at(iterator) if i.id == id
      iterator += 1
    end
  end

  def self.check_all(bd, id)
    bd.each do |i|
      return 1 if i[0] == id
    end
    0
  end

  def self.get_iter(bd, id)
    iterator = 0
    bd.each do |i|
      return iterator if i[0] == id

      iterator += 1
    end
  end

  def self.change_status(bd, id, status)
    bd.each do |i|
      if i[0] == id
        i[1] = status
        break
      end
    end
  end

  def self.check_status(bd, id, status)
    bd.each do |i|
      if i[0] == id
        return 1 if i[1] == status
        return 0
      end
    end
  end
end
