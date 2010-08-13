module MetaPost
  module Standard    
  
    def layers
      @layers ||= []
    end
    
    def draw_on_layer(layer,*strings) 
      layers[layer] ||= []
      layers[layer] << strings.flatten.join
    end
  
    def write!
      result = layers.flatten.join(";\n  ") + ";\n  "
      layers.clear
      result
    end
  
    def x(value)
      "#{value} xunit"
    end
  
    def y(value)
      "#{value} yunit"
    end
  
    def labels
      @labels ||= []
    end
  
    def draw_labels
      labels.join(";\n")+";\n"
    end
  
    def v(*names)
      name = names.join
      @variables ||= {}
      return @variables[name] if @variables.has_key?(name)
      variable_name = name.gsub(/[^a-zA-Z0-9]/,'')
      variable_name.succ! while @variables.has_value?(variable_name)
      @variables[name] = variable_name
      variable_name
    end  
  end


  module Grid
    include Standard
  
    def grid_lines(x_values,y_values = x_values,colour = 'grid')
      x_values = x_values.to_a
      y_values = y_values.to_a
      x_min, x_max = x_values.min, x_values.max
      y_min, y_max = y_values.min, y_values.max

      x_values.each do |x_value|
        grid_line   "draw (#{x x_value}, #{y y_min})--(#{x x_value}, #{y y_max}) withcolor #{colour}"
      end

      y_values.each do |y_value|
        grid_line   "draw (#{x x_min}, #{y y_value})--(#{x x_max}, #{y y_value}) withcolor #{colour}"
      end

      write!
    end
  
    def grid_labels(x_values,y_values = nil,colour = 'black')
      if x_values
        x_values.each do |x_value|
          grid_label  "label.bot(btex #{x_value} etex, (#{x x_value},0)) withcolor #{colour}"
        end
      end
    
      if y_values
        y_values.each do |y_value|
          grid_label  "label.lft(btex #{y_value} etex, (0,#{y y_value})) withcolor #{colour}"
        end
      end
    
      write!
    end
  
    def grid_line(string)
      draw_on_layer 0, string
    end
  
    def grid_label(string)
      draw_on_layer 1, string
    end
  end
  
  module Stacks
    include Standard
    attr_accessor :default_stack_colours
    attr_accessor :stacks
    attr_accessor :stack_sw_x
  
    def stack(stack_name, width, heights, pen_color = self.default_stack_colours, fill_color = nil)
      self.stacks ||= {}
      self.stacks[stack_name] = []
      self.stack_sw_x ||= 0
      heights = [heights] unless heights.is_a?(Array)
      pen_color = Array.new(heights.size,pen_color) unless pen_color.is_a?(Array)
      fill_color = pen_color.map { |pen| "0.75*white+0.25*(#{pen})" } unless fill_color
      fill_color = Array.new(heights.size,fill_color) unless fill_color.is_a?(Array)
      result = []
      height = 0
      heights.each.with_index do |box_height,i|
        self.stacks[stack_name] << box_name = "#{v(stack_name)}[#{i}]"
        box_definition "boxit.#{box_name}()"
        box_position   "#{box_name}.sw = (#{x @stack_sw_x}, #{y height})"
        box_position   "#{box_name}.ne = (#{x(@stack_sw_x + width)}, #{y height + box_height})"
        height = height + box_height
        box_draw       "fill bpath(#{box_name}) withcolor #{fill_color[i]}"
        box_draw       "draw bpath(#{box_name}) withcolor #{pen_color[i]}"
      end    
      self.stack_sw_x = self.stack_sw_x + width
    end
  
    def chart(default_stack_colours, &block)
      self.stacks = nil
      self.stack_sw_x = nil
      self.default_stack_colours = default_stack_colours
      block.call
      write!
    end
  
    def label_box(box_name,text,corner = :n, colour = "black", rotation = nil, offset = nil, label_position = nil)
      rotation ||= {'ne' => '45', 'n' => '45'}[corner.to_s]
      offset ||= {'ne' => "(0.5 cm, 0.5 cm)", 'n' => "(0.5 cm,0.5 cm)", 'e' => "(0.5 cm, 0 cm)"}[corner.to_s]
      label_position ||= {'ne' => 'urt', 'e' => 'rt', 'n' => 'urt' }[corner.to_s]

      anchor = "#{box_name}.#{corner}"
      box_label arrow = "draw (#{anchor} shifted #{offset})..(#{anchor} shifted (#{offset}/10)) withcolor #{colour}"
      box_label text = "label.#{label_position}( btex #{text} etex #{rotation && "rotated #{rotation}"}, (#{anchor} shifted #{offset}) ) withcolor #{colour}"
      arrow + ";\n" + text + ";\n"
    end
  
    def box_definition(string)
      draw_on_layer 0, string
    end
  
    def box_position(string)
      draw_on_layer 1, string
    end
  
    def box_draw(string)
      draw_on_layer 2, string
    end
  
    def box_label(string)
      draw_on_layer 3, string
    end
    
  end
end