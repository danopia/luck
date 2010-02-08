module Luck
# Control is a master object that handles size methods.
#
# If you actually add an instance of Control to a Pane, it'll just crash :D
class Control
  attr_accessor :pane, :display, :x1, :y1, :x2, :y2
  
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
    @pane = pane
    @display = pane.display
    @x1, @y1 = x1, y1
    @x2, @y2 = x2, y2
    
    instance_eval &blck if blck
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
