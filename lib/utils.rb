def each_page(count, page_size = 25)
  page_index = 0
  page_count = (count / page_size.to_f).ceil
  while page_index < page_count
    yield page_index, page_size
    page_index += 1
  end
end
