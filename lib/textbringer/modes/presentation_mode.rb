# frozen_string_literal: true

module Textbringer
  if Window.has_colors?
    Face.define :presentation_title, foreground: "magenta",
      bold: true, underline: true
  end

  class PresentationMode < FundamentalMode
    define_generic_command :forward_slide
    define_generic_command :backward_slide
    define_generic_command :quit_presentation

    PRESENTATION_MODE_MAP = Keymap.new
    PRESENTATION_MODE_MAP.define_key(:right, :forward_slide_command)
    PRESENTATION_MODE_MAP.define_key(:left, :backward_slide_command)
    PRESENTATION_MODE_MAP.define_key("q", :quit_presentation_command)

    define_syntax :presentation_title, /\A.*/

    def initialize(buffer)
      super(buffer)
      buffer.keymap = PRESENTATION_MODE_MAP
      show_current_slide
    end

    def show_current_slide
      Window.redraw
      @buffer.read_only = false
      begin
        @buffer.clear
        slide = buffer[:slide_list].current
        if slide
          @buffer.insert("#{slide.title}\n\n")
          body = slide.body
          img_re = /!\[.*?\]\((.*\.(?:jpg|png))\)/
          img = body.slice(img_re, 1)
          s = body.sub(img_re, "").strip
          @buffer.insert(s)
          if img
            Window.redisplay
            printf("\e[%d;0H", s.empty? ? 3 : s.count("\n") + 5)
            print(`convert -resize 300x300 #{img} - | img2sixel`)
            STDOUT.flush
          end
        end
      ensure
        @buffer.read_only = true
      end
    end

    def forward_slide
      @buffer[:slide_list].forward_slide
      show_current_slide
    end

    def backward_slide
      @buffer[:slide_list].backward_slide
      show_current_slide
    end

    def quit_presentation
      kill_buffer(@buffer)
      Window.redraw
    end
  end
end
