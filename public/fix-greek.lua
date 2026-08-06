function Math(elem)
  -- Replace \mathbf with \symbf inside math elements
  elem.text = string.gsub(elem.text, "\\mathbf", "\\symbf")
  return elem
end
