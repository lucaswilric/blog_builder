require './lib/translator'
require './lib/html-pipeline-translator'

def test(text)
  t = Translator.new
  hpt = HPTranslator.new(asset_root: 'http://blah.com')

  `rm t.txt hpt.txt`
  File.open('t.txt', 'w') {|f| f.write t.translate(text) }
  File.open('hpt.txt', 'w') {|f| f.write hpt.translate(text) }

  puts `diff t.txt hpt.txt`
end

test File.read('test.markdown')
