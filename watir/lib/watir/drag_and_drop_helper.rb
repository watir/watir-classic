module Watir
  module DragAndDropHelper

    def drag_and_drop_on(target)
      perform_action do
        assert_target target
        drop_x = target.send :left_edge_absolute
        drop_y = target.send :top_edge_absolute
        drag_to drop_x, drop_y
      end
    end

    def drag_and_drop_by(distance_x, distance_y)
      perform_action do
        drag_x, drag_y = source_x_y
        drag_to drag_x + distance_x, drag_y + distance_y
      end
    end

    private

    def drag_to(drop_x, drop_y)
      drag_x, drag_y = source_x_y
      mouse = page_container.rautomation.mouse
      mouse.move :x => drag_x + 10, :y => drag_y + 10
      mouse.press
      mouse.move :x => drop_x + 10, :y => drop_y + 10
      mouse.release
    end

    def source_x_y
      return left_edge_absolute, top_edge_absolute
    end

    def assert_target(target)
      target.assert_exists
      target.assert_enabled
    end

    def top_edge
      ole_object.getBoundingClientRect.top.to_i
    end

    def top_edge_absolute
      top_edge + page_container.document.parentWindow.screenTop.to_i
    end

    def left_edge
      ole_object.getBoundingClientRect.left.to_i
    end

    def left_edge_absolute
      left_edge + page_container.document.parentWindow.screenLeft.to_i
    end

  end
end
