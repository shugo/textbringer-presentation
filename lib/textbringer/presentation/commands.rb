define_command(:presentation) do
  buffer = Buffer.current
  page_no = buffer.save_excursion {
    buffer.end_of_line
    buffer.substring(buffer.point_min, buffer.point).scan(/^#/).size
  }
  slide_list = Presentation::SlideList.new(Buffer.current.to_s)
  slide_list.goto_page(page_no)
  buffer = Buffer.find_or_new("*Presentaion*", undo_limit: 0)
  switch_to_buffer(buffer)
  buffer[:slide_list] = slide_list
  presentation_mode
end
