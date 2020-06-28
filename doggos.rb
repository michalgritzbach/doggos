# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'celluloid/current'
require 'net/http'
require 'json'
require 'csv'

# Class responsible for reaching specific breed's `images` endpoint and dumping
# its content into a CSV file.
#
# Includes Celluloid, therefore each `Doggos` instance is a separate Celluloid
# Actor (thread).
class Doggos
  include Celluloid

  def download(breed)
    uri = URI("https://dog.ceo/api/breed/#{breed}/images")
    res = Net::HTTP.get_response(uri)
    parsed = JSON.parse(res.body)

    raise [res.code, breed, parsed['message']].join(' - ') unless res.is_a?(Net::HTTPSuccess)

    build_csv(breed, parsed['message'])
    { "#{breed}.csv" => DateTime.now.to_s }
  end

  private

  def build_csv(breed, image_urls)
    CSV.open("./#{breed}.csv", 'wb') do |csv|
      csv << ['Breed name', 'Image URL']
      image_urls.each do |image_url|
        csv << [parse_breed(image_url), image_url]
      end
    end
  end

  def parse_breed(image_url)
    %r{https\:\/\/images\.dog\.ceo\/breeds\/([\w-]+)\/*}i.match(image_url)[1]
  end
end

# Wrapper for `Doggos` objects instantiation. Creates a Celluloid thread pool
# with default size of 5 (can be set via env variable `POOL_SIZE`).
#
# Doggos pool creates a new thread for every specified breed, each of them
# eventually returning hash of `breed => date of download`, which gets put into
# `updated_at.json` file.
class DoggosRunner
  def self.run(breeds)
    raise ArgumentError, 'Breed names not provided!' unless breeds.count.positive?

    pool = Doggos.pool(size: ENV.fetch('POOL_SIZE', 5).to_i)
    futures = breeds.uniq.map { |breed| pool.future(:download, breed.downcase) }
    downloaded = futures.map(&:value).inject(:merge)
    generate_json(downloaded)
  end

  def self.generate_json(downloaded)
    File.open('./updated_at.json', 'wb') do |f|
      f << JSON.generate(downloaded: downloaded)
    end
  end
end

DoggosRunner.run(ARGV) if $PROGRAM_NAME == __FILE__
