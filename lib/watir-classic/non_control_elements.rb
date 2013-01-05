module Watir
  # Returned by the {Watir::Container#area}.
  class Area < Element
    attr_ole :alt
    attr_ole :type
    attr_ole :href
  end

  # Returned by the {Watir::Container#audio}.
  class Audio < Element
    attr_ole :src
  end

  # Returned by the {Watir::Container#base}.
  class Base < Element
    attr_ole :href
  end

  # Returned by the {Watir::Container#command}.
  class Command < Element
    attr_ole :disabled?
    attr_ole :type
  end

  # Returned by the {Watir::Container#data}.
  class Data < Element
    attr_ole :value
  end

  # Returned by the {Watir::Container#dl}.
  class Dl < Element
    # Returns Hash representation of dl element where each key-value pair consists of dt and dd element text.
    #
    # @return [Hash<String, String>] where key and value is dt and dd text respectively
    def to_hash
      dts.each_with_index.reduce({}) do |memo, item|
        dt, i = *item
        dd = dds[i]
        memo[dt.text] = dd.present? ? dd.text : nil
        memo
      end
    end
  end

  # Returned by the {Watir::Container#embed}.
  class Embed < Element
    attr_ole :src
    attr_ole :type
  end

  # Returned by the {Watir::Container#fieldset}.
  class FieldSet < Element
    attr_ole :name
    attr_ole :disabled?
  end

  # Returned by the {Watir::Container#font}.
  class Font < Element
    attr_ole :color
    attr_ole :face
    attr_ole :size
  end

  # Returned by the {Watir::Container#keygen}.
  class Keygen < Element
    attr_ole :name
    attr_ole :disabled?
  end

  # Returned by the {Watir::Container#label}.
  class Label < Element
    attr_ole :for, :htmlFor
  end

  # Returned by the {Watir::Container#li}.
  class Li < Element
    attr_ole :value
  end

  # Returned by the {Watir::Container#map}.
  class Map < Element
    attr_ole :name
  end

  # Returned by the {Watir::Container#menu}.
  class Menu < Element
    attr_ole :type
  end

  # Returned by the {Watir::Container#meta}.
  class Meta < Element
    attr_ole :http_equiv, :httpEquiv
    attr_ole :content
    attr_ole :name
  end

  # Returned by the {Watir::Container#meter}.
  class Meter < Element
    attr_ole :value
  end

  # Returned by the {Watir::Container#object}.
  class Object < Element
    attr_ole :name
    attr_ole :type
  end

  # Returned by the {Watir::Container#optgroup}.
  class Optgroup < Element
    attr_ole :disabled?
  end

  # Returned by the {Watir::Container#output}.
  class Output < Element
    attr_ole :name
  end

  # Returned by the {Watir::Container#param}.
  class Param < Element
    attr_ole :name
    attr_ole :value
  end

  # Returned by the {Watir::Container#progress}.
  class Progress < Element
    attr_ole :value
  end

  # Returned by the {Watir::Container#script}.
  class Script < Element
    attr_ole :src
    attr_ole :type
  end

  # Returned by the {Watir::Container#source}.
  class Source < Element
    attr_ole :type
  end

  # Returned by the {Watir::Container#style}.
  class Style < Element
    attr_ole :type
  end

  # Returned by the {Watir::Container#track}.
  class Track < Element
    attr_ole :src
  end

  # Returned by the {Watir::Container#video}.
  class Video < Element
    attr_ole :src
  end
end
