define_command(:presentation) do
  src_buffer = Buffer.current
  slide_list = Presentation::SlideList.new(src_buffer)
  buffer = Buffer.find_or_new("*Presentaion*", undo_limit: 0)
  switch_to_buffer(buffer)
  buffer[:source_buffer] = src_buffer
  buffer[:slide_list] = slide_list
  presentation_mode
end
