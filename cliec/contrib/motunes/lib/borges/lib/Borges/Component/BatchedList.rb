##
# A BatchedList paginates a list of items.
#
# The user must render the currently displayed list and the page bar.
#
# Example:
#
# class MyList < Borges::Component
# 
#   def initialize(items)
#     @batcher = Borges::BatchedList.new(items)
#   end
#
#   def choose(item)
#     call(MyView.new(item)) # MyView is a component that views the item.
#   end
#
#   def renderContentOn(r)
#     r.list_do(@batcher.batch) do |item|
#       proc do
#         r.anchor(item.title do choose(item) end
#       end
#     end
#
#     r.render(@batcher)
#   end
# end

class Borges::BatchedList < Borges::Component

  DEFAULT_SIZE = 10

  attr_accessor :batch_size, :current_page, :items

  ##
  # Create a new BatchedList from +items+, with +size+ items per page.

  def initialize(items = [], size = DEFAULT_SIZE)
    @items = items
    @batch_size = size
    @current_page = 0
  end

  ##
  # The batch of items on the current page

  def batch
    return @items[start_index..end_index]
  end

  ##
  # The index of the first item from the batch on the current page.

  def start_index
    return @current_page * @batch_size
  end

  ##
  # The index of the last item from the batch on the current page.

  def end_index
    return [(@current_page + 1) * @batch_size - 1, @items.size].min
  end

  ##
  # The maximum number of pages (indexed from 1)

  def max_pages
    return @items.size / @batch_size
  end

  ##
  # Is the first page in the batch being displayed?

  def on_first_page?
    return @current_page == 0
  end

  ##
  # Is the last page in the batch being displayed?

  def on_last_page?
    return @current_page == (max_pages - 1)
  end

  ##
  # Move to the next page in the batch.

  def next_page
    @current_page += 1 unless on_last_page?
  end

  ##
  # Move to the previous page in the batch.

  def previous_page
    @current_page -= 1 unless on_last_page?
  end

  ##
  # Render the page selector for the batch.
  #
  # You must supply your own code to render the contents of the batch.  See
  # StoreItemList for an example.

  def render_content_on(r)
    return if max_pages == 0
    
    r.div_named('batch') do
      unless on_first_page? then
        r.set_attribute('id', 'pg_prev')
        r.anchor('<<') do previous_page end
      else
        r.text('<<')
      end

      r.space

      0.upto(max_pages - 1) do |i|
        r.space

        unless @current_page == i then
          r.set_attribute('id', 'pg_' + (i + 1).to_s)
          r.anchor(i + 1) do @current_page = i end

        else
          r.bold(i + 1)

        end

      end

      r.space
      r.space

      unless on_last_page? then
        r.set_attribute('id', 'pg_next')
        r.anchor('>>') do next_page end

      else
        r.text('>>')

      end
    end
  end

end

