require 'RMagick'
require "color_util/version"

# -*- encoding : utf-8 -*-
class ColorUtil

  HEX_REGEX = /^#?[A-Fa-f0-9]{6}$/
  REVERSE_THRESHOLD = 185

  class << self

    def get_color_palette(file, num_colors = 2)
      num_colors = num_colors.to_i

      palette = []
      return [] unless File.exists?(file)

      image = Magick::Image.read(file).first
      image.quantize(num_colors).color_histogram.each do |c, n|
        palette << c.to_color(Magick::AllCompliance, false, 8, true)
      end

      palette
    end

    # find the luminance level (0..255) of a hex color
    def luminance(color)
      rgb = hex_to_rgb(color)
      hsl = rgb_to_hsl(rgb)
      return hsl[2]
    end

    # find the saturation level (0..1) of a hex color
    def saturation(color)
      rgb = hex_to_rgb(color)
      hsl = rgb_to_hsl(rgb)
      return hsl[1]
    end

    def hex_to_hsl(color)
      rgb_to_hsl(hex_to_rgb(color))
    end

    def hsl_to_hex(color)
      rgb_to_hex(hsl_to_rgb(color))
    end
=begin
  Finds the reversed black or white color of a given hex rgb string (Ex: '#ccffcc'), based on luminance
=end
    def bw_reversed(color)
      color = chop_hash(color)
      luminance(color) < REVERSE_THRESHOLD ? "#ffffff" : '#000000'
    end

    def darken(color, percent)
      brighten(color, -percent)
    end

    def brighten(color, percent)
      rgb = hex_to_rgb(color)
      hsl = rgb_to_hsl(*rgb)
      hsl[2] += hsl[2] * percent.to_f
      hsl[1] += hsl[1] * percent.to_f
     # hsl[1] += hsl[1] * percent.to_f
      constrain(hsl)
      rgb = hsl_to_rgb(*hsl)
      rgb_to_hex(*rgb)
    end

    def constrain(hsl)
      hsl.each_index {|idx|
        hsl[idx] = [hsl[idx], 0].max
        hsl[idx] = [hsl[idx], 1].min
      }
    end

=begin
  Finds the opposite color of a given hex rgb string (Ex: '#ccffcc')
=end
    def opposite(color)
      hsl = hex_to_hsl(color)
      hsl[0] += 0.5
      hsl[0] -= 1 if hsl[0] > 1
      self.hsl_to_hex(hsl)
    end

    def rgb_to_hex(*opts)
      opts = opts[0] if opts.size == 1

      r = opts[0].to_s(16)
      g = opts[1].to_s(16)
      b = opts[2].to_s(16)

      r = "0#{r}" if r.length == 1
      g = "0#{g}" if g.length == 1
      b = "0#{b}" if b.length == 1
      "##{r}#{g}#{b}"
    end

    def hex_to_rgb(hex)
      hex = chop_hash(hex)
      r = hex[0..1].to_i(16)
      g = hex[2..3].to_i(16)
      b = hex[4..5].to_i(16)
      [r,g,b]
    end

    def chop_hash(c)
      c = c.slice(1,6) if [35, '#'].include?(c[0]) # 35 is dec ascii for '#'
      c
    end
    private :chop_hash

    #http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript
    def rgb_to_hsl(*opts)
      opts = opts[0] if opts.size == 1

      r = opts[0] / 255.0
      g = opts[1] / 255.0
      b = opts[2] / 255.0

      max = [r,g,b].max
      min = [r,g,b].min

      baseV = (max + min) / 2

      h = s = l = baseV

      if (max == min)
        h = s = 0 # achromatic
      else
        diff = max - min
        s = l > 0.5 ? diff / (2 - max - min) : diff / (max + min);

        case max
          when r
            h = ( g - b) / diff + (g < b ? 6 : 0)
          when g
            h = ( b - r) / diff + 2
          when b
            h = (r -g ) / diff + 4
        end

        h /= 6
      end
    [h, s, l]
    end

    def hsl_to_rgb(*opts)

      opts = opts[0] if opts.size == 1

      h = opts[0]
      s = opts[1]
      l = opts[2]

      r = g = b = 0;

      if(s == 0)
        r = g = b = l # achromatic
      else
        q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        p = 2 * l - q;
        r = hue_to_rgb(p, q, h + 1/3.0);
        g = hue_to_rgb(p, q, h);
        b = hue_to_rgb(p, q, h - 1/3.0);
      end
      [(r * 255).to_i, (g * 255).to_i, (b * 255).to_i]
    end

    def hue_to_rgb(*opts)
      opts = opts[0] if opts.size == 1
      p = opts[0]
      q = opts[1]
      t = opts[2]

      t += 1 if t < 0
      t -= 1 if t > 1
      return p + (q - p) * 6 * t if(t < 1/6.0)
      return q if(t < 1/2.0)
      return p + (q - p) * (2/3.0 - t) * 6 if(t < 2/3.0)
      return p
    end
  end
end

