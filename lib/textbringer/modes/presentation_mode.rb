# frozen_string_literal: true

module Textbringer
  CONFIG[:presentation_image_background] = "black"

  if Window.has_colors?
    Face.define :presentation_title, foreground: "magenta",
      bold: true, underline: true
  end

  class PresentationMode < FundamentalMode
    define_generic_command :forward_slide
    define_generic_command :backward_slide
    define_generic_command :quit_presentation
    define_generic_command :show_current_slide

    PRESENTATION_MODE_MAP = Keymap.new
    PRESENTATION_MODE_MAP.define_key(:right, :forward_slide_command)
    PRESENTATION_MODE_MAP.define_key(:left, :backward_slide_command)
    PRESENTATION_MODE_MAP.define_key("q", :quit_presentation_command)
    PRESENTATION_MODE_MAP.define_key("\C-l", :show_current_slide_command)

    define_syntax :presentation_title, /\A.*/

    def initialize(buffer)
      super(buffer)
      buffer.keymap = PRESENTATION_MODE_MAP
      show_current_slide
    end

    def show_current_slide
      Window.delete_other_windows
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
            show_image(img, s)
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

    private

    def show_image(img, body)
      Window.redisplay
      wininfo = `xwininfo -id $WINDOWID`
      width = wininfo.slice(/Width: (\d+)/, 1).to_i
      height = wininfo.slice(/Height: (\d+)/, 1).to_i
      lines = Window.lines
      columns = Window.columns
      y = body.empty? ? 3 : body.count("\n") + 5
      left_margin = 2
      img_width = width * (columns - left_margin * 2) / columns
      img_height = height * (lines - y - 2) / lines
      STDOUT.printf("\e[%d;%dH", y, left_margin + 1)
      img_size = "#{img_width}x#{img_height}"
      img_bg = @buffer[:presentation_image_background]
      STDOUT.print(`convert -resize #{img_size} -gravity center -background '#{img_bg}' -extent #{img_size} '#{img}' - | img2sixel`)
      STDOUT.flush
    end
  end
end
