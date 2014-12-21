f = File.read('app.css')

f.scan(/\/\*\*.*?\*\//m).each do |match|
  puts "MATCH:"
  puts match
end
