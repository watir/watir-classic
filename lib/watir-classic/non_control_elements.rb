module Watir
  class Area < Element
    attr_ole :alt
    attr_ole :type
    attr_ole :href
  end

  class Audio < Element
    attr_ole :src
  end

  class Base < Element
    attr_ole :href
  end

  class Command < Element
    attr_ole :disabled?
    attr_ole :type
  end

  class Data < Element
    attr_ole :value
  end

  class Dl < Element
    def to_hash
      dts.each_with_index.reduce({}) do |memo, item|
        dt, i = *item
        dd = dds[i]
        memo[dt.text] = dd.present? ? dd.text : nil
        memo
      end
    end
  end

  class Embed < Element
    attr_ole :src
    attr_ole :type
  end

  class FieldSet < Element
    attr_ole :name
    attr_ole :disabled?
  end

  class Font < Element
    attr_ole :color
    attr_ole :face
    attr_ole :size
  end

  class Keygen < Element
    attr_ole :name
    attr_ole :disabled?
  end

  class Label < Element
    attr_ole :for, :htmlFor
  end

  class Li < Element
    attr_ole :value
  end

  class Map < Element
    attr_ole :name
  end

  class Menu < Element
    attr_ole :type
  end

  class Meta < Element
    attr_ole :http_equiv, :httpEquiv
    attr_ole :content
    attr_ole :name
  end

  class Meter < Element
    attr_ole :value
  end

  class Object < Element
    attr_ole :name
    attr_ole :type
  end

  class Optgroup < Element
    attr_ole :disabled?
  end

  class Output < Element
    attr_ole :name
  end

  class Param < Element
    attr_ole :name
    attr_ole :value
  end

  class Progress < Element
    attr_ole :value
  end

  class Script < Element
    attr_ole :src
    attr_ole :type
  end

  class Source < Element
    attr_ole :type
  end

  class Style < Element
    attr_ole :type
  end

  class Track < Element
    attr_ole :src
  end

  class Video < Element
    attr_ole :src
  end
end
