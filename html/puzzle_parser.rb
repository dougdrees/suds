require "nokogiri"
require "open-uri"

doc = Nokogiri::HTML(open("http://show.websudoku.com/?level=4"))

table = doc.xpath("//table//tr//td/input")
entries = table.to_ary
if entries.size != 81
  puts "Array size is wrong. #{entries.size}"
  exit
end
entry_itr = entries.each


puts "{"
puts " \"puzzle\": {"
puts "  \"width\": 9,"
puts "  \"height\": 9,"
puts "  \"rows\": ["

begin
  (1..9).each do |r|
    print "   [ "
    (1..8).each do |c|
      value = entry_itr.next.attr("value")
      value = 0 unless value
      print "#{value}, " if value
    end
    value = entry_itr.next.attr("value")
    value = 0 unless value
    if r == 9
      print "#{value} ]\n"
    else
      print "#{value} ],\n"
    end
  end
end

puts "  ],"

table = doc.xpath("//input")
inputs = table.to_ary
number = 0
inputs.each do |input|
  number = input.attr("value").to_i if input.attr("name") == "id"
end

puts "  \"number\": #{number}"
puts " }"
puts "}"



