module Luck
# Display is the main class in any Luck-using application. Display
# manages access to the terminal and does its best to remove any
# explicit ANSI escapes from other classes.
class Display
  # @return [Number] The width of the terminal.
  attr_reader :width
  # @return [Number] The height of the terminal.
  attr_reader :height
  
  # @return [Hash<Symbol, Pane>] A Hash containing all the Panes
  #   belonging to the display.
  attr_reader :panes
  
  # Value determining which parts of the display are dirty and need to
  # be re-drawn.
  #
  # @return [Boolean, Array] False means the display is clean; True
  #   means the whole display is dirty. If the value is an Array, then
  #   it contains a list of Pane keys that need redrawing.
  attr_reader :dirty
  
  attr_accessor :active_control
  
  # Create a new display. If given, the block is run in the context of
  # the new display, to allow for shorter code while creating panels
  # and controls.
  #
  # NOTE: This method sets the console modes when called! To undo the
  # modes, call Display#undo_modes
  def initialize &blck
    @panes = {}
    @dirty = true
    prepare_modes
    
    size = terminal_size
    @width = size[1]
    @height = size[0]
    
    instance_eval &blck if blck
  end
  
  # Creates a new pane and adds it to the display. If given, the block
  # is run in the context of the new Pane to allow for shorter code
  # while creating controls.
  #
  # @param name The key that will be used to refer to the pane. I
  #   recommend using Symbols.
  # @param args The arguments to pass to Pane.new
  #
  # @see Pane#initialize
  def pane name, *args, &blck
    @panes[name] = Pane.new(self, *args, &blck)
  end
  
  # Place a string at some coordinates on the display. Used mostly by
  # panes and controls to render.
  #
  # NOTE: This method does not flush stdout, so the text may not show up
  # until you flush the display! (Rendering method don't need to; the
  # Display flushes after it's done rendering controls)
  #
  # @param [Number] row The y-coordinate, from the top.
  # @param [Number] col The x-coordinate, from the left.
  # @param [String] text The text to print.
  #
  # @example Say Hello at (10, 5)
  #   display.place(5, 10, "Hello")
  def place row, col, text
    print "\e[#{row.to_i};#{col.to_i}H#{text}"
  end
  
  # Encases ANSI color codes in a command sequence. This is useful for
  # embeding in strings.
  #
  # NOTE: This does not print anything to the screen!
  #
  # @todo Abstract out color codes to make it less ANSI-specific, i.e.
  #   color(:red)
  #
  # @param [String, Number] codes The ANSI color codes to encapsulate.
  # @return [String] An ANSI escape sequence.
  #
  # @example Print "Hello" in red, and then reset back
  #   puts "#{color 34}Hello!#{color 0}"
  def color codes
    "\e[#{codes}m"
  end
  
  # Shows or hides the cursor.
  #
  # NOTE: This method flushes stdout, so you don't need to handle that
  # yourself.
  #
  # @param [Boolean] show True to show the cursor, False to hide it.
  def cursor=(show)
    print show ? "\e[?25h" : "\e[?25l"
    $stdout.flush
  end
  
  # Mark part or all of the display as dirty. Dirty portions will be
  # redrawn next loop.
  #
  # @param pane The key of a pane to mark as dirty. If nil, the entire
  #   display will be marked as dirty.
  #
  # @example Redraw the :main pane next loop
  #   display.dirty! :main
  def dirty! pane=nil
    if pane && @dirty.is_a?(Array) && !(@dirty.include?(pane))
      @dirty << pane
    elsif pane && !@dirty
      @dirty = [pane]
    elsif !pane
      @dirty = true
    end
  end
  
  # Handles the display. This handles redrawing dirty panels, reading
  # input, and resizing the display if the terminal has changed sizes.
  def handle
    handle_stdin
    
    size = terminal_size
    if @width != size[1] || @height != size[0]
      @width = size[1]
      @height = size[0]
      dirty!
    end
    
    return unless @dirty
    redraw @dirty
    @dirty = false
  end
  
  # Force an immediate redraw of the entire display or certain panes.
  #
  # @param [Array, True] panes An array of pane keys to redraw. If not
  #   specified (or True), then the entire display is redrawn.
  def redraw panes=true
    print "\e[H\e[J" if panes == true # clear all and go home
    self.cursor = active_control
    
    panes = @panes.keys if panes == true
    
    panes.each do |key|
      @panes[key].redraw
    end
    print "\e[u"
    
    $stdout.flush
  end
  
  # Handle standard input.
  def handle_stdin
    $stdin.read_nonblock(1024).each_char do |chr|
      active_control.handle_char chr if active_control
    end
    
    self.cursor = active_control
    $stdout.flush
    
  rescue Errno::EAGAIN
  rescue EOFError
  end

  TIOCGWINSZ = 0x5413
  TCGETS = 0x5401
  TCSETS = 0x5402
  ECHO   = 8
  ICANON = 2

  # Gets the terminal size.
  #
  # Thanks google for all of this.
  #
  # @return [Array<Number>] [rows, columns]
  def terminal_size
    rows, cols = 25, 80
    buf = [0, 0, 0, 0].pack("SSSS")
    if $stdout.ioctl(TIOCGWINSZ, buf) >= 0 then
      rows, cols, row_pixels, col_pixels = buf.unpack("SSSS")
    end
    return [rows, cols]
  end

  # Prepares the terminal for fun TUI things. Turns off echo and has the
  # terminal give us each char as it is pressed without waiting for the
  # user to press enter.
  def prepare_modes
    buf = [0, 0, 0, 0, 0, 0, ''].pack("IIIICCA*")
    $stdout.ioctl(TCGETS, buf)
    @old_modes = buf.unpack("IIIICCA*")
    new_modes = @old_modes.clone
    new_modes[3] &= ~ECHO # echo off
    new_modes[3] &= ~ICANON # one char @ a time
    $stdout.ioctl(TCSETS, new_modes.pack("IIIICCA*"))
    self.cursor = false
  end
  
  # Restores previous terminal modes. Use to reset the changes that is
  # done by prepare_modes.
  #
  # @see Display#prepare_modes
  def undo_modes
    $stdout.ioctl(TCSETS, @old_modes.pack("IIIICCA*"))
    print "\e[2J\e[H" # clear all and go home
    self.cursor = true # show the mouse
  end
end
end
