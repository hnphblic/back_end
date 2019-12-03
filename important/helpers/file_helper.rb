# frozen_string_literal: true

require 'securerandom'
require 'zip'
require 'timeout'
require 'base64'
#require 'rmagick'
#require_relative '../../lib/magic/libmagic'
#require_relative '../../lib/archive/libarchive'
module FileHelper
  # Usage:
  # source_path = "Users/me/Desktop/stuff_to_zip"
  # list_file = [
  #   {
  #     file_name: 'image',
  #     filename_system: 'xyz.jpg',
  #     extension: 'jpg',
  #   },
  #   {
  #     file_name: 'image',
  #     filename_system:  'abc.txt',
  #     extension: 'txt',
  #   }
  # ]
  # dest_path = "/Users/me/Desktop/archive.zip"
  def zip_file(source_path, dest_path, list_file)
    # Zip.force_entry_names_encoding = 'UTF-8'
    Zip.unicode_names = true
    list_file_name = []
    Zip::File.open(dest_path, Zip::File::CREATE) do |zipfile|
      list_file.each do |file_info|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        origin_name = "#{file_info[:file_name]}.#{file_info[:extension]}"
        name_in_archive = origin_name
        if list_file_name.include? name_in_archive
          num_index = list_file_name.select { |name| name == name_in_archive }.count
          name_in_archive = "#{file_info[:file_name]}(#{num_index}).#{file_info[:extension]}"
        end
        list_file_name << origin_name
        source_file = "#{source_path}/#{file_info[:filename_system]}"
        zipfile.add(name_in_archive, source_file)
      end
    end
  end

  # check dir is existed?
  # if dir is not existed, create new with path
  # Input String: path
  def dir_exists_and_create(path)
    FileUtils.mkdir_p(path) unless File.directory?(path)
  end

  # generate folder with unique name
  def generate_guid_folder(path)
    # make sure name is unique
    Timeout.timeout(10) do
      loop do
        name = SecureRandom.uuid
        path += "/#{name}"
        break unless File.directory?(path)
      end
    end
    new_folder = dir_exists_and_create(path)
    new_folder.first
  rescue StandardError => e
    render_rescue e
    result = helper_render_message(
      400,
      I18n.t('file_controller.errors.cannot_generate_folder'),
    )
    halt result[:status], result[:response].to_json
  end

  # outsource begin
  def list_archive_contents(path)
    list = []

    # Use native libarchive library
    Archive::Reader.open_file(path) do |f|
      f.entries do |i|
        list << { name: i.name, type: i.ftype, size: i.size, time: i.mtime }
      end
    end

    list
  end

  # @param [String] path Full-path of the file.
  # @return [String] E.g. 'text/plain; charset=utf-8'
  def guess_file_mime(path)
    # Detect MIME type of the file using magic(4) library
    mgc = ENV['MAGIC_LIB']&.sub(%r{[^/\\]+$}, 'magic.mgc')

    result = Magic.guess_file_mime(path, database: mgc)
    fail result unless %r{^\w+/}.match?(result)
    result

  # Returns NULL if error
  rescue StandardError => e
    render_rescue e
    nil
  end

  def is_text_file?(mime)
    %r{^text/}.match? mime
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

  def preview_file(path)
    mime = guess_file_mime path
    log_info_message('Guess file mime: ' + mime.inspect)

    # Support Unicode text file
    return File.read(path, mode: 'rb', encoding: (m = /\bcharset=([^ ;]+)/.match(mime)) && m[1]) if is_text_file?(mime)

    # Support images
    return { image: Base64.strict_encode64(make_thumbnail_image(path)) } if is_image_file?(mime)

    # Otherwise, is it a compressed file?
    list_archive_contents path
  end
  # outsource end
end
