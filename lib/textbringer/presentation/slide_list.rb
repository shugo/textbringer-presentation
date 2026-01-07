# frozen_string_literal: true

module Textbringer
  module Presentation
    class Slide
      attr_reader :number, :title
      attr_accessor :start_pos, :end_pos

      def initialize(buffer, number, title)
        @buffer = buffer
        @number = number
        @title = title
        @start_pos = nil
        @end_pos = nil
      end

      def body
        @buffer.substring(@start_pos, @end_pos).sub(/\A.*\n/, "").strip
      end
    end

    class SlideList
      def initialize(buffer)
        @buffer = buffer
        @list = []
        slide = nil
        i = 1
        @buffer.save_excursion do
          @buffer.beginning_of_buffer
          while @buffer.re_search_forward(/^(?:#+[ \t]*([^\r\n]*)|```.*```)/m,
                                          raise_error: false)
            title = match_string(1)
            if title
              @buffer.beginning_of_line
              slide.end_pos = @buffer.point - 1 if slide
              slide = Slide.new(@buffer, i, title.strip)
              slide.start_pos = @buffer.point
              @list.push(slide)
              i += 1
              @buffer.forward_line
            end
          end
          slide.end_pos = @buffer.point_max if slide
        end
        @index = @list.index { |slide|
          slide.start_pos <= @buffer.point && @buffer.point <= slide.end_pos
        } || 0
      end

      def size
        @list.size
      end

      def current
        @list[@index]
      end

      def current_page
        @index + 1
      end

      def goto_page(no)
        if no < 1 || no > @list.size
          raise ArgumentError, "Invalid page number: #{no}"
        end
        @index = no - 1
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
