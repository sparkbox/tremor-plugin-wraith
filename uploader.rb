require "s3_uploader"
require "fog"

class Uploader
  attr_reader :s3_key, :s3_secret, :s3_region, :remote_folder, :bucket_name

  def initialize(s3_key, s3_secret, s3_region = 'us-west-1', s3_bucket = 'sparkbox-wraith')
    @s3_key       = s3_key
    @s3_secret    = s3_secret
    @s3_region    = s3_region
    @bucket_name  = s3_bucket
  end

  def upload()
    wraith_folder = "./shots/"

    uploader = S3Uploader::Uploader.new({
      :s3_key => s3_key,
      :s3_secret => s3_secret,
      :destination_dir => remote_folder,
      :region => s3_region,
      :threads => 10,
      :public => true
    })

    puts "Uploading to #{wraith_folder + remote_folder}, #{bucket_name}"
    uploader.upload(wraith_folder, bucket_name)

    public_gallery_url(bucket_name, remote_folder)
  end

  private

  def remote_folder
    if @remote_folder.nil?
      timestamp = Time.now.to_i
      @remote_folder = "wraith-#{timestamp}/"
    end

    @remote_folder
  end


  def public_gallery_url(bucket, folder)
    gallery_file = s3_connection
      .directories
      .get(bucket, prefix: folder)
      .files
      .get(gallery_key)

    gallery_file.public_url
  end

  def gallery_key
    File.join(remote_folder, 'gallery.html')
  end

  def s3_connection
    if @connection.nil?
      @connection = Fog::Storage.new({
        :provider                 => 'AWS',
        :aws_access_key_id        => s3_key,
        :aws_secret_access_key    => s3_secret,
        :region                   => s3_region
      })
    end

    @connection
  end

  class S3Results
    attr_reader :gallery_url

    def initialize(gallery_url)
      @gallery_url = gallery_url
    end
  end
end
