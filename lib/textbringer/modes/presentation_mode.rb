# frozen_string_literal: true

module Textbringer
  CONFIG[:presentation_top_margin] = 1
  CONFIG[:presentation_left_margin] = 2
  CONFIG[:presentation_image_left_margin] = 2
  CONFIG[:presentation_image_background] = "black"
  CONFIG[:presentation_code_top_margin] = 1
  CONFIG[:presentation_code_left_margin] = 2

  if Window.has_colors?
    Face.define :presentation_title, foreground: "magenta", bold: true
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

    define_syntax :presentation_title, /\A\s*.+/
    define_syntax :keyword, /\*\*.*?\*\*/
    define_syntax :comment, /^[ \t]*>.*/

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
        slide_list = buffer[:slide_list]
        slide = slide_list.current
        if slide
          @buffer.insert("\n" * @buffer[:presentation_top_margin])
          left_margin = " " * @buffer[:presentation_left_margin]
          @buffer.insert("#{left_margin}#{slide.title}\n\n")
          body = slide.body
          img_re = /!\[.*?\]\((.*\.(?:jpg|png))\)/
          img = body.slice(img_re, 1)
          code_re = /^```([a-z]+)?\n(.*?)^```$/m
          lang, code = body.scan(code_re)[0]
          s = body.sub(img_re, "").sub(code_re, "").strip.
            gsub(/^/, left_margin)
          @buffer.insert(s)
          beginning_of_buffer
          if img
            show_image(img, s)
          end
          if code
            show_code(code, lang)
          end
          show_slide_number(slide_list)
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
      Window.delete_other_windows
      buffer = Buffer["*Code*"]
      if buffer
        buffer.kill
      end
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
      y = @buffer[:presentation_top_margin] +
        (/\A\s*\z/.match(body) ? 3 : body.count("\n") + 5)
      left_margin = @buffer[:presentation_image_left_margin]
      img_width = width * (columns - left_margin * 2) / columns
      img_height = height * (lines - y - 2) / lines
      STDOUT.printf("\e[%d;%dH", y, left_margin + 1)
      img_size = "#{img_width}x#{img_height}"
      img_bg = @buffer[:presentation_image_background]
      STDOUT.print(`convert -resize #{img_size} -gravity center -background '#{img_bg}' -extent #{img_size} '#{img}' - | img2sixel`)
      STDOUT.flush
    end

    def show_code(code, lang)
      Window.current.split
      Window.current.shrink_if_larger_than_buffer
      Window.other_window
      buffer = Buffer.find_or_new("*Code*")
      buffer.clear
      switch_to_buffer(buffer)
      if lang
        send(lang.downcase + "_mode")
      else
        fundamental_mode
      end
      insert("\n" * @buffer[:presentation_code_top_margin])
      left_margin = " " * @buffer[:presentation_code_left_margin]
      insert(code.gsub(/^/, left_margin))
      beginning_of_buffer
      Window.other_window
    end

    def show_slide_number(slide_list)
      slide = slide_list.current
      msg = "#{slide.number}/#{slide_list.size}"
      message(msg, log: false)
    end
  end
end
