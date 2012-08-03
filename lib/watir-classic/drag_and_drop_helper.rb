module Watir
  module DragAndDropHelper

    def drag_and_drop_on(target)
      perform_action do
        assert_target target
        drag_to do |mouse|
          ole_object.document.parentWindow.scrollTo(*target.send(:source_x_y_relative))
          drop_x, drop_y = target.send(:source_x_y)
          mouse.move :x => drop_x, :y => drop_y
        end
      end
    end

    def drag_and_drop_by(distance_x, distance_y)
      perform_action do
        drag_to do |mouse|
          drag_x, drag_y = source_x_y
          ole_object.document.parentWindow.scrollTo(drag_x + distance_x, drag_y + distance_y)
          drag_x, drag_y = source_x_y
          mouse.move :x => drag_x + distance_x, :y => drag_y + distance_y
        end
      end
    end

    private

    def drag_to
      ole_object.document.parentWindow.scrollTo(*source_x_y_relative)
      drag_x, drag_y = source_x_y
      mouse = page_container.rautomation.mouse
      mouse.move :x => drag_x , :y => drag_y
      mouse.press
      yield mouse
      mouse.release
    end

    def source_x_y
      center_x_y_absolute left_edge_absolute, top_edge_absolute
    end

    def source_x_y_relative
      center_x_y_absolute left_edge, top_edge
    end

    def assert_target(target)
      target.assert_exists
      target.assert_enabled
    end

    def top_edge
      ole_object.getBoundingClientRect(0).top.to_i
    end

    def top_edge_absolute
      top_edge + page_container.document.parentWindow.screenTop.to_i
    end

    def left_edge
      ole_object.getBoundingClientRect(0).left.to_i
    end

    def left_edge_absolute
      left_edge + page_container.document.parentWindow.screenLeft.to_i
    end

    def right_edge
      ole_object.getBoundingClientRect(0).right.to_i
    end

    def bottom_edge
      ole_object.getBoundingClientRect(0).bottom.to_i
    end

    def center_x_y_absolute x, y
      return (right_edge - left_edge) / 2 + x, (bottom_edge - top_edge) / 2 + y
    end

  end
end
