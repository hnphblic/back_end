# frozen_string_literal: true

require 'net/http'

module ModemHelper


  def isActiveSimBank()
    url = URI.parse('http://127.0.0.1:8000')
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    true
  rescue StandardError => e
    render_rescue e
    false
  end

  def is_text_file?(mime)
    %r{^text/}.match? mime
  end

  def is_integer?(mime)
    %r{^\d+$}.match? mime
  end
  
  def is_image_file?(mime)
    %r{^image/}.match? mime
  end

  def is_pdf_file?(mime)
    %r{^application/pdf\b}.match? mime
  end

  def is_office_file?(mime)
    %r{^application/(ms(word|powerpoint)|vnd\.(openxmlformats|ms-(excel|powerpoint)))\b}.match? mime
  end

  # noinspection RubyResolve
  def make_thumbnail_image(path)
    Magick::Image.read(path).first.thumbnail(480, 320).to_blob do |img|
      img.format  = 'jpg'
      img.quality = 80
    end
  end


  # outsource end
end
