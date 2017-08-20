define_command(:presentation) do
  src_buffer = Buffer.current
  page_no = src_buffer.save_excursion {
    src_buffer.end_of_line
    src_buffer.substring(src_buffer.point_min, src_buffer.point).scan(/^#/).size
  }
  slide_list = Presentation::SlideList.new(src_buffer.to_s)
  slide_list.goto_page(page_no)
  buffer = Buffer.find_or_new("*Presentaion*", undo_limit: 0)
  switch_to_buffer(buffer)
  buffer[:source_buffer] = src_buffer
  buffer[:slide_list] = slide_list
  presentation_mode
end
