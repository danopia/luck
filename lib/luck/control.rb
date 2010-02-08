module Luck
# Control is a master object that handles size methods.
#
# If you actually add an instance of Control to a Pane, it'll just crash :D
class Control
  # The parent of the control. Used to position the control.
  # @return [Pane]
  attr_reader :pane
  
  # The display that the parent is in. Used for rendering onto.
  # @return [Display]
  attr_reader :display
  
  # Sets the control's boundaries. Negative numbers are relative to the
  # parent's bottom boundary.
  # @return [Number]
  attr_writer :x1, :y1, :x2, :y2
  
  # Create a new Control.
  #
  # @param [Pane] pane an instance of Luck::Pane to use for sizes
  # @param [Number] x1 Left boundary of the control. Negative numbers
  #   are relative to the parent's right boundary.
  # @param [Number] y1 Top boundary of the control. Negative numbers
  #   are relative to the parent's bottom boundary.
  # @param [Number] x2 Right boundary of the control. Negative numbers
  #   are relative to the parent's right boundary.
  # @param [Number] y2 Bottom boundary of the control. Negative numbers
  #   are relative to the parent's bottom boundary.
  # 
  # @yield The optional block is executed in the Control instance,
  #   allowing for a limited DSL syntax.
  def initialize pane, x1, y1, x2, y2, &blck
    self.pane = pane
    
    @x1, @y1 = x1, y1
    @x2, @y2 = x2, y2
    
    instance_eval &blck if blck
  end
  
  # Changes the parent of the control.
  # @param [Pane] pane The new parent.
  def pane=(pane)
    @pane = pane
    @display = pane.display
  end
  
  # Calculates the control's absolute left boundary on the display.
  # @return [Number]
  def x1
    @pane.x1 + ((@x1 < 0) ? (@pane.width + @x1) : @x1)
  end
  # Calculates the control's absolute top boundary on the display.
  # @return [Number]
  def y1
    @pane.y1 + ((@y1 < 0) ? (@pane.height + @y1) : @y1)
  end
  
  # Calculates the control's absolute right boundary on the display.
  # @return [Number]
  def x2
    @pane.x1 + ((@x2 < 0) ? (@pane.width + @x2 + 1) : @x2)
  end
  # Calculates the control's absolute bottom boundary on the display.
  # @return [Number]
  def y2
    @pane.y1 + ((@y2 < 0) ? (@pane.height + @y2 + 1) : @y2)
  end
  
  # Calculates the control's width.
  # @return [Number]
  def width
    x2 - x1
  end
  # Calculates the control's width.
  # @return [Number]
  def height
    y2 - y1
  end
end
end
