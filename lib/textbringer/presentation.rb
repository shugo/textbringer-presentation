# frozen_string_literal: true

require_relative "presentation/version"
require_relative "presentation/slide_list"
require_relative "modes/presentation_mode"

module Textbringer
  module Presentation
  end

  include Commands

  define_command(:presentation) do
    slide_list = Presentation::SlideList.new(Buffer.current.to_s)
    buffer = Buffer.find_or_new("*Presentaion*", undo_limit: 0)
    switch_to_buffer(buffer)
    buffer[:slide_list] = slide_list
    presentation_mode
  end
end
