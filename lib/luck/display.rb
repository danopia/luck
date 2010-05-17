module Luck
class Display
  attr_accessor :driver, :client, :panes, :dirty, :active_pane, :active_control, :modal
  
  def initialize client
    @client = client
    @panes = {}
    @dirty = true
    
    @driver = ANSIDriver.new
  end
  
  def width; @driver.width; end
  def height; @driver.height; end
  
  def place x,y,t; @driver.put x,y,t; end
  def color c; @driver.color c; end
  
  def close
    @driver.undo_modes
  end
  
  def pane name, *args, &blck
    if args.any? && args.first.is_a?(Pane)
      @panes[name] = args.first
    else
      @panes[name] = Pane.new(self, *args, &blck)
    end
  end
  
  def alert name, *args, &blck
    @panes[name] = Alert.new(self, *args, &blck)
  end
  
  def dirty! pane=nil
    if pane
      @panes[pane].dirty!
    else
      @dirty = true
    end
  end
  
  def [] pane, control=nil
    if control
      @panes[pane].controls[control]
    else
      @panes[pane]
    end
  end
  
  def focus *path
    self.active_control = self[*path]
  end
  
  def handle
    handle_stdin
    
    if @driver.resized?
      dirty!
    end
    
    if @dirty
      redraw
      @dirty = false
    else
      panes = @panes.values.select {|pane| pane.dirty? && pane.visible? }
      redraw panes if panes.any?
    end
    
    @panes.each_value {|pane| pane.dirty = false }
  end
  
  def redraw panes=nil
    unless panes
      @driver.clear
      @driver.cursor_to_home
    end
    
    panes ||= @panes.values
    panes.each {|pane| pane.redraw if pane.visible? }
    modal.redraw if modal
    @panes.each_value {|pane| pane.draw_title if pane.visible? }
    
    @driver.restore_cursor
    @driver.flush
  end
  
  def active_control= control
    @active_pane = control.pane
    @active_control = control
  end
  
  def cycle_controls
    index = @active_pane.controls.keys.index @active_pane.controls.key(@active_control)
    begin
      index += 1
      index = 0 if index >= @active_pane.controls.size
    end until @active_pane.controls[@active_pane.controls.keys[index]].respond_to? :handle_char
    old = @active_control
    @active_control = @active_pane.controls[@active_pane.controls.keys[index]]
    old.redraw
    @active_control.redraw
  end
  
  def cycle_controls_back
    index = @active_pane.controls.keys.index @active_pane.controls.key(@active_control)
    begin
      index -= 1
      index = @active_pane.controls.size - 1 if index < 0
    end until @active_pane.controls[@active_pane.controls.keys[index]].respond_to? :handle_char
    old = @active_control
    @active_control = @active_pane.controls[@active_pane.controls.keys[index]]
    old.redraw
    @active_control.redraw
  end
  
  BUTTONS = {
    0 => :left,
    1 => :middle,
    2 => :right,
    3 => :release,
    64 => :scrollup,
    65 => :scrolldown
  }
  
  # alt-anything => \e*KEY* (same as Esc, key)
  # alt-[ would become \e[ which is an ANSI escape
  #
  # ctrl-stuff becomes weird stuff, i.e. ctrl-space = \x00, ctrl-a = \x01, ctrl-b = \x02
  #
  # super is not sent?
  def handle_stdin
    @escapes ||= 0
    @ebuff ||= ''
    
    $stdin.read_nonblock(1024).each_char do |chr|
    
      if @escapes == 0
        if chr == "\e"
          @escapes = 1
        elsif chr == "\t"
          cycle_controls
        elsif chr == "\177"
          route_key :backspace
        else
          route_key chr
        end
        
      elsif @escapes == 1 && chr == '['
        @escapes = 2
      elsif @escapes == 1 && chr == 'O'
        @escapes = 5
        
      elsif @escapes == 2
        if chr == 'A'
          route_key :up
        elsif chr == 'B'
          route_key :down
        elsif chr == 'C'
          route_key :right
        elsif chr == 'D'
          route_key :left
        elsif chr == 'E'
          route_key :center
        elsif chr == 'Z'
          cycle_controls_back
        else
          @ebuff = chr
          @escapes = 3
        end
        @escapes = 0 if @escapes == 2
        
      elsif @escapes == 3
        if chr == '~' && @ebuff.to_i.to_s == @ebuff
          route_key case @ebuff.to_i
            when 2; :insert
            when 3; :delete
            when 5; :pageup
            when 6; :pagedown
            when 15; :f5
            when 17; :f6
            when 18; :f7
            when 19; :f8
            when 20; :f9
            when 24; :f12
            else; raise @ebuff.inspect
          end
        elsif @ebuff[0,1] == 'M' && @ebuff.size == 3
          @ebuff += chr
          info, x, y = @ebuff.unpack('xCCC').map{|i| i - 32}
          modifiers = []
          modifiers << :shift if info & 4 == 4
          modifiers << :meta if info & 8 == 8
          modifiers << :control if info & 16 == 16
          pane = pane_at(x, y)
          
          unless modal && modal != pane
            pane.handle_click BUTTONS[info & 71], modifiers, x, y if pane
          end
        elsif @ebuff.size > 10
          raise "long ebuff #{@ebuff.inspect} - #{chr.inspect}"
        else
          @ebuff += chr
          @escapes = 4
        end
        @escapes = 0 if @escapes == 3
        @escapes = 3 if @escapes == 4
        @ebuff = '' if @escapes == 0
        
      elsif @escapes == 5
        if chr == 'H'
          route_key :home
        elsif chr == 'F'
          route_key :end
        elsif chr == 'Q'
          route_key :f2
        elsif chr == 'R'
          route_key :f3
        elsif chr == 'S'
          route_key :f4
        else
          raise "escape 5 #{chr.inspect}"
        end
        @escapes = 0
        
      else
        @escapes = 0
      end
    end
    
    @driver.flush
    
  rescue Errno::EAGAIN
  rescue EOFError
  end
  
  def pane_at x, y
    @panes.values.reverse.each do |pane|
      return pane if pane.visible? && (pane.x1..pane.x2).include?(x) && (pane.y1..pane.y2).include?(y)
    end
    nil
  end
  
  def route_key chr
    @active_control.handle_char chr if @active_control
  end
end
end
