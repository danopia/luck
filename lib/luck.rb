Luck = Module.new

require 'luck/ansi'
require 'luck/control'
require 'luck/display'

require 'luck/pane'
require 'luck/alert' # requires Pane

require 'luck/label' # requires Control
require 'luck/listbox' # requires Control
require 'luck/progressbar' # requires Control

require 'luck/textbox' # requires Label
require 'luck/button' # requires Label
