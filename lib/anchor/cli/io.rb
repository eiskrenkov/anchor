# frozen_string_literal: true

module Anchor
  module CLI
    module IO
      POSITIVE_ANWSER_REGEXP = /^(Y|y|yes)$/i.freeze
      COLOR_CODE_MAPPING = {
        white: 0,
        red: 31,
        green: 32,
        yellow: 33,
        purple: 34,
        pink: 35,
        blue: 36
      }.freeze

      class << self
        def ask_boolean(message, options = {})
          ask("#{message} (Y/n)", **options) do |answer|
            answer.match?(POSITIVE_ANWSER_REGEXP)
          end
        end

        def ask(question, options = {})
          say(question, **options)

          say('Answer: ', newline: false)
          answer = $stdin.gets.strip

          block_given? ? yield(answer) : answer
        end

        def say(message, color: :white, newline: true)
          color_code = COLOR_CODE_MAPPING.fetch(color, 0)
          message = "\e[#{color_code}m#{message}\e[0m"

          newline ? puts(message) : print(message)
        end
      end
    end
  end
end
