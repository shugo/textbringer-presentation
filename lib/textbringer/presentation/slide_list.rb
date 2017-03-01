# frozen_string_literal: true

module Textbringer
  module Presentation
    class Slide
      attr_reader :number, :title, :body

      def initialize(number, title, body)
        @number = number
        @title = title
        @body = body
      end
    end

    class SlideList
      def initialize(s)
        @list = s.scan(/^# *(.*?)\n(.*?)(?:(?=^#)|\z)/m).map.with_index {
          |(title, body), i|
          Slide.new(i + 1, title.strip, body.strip)
        }
        @index = 0
      end

      def size
        @list.size
      end

      def current
        @list[@index]
      end

      def forward_slide
        if @index < @list.size - 1
          @index += 1
        end
      end

      def backward_slide
        if @index > 0
          @index -= 1
        end
      end
    end
  end
end
