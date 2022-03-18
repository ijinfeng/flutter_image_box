
require './submit.rb'

puts '*** start publish pub to https://pub.dartlang.org ***'

system('flutter packages pub publish --server=https://pub.dartlang.org')